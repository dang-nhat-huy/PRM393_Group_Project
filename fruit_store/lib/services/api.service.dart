// lib/services/api.service.dart
import 'package:dio/dio.dart';

/// Central HTTP client for all API calls.
///
/// Uses Dio under the hood and provides:
/// - Automatic JWT token injection via Authorization header
/// - Centralized error handling
/// - JSON deserialization helpers
class ApiService {
  final Dio _dio;

  static const String baseUrl = 'https://iotfarm.onrender.com/';

  ApiService()
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
        onError: (error, handler) {
          handler.next(error);
        },
      ),
    );
  }

  String? _accessToken;

  void setToken(String? token) {
    _accessToken = token;
  }

  String? get accessToken => _accessToken;

  // --- HTTP verbs ---

  /// Sends a GET request to [path] with optional [query] parameters.
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    final response = await _dio.get(path, queryParameters: query);
    return _handleResponse(response);
  }

  /// Sends a POST request to [path] with an optional [data] body.
  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.post(path, data: data);
    return _handleResponse(response);
  }

  /// Sends a PUT request to [path] with an optional [data] body.
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.put(path, data: data);
    return _handleResponse(response);
  }

  /// Sends a PATCH request to [path] with an optional [data] body.
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _dio.patch(path, data: data);
    return _handleResponse(response);
  }

  /// Sends a DELETE request to [path].
  Future<void> delete(String path) async {
    await _dio.delete(path);
  }

  // --- Response handling ---

  Map<String, dynamic> _handleResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is List) {
      return {'data': data};
    }
    return data as Map<String, dynamic>;
  }
}

/// Custom exception for API errors.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
