import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProductPriceField extends StatelessWidget {
  final TextEditingController controller;

  const ProductPriceField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      decoration: InputDecoration(
        labelText: "Price",
        hintText: "Enter product price",
        prefixIcon: const Icon(Icons.attach_money),
        suffixText: "VNĐ",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Price is required";
        }

        final price = double.tryParse(value);

        if (price == null) {
          return "Invalid price";
        }

        if (price <= 0) {
          return "Price must be greater than 0";
        }

        return null;
      },
    );
  }
}