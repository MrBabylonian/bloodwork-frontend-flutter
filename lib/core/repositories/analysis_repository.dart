import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import '../api/api_service.dart';
import '../models/analysis_models.dart';

class AnalysisRepository {
  final ApiService _apiService;
  final Logger _logger = Logger();

  AnalysisRepository({required ApiService apiService})
    : _apiService = apiService;

  /// Upload a PDF file for analysis
  ///
  /// @param patientId Optional human-readable sequential ID (e.g., PAT-001)
  Future<AnalysisUploadResponse?> uploadPdfFile({
    required PlatformFile file,
    String? patientId,
    String? notes,
  }) async {
    try {
      _logger.d('📄 REPO: Uploading PDF file: ${file.name}');

      // Create multipart form data with file bytes
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          file.bytes!,
          filename: file.name,
          contentType: DioMediaType('application', 'pdf'),
        ),
        if (patientId != null) 'patient_id': patientId,
        if (notes != null) 'notes': notes,
      });

      final response = await _apiService.post(
        '/api/v1/analysis/upload',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = AnalysisUploadResponse.fromJson(response.data);
        _logger.d('📄 REPO: Upload successful - ID: ${result.diagnosticId}');
        return result;
      }

      _logger.e('📄 REPO: Upload failed - Status: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.e('📄 REPO: Upload error: $e');
      return null;
    }
  }

  /// Check if a patient has a pending analysis request
  ///
  /// @param patientId Human-readable sequential ID (e.g., PAT-001)
  Future<bool> hasPendingAnalysis(String patientId) async {
    try {
      _logger.d('📄 REPO: Checking pending analysis for patient: $patientId');

      final response = await _apiService.get(
        '/api/v1/diagnostics/patient/$patientId/pending',
      );

      if (response.statusCode == 200) {
        final hasPending = response.data['has_pending_analysis'] as bool;
        _logger.d('📄 REPO: Pending analysis check: $hasPending');
        return hasPending;
      }

      _logger.e(
        '📄 REPO: Pending analysis check failed - Status: ${response.statusCode}',
      );
      return false;
    } catch (e) {
      _logger.e('📄 REPO: Pending analysis check error: $e');
      return false;
    }
  }

  /// Get latest analysis result for a patient
  ///
  /// @param patientId Human-readable sequential ID (e.g., PAT-001)
  Future<AnalysisResult?> getLatestAnalysisForPatient(String patientId) async {
    try {
      _logger.d('📄 REPO: Getting latest analysis for patient: $patientId');

      final response = await _apiService.get(
        '/api/v1/diagnostics/patient/$patientId/latest',
      );

      if (response.statusCode == 200) {
        final result = AnalysisResult.fromJson(response.data);
        _logger.d('📄 REPO: Got latest result - Status: ${result.status}');
        return result;
      }

      _logger.e(
        '📄 REPO: Get latest result failed - Status: ${response.statusCode}',
      );
      return null;
    } catch (e) {
      _logger.e('📄 REPO: Get latest result error: $e');
      return null;
    }
  }
}
