import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:logger/logger.dart';
import '../repositories/analysis_repository.dart';
import '../models/analysis_models.dart';
import '../services/service_locator.dart';

enum AnalysisStatus { idle, uploading, processing, completed, failed }

class AnalysisProvider extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;
  final Logger _logger = Logger();

  AnalysisProvider({AnalysisRepository? analysisRepository})
    : _analysisRepository =
          analysisRepository ?? ServiceLocator().analysisRepository;

  // State
  AnalysisStatus _status = AnalysisStatus.idle;
  String? _errorMessage;
  String? _currentAnalysisId;
  AnalysisResult? _currentResult;
  Map<String, List<AnalysisResult>> _patientResults = {};

  // Getters
  AnalysisStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get currentAnalysisId => _currentAnalysisId;
  AnalysisResult? get currentResult => _currentResult;
  bool get isUploading => _status == AnalysisStatus.uploading;
  bool get isProcessing => _status == AnalysisStatus.processing;
  bool get hasError => _status == AnalysisStatus.failed;

  /// Upload a PDF file for analysis
  Future<bool> uploadPdfFile({
    required PlatformFile file,
    String? patientId,
    String? notes,
  }) async {
    try {
      _logger.d('📄 PROVIDER: Starting PDF upload');
      _setStatus(AnalysisStatus.uploading);

      final response = await _analysisRepository.uploadPdfFile(
        file: file,
        patientId: patientId,
        notes: notes,
      );

      if (response != null) {
        _currentAnalysisId = response.diagnosticId;
        _setStatus(AnalysisStatus.processing);
        _logger.d(
          '📄 PROVIDER: Upload successful - ID: ${response.diagnosticId}',
        );
        return true;
      } else {
        _setError('Failed to upload file');
        return false;
      }
    } catch (e) {
      _logger.e('📄 PROVIDER: Upload error: $e');
      _setError('Upload failed: $e');
      return false;
    }
  }

  /// Check analysis result by ID
  Future<AnalysisResult?> checkAnalysisResult(String analysisId) async {
    try {
      _logger.d('📄 PROVIDER: Checking analysis result: $analysisId');

      final result = await _analysisRepository.getAnalysisResult(analysisId);

      if (result != null) {
        _currentResult = result;

        if (result.isCompleted) {
          _setStatus(AnalysisStatus.completed);
        } else if (result.isFailed) {
          _setStatus(AnalysisStatus.failed);
          _errorMessage = result.errorMessage ?? 'Analysis failed';
        }

        notifyListeners();
        return result;
      }

      return null;
    } catch (e) {
      _logger.e('📄 PROVIDER: Check result error: $e');
      return null;
    }
  }

  /// Get all analysis results for a patient
  Future<List<AnalysisResult>> getPatientAnalysisResults(
    String patientId,
  ) async {
    try {
      _logger.d('📄 PROVIDER: Getting patient results: $patientId');

      final results = await _analysisRepository.getPatientAnalysisResults(
        patientId,
      );
      _patientResults[patientId] = results;

      notifyListeners();
      return results;
    } catch (e) {
      _logger.e('📄 PROVIDER: Get patient results error: $e');
      return [];
    }
  }

  /// Get cached patient results
  List<AnalysisResult> getCachedPatientResults(String patientId) {
    return _patientResults[patientId] ?? [];
  }

  /// Reset state
  void reset() {
    _status = AnalysisStatus.idle;
    _errorMessage = null;
    _currentAnalysisId = null;
    _currentResult = null;
    notifyListeners();
  }

  // Private methods
  void _setStatus(AnalysisStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _clearError();
      notifyListeners();
    }
  }

  void _setError(String message) {
    _errorMessage = message;
    _status = AnalysisStatus.failed;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  @override
  void dispose() {
    _logger.d('📄 PROVIDER: Disposing');
    super.dispose();
  }
}
