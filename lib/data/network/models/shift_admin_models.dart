import 'package:json_annotation/json_annotation.dart';

part 'shift_admin_models.g.dart';

@JsonSerializable(createToJson: false)
class AdminShiftAssignmentDto {
  final int id;
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final int branchId;
  final int shiftId;
  final String? shiftCode;
  final String? shiftName;
  final DateTime effectiveFromDate;
  final DateTime? effectiveToDate;

  const AdminShiftAssignmentDto({
    required this.id,
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    required this.branchId,
    required this.shiftId,
    this.shiftCode,
    this.shiftName,
    required this.effectiveFromDate,
    this.effectiveToDate,
  });

  factory AdminShiftAssignmentDto.fromJson(Map<String, dynamic> json) => _$AdminShiftAssignmentDtoFromJson(json);
}

@JsonSerializable(createToJson: true)
class AssignShiftRequest {
  final int employeeId;
  final int shiftId;
  final DateTime effectiveFromDate;
  final DateTime? effectiveToDate;

  const AssignShiftRequest({
    required this.employeeId,
    required this.shiftId,
    required this.effectiveFromDate,
    this.effectiveToDate,
  });

  Map<String, dynamic> toJson() => _$AssignShiftRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class UpdateShiftAssignmentRequest {
  final int shiftId;
  final DateTime effectiveFromDate;
  final DateTime? effectiveToDate;

  const UpdateShiftAssignmentRequest({
    required this.shiftId,
    required this.effectiveFromDate,
    this.effectiveToDate,
  });

  Map<String, dynamic> toJson() => _$UpdateShiftAssignmentRequestToJson(this);
}
