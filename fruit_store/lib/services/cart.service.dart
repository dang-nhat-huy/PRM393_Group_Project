// lib/services/cart.service.dart
import '../models/cart.model.dart';
import 'api.service.dart';

class CartService {
  final ApiService _api;

  CartService(this._api);

  /// Fetch all cart items.
  Future<CartModel> getCart() async {
    final data = await _api.get('/api/v1/account/cart-items');
    return CartModel.fromJson(data);
  }

  /// Add a product to the cart.
  Future<void> addToCart(int productId, int quantity) async {
    await _api.post('/api/v1/account/add-to-cart?productId=$productId&quantity=$quantity');
  }

  /// Update the quantity of a product in the cart.
  Future<void> updateCartItem(int productId, int quantity) async {
    await _api.put('/api/v1/account/update-cart-item?productId=$productId&quantity=$quantity');
  }

  /// Remove a product from the cart.
  Future<void> removeCartItem(int productId) async {
    await _api.delete('/api/v1/account/remove-cart-item?productId=$productId');
  }

  /// Clear the cart.
  Future<void> clearCart() async {
    await _api.delete('/api/v1/account/clear-cart');
  }
}
