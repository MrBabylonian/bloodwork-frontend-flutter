import '../api/api_service.dart';

/// Repository for diagnostic-related remote calls
class DiagnosticRepository {
  final ApiService _apiService;

  DiagnosticRepository({required ApiService apiService})
    : _apiService = apiService;

  /// Get total tests performed for a patient
  Future<int> getTestsCount(String patientId) async {
    try {
      final response = await _apiService.get(
        '/api/v1/diagnostics/patient/$patientId/tests-count',
      );
      return (response.data as num).toInt();
    } catch (e) {
      // In case of error, log and fallback to 0
      // ignore: avoid_print
      print('Error fetching tests count for $patientId: $e');
      return 0;
    }
  }
}
