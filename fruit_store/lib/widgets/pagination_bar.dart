import 'package:flutter/material.dart';

/// A reusable pagination bar widget.
class PaginationBar extends StatelessWidget {
  final int pageIndex;
  final int totalPages;
  final bool hasNext;
  final bool hasPrevious;
  final void Function(int page) onPageChanged;

  const PaginationBar({
    super.key,
    required this.pageIndex,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed:
                hasPrevious ? () => onPageChanged(pageIndex - 1) : null,
          ),
          const SizedBox(width: 8),
          Text(
            '$pageIndex / $totalPages',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed:
                hasNext ? () => onPageChanged(pageIndex + 1) : null,
          ),
        ],
      ),
    );
  }
}