import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../models/analysis_models.dart';
import '../api/api_service.dart';
import '../services/service_locator.dart';

enum AnalysisStatus { idle, processing, completed, failed }

class AnalysisProvider extends ChangeNotifier {
  final ApiService _apiService = ServiceLocator().apiService;
  final Logger _logger = Logger();

  AnalysisProvider();

  // State
  AnalysisStatus _status = AnalysisStatus.idle;
  String? _errorMessage;
  AnalysisResult? _currentResult;
  bool _isLoading = false;
  bool _hasPendingAnalysis = false;
  bool _isCheckingPendingStatus = false;

  // Getters
  AnalysisStatus get status => _status;
  String? get errorMessage => _errorMessage;
  AnalysisResult? get currentResult => _currentResult;
  bool get isIdle => _status == AnalysisStatus.idle;
  bool get isProcessing => _status == AnalysisStatus.processing;
  bool get hasError => _status == AnalysisStatus.failed;
  bool get isLoading => _isLoading;
  String? get error => _errorMessage;
  bool get hasPendingAnalysis => _hasPendingAnalysis;
  bool get isCheckingPendingStatus => _isCheckingPendingStatus;

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

      final response = await _apiService.uploadPdf(
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

  /// Check if a patient has a pending analysis
  Future<bool> checkPendingAnalysis(String patientId) async {
    try {
      _isCheckingPendingStatus = true;
      notifyListeners();

      _logger.d(
        '📄 PROVIDER: Checking pending analysis for patient: $patientId',
      );

      final hasPending = await _apiService.hasPendingAnalysis(patientId);

      _hasPendingAnalysis = hasPending;
      _isCheckingPendingStatus = false;
      notifyListeners();

      _logger.d('📄 PROVIDER: Pending analysis status: $hasPending');
      return hasPending;
    } catch (e) {
      _logger.e('📄 PROVIDER: Check pending analysis error: $e');
      _isCheckingPendingStatus = false;
      _hasPendingAnalysis = false;
      notifyListeners();
      return false;
    }
  }

  Future<AnalysisResult?> getLatestAnalysisForPatient(String patientId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _logger.d('📄 PROVIDER: Getting latest analysis for patient: $patientId');

      final result = await _apiService.getLatestAnalysis(patientId);

      _isLoading = false;
      notifyListeners();

      if (result != null) {
        _currentResult = result;
        // If we got a result, there's no longer a pending analysis
        _hasPendingAnalysis = false;
        _logger.d('📄 PROVIDER: Got latest analysis result');
      } else {
        _logger.d('📄 PROVIDER: No analysis found for patient');
        // Check if there's a pending analysis
        await checkPendingAnalysis(patientId);
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

  /// Reset state
  void reset() {
    _status = AnalysisStatus.idle;
    _errorMessage = null;
    _currentResult = null;
    _hasPendingAnalysis = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _logger.d('📄 PROVIDER: Disposing');
    super.dispose();
  }
}
