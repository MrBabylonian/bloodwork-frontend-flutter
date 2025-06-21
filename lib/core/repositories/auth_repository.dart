import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../api/simple_api_service.dart';
import '../services/storage_service.dart';
import '../models/auth_models.dart';

class AuthRepository {
  final SimpleApiService _apiService;
  final StorageService _storageService;
  final Logger _logger = Logger();

  AuthRepository({SimpleApiService? apiService, StorageService? storageService})
    : _apiService = apiService ?? SimpleApiService(),
      _storageService = storageService ?? StorageService();

  // Login user
  /// Returns a LoginResponse with user data including human-readable ID (e.g., VET-001)
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

      if (response?.statusCode == 200) {
        final loginResponse = LoginResponse.fromJson(response!.data);

        // Save authentication data
        await _storageService.saveAuthData(
          accessToken: loginResponse.accessToken,
          refreshToken: loginResponse.refreshToken,
          user: loginResponse.user,
          expiresIn: loginResponse.expiresIn,
        );

        // Set token in API service for future requests
        _apiService.setAuthToken(loginResponse.accessToken);

        _logger.d(
          'Login successful for user: $username with ID: ${loginResponse.user.id}',
        );
        return loginResponse;
      } else {
        _logger.w('Login failed with status: ${response?.statusCode}');
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

      if (response?.statusCode == 200) {
        final refreshResponse = RefreshTokenResponse.fromJson(response!.data);

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
        _logger.w('Token refresh failed with status: ${response?.statusCode}');
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
  /// Returns a UserModel with human-readable ID (e.g., VET-001)
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
  /// Returns a RegistrationResponse with human-readable user ID (e.g., VET-001)
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

      if (response?.statusCode == 201) {
        final registrationResponse = RegistrationResponse.fromJson(
          response!.data,
        );
        _logger.d(
          'Registration successful for user: $username with ID: ${registrationResponse.userId}',
        );
        return registrationResponse;
      } else {
        _logger.w('Registration failed with status: ${response?.statusCode}');
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

  // Update user profile
  /// Updates the user profile and returns success status
  Future<bool> updateProfile({
    required String userId,
    required Map<String, dynamic> profileData,
  }) async {
    try {
      _logger.d('Updating profile for user: $userId');

      // The backend expects direct field values, not nested under 'profile'
      final response = await _apiService.put(
        '/api/v1/auth/profile',
        data: profileData,
      );

      if (response?.statusCode == 200) {
        // Update local user data
        final currentUser = await _storageService.getUserData();
        if (currentUser != null) {
          // Update the profile in the user model
          final updatedProfile = {...currentUser.profile};
          profileData.forEach((key, value) {
            updatedProfile[key] = value;
          });

          final updatedUser = UserModel(
            id: currentUser.id,
            username: currentUser.username,
            email: currentUser.email,
            role: currentUser.role,
            profile: updatedProfile,
          );
          await _storageService.saveUserData(updatedUser);
        }

        _logger.d('Profile updated successfully for user: $userId');
        return true;
      } else {
        _logger.w('Profile update failed with status: ${response?.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
      return false;
    }
  }

  // Update password
  /// Updates the user password and returns success status
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      _logger.d('Attempting to update password');

      final response = await _apiService.put(
        '/api/v1/auth/password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (response?.statusCode == 200) {
        _logger.d('Password updated successfully');
        return true;
      } else {
        _logger.w(
          'Password update failed with status: ${response?.statusCode}',
        );
        return false;
      }
    } catch (e) {
      _logger.e('Error updating password: $e');
      return false;
    }
  }
}
