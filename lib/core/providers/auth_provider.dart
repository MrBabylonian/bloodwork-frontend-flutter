import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../repositories/auth_repository.dart';
import '../models/auth_models.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final Logger _logger = Logger();

  AuthProvider({AuthRepository? authRepository})
    : _authRepository = authRepository ?? AuthRepository();

  // Private state variables
  AuthStatus _status = AuthStatus.initial;
  UserModel? _currentUser;
  String? _errorMessage;

  // Public getters
  AuthStatus get status => _status;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  // Initialize authentication (call on app start)
  Future<void> initialize() async {
    try {
      _logger.d('Initializing authentication provider');
      _setStatus(AuthStatus.loading);

      final isAuth = await _authRepository.initializeAuth();

      if (isAuth) {
        final user = await _authRepository.getCurrentUser();
        _currentUser = user;
        _setStatus(AuthStatus.authenticated);
        _logger.d('User is authenticated: ${user?.username}');
      } else {
        _setStatus(AuthStatus.unauthenticated);
        _logger.d('User is not authenticated');
      }
    } catch (e) {
      _logger.e('Error initializing auth: $e');
      _setError('Failed to initialize authentication');
    }
  }

  // Login user
  Future<bool> login({
    required String username,
    required String password,
  }) async {
    try {
      _logger.d('🔐 AUTH: Starting login for: $username');

      // STEP 1: Set loading state and clear errors
      _setStatus(AuthStatus.loading);
      _clearError();

      final loginResponse = await _authRepository.login(
        username: username,
        password: password,
      );

      if (loginResponse != null) {
        // STEP 2: Login successful - set authenticated state
        _currentUser = loginResponse.user;
        _setStatus(AuthStatus.authenticated);
        _logger.d('🔐 AUTH: Login successful for: $username');
        return true;
      } else {
        // STEP 3: Login failed - set unauthenticated state
        _setError('Invalid username or password');
        _setStatus(AuthStatus.unauthenticated);
        _logger.d('🔐 AUTH: Login failed - invalid credentials');
        return false;
      }
    } catch (e) {
      // STEP 4: Login error - set unauthenticated state
      _logger.e('🔐 AUTH: Login error: $e');
      _setError('Login failed. Please try again.');
      _setStatus(AuthStatus.unauthenticated);
      return false;
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      _logger.d('🔐 AUTH: Starting logout');

      // STEP 1: Set loading state
      _setStatus(AuthStatus.loading);

      final success = await _authRepository.logout();

      if (success) {
        // STEP 2: Logout successful - clear state and set unauthenticated
        _currentUser = null;
        _setStatus(AuthStatus.unauthenticated);
        _clearError();
        _logger.d('🔐 AUTH: Logout successful');
      } else {
        // STEP 3: Logout failed but clear local state anyway
        _logger.w('🔐 AUTH: Logout failed, but clearing local state');
        _currentUser = null;
        _setStatus(AuthStatus.unauthenticated);
        _clearError();
      }
    } catch (e) {
      // STEP 4: Logout error - still clear local state
      _logger.e('🔐 AUTH: Logout error: $e');
      _currentUser = null;
      _setStatus(AuthStatus.unauthenticated);
      _clearError();
    }
  }

  // Refresh token
  Future<bool> refreshToken() async {
    try {
      _logger.d('Refreshing token');

      final success = await _authRepository.refreshToken();

      if (!success) {
        _logger.w('Token refresh failed, logging out');
        await logout();
        return false;
      }

      return true;
    } catch (e) {
      _logger.e('Token refresh error: $e');
      await logout();
      return false;
    }
  }

  // Check authentication status
  Future<bool> checkAuthStatus() async {
    try {
      final isAuth = await _authRepository.isAuthenticated();

      if (isAuth && _status != AuthStatus.authenticated) {
        final user = await _authRepository.getCurrentUser();
        _currentUser = user;
        _setStatus(AuthStatus.authenticated);
      } else if (!isAuth && _status == AuthStatus.authenticated) {
        _currentUser = null;
        _setStatus(AuthStatus.unauthenticated);
      }

      return isAuth;
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      return false;
    }
  }

  // Get user role
  String? get userRole => _currentUser?.role;

  // Check if user has specific role
  bool hasRole(String role) {
    return _currentUser?.role == role;
  }

  // Check if user is admin
  bool get isAdmin => hasRole('admin');

  // Check if user is veterinarian
  bool get isVeterinarian => hasRole('veterinarian');

  // Check if user is technician
  bool get isTechnician => hasRole('veterinary_technician');

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

      // STEP 1: Set loading state and clear errors
      _setStatus(AuthStatus.loading);
      _clearError();

      final response = await _authRepository.register(
        username: username,
        email: email,
        password: password,
        role: role,
        profile: profile,
      );

      if (response != null) {
        // STEP 2: Registration successful - stay unauthenticated (pending approval)
        _setStatus(AuthStatus.unauthenticated);
        _logger.d('🔐 AUTH: Registration successful for user: $username');
        return response;
      } else {
        // STEP 3: Registration failed - set unauthenticated state with error
        _setError('Registration failed. Username or email may already exist.');
        _setStatus(AuthStatus.unauthenticated);
        _logger.d('🔐 AUTH: Registration failed - username/email conflict');
        return null;
      }
    } catch (e) {
      // STEP 4: Registration error - set unauthenticated state with error
      _logger.e('🔐 AUTH: Registration error: $e');
      _setError('Registration failed. Please try again.');
      _setStatus(AuthStatus.unauthenticated);
      return null;
    }
  }

  // Private helper methods
  void _setStatus(AuthStatus newStatus) {
    if (_status != newStatus) {
      print('🔐 AUTH PROVIDER: Status changing from $_status to $newStatus');
      _status = newStatus;
      print('🔐 AUTH PROVIDER: isAuthenticated = $isAuthenticated');
      notifyListeners();
      print(
        '🔐 AUTH PROVIDER: notifyListeners() called - router should refresh',
      );
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _setStatus(AuthStatus.error);
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Reset error state
  void clearError() {
    _clearError();
    if (_status == AuthStatus.error) {
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> profileData) async {
    try {
      if (_currentUser == null) {
        _logger.e('Cannot update profile: No user logged in');
        return false;
      }

      final success = await _authRepository.updateProfile(
        userId: _currentUser!.id,
        profileData: profileData,
      );

      if (success) {
        // Refresh current user data
        final user = await _authRepository.getCurrentUser();
        _currentUser = user;
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      _logger.e('Error updating profile: $e');
      return false;
    }
  }

  // Update password
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final success = await _authRepository.updatePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return success;
    } catch (e) {
      _logger.e('Error updating password: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _logger.d('Disposing AuthProvider');
    super.dispose();
  }
}
