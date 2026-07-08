import 'package:flutter/material.dart';

class TableCellWidget extends StatelessWidget {
  final Widget child;
  final int flex;
  final bool showRightBorder;
  final bool center;
  final EdgeInsetsGeometry padding;

  const TableCellWidget({
    super.key,
    required this.child,
    this.flex = 1,
    this.showRightBorder = true,
    this.center = false,
    this.padding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 14,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: padding,
        alignment:
        center ? Alignment.center : Alignment.centerLeft,
        decoration: BoxDecoration(
          border: Border(
            right: showRightBorder
                ? BorderSide(
              color: Colors.grey.shade300,
            )
                : BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }
}