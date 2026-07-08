import 'package:flutter/material.dart';

import 'package:fruit_store/core/constants/app_colors.dart';
import 'package:fruit_store/features/products/product_routes.dart';
import 'package:fruit_store/features/welcome/presentation/screens/welcome_screen.dart';

void main() {
  runApp(const FruitStoreApp());
}

class FruitStoreApp extends StatelessWidget {
  const FruitStoreApp({super.key});

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

        '/cart': (context) => const Scaffold(
          body: Center(
            child: Text('Cart Screen'),
          ),
        ),
      },
    );
  }
}