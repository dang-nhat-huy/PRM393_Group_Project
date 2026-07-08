// lib/services/auth.service.dart
import 'api.service.dart';

/// Handles authentication: login, register, logout.
/// Stores the JWT token in [ApiService] for subsequent requests.
class AuthService {
  final ApiService _api;

  AuthService(this._api);

  /// Logs in with [email] and [password].
  /// Returns the JWT token.
  Future<String> login(
    String email,
    String password,
  ) async {
    final data = await _api.post('/api/v1/account/login', data: {
      'email': email,
      'password': password,
    });
    final token = data['token'] as String;
    _api.setToken(token);
    return token;
  }

  /// Registers a new user with [email], [password], and [confirmPassword].
  /// Returns the JWT token.
  Future<String> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final data = await _api.post('/api/v1/account/register', data: {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    final token = data['token'] as String;
    _api.setToken(token);

    return token;
  }

  /// Clears the stored token (logs out).
  void logout() {
    _api.setToken(null);
  }
}