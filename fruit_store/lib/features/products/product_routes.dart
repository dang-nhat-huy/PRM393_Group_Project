import 'package:flutter/material.dart';

import 'package:fruit_store/features/products/data/models/product_model.dart';
import 'package:fruit_store/features/products/presentation/screens/product_detail_screen.dart';
import 'package:fruit_store/features/products/presentation/screens/product_list_screen.dart';

class ProductRoutes {
  static Map<String, WidgetBuilder> routes = {
    '/products': (context) => const ProductListScreen(),

    '/product-detail': (context) {
      final product =
      ModalRoute.of(context)!.settings.arguments as ProductModel;

      return ProductDetailScreen(product: product);
    },
  };
}