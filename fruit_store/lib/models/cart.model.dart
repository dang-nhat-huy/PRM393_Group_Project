// lib/models/cart.model.dart
import 'store_product.model.dart';

class CartModel {
  final String paymentStatus;
  final String createdAt;
  final String updatedAt;
  final List<CartItemModel> items;

  CartModel({
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final list = json['cartItems'] as List<dynamic>? ?? [];
    return CartModel(
      paymentStatus: json['paymentStatus'] as String? ?? 'UNPAID',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      items: list.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentStatus': paymentStatus,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'cartItems': items.map((e) => e.toJson()).toList(),
    };
  }
}

class CartItemModel {
  final int cartId;
  final int productId;
  final int quantity;
  final double priceQuantity;
  StoreProduct? product; // Resolved client-side for displaying details

  CartItemModel({
    required this.cartId,
    required this.productId,
    required this.quantity,
    required this.priceQuantity,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      cartId: json['cartId'] as int? ?? 0,
      productId: json['productId'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 0,
      priceQuantity: (json['priceQuantity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cartId': cartId,
      'productId': productId,
      'quantity': quantity,
      'priceQuantity': priceQuantity,
    };
  }
}
