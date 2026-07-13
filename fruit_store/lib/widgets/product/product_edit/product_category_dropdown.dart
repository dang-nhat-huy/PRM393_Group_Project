import 'package:flutter/material.dart';

import '../../../models/category_model.dart';

class ProductCategoryDropdown extends StatelessWidget {
  final List<Category> categories;
  final Category? selectedCategory;
  final ValueChanged<Category?> onChanged;

  const ProductCategoryDropdown({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Category>(
      initialValue: selectedCategory,
      decoration: InputDecoration(
        labelText: "Category",
        prefixIcon: const Icon(Icons.category_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: categories
          .map(
            (category) => DropdownMenuItem<Category>(
              value: category,
              child: Text(category.categoryName),
            ),
          )
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null) {
          return "Please select a category";
        }
        return null;
      },
    );
  }
}