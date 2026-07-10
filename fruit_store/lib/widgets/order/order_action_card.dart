import 'package:flutter/material.dart';

import '../../constants/order.constant.dart';

class OrderActionCard extends StatelessWidget {
  final OrderStatus? status;

  final VoidCallback? onDeliver;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const OrderActionCard({
    super.key,
    required this.status,
    this.onDeliver,
    this.onComplete,
    this.onCancel,
  });

  bool get canDeliver {
    return status == OrderStatus.paid ||
        status == OrderStatus.pending ||
        status == OrderStatus.undischarged;
  }

  bool get canComplete {
    return status == OrderStatus.delivered;
  }

  bool get canCancel {
    return status == OrderStatus.pending ||
        status == OrderStatus.paid ||
        status == OrderStatus.undischarged;
  }

  @override
  Widget build(BuildContext context) {
    if (!canDeliver && !canComplete && !canCancel) {
      return const SizedBox.shrink();
    }

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
              "Order Actions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 20),

            if (canDeliver)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onDeliver,
                  icon: const Icon(Icons.local_shipping),
                  label: const Text("Mark as Delivered"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (canComplete)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onComplete,
                  icon: const Icon(Icons.check_circle),
                  label: const Text("Complete Order"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),

            if (canCancel)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel),
                    label: const Text("Cancel Order"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(
                        color: Colors.red,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}