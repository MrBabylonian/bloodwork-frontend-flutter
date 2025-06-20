import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../interceptors/auth_interceptor.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

/// Production-grade API service with automatic authentication
///
/// This service provides a clean interface for all HTTP requests
/// with automatic auth header injection through middleware.
/// Features:
/// - Automatic token injection
/// - Token refresh on 401 errors
/// - Clean error handling
/// - Production-ready logging
class ApiService {
  static const String _baseUrl = 'http://localhost:8000';

  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService({
    required StorageService storageService,
    required AuthProvider authProvider,
  }) {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _setupInterceptors(storageService, authProvider);
  }

  void _setupInterceptors(
    StorageService storageService,
    AuthProvider authProvider,
  ) {
    // Add authentication interceptor first
    _dio.interceptors.add(
      AuthInterceptor(
        storageService: storageService,
        authProvider: authProvider,
      ),
    );

    // Add logging interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logger.d('Request: ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          _logger.d(
            'Response: ${response.statusCode} ${response.requestOptions.path}',
          );
          handler.next(response);
        },
        onError: (error, handler) {
          _logger.e('Error: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      _logger.e('GET request failed: $e');
      rethrow;
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        options: headers != null ? Options(headers: headers) : null,
      );
      return response;
    } catch (e) {
      _logger.e('POST request failed: $e');
      rethrow;
    }
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    try {
      final response = await _dio.put(path, data: data);
      return response;
    } catch (e) {
      _logger.e('PUT request failed: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<Response> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response;
    } catch (e) {
      _logger.e('DELETE request failed: $e');
      rethrow;
    }
  }
}
