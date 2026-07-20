class ApiConstants {
  static const String baseUrl = 'http://10.0.2.2:5002/api/v1';

  static String productsList({
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return '$baseUrl/products/products-list?pageIndex=$pageIndex&pageSize=$pageSize';
  }
}