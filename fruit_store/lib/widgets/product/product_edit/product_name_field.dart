import 'package:flutter/material.dart';

class ProductNameField extends StatelessWidget {
  final TextEditingController controller;

  const ProductNameField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: "Product Name",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.shopping_bag_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter product name";
        }
        return null;
      },
    );
  }
}