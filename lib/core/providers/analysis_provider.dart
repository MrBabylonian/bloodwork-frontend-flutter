import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/analysis_models.dart';
import '../repositories/analysis_repository.dart';
import '../services/service_locator.dart';

enum AnalysisStatus { idle, processing, completed, failed }

class AnalysisProvider extends ChangeNotifier {
  final AnalysisRepository _analysisRepository;
  final Logger _logger = Logger();

  AnalysisProvider({AnalysisRepository? analysisRepository})
    : _analysisRepository =
          analysisRepository ?? ServiceLocator().analysisRepository;

  // State
  AnalysisStatus _status = AnalysisStatus.idle;
  String? _errorMessage;
  AnalysisResult? _currentResult;
  Map<String, List<AnalysisResult>> _patientResults = {};
  bool _isLoading = false;

  // Getters
  AnalysisStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AnalysisResult? get currentResult => _currentResult;
  Map<String, List<AnalysisResult>> get patientResults => _patientResults;
  bool get isIdle => _status == AnalysisStatus.idle;
  bool get isProcessing => _status == AnalysisStatus.processing;
  bool get hasError => _status == AnalysisStatus.failed;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;

  /// Upload a PDF file for analysis
  Future<AnalysisUploadResponse?> uploadPdfFile({
    required PlatformFile file,
    String? patientId,
    String? notes,
  }) async {
    _status = AnalysisStatus.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.d('📄 PROVIDER: Starting PDF upload');

      final response = await _analysisRepository.uploadPdfFile(
        file: file,
        patientId: patientId,
        notes: notes,
      );

      if (response != null) {
        _status = AnalysisStatus.completed;
        _logger.d(
          '📄 PROVIDER: Upload successful - ID: ${response.diagnosticId}',
        );
      } else {
        _status = AnalysisStatus.failed;
        _errorMessage = "Upload failed";
        _logger.e('📄 PROVIDER: Upload failed');
      }

      notifyListeners();
      return response;
    } catch (e) {
      _logger.e('📄 PROVIDER: Upload error: $e');
      _status = AnalysisStatus.failed;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get analysis result by ID
  Future<AnalysisResult?> getAnalysisResult(String diagnosticId) async {
    _status = AnalysisStatus.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.d('📄 PROVIDER: Getting analysis result: $diagnosticId');

      final result = await _analysisRepository.getAnalysisResult(diagnosticId);

      if (result != null) {
        _currentResult = result;
        _status = AnalysisStatus.completed;
        _logger.d('📄 PROVIDER: Got result - Status: ${result.status}');
      } else {
        _status = AnalysisStatus.failed;
        _errorMessage = "Result not found";
        _logger.e('📄 PROVIDER: Result not found');
      }

      notifyListeners();
      return result;
    } catch (e) {
      _logger.e('📄 PROVIDER: Get result error: $e');
      _status = AnalysisStatus.failed;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Get all analysis results for a patient
  Future<List<AnalysisResult>> getPatientAnalysisResults(
    String patientId,
  ) async {
    _status = AnalysisStatus.processing;
    _errorMessage = null;
    notifyListeners();

    try {
      _logger.d('📄 PROVIDER: Getting patient results: $patientId');

      final results = await _analysisRepository.getPatientAnalysisResults(
        patientId,
      );

      _patientResults[patientId] = results;
      _status = AnalysisStatus.completed;
      _logger.d('📄 PROVIDER: Found ${results.length} results for patient');

      notifyListeners();
      return results;
    } catch (e) {
      _logger.e('📄 PROVIDER: Get patient results error: $e');
      _status = AnalysisStatus.failed;
      _errorMessage = e.toString();
      notifyListeners();
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
    _currentResult = null;
    notifyListeners();
  }

  Future<AnalysisResult?> getLatestAnalysisForPatient(String patientId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _logger.d('📄 PROVIDER: Getting latest analysis for patient: $patientId');

      final result = await _analysisRepository.getLatestAnalysisForPatient(
        patientId,
      );

      _isLoading = false;
      notifyListeners();

      if (result != null) {
        _logger.d('📄 PROVIDER: Got latest analysis result');
      } else {
        _logger.d('📄 PROVIDER: No analysis found for patient');
      }

      return result;
    } catch (e) {
      _logger.e('📄 PROVIDER: Get latest analysis error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<AnalysisUploadResponse?> uploadAnalysis(
    String filePath,
    String patientId,
    String? notes,
  ) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _logger.d('📄 PROVIDER: Uploading analysis from path: $filePath');

      final result = await _analysisRepository.uploadAnalysis(
        filePath,
        patientId,
        notes,
      );

      _isLoading = false;
      notifyListeners();

      return result;
    } catch (e) {
      _logger.e('📄 PROVIDER: Upload analysis error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<List<AnalysisResult>> getAnalysisForPatient(String patientId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _logger.d('📄 PROVIDER: Getting all analysis for patient: $patientId');

      final results = await _analysisRepository.getAnalysisForPatient(
        patientId,
      );

      _isLoading = false;
      notifyListeners();

      return results;
    } catch (e) {
      _logger.e('📄 PROVIDER: Get analysis for patient error: $e');
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  @override
  void dispose() {
    _logger.d('📄 PROVIDER: Disposing');
    super.dispose();
  }
}
