import 'package:dio/dio.dart';

import '../services/storage_service.dart';
import '../providers/auth_provider.dart';

/// HTTP interceptor that automatically injects Authorization headers
/// into all API requests. This provides a clean, production-grade
/// solution for handling authentication across the entire app.
///
/// Features:
/// - Automatic header injection for all requests
/// - Token refresh on 401 errors
/// - Clean separation of concerns
/// - Production-ready error handling
class AuthInterceptor extends Interceptor {
  final StorageService _storageService;
  final AuthProvider _authProvider;

  AuthInterceptor({
    required StorageService storageService,
    required AuthProvider authProvider,
  }) : _storageService = storageService,
       _authProvider = authProvider;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get current access token
      final accessToken = await _storageService.getAccessToken();

      if (accessToken != null && accessToken.isNotEmpty) {
        // Inject Authorization header
        options.headers['Authorization'] = 'Bearer $accessToken';

        // Debug logging
        print(
          '[AuthInterceptor] Injected auth header for: ${options.method} ${options.path}',
        );
      } else {
        print(
          '[AuthInterceptor] No access token available for: ${options.method} ${options.path}',
        );
      }

      handler.next(options);
    } catch (e) {
      print('[AuthInterceptor] Error injecting auth header: $e');
      handler.next(options);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized errors with automatic token refresh
    if (err.response?.statusCode == 401) {
      print('[AuthInterceptor] 401 error detected, attempting token refresh');

      try {
        // Attempt to refresh the token
        final refreshed = await _authProvider.refreshToken();

        if (refreshed) {
          // Retry the original request with new token
          final response = await _retryRequest(err.requestOptions);
          handler.resolve(response);
          return;
        } else {
          // Refresh failed, user needs to login again
          print('[AuthInterceptor] Token refresh failed, logging out user');
          await _authProvider.logout();
        }
      } catch (e) {
        print('[AuthInterceptor] Error during token refresh: $e');
        await _authProvider.logout();
      }
    }

    handler.next(err);
  }

  /// Retry the original request with fresh authentication token
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    // Get fresh token
    final accessToken = await _storageService.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Create new Dio instance to avoid interceptor loops
    final dio = Dio();

    return await dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
        contentType: requestOptions.contentType,
        responseType: requestOptions.responseType,
        followRedirects: requestOptions.followRedirects,
        maxRedirects: requestOptions.maxRedirects,
        receiveTimeout: requestOptions.receiveTimeout,
        sendTimeout: requestOptions.sendTimeout,
      ),
    );
  }
}
