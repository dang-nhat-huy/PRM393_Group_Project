import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      elevation: 0,
      backgroundColor: _backgroundColor,
      side: BorderSide(
        color: _borderColor,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      label: Text(
        status,
        style: TextStyle(
          color: _textColor,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Color get _backgroundColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.blue.shade50;

      case 'active':
        return Colors.lightBlue.shade50;

      case 'delivered':
        return Colors.green.shade50;

      case 'completed':
        return Colors.teal.shade50;

      case 'pending':
        return Colors.orange.shade50;

      case 'cancelled':
        return Colors.red.shade50;

      case 'processing':
      case 'in progress':
        return Colors.amber.shade50;

      default:
        return Colors.grey.shade100;
    }
  }

  Color get _textColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.blue.shade700;

      case 'active':
        return Colors.lightBlue.shade700;

      case 'delivered':
        return Colors.green.shade700;

      case 'completed':
        return Colors.teal.shade700;

      case 'pending':
        return Colors.orange.shade700;

      case 'cancelled':
        return Colors.red.shade700;

      case 'processing':
      case 'in progress':
        return Colors.amber.shade900;

      default:
        return Colors.grey.shade700;
    }
  }

  Color get _borderColor {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.blue.shade200;

      case 'active':
        return Colors.lightBlue.shade200;

      case 'delivered':
        return Colors.green.shade200;

      case 'completed':
        return Colors.teal.shade200;

      case 'pending':
        return Colors.orange.shade200;

      case 'cancelled':
        return Colors.red.shade200;

      case 'processing':
      case 'in progress':
        return Colors.amber.shade200;

      default:
        return Colors.grey.shade300;
    }
  }
}