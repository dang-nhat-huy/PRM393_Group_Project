class ApiConstants {
  static const String baseUrl = 'https://iotfarm.onrender.com/api/v1';

  static String productsList({
    int pageIndex = 1,
    int pageSize = 20,
  }) {
    return '$baseUrl/products/products-list?pageIndex=$pageIndex&pageSize=$pageSize';
  }
}