import 'package:flutter/material.dart';
import 'package:fruit_store/models/order.model.dart';


class CustomerInformationCard extends StatelessWidget {
  final Order order;

  const CustomerInformationCard({
    super.key,
    required this.order,
  });

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value.isEmpty ? "-" : value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = order.customer;
    final profile = customer?.accountProfile;

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
              "Customer Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 18),

            _buildInfoRow(
              "Name",
              profile?.fullName ?? "-",
            ),

            _buildInfoRow(
              "Email",
              customer?.email ?? "-",
            ),

            _buildInfoRow(
              "Phone",
              profile?.phone ?? "-",
            ),

            _buildInfoRow(
              "Address",
              profile?.address ?? "-",
            ),
          ],
        ),
      ),
    );
  }
}