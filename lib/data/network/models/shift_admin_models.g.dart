// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminShiftAssignmentDto _$AdminShiftAssignmentDtoFromJson(
  Map<String, dynamic> json,
) => AdminShiftAssignmentDto(
  id: (json['id'] as num).toInt(),
  employeeId: (json['employeeId'] as num).toInt(),
  employeeCode: json['employeeCode'] as String?,
  employeeName: json['employeeName'] as String?,
  branchId: (json['branchId'] as num).toInt(),
  shiftId: (json['shiftId'] as num).toInt(),
  shiftCode: json['shiftCode'] as String?,
  shiftName: json['shiftName'] as String?,
  effectiveFromDate: DateTime.parse(json['effectiveFromDate'] as String),
  effectiveToDate: json['effectiveToDate'] == null
      ? null
      : DateTime.parse(json['effectiveToDate'] as String),
);

AssignShiftRequest _$AssignShiftRequestFromJson(Map<String, dynamic> json) =>
    AssignShiftRequest(
      employeeId: (json['employeeId'] as num).toInt(),
      shiftId: (json['shiftId'] as num).toInt(),
      effectiveFromDate: DateTime.parse(json['effectiveFromDate'] as String),
      effectiveToDate: json['effectiveToDate'] == null
          ? null
          : DateTime.parse(json['effectiveToDate'] as String),
    );

Map<String, dynamic> _$AssignShiftRequestToJson(AssignShiftRequest instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'shiftId': instance.shiftId,
      'effectiveFromDate': instance.effectiveFromDate.toIso8601String(),
      'effectiveToDate': instance.effectiveToDate?.toIso8601String(),
    };

UpdateShiftAssignmentRequest _$UpdateShiftAssignmentRequestFromJson(
  Map<String, dynamic> json,
) => UpdateShiftAssignmentRequest(
  shiftId: (json['shiftId'] as num).toInt(),
  effectiveFromDate: DateTime.parse(json['effectiveFromDate'] as String),
  effectiveToDate: json['effectiveToDate'] == null
      ? null
      : DateTime.parse(json['effectiveToDate'] as String),
);

Map<String, dynamic> _$UpdateShiftAssignmentRequestToJson(
  UpdateShiftAssignmentRequest instance,
) => <String, dynamic>{
  'shiftId': instance.shiftId,
  'effectiveFromDate': instance.effectiveFromDate.toIso8601String(),
  'effectiveToDate': instance.effectiveToDate?.toIso8601String(),
};
