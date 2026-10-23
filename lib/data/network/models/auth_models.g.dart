// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  employeeCode: json['employeeCode'] as String?,
  password: json['password'] as String?,
  deviceId: json['deviceId'] as String?,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'employeeCode': instance.employeeCode,
      'password': instance.password,
      'deviceId': instance.deviceId,
    };

FirstTimeActivationRequest _$FirstTimeActivationRequestFromJson(
  Map<String, dynamic> json,
) => FirstTimeActivationRequest(
  employeeCode: json['employeeCode'] as String?,
  temporaryPassword: json['temporaryPassword'] as String?,
  newPassword: json['newPassword'] as String?,
  deviceId: json['deviceId'] as String?,
  faceImageBase64: json['faceImageBase64'] as String?,
);

Map<String, dynamic> _$FirstTimeActivationRequestToJson(
  FirstTimeActivationRequest instance,
) => <String, dynamic>{
  'employeeCode': instance.employeeCode,
  'temporaryPassword': instance.temporaryPassword,
  'newPassword': instance.newPassword,
  'deviceId': instance.deviceId,
  'faceImageBase64': instance.faceImageBase64,
};

RefreshTokenRequest _$RefreshTokenRequestFromJson(Map<String, dynamic> json) =>
    RefreshTokenRequest(refreshToken: json['refreshToken'] as String);

Map<String, dynamic> _$RefreshTokenRequestToJson(
  RefreshTokenRequest instance,
) => <String, dynamic>{'refreshToken': instance.refreshToken};

AuthUserInfo _$AuthUserInfoFromJson(Map<String, dynamic> json) => AuthUserInfo(
  id: (json['id'] as num).toInt(),
  employeeCode: json['employeeCode'] as String?,
  fullName: json['fullName'] as String?,
  role: json['role'] as String?,
  branchId: (json['branchId'] as num).toInt(),
  departmentId: (json['departmentId'] as num?)?.toInt(),
);

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  token: json['token'] as String?,
  refreshToken: json['refreshToken'] as String?,
  isActivated: json['isActivated'] as bool,
  userInfo: json['userInfo'] == null
      ? null
      : AuthUserInfo.fromJson(json['userInfo'] as Map<String, dynamic>),
);

EmployeeMeResponse _$EmployeeMeResponseFromJson(Map<String, dynamic> json) =>
    EmployeeMeResponse(
      id: (json['id'] as num).toInt(),
      employeeCode: json['employeeCode'] as String?,
      fullName: json['fullName'] as String?,
      role: json['role'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      email: json['email'] as String?,
      isEmailVerified: json['isEmailVerified'] as bool,
      isActivated: json['isActivated'] as bool,
    );

ChangePasswordRequest _$ChangePasswordRequestFromJson(
  Map<String, dynamic> json,
) => ChangePasswordRequest(
  currentPassword: json['currentPassword'] as String,
  newPassword: json['newPassword'] as String,
);

Map<String, dynamic> _$ChangePasswordRequestToJson(
  ChangePasswordRequest instance,
) => <String, dynamic>{
  'currentPassword': instance.currentPassword,
  'newPassword': instance.newPassword,
};

RequestPasswordResetRequest _$RequestPasswordResetRequestFromJson(
  Map<String, dynamic> json,
) => RequestPasswordResetRequest(
  employeeCodeOrEmail: json['employeeCodeOrEmail'] as String?,
);

Map<String, dynamic> _$RequestPasswordResetRequestToJson(
  RequestPasswordResetRequest instance,
) => <String, dynamic>{'employeeCodeOrEmail': instance.employeeCodeOrEmail};

ResetPasswordRequest _$ResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => ResetPasswordRequest(
  employeeCodeOrEmail: json['employeeCodeOrEmail'] as String?,
  otp: json['otp'] as String?,
  newPassword: json['newPassword'] as String?,
);

Map<String, dynamic> _$ResetPasswordRequestToJson(
  ResetPasswordRequest instance,
) => <String, dynamic>{
  'employeeCodeOrEmail': instance.employeeCodeOrEmail,
  'otp': instance.otp,
  'newPassword': instance.newPassword,
};

RequestEmailVerificationRequest _$RequestEmailVerificationRequestFromJson(
  Map<String, dynamic> json,
) => RequestEmailVerificationRequest(email: json['email'] as String?);

Map<String, dynamic> _$RequestEmailVerificationRequestToJson(
  RequestEmailVerificationRequest instance,
) => <String, dynamic>{'email': instance.email};

VerifyEmailRequest _$VerifyEmailRequestFromJson(Map<String, dynamic> json) =>
    VerifyEmailRequest(otp: json['otp'] as String?);

Map<String, dynamic> _$VerifyEmailRequestToJson(VerifyEmailRequest instance) =>
    <String, dynamic>{'otp': instance.otp};

MessageResponse _$MessageResponseFromJson(Map<String, dynamic> json) =>
    MessageResponse(message: json['message'] as String?);

ApiMessageResponse _$ApiMessageResponseFromJson(Map<String, dynamic> json) =>
    ApiMessageResponse(
      success: json['success'] as bool,
      message: json['message'] as String?,
    );
