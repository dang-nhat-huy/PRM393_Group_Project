import 'package:flutter_test/flutter_test.dart';
import 'package:fruit_store/models/auth_result.dart';

void main() {
  group('AuthResult Model Tests', () {
    test('AuthResult instantiates with provided parameters correctly', () {
      final authResult = AuthResult(
        token: 'sample_token_123',
        role: 'Customer',
        accountId: 42,
      );

      expect(authResult.token, equals('sample_token_123'));
      expect(authResult.role, equals('Customer'));
      expect(authResult.accountId, equals(42));
    });
  });
}
