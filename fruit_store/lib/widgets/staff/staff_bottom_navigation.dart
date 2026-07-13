import 'package:flutter/material.dart';

class StaffBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StaffBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.deepOrange,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.receipt_long),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2),
          label: "Products",
        ),
      ],
    );
  }
}