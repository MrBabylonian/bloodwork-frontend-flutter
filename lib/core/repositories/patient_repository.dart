import 'package:logger/logger.dart';
import '../api/api_service.dart';
import '../models/patient_models.dart';
import '../services/storage_service.dart';

class PatientRepository {
  final ApiService _apiService;
  final StorageService _storageService;
  final Logger _logger = Logger();

  PatientRepository({ApiService? apiService, StorageService? storageService})
    : _apiService = apiService ?? ApiService(),
      _storageService = storageService ?? StorageService();

  /// Get all patients
  Future<List<PatientModel>> getAllPatients() async {
    try {
      _logger.d('🏥 Fetching all patients');
      await _setAuthToken();

      final response = await _apiService.get('/api/v1/patients/');
      final List<dynamic> patientsJson = response.data;

      final patients =
          patientsJson.map((json) => PatientModel.fromJson(json)).toList();

      _logger.d('🏥 Successfully fetched ${patients.length} patients');
      return patients;
    } catch (e) {
      _logger.e('🏥 Error fetching patients: $e');
      throw Exception('Failed to fetch patients: $e');
    }
  }

  /// Get patient by ID
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      _logger.d('🏥 Fetching patient with ID: $patientId');
      await _setAuthToken();

      final response = await _apiService.get('/api/v1/patients/$patientId');
      final patient = PatientModel.fromJson(response.data);

      _logger.d('🏥 Successfully fetched patient: ${patient.name}');
      return patient;
    } catch (e) {
      _logger.e('🏥 Error fetching patient $patientId: $e');
      return null;
    }
  }

  /// Create new patient
  Future<PatientModel?> createPatient(PatientCreateRequest request) async {
    try {
      _logger.d('🏥 Creating patient: ${request.name}');
      await _setAuthToken();

      final response = await _apiService.post(
        '/api/v1/patients/',
        data: request.toJson(),
      );

      final patient = PatientModel.fromJson(response.data);
      _logger.d('🏥 Successfully created patient: ${patient.name}');
      return patient;
    } catch (e) {
      _logger.e('🏥 Error creating patient: $e');
      throw Exception('Failed to create patient: $e');
    }
  }

  /// Update patient
  Future<PatientModel?> updatePatient(
    String patientId,
    PatientUpdateRequest request,
  ) async {
    try {
      _logger.d('🏥 Updating patient: $patientId');
      await _setAuthToken();

      final response = await _apiService.put(
        '/api/v1/patients/$patientId',
        data: request.toJson(),
      );

      final patient = PatientModel.fromJson(response.data);
      _logger.d('🏥 Successfully updated patient: ${patient.name}');
      return patient;
    } catch (e) {
      _logger.e('🏥 Error updating patient $patientId: $e');
      throw Exception('Failed to update patient: $e');
    }
  }

  /// Delete patient
  Future<bool> deletePatient(String patientId) async {
    try {
      _logger.d('🏥 Deleting patient: $patientId');
      await _setAuthToken();

      await _apiService.delete('/api/v1/patients/$patientId');

      _logger.d('🏥 Successfully deleted patient: $patientId');
      return true;
    } catch (e) {
      _logger.e('🏥 Error deleting patient $patientId: $e');
      return false;
    }
  }

  /// Search patients by name
  Future<List<PatientModel>> searchPatients(String name) async {
    try {
      _logger.d('🏥 Searching patients with name: $name');
      await _setAuthToken();

      final response = await _apiService.get('/api/v1/patients/search/$name');
      final List<dynamic> patientsJson = response.data;

      final patients =
          patientsJson.map((json) => PatientModel.fromJson(json)).toList();

      _logger.d('🏥 Found ${patients.length} patients matching: $name');
      return patients;
    } catch (e) {
      _logger.e('🏥 Error searching patients: $e');
      return [];
    }
  }

  /// Set auth token for API requests
  Future<void> _setAuthToken() async {
    final token = await _storageService.getAccessToken();
    if (token != null) {
      _apiService.setAuthToken(token);
    }
  }
}
