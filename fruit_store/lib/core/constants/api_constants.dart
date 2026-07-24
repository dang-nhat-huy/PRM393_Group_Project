class ApiConstants {
  static const String baseUrl = 'https://scaling-chainsaw.onrender.com';
  static const String authBaseUrl = 'https://scaling-chainsaw-auth.onrender.com';

  static String productsList({
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return '$baseUrl/api/v1/products/products-list?pageIndex=$pageIndex&pageSize=$pageSize';
  }
}