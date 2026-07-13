// lib/screens/admin/order_detail_screen.dart
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../constants/order.constant.dart';
import '../../models/order.model.dart';
import '../../services/order.service.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/order/order_action_card.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;
  final OrderService orderService;

  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.orderService,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Order _order;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
  }

  Color _statusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.paid:
        return Colors.blue;
      case OrderStatus.delivered:
        return AppTheme.successGreen;
      case OrderStatus.completed:
        return const Color(0xFF1B5E20);
      case OrderStatus.cancelled:
        return AppTheme.errorRed;
      default:
        return AppTheme.textGray;
    }
  }

  String _formatCurrency(int amount) {
    return '₫${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (match) => '${match[1]},')}';
  }

  Future<void> _updateStatus(String action) async {
    final newStatus = action == 'deliver'
        ? OrderStatus.delivered
        : action == 'complete'
        ? OrderStatus.completed
        : OrderStatus.cancelled;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Change'),
        content: Text(
          'Change order #${_order.orderId} status to ${newStatus.name.toUpperCase()}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        switch (action) {
          case 'deliver':
            await widget.orderService.updateDeliveryStatus(_order.orderId);
            break;
          case 'complete':
            await widget.orderService.updateCompletedStatus(_order.orderId);
            break;
          case 'cancel':
            await widget.orderService.updateCancelStatus(_order.orderId);
            break;
        }
        setState(() {
          _order = Order(
            orderId: _order.orderId,
            totalPrice: _order.totalPrice,
            shippingAddress: _order.shippingAddress,
            status: newStatus,
            createdAt: _order.createdAt,
            updatedAt: _order.updatedAt,
            fullname: _order.fullname,
            email: _order.email,
            orderDetailIds: _order.orderDetailIds,
            orderItems: _order.orderItems,
            customerId: _order.customerId,
            customer: _order.customer,
            orderDetails: _order.orderDetails,
            payments: _order.payments,
          );
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status changed to ${newStatus.name}'),
              backgroundColor: AppTheme.successGreen,
            ),
          );
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update status: $e'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _order.status;
    final customerName = _order.fullname ?? 'Unknown';
    final email = _order.email ?? 'N/A';
    final address = _order.shippingAddress ?? 'N/A';
    final items = _order.orderItems ?? [];
    final itemCount = items.length;

    return Scaffold(
      appBar: AppBar(title: Text('Order #${_order.orderId}')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Order header
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: AppTheme.primaryOrange.withValues(
                              alpha: 0.15,
                            ),
                            child: Text(
                              '#${_order.orderId}',
                              style: const TextStyle(
                                fontSize: 24,
                                color: AppTheme.primaryOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _formatCurrency(_order.totalPrice),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryOrange,
                            ),
                          ),
                          const SizedBox(height: 12),
                          if (status != null)
                            StatusBadge(
                              text: status.name.toUpperCase(),
                              color: _statusColor(status),
                              background: _statusColor(
                                status,
                              ).withValues(alpha: 0.1),
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Customer Information
                  _buildSection('Customer Information', [
                    _buildInfoRow('Name', customerName),
                    _buildInfoRow('Email', email),
                    _buildInfoRow('Address', address),
                  ]),

                  const SizedBox(height: 16),

                  // Order Information
                  _buildSection('Order Information', [
                    _buildInfoRow('Order ID', _order.orderId.toString()),
                    _buildInfoRow('Created At', _order.createdAt),
                    if (_order.updatedAt != null)
                      _buildInfoRow('Updated At', _order.updatedAt!),
                    _buildInfoRow('Items', '$itemCount item(s)'),
                  ]),

                  const SizedBox(height: 16),

                  OrderActionCard(
                    status: _order.status,
                    onDeliver: () => _updateStatus('deliver'),
                    onComplete: () => _updateStatus('complete'),
                    onCancel: () => _updateStatus('cancel'),
                  ),

                  const SizedBox(height: 16),

                  // Product List
                  if (items.isNotEmpty)
                    _buildSection(
                      'Products',
                      items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              if (item.images != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item.images!,
                                    width: 48,
                                    height: 48,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) =>
                                        const Icon(Icons.image, size: 48),
                                  ),
                                )
                              else
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryOrange.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.image,
                                    color: AppTheme.primaryOrange,
                                  ),
                                ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.productName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Qty: ${item.stockQuantity} × ${_formatCurrency(item.price)}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                _formatCurrency(
                                  item.price * item.stockQuantity,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryOrange,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryOrange,
              ),
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppTheme.textGray, fontSize: 14),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
