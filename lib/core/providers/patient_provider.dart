import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../repositories/patient_repository.dart';
import '../models/patient_models.dart';
import '../services/service_locator.dart';

enum PatientStatus { loading, loaded, error, empty }

class PatientProvider extends ChangeNotifier {
  final PatientRepository _patientRepository;
  final Logger _logger = Logger();

  PatientProvider({PatientRepository? patientRepository})
    : _patientRepository =
          patientRepository ?? ServiceLocator().patientRepository;

  // State
  PatientStatus _status = PatientStatus.empty;
  List<PatientModel> _patients = [];
  String? _errorMessage;

  // Getters
  PatientStatus get status => _status;
  List<PatientModel> get patients => _patients;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == PatientStatus.loading;
  bool get hasError => _status == PatientStatus.error;
  bool get isEmpty => _status == PatientStatus.empty;

  /// Load all patients
  Future<void> loadPatients() async {
    try {
      _logger.d('🏥 PROVIDER: Loading patients');
      _setStatus(PatientStatus.loading);

      final patients = await _patientRepository.getAllPatients();

      _patients = patients;
      _setStatus(patients.isEmpty ? PatientStatus.empty : PatientStatus.loaded);
      _logger.d('🏥 PROVIDER: Loaded ${patients.length} patients');
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error loading patients: $e');
      _setError('Failed to load patients');
    }
  }

  /// Search patients
  Future<void> searchPatients(String query) async {
    if (query.isEmpty) {
      await loadPatients();
      return;
    }

    try {
      _logger.d('🏥 PROVIDER: Searching patients: $query');
      _setStatus(PatientStatus.loading);

      final patients = await _patientRepository.searchPatients(query);

      _patients = patients;
      _setStatus(patients.isEmpty ? PatientStatus.empty : PatientStatus.loaded);
      _logger.d('🏥 PROVIDER: Found ${patients.length} patients');
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
    await loadPatients();
  }

  /// Create new patient
  Future<bool> createPatient(PatientCreateRequest request) async {
    try {
      _logger.d('🏥 PROVIDER: Creating patient: ${request.name}');
      _setStatus(PatientStatus.loading);

      final patient = await _patientRepository.createPatient(request);

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
      return await _patientRepository.getPatientById(patientId);
    } catch (e) {
      _logger.e('🏥 PROVIDER: Error getting patient: $e');
      return null;
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
