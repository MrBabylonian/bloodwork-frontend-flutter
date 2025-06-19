import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

class ApiService {
  static const String _baseUrl = 'http://localhost:8000';

  late final Dio _dio;
  final Logger _logger = Logger();

  ApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _setupInterceptors();
  }

  void _setupInterceptors() {
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
  Future<Response> post(String path, {dynamic data}) async {
    try {
      final response = await _dio.post(path, data: data);
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

  // Set authorization token
  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  // Clear authorization token
  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
