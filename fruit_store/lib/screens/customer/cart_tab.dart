// lib/screens/customer/cart_tab.dart
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../models/cart.model.dart';
import '../../models/store_product.model.dart';
import '../../services/cart.service.dart';
import '../../services/order.service.dart';
import '../../services/product.service.dart';

class CartTab extends StatefulWidget {
  final CartService cartService;
  final ProductService productService;
  final OrderService orderService;

  const CartTab({
    super.key,
    required this.cartService,
    required this.productService,
    required this.orderService,
  });

  @override
  State<CartTab> createState() => _CartTabState();
}

class _CartTabState extends State<CartTab> {
  CartModel? _cart;
  bool _isLoading = false;
  String? _error;
  final _addressController = TextEditingController();
  bool _isCheckingOut = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadCart() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final cart = await widget.cartService.getCart();
      
      // Load details for each product in the cart
      final List<Future<void>> futures = [];
      for (final item in cart.items) {
        futures.add(
          widget.productService.getProductById(item.productId).then((prod) {
            item.product = prod;
          }).catchError((_) {
            // Fallback product info
            item.product = StoreProduct(
              productId: item.productId,
              productName: 'Product #${item.productId}',
              price: item.priceQuantity / item.quantity,
              stockQuantity: 999,
              status: 'ACTIVE',
              createdAt: '',
            );
          })
        );
      }
      
      await Future.wait(futures);
      
      if (mounted) {
        setState(() {
          _cart = cart;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to load cart items.';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _updateQuantity(CartItemModel item, int newQty) async {
    if (newQty <= 0) {
      _removeItem(item);
      return;
    }
    
    if (item.product != null && newQty > item.product!.stockQuantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot add more. Only ${item.product!.stockQuantity} items in stock.'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await widget.cartService.updateCartItem(item.productId, newQty);
      _loadCart();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update quantity.'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _removeItem(CartItemModel item) async {
    try {
      await widget.cartService.removeCartItem(item.productId);
      _loadCart();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Item removed from cart.'),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to remove item.'),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  double _calculateTotal() {
    if (_cart == null) return 0.0;
    return _cart!.items.fold(0.0, (sum, item) => sum + item.priceQuantity);
  }

  void _showCheckoutDialog() {
    _addressController.clear();
    showDialog(
      context: context,
      barrierDismissible: !_isCheckingOut,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Checkout Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please enter shipping address:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      hintText: 'e.g. 123 Main Street, District 1, HCMC',
                      labelText: 'Shipping Address',
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isCheckingOut ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: _isCheckingOut
                      ? null
                      : () async {
                          final address = _addressController.text.trim();
                          if (address.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter an address.'),
                                backgroundColor: AppTheme.errorRed,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          setDialogState(() => _isCheckingOut = true);
                          try {
                            // Order items mapping for backend SelectProductDTO: { productId, stockQuantity }
                            final orderItems = _cart!.items.map((item) {
                              return {
                                'productId': item.productId,
                                'stockQuantity': item.quantity,
                              };
                            }).toList();

                            await widget.orderService.createOrder(
                              orderItems: orderItems,
                              shippingAddress: address,
                            );

                            // Clear cart on success
                            await widget.cartService.clearCart();

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Order placed successfully!'),
                                  backgroundColor: AppTheme.successGreen,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              _loadCart();
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to place order.'),
                                  backgroundColor: AppTheme.errorRed,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          } finally {
                            setDialogState(() => _isCheckingOut = false);
                          }
                        },
                  child: _isCheckingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.white),
                        )
                      : const Text('Place Order'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _calculateTotal();
    final items = _cart?.items ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Shopping Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCart,
          ),
          if (items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Cart',
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Are you sure you want to remove all items from your cart?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
                    ],
                  ),
                );
                if (confirm == true) {
                  await widget.cartService.clearCart();
                  _loadCart();
                }
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _error != null
              ? Center(
                  child: TextButton.icon(
                    onPressed: _loadCart,
                    icon: const Icon(Icons.refresh),
                    label: Text(_error!),
                  ),
                )
              : items.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_basket_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'Your cart is empty',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                          ),
                          const SizedBox(height: 8),
                          const Text('Add items from the store to checkout.', style: TextStyle(color: AppTheme.textGray)),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemBuilder: (context, index) {
                              final item = items[index];
                              final product = item.product;
                              
                              return Dismissible(
                                key: Key('cart-item-${item.productId}'),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  color: AppTheme.errorRed,
                                  child: const Icon(Icons.delete, color: AppTheme.white),
                                ),
                                onDismissed: (_) => _removeItem(item),
                                child: Card(
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Row(
                                      children: [
                                        // Product Image
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: product?.images != null && product!.images!.isNotEmpty
                                              ? Image.network(
                                                  product.images!,
                                                  width: 70,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) => _buildPlaceholder(),
                                                )
                                              : _buildPlaceholder(),
                                        ),
                                        const SizedBox(width: 14),
                                        
                                        // Details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                product?.productName ?? 'Product #${item.productId}',
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${(product?.price ?? 0).toStringAsFixed(0)}đ${product?.unit != null ? " / ${product!.unit}" : ""}',
                                                style: const TextStyle(color: AppTheme.textGray, fontSize: 13),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                'Total: ${item.priceQuantity.toStringAsFixed(0)}đ',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: AppTheme.primaryOrange,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        // Quantity buttons
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppTheme.textGray),
                                                  onPressed: () => _updateQuantity(item, item.quantity - 1),
                                                ),
                                                Text(
                                                  '${item.quantity}',
                                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.add_circle_outline, size: 22, color: AppTheme.primaryOrange),
                                                  onPressed: () => _updateQuantity(item, item.quantity + 1),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Summary Card
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.white,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                offset: const Offset(0, -4),
                                blurRadius: 10,
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Subtotal', style: TextStyle(color: AppTheme.textGray, fontSize: 15)),
                                  Text('${total.toStringAsFixed(0)}đ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Shipping Fee', style: TextStyle(color: AppTheme.textGray, fontSize: 15)),
                                  Text('Free', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.successGreen, fontSize: 16)),
                                ],
                              ),
                              const Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Payment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(
                                    '${total.toStringAsFixed(0)}đ',
                                    style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange, fontSize: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _showCheckoutDialog,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryOrange,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Proceed to Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.orange.shade50,
      child: const Icon(Icons.image_outlined, color: AppTheme.primaryOrange, size: 24),
    );
  }
}
