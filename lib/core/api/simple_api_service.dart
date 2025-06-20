import 'package:dio/dio.dart';

/// Simple API service for authentication operations only
///
/// This is used during the initial setup phase before the full
/// ApiService with interceptors is available.
class SimpleApiService {
  static const String _baseUrl = 'http://localhost:8000';
  late final Dio _dio;

  SimpleApiService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json'},
      ),
    );
  }

  Future<Response?> post(String path, {Object? data}) async {
    try {
      return await _dio.post(path, data: data);
    } catch (e) {
      print('Simple API POST error: $e');
      return null;
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }
}
