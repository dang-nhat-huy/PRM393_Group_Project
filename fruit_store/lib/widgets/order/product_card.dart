import 'package:flutter/material.dart';

import '../../models/order.model.dart';

class ProductCard extends StatelessWidget {
  final OrderDetailItem item;

  const ProductCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final product = item.product;

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
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: product?.images != null &&
                      product!.images!.isNotEmpty
                  ? Image.network(
                      product.images!,
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          _buildPlaceholder(),
                    )
                  : _buildPlaceholder(),
            ),

            const SizedBox(width: 16),

            /// Product Information
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    product?.productName ??
                        "Unknown Product",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Quantity: ${item.quantity}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Unit Price: ₫${item.unitPrice}",
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            /// Total Price
            Text(
              "₫${item.quantity * item.unitPrice}",
              style: const TextStyle(
                color: Colors.deepOrange,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.image,
        color: Colors.grey,
      ),
    );
  }
}