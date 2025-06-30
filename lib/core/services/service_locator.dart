import '../api/api_service.dart';
import '../providers/auth_provider.dart';
import '../services/storage_service.dart';

/// Service locator for dependency injection
///
/// This provides a clean, production-grade way to manage dependencies
/// and avoid circular dependencies in the authentication system.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  // Core services
  StorageService? _storageService;
  ApiService? _apiService;

  // Providers
  AuthProvider? _authProvider;

  /// Initialize all services in the correct order
  Future<void> initialize() async {
    // Initialize storage service first
    _storageService = StorageService();

    // Create auth provider (no repository needed)
    _authProvider = AuthProvider();

    // Now create the full ApiService with interceptors
    _apiService = ApiService(
      storageService: _storageService!,
      authProvider: _authProvider!,
    );

    // Inject ApiService into AuthProvider to break circular dependency
    _authProvider!.setApiService(_apiService!);

    // Initialize auth provider (now that ApiService is ready)
    await _authProvider!.initialize();
  }

  // Getters
  StorageService get storageService => _storageService!;
  ApiService get apiService => _apiService!;
  AuthProvider get authProvider => _authProvider!;
}
