import 'package:flutter/material.dart';

class OrderFilterBar extends StatelessWidget {
  final List<String> filters;
  final String selectedFilter;
  final ValueChanged<String> onSelected;

  const OrderFilterBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onSelected,
  });

  Color _chipColor(String filter) {
    switch (filter.toLowerCase()) {
      case "pending":
        return Colors.orange;

      case "processing":
        return Colors.blue;

      case "delivered":
        return Colors.green;

      case "completed":
        return const Color(0xFF1B5E20);

      case "cancelled":
        return Colors.red;

      case "paid":
        return Colors.teal;

      default:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (_, index) {
          final filter = filters[index];
          final selected = filter == selectedFilter;

          return ChoiceChip(
            label: Text(filter),
            selected: selected,
            onSelected: (_) => onSelected(filter),

            selectedColor: _chipColor(filter),

            backgroundColor: Colors.white,

            side: BorderSide(
              color: selected
                  ? _chipColor(filter)
                  : Colors.grey.shade300,
            ),

            labelStyle: TextStyle(
              color: selected
                  ? Colors.white
                  : Colors.black87,
              fontWeight: FontWeight.w500,
            ),

            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          );
        },
      ),
    );
  }
}