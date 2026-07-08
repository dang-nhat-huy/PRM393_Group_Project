import 'package:flutter/material.dart';
import 'table_cell.dart';

class OrderTableHeader extends StatelessWidget {
  const OrderTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.deepOrange,
        border: Border.all(
          color: Colors.orange.shade300,
        ),
      ),
      child: const Row(
        children: [
          TableCellWidget(
            flex: 1,
            center: true,
            child: Text(
              'ID',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TableCellWidget(
            flex: 2,
            child: Text(
              'Customer',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TableCellWidget(
            flex: 2,
            child: Text(
              'Total',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TableCellWidget(
            flex: 2,
            child: Text(
              'Status',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          TableCellWidget(
            flex: 1,
            showRightBorder: false,
            center: true,
            child: Text(
              'Action',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}