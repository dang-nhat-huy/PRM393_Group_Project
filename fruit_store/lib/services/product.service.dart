
import 'package:fruit_store/models/product.model.dart';

import '../../../services/api.service.dart';

class ProductService {
  final ApiService _api;

  ProductService(this._api);

  /// =========================
  /// Get Product List
  /// =========================
  Future<List<Product>> getProducts({
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.get(
      "/api/v1/products/products-list",
      query: {
        "pageIndex": pageIndex.toString(),
        "pageSize": pageSize.toString(),
      },
    );

    final List items =
        response["data"]?["items"] as List? ?? [];

    return items
        .map((e) => Product.fromJson(e))
        .toList();
  }

  /// =========================
  /// Search Product
  /// =========================
  Future<List<Product>> searchProduct(
    String keyword, {
    int pageIndex = 1,
    int pageSize = 10,
  }) async {
    final response = await _api.get(
      "/api/v1/products/search-product/$keyword",
      query: {
        "pageIndex": pageIndex.toString(),
        "pageSize": pageSize.toString(),
      },
    );

    final List items =
        response["data"]?["items"] as List? ?? [];

    return items
        .map((e) => Product.fromJson(e))
        .toList();
  }

  /// =========================
  /// Get Product By Id
  /// =========================
  Future<Product?> getProductById(
    int id,
  ) async {
    final response = await _api.get(
      "/api/v1/products/product/$id",
    );

    if (response["data"] == null) {
      return null;
    }

    return Product.fromJson(response["data"]);
  }
}