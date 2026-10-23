// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShiftDto _$ShiftDtoFromJson(Map<String, dynamic> json) => ShiftDto(
  id: (json['id'] as num?)?.toInt(),
  shiftCode: json['shiftCode'] as String?,
  shiftName: json['shiftName'] as String?,
  startTime: const TimeSpanConverter().fromJson(json['startTime'] as String),
  endTime: const TimeSpanConverter().fromJson(json['endTime'] as String),
  isActive: json['isActive'] as bool,
);

Map<String, dynamic> _$ShiftDtoToJson(ShiftDto instance) => <String, dynamic>{
  'id': instance.id,
  'shiftCode': instance.shiftCode,
  'shiftName': instance.shiftName,
  'startTime': const TimeSpanConverter().toJson(instance.startTime),
  'endTime': const TimeSpanConverter().toJson(instance.endTime),
  'isActive': instance.isActive,
};

CreateShiftRequest _$CreateShiftRequestFromJson(Map<String, dynamic> json) =>
    CreateShiftRequest(
      shiftCode: json['shiftCode'] as String,
      shiftName: json['shiftName'] as String,
      startTime: const TimeSpanConverter().fromJson(
        json['startTime'] as String,
      ),
      endTime: const TimeSpanConverter().fromJson(json['endTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );

Map<String, dynamic> _$CreateShiftRequestToJson(CreateShiftRequest instance) =>
    <String, dynamic>{
      'shiftCode': instance.shiftCode,
      'shiftName': instance.shiftName,
      'startTime': const TimeSpanConverter().toJson(instance.startTime),
      'endTime': const TimeSpanConverter().toJson(instance.endTime),
      'isActive': instance.isActive,
    };

EmployeeShiftScheduleDto _$EmployeeShiftScheduleDtoFromJson(
  Map<String, dynamic> json,
) => EmployeeShiftScheduleDto(
  assignmentId: (json['assignmentId'] as num?)?.toInt(),
  effectiveFromDate: DateTime.parse(json['effectiveFromDate'] as String),
  effectiveToDate: json['effectiveToDate'] == null
      ? null
      : DateTime.parse(json['effectiveToDate'] as String),
  shift: json['shift'] == null
      ? null
      : ShiftDto.fromJson(json['shift'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EmployeeShiftScheduleDtoToJson(
  EmployeeShiftScheduleDto instance,
) => <String, dynamic>{
  'assignmentId': instance.assignmentId,
  'effectiveFromDate': instance.effectiveFromDate.toIso8601String(),
  'effectiveToDate': instance.effectiveToDate?.toIso8601String(),
  'shift': instance.shift,
};
