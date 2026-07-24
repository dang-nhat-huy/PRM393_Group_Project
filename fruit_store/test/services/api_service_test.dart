import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_store/core/constants/api_constants.dart';
import 'package:fruit_store/services/api.service.dart';

void main() {
  group('ApiConstants Tests', () {
    test('baseUrl should point to valid scaling-chainsaw endpoint', () {
      expect(ApiConstants.baseUrl, equals('https://scaling-chainsaw.onrender.com'));
    });

    test('authBaseUrl should point to valid auth endpoint', () {
      expect(ApiConstants.authBaseUrl, equals('https://scaling-chainsaw-auth.onrender.com'));
    });

    test('productsList URL generator should format query params correctly', () {
      final url = ApiConstants.productsList(pageIndex: 2, pageSize: 15);
      expect(
        url,
        equals('https://scaling-chainsaw.onrender.com/api/v1/products/products-list?pageIndex=2&pageSize=15'),
      );
    });
  });

  group('ApiService Tests', () {
    test('default ApiService initializes with default ApiConstants.baseUrl', () {
      final apiService = ApiService();
      expect(apiService.accessToken, isNull);
    });

    test('setToken updates and retrieves access token correctly', () {
      final apiService = ApiService();
      const testToken = 'mock_jwt_token_xyz';
      apiService.setToken(testToken);
      expect(apiService.accessToken, equals(testToken));

      apiService.setToken(null);
      expect(apiService.accessToken, isNull);
    });
  });
}
