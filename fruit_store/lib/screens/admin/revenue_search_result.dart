// lib/screens/admin/revenue_search_result.dart
import 'package:flutter/material.dart';
import '../../constants/app_theme.dart';
import '../../constants/order.constant.dart';
import '../../models/order.model.dart';
import '../../services/order.service.dart';
import '../../widgets/status_badge.dart';
import 'order_detail_screen.dart';

class RevenueSearchResultScreen extends StatefulWidget {
  final OrderService orderService;
  final String query;

  const RevenueSearchResultScreen({
    super.key,
    required this.orderService,
    required this.query,
  });

  @override
  State<RevenueSearchResultScreen> createState() =>
      _RevenueSearchResultScreenState();
}

class _RevenueSearchResultScreenState extends State<RevenueSearchResultScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _search();
  }

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      // Try email search first, fall back to name search
      // Since both APIs exist, try email (more specific)
      List<Order> orders = [];
      try {
        final response =
            await widget.orderService.getByEmail(widget.query);
        orders = response.items;
      } catch (_) {
        // Fall back to customer name search
        try {
          final response =
              await widget.orderService.getByCustomerName(widget.query);
          orders = response.items;
        } catch (_) {
          orders = [];
        }
      }
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _orders = [];
        _isLoading = false;
      });
    }
  }

  Color _statusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.active:
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
    return '₫${amount.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        )}';
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.primaryOrange;

    return Scaffold(
      appBar: AppBar(
        title: Text('Results: "${widget.query}"'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _orders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off,
                          size: 64,
                          color: AppTheme.textGray.withValues(alpha: 0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'No orders found',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppTheme.textGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No results for "${widget.query}"',
                        style: const TextStyle(color: AppTheme.textGray),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _search,
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 16),
                    itemCount: _orders.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final order = _orders[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor:
                                color.withValues(alpha: 0.15),
                            child: Text(
                              '#${order.orderId}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  order.fullname ?? 'Unknown',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              Text(
                                _formatCurrency(order.totalPrice),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: color,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                order.createdAt,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray),
                              ),
                              const SizedBox(height: 6),
                              if (order.status != null)
                                StatusBadge(
                                  text: order.status!.name.toUpperCase(),
                                  color: _statusColor(order.status),
                                  background: _statusColor(order.status)
                                      .withValues(alpha: 0.1),
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right,
                              color: AppTheme.textGray),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderDetailScreen(
                                  order: order,
                                  orderService: widget.orderService,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}