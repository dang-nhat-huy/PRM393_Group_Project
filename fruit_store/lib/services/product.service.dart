// lib/services/product.service.dart
import 'package:fruit_store/models/category_model.dart';
import 'package:fruit_store/models/product.model.dart';
import 'package:fruit_store/models/product_update_request.dart';
import 'api.service.dart';

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

    final List items = response["data"]?["items"] as List? ?? [];

    return items.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
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

    final List items = response["data"]?["items"] as List? ?? [];

    return items.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// =========================
  /// Get Product By Id
  /// =========================
  Future<Product?> getProductById(int id) async {
    final response = await _api.get("/api/v1/products/get-product/$id");

    if (response["data"] == null) {
      return null;
    }

    final productData = response["data"] as Map<String, dynamic>;
    // Merge the productId into the response body since the detail API response does not contain it
    productData['productId'] = id;

    return Product.fromJson(productData);
  }

  /// =========================
  /// Update Product
  /// =========================
  Future<void> updateProduct(int id, ProductUpdateRequest request) async {
    await _api.put("/api/v1/products/update/$id", data: request.toJson());
  }

  /// =========================
  /// Get Categories
  /// =========================
  Future<List<Category>> getCategories() async {
    final response = await _api.get("/api/v1/category/get-all");

    final List items = response["data"] as List;

    return items.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Filter products by status, category, etc.
  Future<List<Product>> filter({
    int pageIndex = 1,
    int pageSize = 20,
    String? status,
    int? categoryId,
    bool? sortByStockAsc,
  }) async {
    final query = <String, dynamic>{
      'pageIndex': pageIndex.toString(),
      'pageSize': pageSize.toString(),
    };
    if (status != null) query['status'] = status;
    if (categoryId != null) query['categoryId'] = categoryId.toString();
    if (sortByStockAsc != null) query['sortByStockAsc'] = sortByStockAsc.toString();

    final data = await _api.get('/api/v1/products/product-filter', query: query);
    final responseData = data['data'];
    if (responseData != null && responseData['items'] != null) {
      final list = responseData['items'] as List<dynamic>;
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
