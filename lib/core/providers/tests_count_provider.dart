import 'package:flutter/foundation.dart';

import '../api/api_service.dart';
import '../services/service_locator.dart';

/// Provides cached blood-test counts for patients to avoid duplicate network calls.
class TestsCountProvider extends ChangeNotifier {
  final ApiService _apiService = ServiceLocator().apiService;

  final Map<String, int> _counts = <String, int>{};
  final Set<String> _loading = <String>{};

  /// Returns the cached count for [patientId] or null if not loaded yet.
  int? getCount(String patientId) => _counts[patientId];

  /// Lazily loads the tests count for [patientId] once and caches it.
  Future<void> loadCount(String patientId) async {
    if (_counts.containsKey(patientId) || _loading.contains(patientId)) return;

    _loading.add(patientId);
    try {
      final int count = await _apiService.getTestsCount(patientId);
      _counts[patientId] = count;
      notifyListeners();
    } catch (_) {
      // Silently ignore errors; UI will simply show no value.
    } finally {
      _loading.remove(patientId);
    }
  }
}
