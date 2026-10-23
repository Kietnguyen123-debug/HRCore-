// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'employee_admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Employee _$EmployeeFromJson(Map<String, dynamic> json) => Employee(
  id: (json['id'] as num).toInt(),
  employeeCode: json['employeeCode'] as String?,
  fullName: json['fullName'] as String?,
  branchId: (json['branchId'] as num).toInt(),
  departmentId: (json['departmentId'] as num?)?.toInt(),
  branchName: json['branchName'] as String?,
  departmentName: json['departmentName'] as String?,
  hasBoundDevice: json['hasBoundDevice'] as bool,
  hasFaceRegistered: json['hasFaceRegistered'] as bool,
  isActive: json['isActive'] as bool,
  email: json['email'] as String?,
  role: json['role'] as String?,
  isActivated: json['isActivated'] as bool? ?? false,
  isEmailVerified: json['isEmailVerified'] as bool? ?? false,
  baseSalary: (json['baseSalary'] as num?)?.toDouble() ?? 0,
  allowance: (json['allowance'] as num?)?.toDouble() ?? 0,
  penaltyPerLateMinute: (json['penaltyPerLateMinute'] as num?)?.toDouble() ?? 0,
  dependentCount: (json['dependentCount'] as num?)?.toInt() ?? 0,
  socialInsuranceBase: (json['socialInsuranceBase'] as num?)?.toDouble(),
  totalAnnualLeave: (json['totalAnnualLeave'] as num?)?.toInt() ?? 12,
  usedAnnualLeave: (json['usedAnnualLeave'] as num?)?.toInt() ?? 0,
  remainingAnnualLeave: (json['remainingAnnualLeave'] as num?)?.toInt() ?? 0,
);

CreateEmployeeProfileRequest _$CreateEmployeeProfileRequestFromJson(
  Map<String, dynamic> json,
) => CreateEmployeeProfileRequest(
  employeeCode: json['employeeCode'] as String,
  fullName: json['fullName'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
  departmentId: (json['departmentId'] as num?)?.toInt(),
  role: json['role'] as String,
  email: json['email'] as String?,
  baseSalary: (json['baseSalary'] as num).toDouble(),
  allowance: (json['allowance'] as num).toDouble(),
  penaltyPerLateMinute: (json['penaltyPerLateMinute'] as num).toDouble(),
  dependentCount: (json['dependentCount'] as num).toInt(),
  socialInsuranceBase: (json['socialInsuranceBase'] as num?)?.toDouble(),
  totalAnnualLeave: (json['totalAnnualLeave'] as num).toInt(),
);

Map<String, dynamic> _$CreateEmployeeProfileRequestToJson(
  CreateEmployeeProfileRequest instance,
) => <String, dynamic>{
  'employeeCode': instance.employeeCode,
  'fullName': instance.fullName,
  'branchId': instance.branchId,
  'departmentId': instance.departmentId,
  'role': instance.role,
  'email': instance.email,
  'baseSalary': instance.baseSalary,
  'allowance': instance.allowance,
  'penaltyPerLateMinute': instance.penaltyPerLateMinute,
  'dependentCount': instance.dependentCount,
  'socialInsuranceBase': instance.socialInsuranceBase,
  'totalAnnualLeave': instance.totalAnnualLeave,
};

UpdateEmployeeRequest _$UpdateEmployeeRequestFromJson(
  Map<String, dynamic> json,
) => UpdateEmployeeRequest(
  fullName: json['fullName'] as String,
  branchId: (json['branchId'] as num?)?.toInt(),
  departmentId: (json['departmentId'] as num?)?.toInt(),
  role: json['role'] as String,
);

Map<String, dynamic> _$UpdateEmployeeRequestToJson(
  UpdateEmployeeRequest instance,
) => <String, dynamic>{
  'fullName': instance.fullName,
  'branchId': instance.branchId,
  'departmentId': instance.departmentId,
  'role': instance.role,
};

AdminResetPasswordRequest _$AdminResetPasswordRequestFromJson(
  Map<String, dynamic> json,
) => AdminResetPasswordRequest(
  newTemporaryPassword: json['newTemporaryPassword'] as String,
);

Map<String, dynamic> _$AdminResetPasswordRequestToJson(
  AdminResetPasswordRequest instance,
) => <String, dynamic>{'newTemporaryPassword': instance.newTemporaryPassword};

StatusMessageResponse _$StatusMessageResponseFromJson(
  Map<String, dynamic> json,
) => StatusMessageResponse(
  message: json['message'] as String?,
  isActive: json['isActive'] as bool,
);
