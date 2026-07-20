// lib/screens/customer/customer_home_screen.dart
import 'package:flutter/material.dart';

import '../../constants/app_theme.dart';
import '../../services/api.service.dart';
import '../../services/cart.service.dart';
import '../../services/order.service.dart';
import '../../services/product.service.dart';
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
  late final ApiService _accountApiService;

  @override
  void initState() {
    super.initState();
    _productService = ProductService(widget.apiService);
    _cartService = CartService(widget.apiService);
    _orderService = OrderService(widget.apiService);

    _accountApiService = ApiService(baseUrl: 'https://scaling-chainsaw-auth.onrender.com');
    // Sync the JWT token from the main API service
    _accountApiService.setToken(widget.apiService.accessToken);
  }

  void _onTabChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pass a unique key based on _currentIndex so each tab can detect
    // when it becomes active and reload its data.
    final tabs = [
      ShopTab(
        key: ValueKey('shop-$_currentIndex'),
        productService: _productService,
        cartService: _cartService,
        isActive: _currentIndex == 0,
      ),
      CartTab(
        key: ValueKey('cart-$_currentIndex'),
        cartService: _cartService,
        productService: _productService,
        orderService: _orderService,
        isActive: _currentIndex == 1,
      ),
      OrdersTab(
        key: ValueKey('orders-$_currentIndex'),
        orderService: _orderService,
        isActive: _currentIndex == 2,
      ),
      ProfileTab(
        key: ValueKey('profile-$_currentIndex'),
        email: widget.email,
        apiService: _accountApiService,
        isActive: _currentIndex == 3,
      ),
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
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}