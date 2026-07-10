import 'package:flutter/material.dart';

import '../../models/product.model.dart';

class ProductRow extends StatelessWidget {
  final Product product;

  const ProductRow({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "${product.productId}",
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                product.productName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "${product.price.toStringAsFixed(0)} đ",
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "${product.stockQuantity} kg",
              ),
            ),
          ),
        ],
      ),
    );
  }
}