import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:fruit_store/features/cart/data/models/cart_item_model.dart';
import 'package:fruit_store/features/products/data/models/product_model.dart';
import 'package:fruit_store/features/products/data/services/product_service.dart';
import 'package:fruit_store/services/app_session.dart';

class CartService {
  static const String _baseUrl = 'https://iotfarm.onrender.com';

  final ProductService _productService = ProductService();

  Map<String, String> get _headers {
    final token = AppSession.instance.token;

    if (token == null || token.isEmpty) {
      throw Exception('Bạn cần đăng nhập để sử dụng giỏ hàng.');
    }

    return {
      'accept': '*/*',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String> addToCart({
    required int productId,
    int quantity = 1,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/account/add-to-cart?productId=$productId&quantity=$quantity',
    );

    final response = await http.post(
      uri,
      headers: _headers,
    );

    final result = _handleResponse(response);

    return result['message']?.toString() ?? 'Product added to cart successfully';
  }

  Future<List<CartItemModel>> getCartItems() async {
    final uri = Uri.parse('$_baseUrl/api/v1/account/cart-items');

    final response = await http.get(
      uri,
      headers: _headers,
    );

    final body = _handleResponse(response);
    final rawItems = _extractItems(body);

    final cartItems = rawItems
        .whereType<Map<String, dynamic>>()
        .map(CartItemModel.fromJson)
        .where((item) => item.productId != 0)
        .toList();

    if (cartItems.isEmpty) {
      return [];
    }

    return _attachProductInfo(cartItems);
  }

  Future<void> updateCartItem({
    required int productId,
    required int quantity,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/account/update-cart-item?productId=$productId&quantity=$quantity',
    );

    final response = await http.put(
      uri,
      headers: _headers,
    );

    _handleResponse(response);
  }

  Future<void> removeCartItem({
    required int productId,
  }) async {
    final uri = Uri.parse(
      '$_baseUrl/api/v1/account/remove-cart-item?productId=$productId',
    );

    final response = await http.delete(
      uri,
      headers: _headers,
    );

    _handleResponse(response);
  }

  Future<void> clearCart() async {
    final uri = Uri.parse('$_baseUrl/api/v1/account/clear-cart');

    final response = await http.delete(
      uri,
      headers: _headers,
    );

    _handleResponse(response);
  }

  Future<List<CartItemModel>> _attachProductInfo(
      List<CartItemModel> cartItems,
      ) async {
    try {
      final products = await _productService.getProducts(
        pageIndex: 1,
        pageSize: 100,
      );

      final Map<int, ProductModel> productMap = {
        for (final product in products) product.productId: product,
      };

      return cartItems.map((cartItem) {
        final product = productMap[cartItem.productId];

        if (product == null) {
          return cartItem;
        }

        return cartItem.copyWith(
          productName: product.productName,
          image: product.images,
          unit: product.unit,
          stockQuantity: product.stockQuantity,
          price: cartItem.price > 0 ? cartItem.price : product.price,
        );
      }).toList();
    } catch (_) {
      return cartItems;
    }
  }

  List<dynamic> _extractItems(Map<String, dynamic> body) {
    final cartItems = body['cartItems'] ?? body['CartItems'];

    if (cartItems is List) {
      return cartItems;
    }

    final data = body['data'];

    if (data is List) {
      return data;
    }

    if (data is Map<String, dynamic>) {
      final dataCartItems = data['cartItems'] ??
          data['CartItems'] ??
          data['items'] ??
          data['Items'];

      if (dataCartItems is List) {
        return dataCartItems;
      }
    }

    return [];
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final isHttpSuccess =
        response.statusCode >= 200 && response.statusCode < 300;

    if (response.body.trim().isEmpty) {
      if (isHttpSuccess) {
        return {
          'status': response.statusCode,
          'message': 'Success',
        };
      }

      throw Exception('Có lỗi xảy ra khi xử lý giỏ hàng.');
    }

    dynamic decodedBody;

    try {
      decodedBody = jsonDecode(response.body);
    } catch (_) {
      if (isHttpSuccess) {
        return {
          'status': response.statusCode,
          'message': response.body,
        };
      }

      throw Exception(response.body);
    }

    if (decodedBody is String) {
      if (isHttpSuccess) {
        return {
          'status': response.statusCode,
          'message': decodedBody,
        };
      }

      throw Exception(decodedBody);
    }

    if (decodedBody is! Map<String, dynamic>) {
      if (isHttpSuccess) {
        return {
          'status': response.statusCode,
          'data': decodedBody,
        };
      }

      throw Exception('Response không hợp lệ.');
    }

    final body = decodedBody;

    final apiStatus = body['status'];

    final isApiSuccess = apiStatus == null ||
        apiStatus == 1 ||
        apiStatus == 200 ||
        apiStatus == 201;

    if (isHttpSuccess && isApiSuccess) {
      return body;
    }

    throw Exception(
      body['message']?.toString() ?? 'Có lỗi xảy ra khi xử lý giỏ hàng.',
    );
  }
}