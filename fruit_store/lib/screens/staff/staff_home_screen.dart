import 'package:flutter/material.dart';

import '../../services/api.service.dart';
import 'staff_dashboard_screen.dart';
import 'product_list_screen.dart';
import '../../widgets/staff/staff_bottom_navigation.dart';

class StaffHomeScreen extends StatefulWidget {
  final ApiService apiService;

  const StaffHomeScreen({
    super.key,
    required this.apiService,
  });

  @override
  State<StaffHomeScreen> createState() => _StaffHomeScreenState();
}

class _StaffHomeScreenState extends State<StaffHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      StaffDashboardScreen(
        apiService: widget.apiService,
      ),
      ProductListScreen(
        apiService: widget.apiService,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: StaffBottomNavigation(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}