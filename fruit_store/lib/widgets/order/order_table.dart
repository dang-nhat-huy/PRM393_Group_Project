import 'package:flutter/material.dart';

import '../../models/order.dart';
import 'order_row.dart';
import 'order_table_header.dart';

class OrderTable extends StatelessWidget {
  final List<Order> orders;
  final bool isLoading;
  final String? error;
  final Future<void> Function()? onRefresh;
  final void Function(Order order)? onViewDetail;

  const OrderTable({
    super.key,
    required this.orders,
    this.isLoading = false,
    this.error,
    this.onRefresh,
    this.onViewDetail,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null && error!.isNotEmpty) {
      return Center(
        child: Text(
          error!,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    if (orders.isEmpty) {
      return const Center(
        child: Text(
          "No orders found",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    Widget table = Column(
      children: [
        const OrderTableHeader(),

        Expanded(
          child: ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return OrderRow(
                order: order,
                onMorePressed: () {
                  onViewDetail?.call(order);
                },
              );
            },
          ),
        ),
      ],
    );

    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: table,
      );
    }

    return table;
  }
}