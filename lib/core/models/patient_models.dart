/// Patient models that match the backend schema exactly
class PatientAge {
  final int years;
  final int months;

  const PatientAge({required this.years, required this.months});

  factory PatientAge.fromJson(Map<String, dynamic> json) {
    return PatientAge(years: json['years'] ?? 0, months: json['months'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'years': years, 'months': months};
  }

  @override
  String toString() {
    if (months == 0) {
      return '$years anni';
    } else if (years == 0) {
      return '$months mesi';
    } else {
      return '$years anni e $months mesi';
    }
  }
}

class PatientOwnerInfo {
  final String name;
  final String email;
  final String phone;

  const PatientOwnerInfo({
    required this.name,
    required this.email,
    required this.phone,
  });

  factory PatientOwnerInfo.fromJson(Map<String, dynamic> json) {
    return PatientOwnerInfo(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'email': email, 'phone': phone};
  }
}

class PatientModel {
  /// Human-readable sequential ID (e.g., PAT-001)
  final String id;

  /// Patient ID - can be a custom ID assigned by the clinic
  final String patientId;
  final String name;
  final String species;
  final String breed;
  final DateTime birthdate;
  final String sex;
  final double? weight;
  final PatientOwnerInfo ownerInfo;
  final Map<String, dynamic> medicalHistory;

  /// ID of the user who created the patient (e.g., VET-001 or TEC-001)
  final String createdBy;

  /// ID of the user assigned to the patient (e.g., VET-001 or TEC-001)
  final String assignedTo;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const PatientModel({
    required this.id,
    required this.patientId,
    required this.name,
    required this.species,
    required this.breed,
    required this.birthdate,
    required this.sex,
    required this.weight,
    required this.ownerInfo,
    required this.medicalHistory,
    required this.createdBy,
    required this.assignedTo,
    required this.createdAt,
    required this.updatedAt,
    required this.isActive,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['patient_id'],
      patientId: json['patient_id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      birthdate: DateTime.parse(json['birthdate']),
      sex: json['sex'],
      weight: json['weight']?.toDouble(),
      ownerInfo: PatientOwnerInfo.fromJson(json['owner_info']),
      medicalHistory: json['medical_history'] ?? {},
      createdBy: json['created_by'],
      assignedTo: json['assigned_to'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'name': name,
      'species': species,
      'breed': breed,
      'birthdate': birthdate.toIso8601String(),
      'sex': sex,
      'weight': weight,
      'owner_info': ownerInfo.toJson(),
      'medical_history': medicalHistory,
      'created_by': createdBy,
      'assigned_to': assignedTo,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  /// Calculate age based on birthdate
  PatientAge get age {
    final now = DateTime.now();
    int years = now.year - birthdate.year;
    int months = now.month - birthdate.month;

    // Adjust years and months if needed
    if (months < 0) {
      years--;
      months += 12;
    }

    // Further adjustment for day of month
    if (now.day < birthdate.day) {
      months--;
      if (months < 0) {
        years--;
        months += 12;
      }
    }

    return PatientAge(years: years, months: months);
  }
}

class PatientCreateRequest {
  final String name;
  final String species;
  final String breed;
  final DateTime birthdate;
  final String sex;
  final double? weight;
  final PatientOwnerInfo ownerInfo;
  final Map<String, dynamic> medicalHistory;

  const PatientCreateRequest({
    required this.name,
    required this.species,
    required this.breed,
    required this.birthdate,
    required this.sex,
    this.weight,
    required this.ownerInfo,
    this.medicalHistory = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'breed': breed,
      'birthdate': birthdate.toIso8601String(),
      'sex': sex,
      'weight': weight,
      'owner_info': ownerInfo.toJson(),
      'medical_history': medicalHistory,
    };
  }
}

class PatientUpdateRequest {
  final String? name;
  final String? species;
  final String? breed;
  final DateTime? birthdate;
  final String? sex;
  final double? weight;
  final PatientOwnerInfo? ownerInfo;
  final Map<String, dynamic>? medicalHistory;

  const PatientUpdateRequest({
    this.name,
    this.species,
    this.breed,
    this.birthdate,
    this.sex,
    this.weight,
    this.ownerInfo,
    this.medicalHistory,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};
    if (name != null) json['name'] = name;
    if (species != null) json['species'] = species;
    if (breed != null) json['breed'] = breed;
    if (birthdate != null) json['birthdate'] = birthdate!.toIso8601String();
    if (sex != null) json['sex'] = sex;
    if (weight != null) json['weight'] = weight;
    if (ownerInfo != null) json['owner_info'] = ownerInfo!.toJson();
    if (medicalHistory != null) json['medical_history'] = medicalHistory;
    return json;
  }
}

class PatientListResponse {
  final List<PatientModel> patients;
  final int total;
  final int page;
  final int limit;

  const PatientListResponse({
    required this.patients,
    required this.total,
    required this.page,
    required this.limit,
  });

  factory PatientListResponse.fromJson(Map<String, dynamic> json) {
    return PatientListResponse(
      patients:
          (json['patients'] as List)
              .map((patient) => PatientModel.fromJson(patient))
              .toList(),
      total: json['total'],
      page: json['page'],
      limit: json['limit'],
    );
  }
}
