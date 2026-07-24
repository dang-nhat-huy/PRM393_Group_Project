// lib/services/api.service.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:fruit_store/core/constants/api_constants.dart';

/// Central HTTP client for all API calls.
///
/// Uses Dio under the hood and provides:
/// - Automatic JWT token injection via Authorization header
/// - Centralized error handling
/// - JSON deserialization helpers
class ApiService {
  final Dio _dio;

  ApiService({String baseUrl = ApiConstants.baseUrl})
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
    try {
      final response = await _dio.get(path, queryParameters: query);
      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint("GET Error: ${e.message}");
      rethrow;
    }
  }

  /// Sends a POST request to [path] with an optional [data] body.
  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint("POST Error: ${e.message}");
      rethrow;
    }
  }

  /// Sends a POST request that returns void (no response body needed).
  /// Useful for endpoints that return empty or plain text responses on success.
  Future<void> postNoResponse(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      await _dio.post(path, data: data);
    } on DioException catch (e) {
      debugPrint("POST Error: ${e.message}");
      rethrow;
    }
  }

  /// Sends a PUT request to [path] with an optional [data] body.
  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.put(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint("PUT Error: ${e.message}");
      rethrow;
    }
  }

  /// Sends a PATCH request to [path] with an optional [data] body.
  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return _handleResponse(response);
    } on DioException catch (e) {
      debugPrint("PATCH Error: ${e.message}");
      rethrow;
    }
  }

  /// Sends a DELETE request to [path].
  Future<void> delete(String path) async {
    await _dio.delete(path);
  }

  // --- Response handling ---

  dynamic _handleResponse(Response<dynamic> response) {
    final data = response.data;
    if (data is List) {
      return {'data': data};
    }
    if (data is Map) {
      return data;
    }
    // Handle non-Map responses (e.g. plain text, empty body for 201 Created)
    return {'data': data, 'statusCode': response.statusCode};
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