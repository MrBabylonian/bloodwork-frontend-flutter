import '../api/api_service.dart';
import '../providers/auth_provider.dart';
import '../repositories/analysis_repository.dart';
import '../repositories/auth_repository.dart';
import '../repositories/patient_repository.dart';
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

  // Repositories
  AuthRepository? _authRepository;
  AnalysisRepository? _analysisRepository;
  PatientRepository? _patientRepository;

  // Providers
  AuthProvider? _authProvider;

  /// Initialize all services in the correct order
  Future<void> initialize() async {
    // Initialize storage service first
    _storageService = StorageService();

    // Create auth repository (will create its own simple ApiService initially)
    _authRepository = AuthRepository();

    // Create auth provider
    _authProvider = AuthProvider(authRepository: _authRepository);

    // Initialize auth provider
    await _authProvider!.initialize();

    // Now create the full ApiService with interceptors
    _apiService = ApiService(
      storageService: _storageService!,
      authProvider: _authProvider!,
    );

    // Update repositories to use the full ApiService
    _analysisRepository = AnalysisRepository(apiService: _apiService!);
    _patientRepository = PatientRepository(apiService: _apiService!);
  }

  // Getters
  StorageService get storageService => _storageService!;
  ApiService get apiService => _apiService!;
  AuthRepository get authRepository => _authRepository!;
  AnalysisRepository get analysisRepository => _analysisRepository!;
  PatientRepository get patientRepository => _patientRepository!;
  AuthProvider get authProvider => _authProvider!;
}
