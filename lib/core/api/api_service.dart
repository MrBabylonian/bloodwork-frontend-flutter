import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:file_picker/file_picker.dart';

import '../interceptors/auth_interceptor.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';
import '../models/auth_models.dart';
import '../models/patient_models.dart';
import '../models/analysis_models.dart';

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
  final StorageService _storageService;

  ApiService({
    required StorageService storageService,
    required AuthProvider authProvider,
  }) : _storageService = storageService {
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

  // -------------------------
  // AUTH ENDPOINTS (high-level)
  // -------------------------

  Future<LoginResponse?> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await post(
        '/api/v1/auth/login',
        data: LoginRequest(username: username, password: password).toJson(),
      );

      if (response.statusCode == 200) {
        final loginResp = LoginResponse.fromJson(response.data);

        // Persist tokens & user data
        await _storageService.saveAuthData(
          accessToken: loginResp.accessToken,
          refreshToken: loginResp.refreshToken,
          user: loginResp.user,
          expiresIn: loginResp.expiresIn,
        );

        // Set auth header for subsequent requests
        _dio.options.headers['Authorization'] =
            'Bearer ${loginResp.accessToken}';

        return loginResp;
      }
      _logger.w('Login failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      _logger.e('Login error: ${e.message}');
      return null;
    }
  }

  Future<bool> logout() async {
    try {
      final refresh = await _storageService.getRefreshToken();
      if (refresh != null) {
        await post('/api/v1/auth/logout', data: {'refresh_token': refresh});
      }

      await _storageService.clearAuthData();
      _dio.options.headers.remove('Authorization');
      return true;
    } catch (e) {
      _logger.e('Logout error: $e');
      return false;
    }
  }

  Future<bool> refreshToken() async {
    try {
      final refresh = await _storageService.getRefreshToken();
      if (refresh == null) return false;

      final response = await post(
        '/api/v1/auth/refresh',
        data: {'refresh_token': refresh},
      );

      if (response.statusCode == 200) {
        final refreshResp = RefreshTokenResponse.fromJson(response.data);
        await _storageService.updateAccessToken(
          accessToken: refreshResp.accessToken,
          expiresIn: refreshResp.expiresIn,
        );
        _dio.options.headers['Authorization'] =
            'Bearer ${refreshResp.accessToken}';
        return true;
      }
      _logger.w('Token refresh failed: ${response.statusCode}');
      return false;
    } on DioException catch (e) {
      _logger.e('Token refresh dio error: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      return false;
    }
  }

  Future<bool> isAuthenticated() async {
    final loggedIn = await _storageService.isLoggedIn();
    if (!loggedIn) return false;

    final expired = await _storageService.isTokenExpired();
    if (expired) {
      _logger.d('Access token expired, attempting refresh');
      return await refreshToken();
    }

    final access = await _storageService.getAccessToken();
    if (access != null) {
      _dio.options.headers['Authorization'] = 'Bearer $access';
    }
    return true;
  }

  Future<UserModel?> getCurrentUser() async {
    return _storageService.getUserData();
  }

  Future<bool> initializeAuth() async {
    return isAuthenticated();
  }

  Future<RegistrationResponse?> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    required UserProfile profile,
  }) async {
    try {
      final response = await post(
        '/api/v1/auth/register',
        data:
            RegistrationRequest(
              username: username,
              email: email,
              password: password,
              role: role,
              profile: profile.toJson(),
            ).toJson(),
      );

      if (response.statusCode == 201) {
        return RegistrationResponse.fromJson(response.data);
      }
      _logger.w('Register failed: ${response.statusCode}');
      return null;
    } on DioException catch (e) {
      _logger.e('Register dio error: ${e.message}');
      return null;
    }
  }

  Future<bool> updateProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      final response = await put('/api/v1/auth/profile', data: profileData);
      if (response.statusCode == 200) {
        // Update locally
        final current = await _storageService.getUserData();
        if (current != null) {
          final updatedProfile = {...current.profile, ...profileData};
          final updatedUser = UserModel(
            id: current.id,
            username: current.username,
            email: current.email,
            role: current.role,
            profile: updatedProfile,
          );
          await _storageService.saveUserData(updatedUser);
        }
        return true;
      }
      return false;
    } catch (e) {
      _logger.e('Update profile error: $e');
      return false;
    }
  }

  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await put(
        '/api/v1/auth/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      _logger.e('Update password error: $e');
      return false;
    }
  }

  // -------------------------
  // PATIENT ENDPOINTS
  // -------------------------

  Future<PatientListResponse> getPatients({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await get(
      '/api/v1/patients/',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PatientListResponse.fromJson(response.data);
  }

  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      final response = await get('/api/v1/patients/$patientId');
      return PatientModel.fromJson(response.data);
    } catch (e) {
      _logger.e('Get patient error: $e');
      return null;
    }
  }

  Future<PatientModel?> createPatient(PatientCreateRequest request) async {
    try {
      final response = await post('/api/v1/patients/', data: request.toJson());
      return PatientModel.fromJson(response.data);
    } catch (e) {
      _logger.e('Create patient error: $e');
      return null;
    }
  }

  Future<PatientModel?> updatePatient(
    String patientId,
    PatientUpdateRequest request,
  ) async {
    try {
      final response = await put(
        '/api/v1/patients/$patientId',
        data: request.toJson(),
      );
      return PatientModel.fromJson(response.data);
    } catch (e) {
      _logger.e('Update patient error: $e');
      return null;
    }
  }

  Future<bool> deletePatient(String patientId) async {
    try {
      await delete('/api/v1/patients/$patientId');
      return true;
    } catch (e) {
      _logger.e('Delete patient error: $e');
      return false;
    }
  }

  Future<PatientListResponse> searchPatients(
    String name, {
    int page = 1,
    int limit = 10,
  }) async {
    final response = await get(
      '/api/v1/patients/search/$name',
      queryParameters: {'page': page, 'limit': limit},
    );
    return PatientListResponse.fromJson(response.data);
  }

  // -------------------------
  // ANALYSIS ENDPOINTS
  // -------------------------

  Future<AnalysisUploadResponse?> uploadPdf({
    required PlatformFile file,
    String? patientId,
    String? notes,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
          contentType: DioMediaType('application', 'pdf'),
        ),
        if (patientId != null) 'patient_id': patientId,
        if (notes != null) 'notes': notes,
      });

      final response = await post('/api/v1/analysis/upload', data: formData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AnalysisUploadResponse.fromJson(response.data);
      }
      _logger.e('Upload PDF failed: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.e('Upload PDF error: $e');
      return null;
    }
  }

  Future<bool> hasPendingAnalysis(String patientId) async {
    try {
      final response = await get(
        '/api/v1/diagnostics/patient/$patientId/pending',
      );
      if (response.statusCode == 200) {
        return response.data['has_pending_analysis'] as bool;
      }
      return false;
    } catch (e) {
      _logger.e('Pending analysis check error: $e');
      return false;
    }
  }

  Future<AnalysisResult?> getLatestAnalysis(String patientId) async {
    try {
      final response = await get(
        '/api/v1/diagnostics/patient/$patientId/latest',
      );
      if (response.statusCode == 200) {
        return AnalysisResult.fromJson(response.data);
      }
      return null;
    } catch (e) {
      _logger.e('Get latest analysis error: $e');
      return null;
    }
  }

  Future<int> getTestsCount(String patientId) async {
    try {
      final response = await get(
        '/api/v1/diagnostics/patient/$patientId/tests-count',
      );
      return (response.data as num).toInt();
    } catch (e) {
      _logger.e('Get tests count error: $e');
      return 0;
    }
  }
}
