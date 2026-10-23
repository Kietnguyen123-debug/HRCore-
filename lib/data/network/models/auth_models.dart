import 'package:json_annotation/json_annotation.dart';

part 'auth_models.g.dart';

@JsonSerializable(createToJson: true)
class LoginRequest {
  final String? employeeCode;
  final String? password;
  final String? deviceId;

  const LoginRequest({
    this.employeeCode,
    this.password,
    this.deviceId,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class FirstTimeActivationRequest {
  final String? employeeCode;
  final String? temporaryPassword;
  final String? newPassword;
  final String? deviceId;
  final String? faceImageBase64;

  const FirstTimeActivationRequest({
    this.employeeCode,
    this.temporaryPassword,
    this.newPassword,
    this.deviceId,
    this.faceImageBase64,
  });

  factory FirstTimeActivationRequest.fromJson(Map<String, dynamic> json) => _$FirstTimeActivationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$FirstTimeActivationRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) => _$RefreshTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshTokenRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class AuthUserInfo {
  final int id;
  final String? employeeCode;
  final String? fullName;
  final String? role;
  final int branchId;
  final int? departmentId;

  const AuthUserInfo({
    required this.id,
    this.employeeCode,
    this.fullName,
    this.role,
    required this.branchId,
    this.departmentId,
  });

  factory AuthUserInfo.fromJson(Map<String, dynamic> json) => _$AuthUserInfoFromJson(json);
}

@JsonSerializable(createToJson: false)
class AuthResponse {
  final bool success;
  final String? message;
  final String? token;
  final String? refreshToken;
  final bool isActivated;
  final AuthUserInfo? userInfo;

  const AuthResponse({
    required this.success,
    this.message,
    this.token,
    this.refreshToken,
    required this.isActivated,
    this.userInfo,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
}

class EmployeeMeResponse {
  final int id;
  final String? employeeCode;
  final String? fullName;
  final String? role;
  final int branchId;
  final String? email;
  final bool isEmailVerified;
  final bool isActivated;
  final int? totalAnnualLeave;
  final int? usedAnnualLeave;
  final int? remainingAnnualLeave;

  const EmployeeMeResponse({
    required this.id,
    this.employeeCode,
    this.fullName,
    this.role,
    required this.branchId,
    this.email,
    required this.isEmailVerified,
    required this.isActivated,
    this.totalAnnualLeave,
    this.usedAnnualLeave,
    this.remainingAnnualLeave,
  });

  factory EmployeeMeResponse.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    dynamic findKey(List<String> keys) {
      for (var k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    return EmployeeMeResponse(
      id: (json['id'] as num?)?.toInt() ?? (json['Id'] as num?)?.toInt() ?? 0,
      employeeCode: json['employeeCode'] as String? ?? json['EmployeeCode'] as String?,
      fullName: json['fullName'] as String? ?? json['FullName'] as String?,
      role: json['role'] as String? ?? json['Role'] as String?,
      branchId: (json['branchId'] as num?)?.toInt() ?? (json['BranchId'] as num?)?.toInt() ?? 0,
      email: json['email'] as String? ?? json['Email'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool? ?? json['IsEmailVerified'] as bool? ?? false,
      isActivated: json['isActivated'] as bool? ?? json['IsActivated'] as bool? ?? false,
      totalAnnualLeave: parseInt(findKey(['totalAnnualLeave', 'TotalAnnualLeave'])),
      usedAnnualLeave: parseInt(findKey(['usedAnnualLeave', 'UsedAnnualLeave'])),
      remainingAnnualLeave: parseInt(findKey(['remainingAnnualLeave', 'RemainingAnnualLeave'])),
    );
  }
}

/// Chuẩn OpenAPI: Chỉ chứa currentPassword và newPassword
/// C# Server bật `additionalProperties: false` nên tuyệt đối KHÔNG gửi `confirmPassword` lên JSON.
@JsonSerializable(createToJson: true)
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) => _$ChangePasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ChangePasswordRequestToJson(this);
}

/// Chuẩn OpenAPI: Key truyền lên là `employeeCodeOrEmail`
@JsonSerializable(createToJson: true)
class RequestPasswordResetRequest {
  final String? employeeCodeOrEmail;

  const RequestPasswordResetRequest({this.employeeCodeOrEmail});

  factory RequestPasswordResetRequest.fromJson(Map<String, dynamic> json) => _$RequestPasswordResetRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestPasswordResetRequestToJson(this);
}

/// Chuẩn OpenAPI: Key truyền lên là `employeeCodeOrEmail`, `otp`, `newPassword`
@JsonSerializable(createToJson: true)
class ResetPasswordRequest {
  final String? employeeCodeOrEmail;
  final String? otp;
  final String? newPassword;

  const ResetPasswordRequest({
    this.employeeCodeOrEmail,
    this.otp,
    this.newPassword,
  });

  factory ResetPasswordRequest.fromJson(Map<String, dynamic> json) => _$ResetPasswordRequestFromJson(json);
  Map<String, dynamic> toJson() => _$ResetPasswordRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class RequestEmailVerificationRequest {
  final String? email;

  const RequestEmailVerificationRequest({this.email});

  factory RequestEmailVerificationRequest.fromJson(Map<String, dynamic> json) => _$RequestEmailVerificationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RequestEmailVerificationRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class VerifyEmailRequest {
  final String? otp;

  const VerifyEmailRequest({this.otp});

  factory VerifyEmailRequest.fromJson(Map<String, dynamic> json) => _$VerifyEmailRequestFromJson(json);
  Map<String, dynamic> toJson() => _$VerifyEmailRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class MessageResponse {
  final String? message;

  const MessageResponse({this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) => _$MessageResponseFromJson(json);
}

@JsonSerializable(createToJson: false)
class ApiMessageResponse {
  final bool success;
  final String? message;

  const ApiMessageResponse({
    required this.success,
    this.message,
  });

  factory ApiMessageResponse.fromJson(Map<String, dynamic> json) => _$ApiMessageResponseFromJson(json);
}