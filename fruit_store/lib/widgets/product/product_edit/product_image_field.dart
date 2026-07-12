import 'package:flutter/material.dart';

class ProductImageField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const ProductImageField({
    super.key,
    required this.controller,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(
        labelText: "Image URL",
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.image_outlined),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter image URL";
        }
        return null;
      },
    );
  }
}