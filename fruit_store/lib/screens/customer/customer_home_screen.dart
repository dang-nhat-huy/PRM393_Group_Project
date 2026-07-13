// lib/screens/customer/customer_home_screen.dart
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../services/api.service.dart';
import '../../services/cart.service.dart';
import '../../services/order.service.dart';
import '../../services/product.service.dart';
import '../chatbot/chatbot_screen.dart';
import 'cart_tab.dart';
import 'orders_tab.dart';
import 'profile_tab.dart';
import 'shop_tab.dart';

class CustomerHomeScreen extends StatefulWidget {
  final ApiService apiService;
  final String email;

  const CustomerHomeScreen({
    super.key,
    required this.apiService,
    required this.email,
  });

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  int _currentIndex = 0;
  late final ProductService _productService;
  late final CartService _cartService;
  late final OrderService _orderService;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(widget.apiService);
    _cartService = CartService(widget.apiService);
    _orderService = OrderService(widget.apiService);
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tabs = [
      ShopTab(productService: _productService, cartService: _cartService),
      CartTab(
        cartService: _cartService,
        productService: _productService,
        orderService: _orderService,
      ),
      OrdersTab(orderService: _orderService),
      const ChatbotScreen(),
      ProfileTab(email: widget.email, apiService: widget.apiService),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabChanged,
        selectedItemColor: AppTheme.primaryOrange,
        unselectedItemColor: AppTheme.textGray,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront_outlined),
            activeIcon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart_outlined),
            activeIcon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
