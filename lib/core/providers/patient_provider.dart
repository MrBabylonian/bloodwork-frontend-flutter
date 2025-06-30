import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/patient_models.dart';
import '../api/api_service.dart';
import '../services/service_locator.dart';

enum PatientStatus { loading, loaded, error, empty }

class PatientProvider extends ChangeNotifier {
  final ApiService _apiService = ServiceLocator().apiService;
  final Logger _logger = Logger();

  PatientProvider();

  // State
  PatientStatus _status = PatientStatus.empty;
  List<PatientModel> _patients = [];
  String? _errorMessage;

  // Pagination state
  int _currentPage = 1;
  int _limit = 10;
  int _totalPatients = 0;
  bool _hasMorePages = false;
  bool _isLoadingMore = false;

  // Getters
  PatientStatus get status => _status;
  List<PatientModel> get patients => _patients;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PatientStatus.loading;
  bool get hasError => _status == PatientStatus.error;
  bool get isEmpty => _status == PatientStatus.empty;

  // Pagination getters
  int get currentPage => _currentPage;
  int get limit => _limit;
  int get totalPatients => _totalPatients;
  bool get hasMorePages => _hasMorePages;
  bool get isLoadingMore => _isLoadingMore;

  /// Load patients with pagination
  Future<void> loadPatients({bool reset = false}) async {
    try {
      if (reset) {
        _currentPage = 1;
        _logger.d('🏥 PROVIDER: Resetting pagination and loading patients');
        _setStatus(PatientStatus.loading);
      } else {
        _logger.d('🏥 PROVIDER: Loading patients (page $_currentPage)');
        if (_currentPage == 1) {
          _setStatus(PatientStatus.loading);
        }
      }

      final response = await _apiService.getPatients(
        page: _currentPage,
        limit: _limit,
      );

      // Update pagination state
      _totalPatients = response.total;

      // Calculate if there are more pages
      _hasMorePages = (_currentPage * _limit) < response.total;

      // Update patients list
      if (reset || _currentPage == 1) {
        _patients = response.patients;
      } else {
        _patients.addAll(response.patients);
      }

      _setStatus(
        response.patients.isEmpty && _patients.isEmpty
            ? PatientStatus.empty
            : PatientStatus.loaded,
      );

      _logger.d(
        '🏥 PROVIDER: Loaded ${response.patients.length} patients ' +
            '(page $_currentPage of ${(response.total + _limit - 1) ~/ _limit})',
      );
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error loading patients: $e');
      _setError('Failed to load patients');
    }
  }

  /// Load next page of patients
  Future<void> loadMorePatients() async {
    if (!_hasMorePages || _isLoadingMore) return;

    _isLoadingMore = true;
    notifyListeners();

    _currentPage++;
    await loadPatients();

    _isLoadingMore = false;
    notifyListeners();
  }

  /// Search patients with pagination
  Future<void> searchPatients(String query, {bool reset = false}) async {
    if (query.isEmpty) {
      await loadPatients(reset: true);
      return;
    }

    try {
      if (reset) {
        _currentPage = 1;
        _logger.d(
          '🏥 PROVIDER: Resetting pagination and searching patients: $query',
        );
        _setStatus(PatientStatus.loading);
      } else {
        _logger.d(
          '🏥 PROVIDER: Searching patients: $query (page $_currentPage)',
        );
        if (_currentPage == 1) {
          _setStatus(PatientStatus.loading);
        }
      }

      final response = await _apiService.searchPatients(
        query,
        page: _currentPage,
        limit: _limit,
      );

      // Update pagination state
      _totalPatients = response.total;

      // Calculate if there are more pages
      _hasMorePages = (_currentPage * _limit) < response.total;

      // Update patients list
      if (reset || _currentPage == 1) {
        _patients = response.patients;
      } else {
        _patients.addAll(response.patients);
      }

      _setStatus(
        response.patients.isEmpty && _patients.isEmpty
            ? PatientStatus.empty
            : PatientStatus.loaded,
      );

      _logger.d(
        '🏥 PROVIDER: Found ${response.patients.length} patients matching "$query" ' +
            '(page $_currentPage of ${(response.total + _limit - 1) ~/ _limit})',
      );
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error searching patients: $e');
      _setError('Failed to search patients');
    }
  }

  /// Filter patients locally
  List<PatientModel> filterPatients(String query) {
    if (query.isEmpty) return _patients;

    final lowerQuery = query.toLowerCase();
    return _patients.where((patient) {
      return patient.name.toLowerCase().contains(lowerQuery) ||
          patient.ownerInfo.name.toLowerCase().contains(lowerQuery) ||
          patient.breed.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// Refresh patients
  Future<void> refresh() async {
    await loadPatients(reset: true);
  }

  /// Create new patient
  Future<bool> createPatient(PatientCreateRequest request) async {
    try {
      _logger.d('🏥 PROVIDER: Creating patient: ${request.name}');
      _setStatus(PatientStatus.loading);

      final patient = await _apiService.createPatient(request);

      if (patient != null) {
        // Add to local list and update state
        _patients.add(patient);
        _setStatus(PatientStatus.loaded);
        _logger.d('🏥 PROVIDER: Successfully created patient: ${patient.name}');
        return true;
      } else {
        _setError('Failed to create patient');
        return false;
      }
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error creating patient: $e');
      _setError('Failed to create patient: $e');
      return false;
    }
  }

  /// Get patient by ID
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      return await _apiService.getPatientById(patientId);
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error getting patient: $e');
      return null;
    }
  }

  /// Update existing patient
  Future<bool> updatePatient(
    String patientId,
    PatientUpdateRequest request,
  ) async {
    try {
      _logger.d('🏥 PROVIDER: Updating patient: $patientId');

      final updatedPatient = await _apiService.updatePatient(
        patientId,
        request,
      );

      if (updatedPatient != null) {
        // Update local list if exists
        final index = _patients.indexWhere(
          (p) => p.id == patientId || p.patientId == patientId,
        );
        if (index != -1) {
          _patients[index] = updatedPatient;
        }
        notifyListeners();
        return true;
      } else {
        _setError('Failed to update patient');
        return false;
      }
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error updating patient $patientId: $e');
      _setError('Failed to update patient');
      return false;
    }
  }

  // Private methods
  void _setStatus(PatientStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _clearError();
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = PatientStatus.error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _logger.d('🏥 PROVIDER: Disposing');
    super.dispose();
  }
}
