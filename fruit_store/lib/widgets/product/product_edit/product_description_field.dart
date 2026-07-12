import 'package:flutter/material.dart';

class ProductDescriptionField extends StatelessWidget {
  final TextEditingController controller;

  const ProductDescriptionField({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: 5,
      minLines: 4,
      textInputAction: TextInputAction.newline,
      decoration: InputDecoration(
        labelText: "Description",
        hintText: "Enter product description",
        alignLabelWithHint: true,
        prefixIcon: const Padding(
          padding: EdgeInsets.only(bottom: 70),
          child: Icon(Icons.description_outlined),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return "Please enter product description";
        }

        if (value.trim().length < 10) {
          return "Description must be at least 10 characters";
        }

        return null;
      },
    );
  }
}