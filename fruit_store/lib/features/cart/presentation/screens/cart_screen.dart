import 'package:flutter/material.dart';

import 'package:fruit_store/core/constants/app_colors.dart';
import 'package:fruit_store/core/utils/currency_formatter.dart';
import 'package:fruit_store/features/cart/data/models/cart_item_model.dart';
import 'package:fruit_store/features/cart/data/services/cart_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CartService _cartService = CartService();

  late Future<List<CartItemModel>> _cartFuture;

  @override
  void initState() {
    super.initState();
    _cartFuture = _cartService.getCartItems();
  }

  Future<void> _reloadCart() async {
    setState(() {
      _cartFuture = _cartService.getCartItems();
    });
  }

  num _calculateTotal(List<CartItemModel> items) {
    return items.fold<num>(
      0,
          (total, item) => total + item.totalPrice,
    );
  }

  Future<void> _increaseQuantity(CartItemModel item) async {
    try {
      await _cartService.updateCartItem(
        productId: item.productId,
        quantity: item.quantity + 1,
      );

      await _reloadCart();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _decreaseQuantity(CartItemModel item) async {
    try {
      if (item.quantity <= 1) {
        await _removeItem(item);
        return;
      }

      await _cartService.updateCartItem(
        productId: item.productId,
        quantity: item.quantity - 1,
      );

      await _reloadCart();
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _removeItem(CartItemModel item) async {
    try {
      await _cartService.removeCartItem(productId: item.productId);
      await _reloadCart();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${item.productName} khỏi giỏ hàng'),
          backgroundColor: AppColors.primaryOrange,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _clearCart() async {
    try {
      await _cartService.clearCart();
      await _reloadCart();
    } catch (e) {
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _checkout() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Luồng checkout sẽ được phát triển ở bước tiếp theo.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: SafeArea(
        child: FutureBuilder<List<CartItemModel>>(
          future: _cartFuture,
          builder: (context, snapshot) {
            final isLoading = snapshot.connectionState == ConnectionState.waiting;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryOrange,
                ),
              );
            }

            if (snapshot.hasError) {
              return _buildError(snapshot.error.toString());
            }

            final items = snapshot.data ?? [];

            return Column(
              children: [
                _buildHeader(items),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmptyCart()
                      : RefreshIndicator(
                    color: AppColors.primaryOrange,
                    onRefresh: _reloadCart,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      itemCount: items.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _buildCartItem(items[index]);
                      },
                    ),
                  ),
                ),
                if (items.isNotEmpty) _buildBottomBar(items),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(List<CartItemModel> items) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
            child: Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.primaryOrange,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'My Basket',
              style: TextStyle(
                color: Color(0xFF27214D),
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          if (items.isNotEmpty)
            TextButton(
              onPressed: _clearCart,
              child: const Text(
                'Clear',
                style: TextStyle(
                  color: AppColors.primaryOrange,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItemModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 86,
            height: 86,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: const Color(0xFFFFFAF3),
                child: item.image.isEmpty
                    ? const Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.primaryOrange,
                )
                    : Image.network(
                  item.image,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) {
                    return const Icon(
                      Icons.image_not_supported_outlined,
                      color: AppColors.primaryOrange,
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SizedBox(
              height: 92,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF27214D),
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${CurrencyFormatter.formatVnd(item.price)} / ${item.unit}',
                    style: const TextStyle(
                      color: AppColors.primaryOrange,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onTap: () => _decreaseQuantity(item),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          item.quantity.toString(),
                          style: const TextStyle(
                            color: Color(0xFF27214D),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      _buildQuantityButton(
                        icon: Icons.add,
                        onTap: () => _increaseQuantity(item),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(
            height: 92,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                GestureDetector(
                  onTap: () => _removeItem(item),
                  child: const Icon(
                    Icons.delete_outline,
                    color: Colors.redAccent,
                    size: 23,
                  ),
                ),
                const Spacer(),
                Text(
                  CurrencyFormatter.formatVnd(item.totalPrice),
                  style: const TextStyle(
                    color: Color(0xFF27214D),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: Color(0xFFFFF3E5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: AppColors.primaryOrange,
          size: 18,
        ),
      ),
    );
  }

  Widget _buildBottomBar(List<CartItemModel> items) {
    final total = _calculateTotal(items);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: AppColors.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.formatVnd(total),
                    style: const TextStyle(
                      color: Color(0xFF27214D),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                onPressed: _checkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryOrange,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Checkout',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: Color(0xFFFFF3E5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                color: AppColors.primaryOrange,
                size: 42,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Giỏ hàng đang trống',
              style: TextStyle(
                color: Color(0xFF27214D),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Hãy thêm sản phẩm tươi sạch vào giỏ hàng của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Tiếp tục mua hàng'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.redAccent,
              size: 48,
            ),
            const SizedBox(height: 12),
            const Text(
              'Không thể tải giỏ hàng',
              style: TextStyle(
                color: Color(0xFF27214D),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message.replaceFirst('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: _reloadCart,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryOrange,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}