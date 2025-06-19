import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../api/api_service.dart';
import '../services/storage_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final ApiService _apiService;
  final StorageService _storageService;
  final Logger _logger = Logger();

  AuthRepository({ApiService? apiService, StorageService? storageService})
    : _apiService = apiService ?? ApiService(),
      _storageService = storageService ?? StorageService();

  // Login user
  Future<LoginResponse?> login({
    required String username,
    required String password,
  }) async {
    try {
      _logger.d('Attempting login for user: $username');

      final loginRequest = LoginRequest(username: username, password: password);

      final response = await _apiService.post(
        '/api/v1/auth/login',
        data: loginRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response.data);

        // Save authentication data
        await _storageService.saveAuthData(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          user: loginResponse.user,
          expiresIn: loginResponse.expiresIn,
        );

        // Set token in API service for future requests
        _apiService.setAuthToken(loginResponse.accessToken);

        _logger.d('Login successful for user: $username');
        return loginResponse;
      } else {
        _logger.w('Login failed with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _logger.e('Login API error: ${e.message}');

      if (e.response?.statusCode == 401) {
        _logger.w('Invalid credentials for user: $username');
      }

      return null;
    } catch (e) {
      _logger.e('Unexpected error during login: $e');
      return null;
    }
  }

  // Logout user
  Future<bool> logout() async {
    try {
      _logger.d('Attempting logout');

      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Call backend logout endpoint
          final logoutRequest = RefreshTokenRequest(refreshToken: refreshToken);

          await _apiService.post(
            '/api/v1/auth/logout',
            data: logoutRequest.toJson(),
          );
        } catch (e) {
          // Continue with local logout even if backend call fails
          _logger.w('Backend logout failed, continuing with local logout: $e');
        }
      }

      // Clear local authentication data
      await _storageService.clearAuthData();

      // Clear token from API service
      _apiService.clearAuthToken();

      _logger.d('Logout successful');
      return true;
    } catch (e) {
      _logger.e('Error during logout: $e');
      return false;
    }
  }

  // Refresh access token
  Future<bool> refreshToken() async {
    try {
      _logger.d('Attempting token refresh');

      final refreshToken = await _storageService.getRefreshToken();

      if (refreshToken == null) {
        _logger.w('No refresh token available');
        return false;
      }

      final refreshRequest = RefreshTokenRequest(refreshToken: refreshToken);

      final response = await _apiService.post(
        '/api/v1/auth/refresh',
        data: refreshRequest.toJson(),
      );

      if (response.statusCode == 200) {
        final refreshResponse = RefreshTokenResponse.fromJson(response.data);

        // Update access token
        await _storageService.updateAccessToken(
          accessToken: refreshResponse.accessToken,
          expiresIn: refreshResponse.expiresIn,
        );

        // Update token in API service
        _apiService.setAuthToken(refreshResponse.accessToken);

        _logger.d('Token refresh successful');
        return true;
      } else {
        _logger.w('Token refresh failed with status: ${response.statusCode}');
        return false;
      }
    } on DioException catch (e) {
      _logger.e('Token refresh API error: ${e.message}');

      if (e.response?.statusCode == 401) {
        _logger.w('Refresh token expired, logout required');
        await logout();
      }

      return false;
    } catch (e) {
      _logger.e('Unexpected error during token refresh: $e');
      return false;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final isLoggedIn = await _storageService.isLoggedIn();

      if (!isLoggedIn) {
        return false;
      }

      // Check if token is expired
      final isExpired = await _storageService.isTokenExpired();

      if (isExpired) {
        _logger.d('Token expired, attempting refresh');
        final refreshSuccess = await refreshToken();
        return refreshSuccess;
      }

      // Set token in API service if we have a valid token
      final accessToken = await _storageService.getAccessToken();
      if (accessToken != null) {
        _apiService.setAuthToken(accessToken);
      }

      return true;
    } catch (e) {
      _logger.e('Error checking authentication status: $e');
      return false;
    }
  }

  // Get current user data
  Future<UserModel?> getCurrentUser() async {
    try {
      return await _storageService.getUserData();
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  // Initialize authentication (call this on app start)
  Future<bool> initializeAuth() async {
    try {
      _logger.d('Initializing authentication');

      final isAuth = await isAuthenticated();

      if (isAuth) {
        _logger.d('User is authenticated');
        return true;
      } else {
        _logger.d('User is not authenticated');
        return false;
      }
    } catch (e) {
      _logger.e('Error initializing authentication: $e');
      return false;
    }
  }

  // Register new user
  Future<RegistrationResponse?> register({
    required String username,
    required String email,
    required String password,
    required UserRole role,
    required UserProfile profile,
  }) async {
    try {
      _logger.d('Attempting registration for user: $username');

      final registrationRequest = RegistrationRequest(
        username: username,
        email: email,
        password: password,
        role: role,
        profile: profile.toJson(),
      );

      final response = await _apiService.post(
        '/api/v1/auth/register',
        data: registrationRequest.toJson(),
      );

      if (response.statusCode == 201) {
        _logger.d('Registration successful for user: $username');
        return RegistrationResponse.fromJson(response.data);
      } else {
        _logger.w('Registration failed with status: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      _logger.e('Registration API error: ${e.message}');

      if (e.response?.statusCode == 400) {
        _logger.w('Username or email already exists for user: $username');
      }

      return null;
    } catch (e) {
      _logger.e('Unexpected error during registration: $e');
      return null;
    }
  }
}
