// lib/services/auth.service.dart
import 'package:jwt_decoder/jwt_decoder.dart';

import '../models/auth_result.dart';
import 'api.service.dart';

/// Handles authentication: login, register, logout.
/// Stores the JWT token in [ApiService] for subsequent requests.
class AuthService {
  final ApiService _api;

  AuthService(this._api);

  /// Logs in with [email] and [password].
  /// Returns the JWT token.
  Future<AuthResult> login(
      String email,
      String password,
      ) async {

    final data = await _api.post(
      '/api/v1/account/login',
      data: {
        'email': email,
        'password': password,
      },
    );

    final token = data["token"] as String;

    _api.setToken(token);

    final decoded = JwtDecoder.decode(token);

    return AuthResult(
      token: token,
      role: decoded["role"],
      accountId: int.parse(decoded["nameid"]),
    );
  }

  /// Registers a new user with [email], [password], and [confirmPassword].
  /// Returns the JWT token if one is returned, otherwise returns null.
  Future<String?> register({
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final response = await _api.post('/api/v1/account/register', data: {
      'email': email,
      'password': password,
      'confirmPassword': confirmPassword,
    });

    // Handle different response formats
    // Some backends return a token directly on registration
    // Others return 201 with a success message and no token
    if (response is Map && response.containsKey('token')) {
      final token = response['token'] as String;
      _api.setToken(token);
      return token;
    }

    // No token returned, registration was successful without auto-login
    return null;
  }

  /// Clears the stored token (logs out).
  void logout() {
    _api.setToken(null);
  }
}