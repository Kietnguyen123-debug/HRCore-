import 'package:json_annotation/json_annotation.dart';

part 'employee_admin_models.g.dart';

@JsonSerializable(createToJson: false)
class Employee {
  final int id;
  final String? employeeCode;
  final String? fullName;
  final int branchId;
  final int? departmentId;
  final String? branchName;
  final String? departmentName;
  final bool hasBoundDevice;
  final bool hasFaceRegistered;
  final bool isActive;
  
  // Additional fields for detail context if used in same object
  final String? email;
  final String? role;
  final bool isActivated;
  final bool isEmailVerified;
  final double baseSalary;
  final double allowance;
  final double penaltyPerLateMinute;
  final int dependentCount;
  final double? socialInsuranceBase;
  final int totalAnnualLeave;
  final int usedAnnualLeave;
  final int remainingAnnualLeave;

  const Employee({
    required this.id,
    this.employeeCode,
    this.fullName,
    required this.branchId,
    this.departmentId,
    this.branchName,
    this.departmentName,
    required this.hasBoundDevice,
    required this.hasFaceRegistered,
    required this.isActive,
    this.email,
    this.role,
    this.isActivated = false,
    this.isEmailVerified = false,
    this.baseSalary = 0,
    this.allowance = 0,
    this.penaltyPerLateMinute = 0,
    this.dependentCount = 0,
    this.socialInsuranceBase,
    this.totalAnnualLeave = 12,
    this.usedAnnualLeave = 0,
    this.remainingAnnualLeave = 0,
  });

  factory Employee.fromJson(Map<String, dynamic> json) => _$EmployeeFromJson(json);
}

// Keep as alias or separate if needed, but I'll use Employee for both to satisfy UI
typedef EmployeeListItemResponse = Employee;
typedef EmployeeDetailResponse = Employee;

@JsonSerializable(createToJson: true)
class CreateEmployeeProfileRequest {
  final String employeeCode;
  final String fullName;
  final int? branchId;
  final int? departmentId;
  final String role;
  final String? email;
  final double baseSalary;
  final double allowance;
  final double penaltyPerLateMinute;
  final int dependentCount;
  final double? socialInsuranceBase;
  final int totalAnnualLeave;

  const CreateEmployeeProfileRequest({
    required this.employeeCode,
    required this.fullName,
    this.branchId,
    this.departmentId,
    required this.role,
    this.email,
    required this.baseSalary,
    required this.allowance,
    required this.penaltyPerLateMinute,
    required this.dependentCount,
    this.socialInsuranceBase,
    required this.totalAnnualLeave,
  });

  Map<String, dynamic> toJson() => _$CreateEmployeeProfileRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class UpdateEmployeeRequest {
  final String fullName;
  final int? branchId;
  final int? departmentId;
  final String role;

  const UpdateEmployeeRequest({
    required this.fullName,
    this.branchId,
    this.departmentId,
    required this.role,
  });

  Map<String, dynamic> toJson() => _$UpdateEmployeeRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class AdminResetPasswordRequest {
  final String newTemporaryPassword;

  const AdminResetPasswordRequest({required this.newTemporaryPassword});

  Map<String, dynamic> toJson() => _$AdminResetPasswordRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class StatusMessageResponse {
  final String? message;
  final bool isActive;

  const StatusMessageResponse({
    this.message,
    required this.isActive,
  });

  factory StatusMessageResponse.fromJson(Map<String, dynamic> json) => _$StatusMessageResponseFromJson(json);
}
