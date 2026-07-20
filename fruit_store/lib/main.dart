import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';

import 'package:fruit_store/core/constants/app_colors.dart';
import 'package:fruit_store/features/products/product_routes.dart';
import 'package:fruit_store/features/welcome/presentation/screens/welcome_screen.dart';
import 'package:fruit_store/screens/login/login_screen.dart';
import 'package:fruit_store/services/deep_link.service.dart';

void main() {
  runApp(const FruitStoreApp());
}

class FruitStoreApp extends StatefulWidget {
  const FruitStoreApp({super.key});

  @override
  State<FruitStoreApp> createState() => _FruitStoreAppState();
}

class _FruitStoreAppState extends State<FruitStoreApp> {
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    _appLinks = AppLinks();
    _initDeepLinks();
  }

  Future<void> _initDeepLinks() async {
    // Handle link when app was opened from a terminated state
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleDeepLink(initialUri);
      }
    } catch (_) {
      // No initial link
    }

    // Handle links when app is already running
    _linkSubscription = _appLinks.uriLinkStream.listen(_handleDeepLink);
  }

  void _handleDeepLink(Uri uri) {
    if (DeepLinkService.isPaymentCallback(uri)) {
      final orderId = DeepLinkService.parseOrderIdFromUri(uri);
      if (orderId != null && mounted) {
        // Show a snackbar to inform the user about payment verification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Payment for order #$orderId completed. Go to Orders tab to verify.',
            ),
            backgroundColor: AppColors.primaryOrange,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fruit Store',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryOrange,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.textDark,
          elevation: 0,
        ),
      ),
      initialRoute: '/welcome',
      routes: {
        '/welcome': (context) => const WelcomeScreen(),

        ...ProductRoutes.routes,

        '/login': (context) => const LoginScreen(),

        '/cart': (context) => const Scaffold(
          body: Center(
            child: Text('Cart Screen'),
          ),
        ),
      },
    );
  }
}
