import 'package:flutter/material.dart';

class ProductTableHeader extends StatelessWidget {
  const ProductTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.deepOrange,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: const Row(
        children: [
          Expanded(
            flex: 1,
            child: Center(
              child: Text(
                "ID",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: Text(
                "Product",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Price",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: Text(
                "Stock",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}