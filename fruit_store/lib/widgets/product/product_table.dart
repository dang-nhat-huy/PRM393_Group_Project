import 'package:flutter/material.dart';

import '../../models/product.model.dart';
import 'product_row.dart';
import 'product_table_header.dart';

class ProductTable extends StatelessWidget {
  final List<Product> products;

  const ProductTable({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const ProductTableHeader(),

        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          itemBuilder: (_, index) {
            return ProductRow(
              product: products[index],
            );
          },
        ),
      ],
    );
  }
}