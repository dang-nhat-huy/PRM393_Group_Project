import 'package:flutter/material.dart';

import '../../models/order.dart';
import 'status_chip.dart';
import 'table_cell.dart';

class OrderRow extends StatelessWidget {
  final Order order;
  final VoidCallback? onMorePressed;

  const OrderRow({
    super.key,
    required this.order,
    this.onMorePressed,
  });

  String get formattedPrice {
    final price = order.totalPrice ?? 0;

    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade300),
          right: BorderSide(color: Colors.grey.shade300),
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
        color: Colors.white,
      ),
      child: Row(
        children: [
          TableCellWidget(
            flex: 1,
            center: true,
            child: Text(
              "#${order.orderId}",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          TableCellWidget(
            flex: 2,
            child: Text(
              order.fullname,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          TableCellWidget(
            flex: 2,
            child: Text(
              "$formattedPrice đ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          TableCellWidget(
            flex: 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: StatusChip(
                status: order.status,
              ),
            ),
          ),

          TableCellWidget(
            flex: 1,
            center: true,
            showRightBorder: false,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "more") {
                  onMorePressed?.call();
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(
                  value: "more",
                  child: Text("View Detail"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}