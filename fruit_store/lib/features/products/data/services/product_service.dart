import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:fruit_store/core/constants/api_constants.dart';
import 'package:fruit_store/features/products/data/models/product_model.dart';

class ProductService {
  Future<List<ProductModel>> getProducts({
    int pageIndex = 1,
    int pageSize = 20,
  }) async {
    final uri = Uri.parse(
      ApiConstants.productsList(
        pageIndex: pageIndex,
        pageSize: pageSize,
      ),
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Không thể tải danh sách sản phẩm');
    }

    final Map<String, dynamic> body = jsonDecode(response.body);

    if (body['status'] != 1) {
      throw Exception(body['message'] ?? 'Lỗi khi lấy dữ liệu sản phẩm');
    }

    final data = body['data'];
    final List<dynamic> items = data['items'] ?? [];

    return items
        .map((item) => ProductModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}