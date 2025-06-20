/// Analysis models that match the backend schema for file upload and results

class AnalysisUploadRequest {
  final String? patientId;
  final String? notes;

  const AnalysisUploadRequest({this.patientId, this.notes});

  Map<String, dynamic> toJson() {
    return {
      if (patientId != null) 'patient_id': patientId,
      if (notes != null) 'notes': notes,
    };
  }
}

class AnalysisUploadResponse {
  final String diagnosticId;
  final String message;
  final String status;

  const AnalysisUploadResponse({
    required this.diagnosticId,
    required this.message,
    required this.status,
  });

  factory AnalysisUploadResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisUploadResponse(
      diagnosticId: json['diagnostic_id'] ?? '',
      message: json['message'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }
}

class AnalysisResult {
  final String id;
  final String patientId;
  final String status;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic>? results;
  final String? errorMessage;

  const AnalysisResult({
    required this.id,
    required this.patientId,
    required this.status,
    required this.createdAt,
    this.completedAt,
    this.results,
    this.errorMessage,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) {
    return AnalysisResult(
      id: json['id'] ?? '',
      patientId: json['patient_id'] ?? '',
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['created_at']),
      completedAt:
          json['completed_at'] != null
              ? DateTime.parse(json['completed_at'])
              : null,
      results: json['results'],
      errorMessage: json['error_message'],
    );
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
