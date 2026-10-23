// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'overtime_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OvertimeRequest _$OvertimeRequestFromJson(Map<String, dynamic> json) =>
    OvertimeRequest(
      workDate: DateTime.parse(json['workDate'] as String),
      hours: (json['hours'] as num).toDouble(),
      multiplier: (json['multiplier'] as num).toDouble(),
    );

Map<String, dynamic> _$OvertimeRequestToJson(OvertimeRequest instance) =>
    <String, dynamic>{
      'workDate': instance.workDate.toIso8601String(),
      'hours': instance.hours,
      'multiplier': instance.multiplier,
    };

OvertimeResponse _$OvertimeResponseFromJson(Map<String, dynamic> json) =>
    OvertimeResponse(
      id: (json['Id'] as num?)?.toInt(),
      employeeId: (json['EmployeeId'] as num?)?.toInt(),
      workDate: json['WorkDate'] == null
          ? null
          : DateTime.parse(json['WorkDate'] as String),
      hours: (json['Hours'] as num?)?.toDouble(),
      multiplier: (json['Multiplier'] as num?)?.toDouble(),
      status: json['Status'] as String?,
    );

EmployeeOvertimeDto _$EmployeeOvertimeDtoFromJson(Map<String, dynamic> json) =>
    EmployeeOvertimeDto(
      id: (json['Id'] as num).toInt(),
      workDate: DateTime.parse(json['WorkDate'] as String),
      hours: (json['Hours'] as num).toDouble(),
      multiplier: (json['Multiplier'] as num).toDouble(),
      status: json['Status'] as String?,
    );
