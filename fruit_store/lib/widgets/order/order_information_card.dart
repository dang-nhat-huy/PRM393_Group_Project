import 'package:flutter/material.dart';

import '../../models/order.model.dart';
import '../../constants/order.constant.dart';

class OrderInformationCard extends StatelessWidget {
  final Order order;

  const OrderInformationCard({
    super.key,
    required this.order,
  });

  Color _statusColor(OrderStatus? status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;

      case OrderStatus.paid:
        return Colors.blue;

      case OrderStatus.active:
        return Colors.indigo;

      case OrderStatus.delivered:
        return Colors.teal;

      case OrderStatus.completed:
        return Colors.green;

      case OrderStatus.cancelled:
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  String _statusText(OrderStatus? status) {
    if (status == null) return "-";

    return status.name.toUpperCase();
  }

  Widget _buildInfoRow(
    String title,
    Widget value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final itemCount = order.orderDetails?.length ?? 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 18),

            _buildInfoRow(
              "Order ID",
              Text(
                "#${order.orderId}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _buildInfoRow(
              "Status",
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor(order.status).withOpacity(.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _statusColor(order.status),
                  ),
                ),
                child: Text(
                  _statusText(order.status),
                  style: TextStyle(
                    color: _statusColor(order.status),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            _buildInfoRow(
              "Created At",
              Text(
                order.createdAt,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _buildInfoRow(
              "Total",
              Text(
                "₫${order.totalPrice}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
            ),

            _buildInfoRow(
              "Items",
              Text(
                "$itemCount item(s)",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            _buildInfoRow(
              "Shipping",
              Text(
                order.shippingAddress ?? "-",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}