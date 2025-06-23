import 'package:logger/logger.dart';
import '../api/api_service.dart';
import '../models/patient_models.dart';

/// Patient repository with automatic authentication via interceptor
///
/// This repository provides clean CRUD operations for patient management
/// without manual auth header management - all handled by middleware.
class PatientRepository {
  final ApiService _apiService;
  final Logger _logger = Logger();

  PatientRepository({required ApiService apiService})
    : _apiService = apiService;

  /// Get all patients with pagination
  ///
  /// @param page Page number (1-indexed)
  /// @param limit Number of items per page
  Future<PatientListResponse> getAllPatients({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.d('🏥 Fetching patients (page: $page, limit: $limit)');

      final response = await _apiService.get(
        '/api/v1/patients/',
        queryParameters: {'page': page, 'limit': limit},
      );

      final patientListResponse = PatientListResponse.fromJson(response.data);

      _logger.d(
        '🏥 Successfully fetched ${patientListResponse.patients.length} patients ' +
            '(page ${patientListResponse.page} of ${(patientListResponse.total + patientListResponse.limit - 1) ~/ patientListResponse.limit})',
      );

      return patientListResponse;
    } catch (e) {
      _logger.e('🏥 Error fetching patients: $e');
      throw Exception('Failed to fetch patients: $e');
    }
  }

  /// Get patient by ID
  ///
  /// @param patientId Human-readable sequential ID (e.g., PAT-001)
  Future<PatientModel?> getPatientById(String patientId) async {
    try {
      _logger.d('🏥 Fetching patient with ID: $patientId');

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

      final response = await _apiService.post(
        '/api/v1/patients/',
        data: request.toJson(),
      );

      final patient = PatientModel.fromJson(response.data);
      _logger.d(
        '🏥 Successfully created patient: ${patient.name} with ID: ${patient.id}',
      );
      return patient;
    } catch (e) {
      _logger.e('🏥 Error creating patient: $e');
      throw Exception('Failed to create patient: $e');
    }
  }

  /// Update patient
  ///
  /// @param patientId Human-readable sequential ID (e.g., PAT-001)
  Future<PatientModel?> updatePatient(
    String patientId,
    PatientUpdateRequest request,
  ) async {
    try {
      _logger.d('🏥 Updating patient: $patientId');

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
  ///
  /// @param patientId Human-readable sequential ID (e.g., PAT-001)
  Future<bool> deletePatient(String patientId) async {
    try {
      _logger.d('🏥 Deleting patient: $patientId');

      await _apiService.delete('/api/v1/patients/$patientId');

      _logger.d('🏥 Successfully deleted patient: $patientId');
      return true;
    } catch (e) {
      _logger.e('🏥 Error deleting patient $patientId: $e');
      return false;
    }
  }

  /// Search patients by name
  ///
  /// @param name Name to search for
  /// @param page Page number (1-indexed)
  /// @param limit Number of items per page
  Future<PatientListResponse> searchPatients(
    String name, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      _logger.d(
        '🏥 Searching patients with name: $name (page: $page, limit: $limit)',
      );

      final response = await _apiService.get(
        '/api/v1/patients/search/$name',
        queryParameters: {'page': page, 'limit': limit},
      );

      final patientListResponse = PatientListResponse.fromJson(response.data);

      _logger.d(
        '🏥 Found ${patientListResponse.patients.length} patients matching: $name ' +
            '(page ${patientListResponse.page} of ${(patientListResponse.total + patientListResponse.limit - 1) ~/ patientListResponse.limit})',
      );

      return patientListResponse;
    } catch (e) {
      _logger.e('🏥 Error searching patients: $e');
      // Return empty response instead of throwing
      return PatientListResponse(
        patients: [],
        total: 0,
        page: page,
        limit: limit,
      );
    }
  }
}
