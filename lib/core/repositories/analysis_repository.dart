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
        '/analysis/pdf_analysis',
        data: formData,
      );

      if (response.statusCode == 200) {
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

  /// Get analysis result by diagnostic ID
  ///
  /// @param diagnosticId Human-readable sequential ID (e.g., DGN-001)
  Future<AnalysisResult?> getAnalysisResult(String diagnosticId) async {
    try {
      _logger.d('📄 REPO: Getting analysis result: $diagnosticId');

      final response = await _apiService.get(
        '/analysis/pdf_analysis_result/$diagnosticId',
      );

      if (response.statusCode == 200) {
        final result = AnalysisResult.fromJson(response.data);
        _logger.d('📄 REPO: Got result - Status: ${result.status}');
        return result;
      }

      _logger.e('📄 REPO: Get result failed - Status: ${response.statusCode}');
      return null;
    } catch (e) {
      _logger.e('📄 REPO: Get result error: $e');
      return null;
    }
  }

  /// Get all analysis results for a patient
  ///
  /// @param patientId Human-readable sequential ID (e.g., PAT-001)
  Future<List<AnalysisResult>> getPatientAnalysisResults(
    String patientId,
  ) async {
    try {
      _logger.d('📄 REPO: Getting patient analysis results: $patientId');

      final response = await _apiService.get(
        '/analysis/patient/$patientId/results',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final results =
            data.map((json) => AnalysisResult.fromJson(json)).toList();
        _logger.d('📄 REPO: Found ${results.length} results for patient');
        return results;
      }

      _logger.e(
        '📄 REPO: Get patient results failed - Status: ${response.statusCode}',
      );
      return [];
    } catch (e) {
      _logger.e('📄 REPO: Get patient results error: $e');
      return [];
    }
  }
}
