// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../services/api.service.dart';
import '../../services/order.service.dart';
import '../../services/user.service.dart';
import '../chatbot/chatbot_screen.dart';
import 'account_list.dart';
import 'revenue_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  final ApiService apiService;

  const AdminHomeScreen({super.key, required this.apiService});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;

  late final UserService _userService;
  late final OrderService _orderService;

  @override
  void initState() {
    super.initState();
    _userService = UserService(widget.apiService);
    _orderService = OrderService(widget.apiService);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      AccountListScreen(userService: _userService),
      RevenueScreen(orderService: _orderService),
      const ChatbotScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textGray,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Accounts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Revenue',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
        ],
      ),
    );
  }
}