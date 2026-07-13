// lib/services/product.service.dart
import '../models/store_product.model.dart';
import 'api.service.dart';

class ProductService {
  final ApiService _api;

  ProductService(this._api);

  /// Fetch a paginated list of products
  Future<List<StoreProduct>> getAll({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final query = {
      'pageIndex': pageIndex.toString(),
      'pageSize': pageSize.toString(),
    };
    final data = await _api.get('/api/v1/products/products-list', query: query);
    final responseData = data['data'];
    if (responseData != null && responseData['items'] != null) {
      final list = responseData['items'] as List<dynamic>;
      return list.map((e) => StoreProduct.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Get details of a single product
  Future<StoreProduct> getProductById(int productId) async {
    final data = await _api.get('/api/v1/products/get-product/$productId');
    final productData = data['data'] as Map<String, dynamic>;
    // Merge the productId into the response body since the detail API response does not contain it
    productData['productId'] = productId;
    return StoreProduct.fromJson(productData);
  }

  /// Search products by name
  Future<List<StoreProduct>> searchByName(
    String name, {
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final query = {
      'pageIndex': pageIndex.toString(),
      'pageSize': pageSize.toString(),
    };
    final encodedName = Uri.encodeComponent(name);
    final data = await _api.get('/api/v1/products/search-product/$encodedName', query: query);
    final responseData = data['data'];
    if (responseData != null && responseData['items'] != null) {
      final list = responseData['items'] as List<dynamic>;
      return list.map((e) => StoreProduct.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }

  /// Filter products by status, category, etc.
  Future<List<StoreProduct>> filter({
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
      return list.map((e) => StoreProduct.fromJson(e as Map<String, dynamic>)).toList();
    }
    return [];
  }
}
