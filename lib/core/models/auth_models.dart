import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable()
class LoginRequest {
  final String username;
  final String password;

  LoginRequest({required this.username, required this.password});

  factory LoginRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable()
class UserModel {
  final String id;
  final String username;
  final String role;
  final Map<String, dynamic> profile;

  UserModel({
    required this.id,
    required this.username,
    required this.role,
    required this.profile,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

@JsonSerializable()
class LoginResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  final UserModel user;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) =>
      _$LoginResponseFromJson(json);

  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}

@JsonSerializable()
class RefreshTokenRequest {
  @JsonKey(name: 'refresh_token')
  final String refreshToken;

  RefreshTokenRequest({required this.refreshToken});

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable()
class RefreshTokenResponse {
  @JsonKey(name: 'access_token')
  final String accessToken;

  @JsonKey(name: 'token_type')
  final String tokenType;

  @JsonKey(name: 'expires_in')
  final int expiresIn;

  RefreshTokenResponse({
    required this.accessToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) =>
      _$RefreshTokenResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RefreshTokenResponseToJson(this);
}

// User role enum
enum UserRole {
  @JsonValue('veterinarian')
  veterinarian,
  @JsonValue('veterinary_technician')
  veterinaryTechnician,
}

// Approval status enum
enum ApprovalStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
}

@JsonSerializable()
class UserProfile {
  @JsonKey(name: 'first_name')
  final String firstName;

  @JsonKey(name: 'last_name')
  final String lastName;

  @JsonKey(name: 'license_number')
  final String licenseNumber;

  @JsonKey(name: 'clinic_name')
  final String clinicName;

  final String phone;

  UserProfile({
    required this.firstName,
    required this.lastName,
    required this.licenseNumber,
    required this.clinicName,
    required this.phone,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

@JsonSerializable()
class RegistrationRequest {
  final String username;
  final String email;
  final String password;
  final UserRole role;
  final Map<String, dynamic> profile;

  RegistrationRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.profile,
  });

  factory RegistrationRequest.fromJson(Map<String, dynamic> json) =>
      _$RegistrationRequestFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationRequestToJson(this);
}

@JsonSerializable()
class RegistrationResponse {
  final String message;

  @JsonKey(name: 'user_id')
  final String userId;

  @JsonKey(name: 'approval_status')
  final ApprovalStatus approvalStatus;

  RegistrationResponse({
    required this.message,
    required this.userId,
    required this.approvalStatus,
  });

  factory RegistrationResponse.fromJson(Map<String, dynamic> json) =>
      _$RegistrationResponseFromJson(json);

  Map<String, dynamic> toJson() => _$RegistrationResponseToJson(this);
}
