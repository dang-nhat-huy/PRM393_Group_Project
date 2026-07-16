// lib/screens/customer/orders_tab.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_theme.dart';
import '../../constants/order.constant.dart';
import '../../models/order.model.dart';
import '../../services/order.service.dart';

class OrdersTab extends StatefulWidget {
  final OrderService orderService;

  const OrdersTab({super.key, required this.orderService});

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await widget.orderService.getByCurrentAccount(pageSize: 50);
      setState(() {
        _orders = response.items;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load order history.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(OrderStatus? status) {
    if (status == null) return AppTheme.textGray;
    switch (status) {
      case OrderStatus.unpaid:
        return Colors.redAccent;
      case OrderStatus.paid:
        return Colors.purple;
      case OrderStatus.undischarged:
        return Colors.blue;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.delivered:
        return Colors.teal;
      case OrderStatus.completed:
        return AppTheme.successGreen;
      case OrderStatus.cancelled:
        return AppTheme.errorRed;
    }
  }

  void _showOrderDetail(Order order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return FutureBuilder<Order>(
          future: widget.orderService.getById(order.orderId),
          builder: (context, snapshot) {
            Widget body;
            if (snapshot.connectionState == ConnectionState.waiting) {
              body = const SizedBox(
                height: 300,
                child: Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange)),
              );
            } else if (snapshot.hasError || !snapshot.hasData) {
              body = SizedBox(
                height: 300,
                child: Center(
                  child: Text(
                    'Failed to load order details.',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              );
            } else {
              final fullOrder = snapshot.data!;
              final items = fullOrder.orderDetails ?? [];
              bool isPaying = false;
              body = StatefulBuilder(
                builder: (context, setSheetState) {
                  return Container(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Order #${fullOrder.orderId}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(fullOrder.status).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                fullOrder.status?.name.toUpperCase() ?? 'PENDING',
                                style: TextStyle(
                                  color: _getStatusColor(fullOrder.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Placed on: ${fullOrder.createdAt.split('T')[0]}',
                          style: const TextStyle(color: AppTheme.textGray, fontSize: 13),
                        ),
                        const Divider(height: 32),
                        
                        // Shipping details
                        const Text('Shipping Information', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 6),
                        Text(
                          fullOrder.shippingAddress ?? 'No shipping address provided.',
                          style: const TextStyle(color: AppTheme.textDark, fontSize: 14),
                        ),
                        const Divider(height: 32),

                        // Items list
                        const Text('Ordered Items', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 10),
                        Expanded(
                          child: ListView.builder(
                            itemCount: items.length,
                            itemBuilder: (context, idx) {
                              final detail = items[idx];
                              final prodName = detail.product?.productName ?? 'Product #${detail.productId}';
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: Colors.orange.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(Icons.shopping_basket_outlined, color: AppTheme.primaryOrange, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(prodName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                                          Text('Quantity: ${detail.quantity}', style: const TextStyle(color: AppTheme.textGray, fontSize: 12)),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      '${(detail.unitPrice * detail.quantity).toStringAsFixed(0)}đ',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text(
                              '${fullOrder.totalPrice.toStringAsFixed(0)}đ',
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryOrange, fontSize: 18),
                            ),
                          ],
                        ),
                        if (fullOrder.status == OrderStatus.unpaid) ...[
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: isPaying
                                  ? null
                                  : () async {
                                      setSheetState(() => isPaying = true);
                                      try {
                                        final paymentUrl = await widget.orderService.createPaymentUrl(
                                          orderId: fullOrder.orderId,
                                          amount: fullOrder.totalPrice.toDouble(),
                                        );

                                        if (paymentUrl.isNotEmpty) {
                                          final uri = Uri.parse(paymentUrl);
                                          if (await canLaunchUrl(uri)) {
                                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                                            if (context.mounted) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Opening VNPay payment portal...'),
                                                  backgroundColor: AppTheme.successGreen,
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                              Navigator.pop(context);
                                              _loadOrders();
                                            }
                                          } else {
                                            throw Exception('Could not launch payment URL.');
                                          }
                                        } else {
                                          throw Exception('Payment URL is empty.');
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(
                                              content: Text('Failed to initiate payment: ${e.toString()}'),
                                              backgroundColor: AppTheme.errorRed,
                                              behavior: SnackBarBehavior.floating,
                                            ),
                                          );
                                        }
                                      } finally {
                                        setSheetState(() => isPaying = false);
                                      }
                                    },
                              icon: isPaying
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.payment, color: Colors.white),
                              label: Text(
                                isPaying ? 'Processing...' : 'Pay with VNPay',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryOrange,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            }

            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: body,
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadOrders,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryOrange))
          : _error != null
              ? Center(
                  child: TextButton.icon(
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                    label: Text(_error!),
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text(
                            'No orders yet',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textGray),
                          ),
                          const SizedBox(height: 8),
                          const Text('Your order history will be shown here.', style: TextStyle(color: AppTheme.textGray)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _orders.length,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (context, index) {
                        final order = _orders[index];
                        final dateStr = order.createdAt.split('T')[0];
                        return Card(
                          child: InkWell(
                            onTap: () => _showOrderDetail(order),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Order #${order.orderId}',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _getStatusColor(order.status).withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          order.status?.name.toUpperCase() ?? 'PENDING',
                                          style: TextStyle(
                                            color: _getStatusColor(order.status),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('Date: $dateStr', style: const TextStyle(color: AppTheme.textGray, fontSize: 13)),
                                      Text(
                                        'Total: ${order.totalPrice.toStringAsFixed(0)}đ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryOrange,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (order.shippingAddress != null) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      'Ship to: ${order.shippingAddress}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: AppTheme.textGray, fontSize: 12),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
