// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ResolvedShiftDto _$ResolvedShiftDtoFromJson(Map<String, dynamic> json) =>
    ResolvedShiftDto(
      assignmentId: (json['assignmentId'] as num?)?.toInt(),
      workDate: DateTime.parse(json['workDate'] as String),
      shiftId: (json['shiftId'] as num?)?.toInt(),
      shiftCode: json['shiftCode'] as String?,
      shiftName: json['shiftName'] as String?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      source: json['source'] as String?,
      exceptionId: (json['exceptionId'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ResolvedShiftDtoToJson(ResolvedShiftDto instance) =>
    <String, dynamic>{
      'assignmentId': instance.assignmentId,
      'workDate': instance.workDate.toIso8601String(),
      'shiftId': instance.shiftId,
      'shiftCode': instance.shiftCode,
      'shiftName': instance.shiftName,
      'startTime': instance.startTime,
      'endTime': instance.endTime,
      'source': instance.source,
      'exceptionId': instance.exceptionId,
    };

RosterEmployeeDto _$RosterEmployeeDtoFromJson(Map<String, dynamic> json) =>
    RosterEmployeeDto(
      employeeId: (json['employeeId'] as num).toInt(),
      employeeCode: json['employeeCode'] as String?,
      employeeName: json['employeeName'] as String?,
      workGroupName: json['workGroupName'] as String?,
      days: (json['days'] as List<dynamic>?)
          ?.map((e) => ResolvedShiftDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RosterEmployeeDtoToJson(RosterEmployeeDto instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'employeeCode': instance.employeeCode,
      'employeeName': instance.employeeName,
      'workGroupName': instance.workGroupName,
      'days': instance.days,
    };

RosterResponse _$RosterResponseFromJson(Map<String, dynamic> json) =>
    RosterResponse(
      from: DateTime.parse(json['from'] as String),
      to: DateTime.parse(json['to'] as String),
      employees: (json['employees'] as List<dynamic>?)
          ?.map((e) => RosterEmployeeDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$RosterResponseToJson(RosterResponse instance) =>
    <String, dynamic>{
      'from': instance.from.toIso8601String(),
      'to': instance.to.toIso8601String(),
      'employees': instance.employees,
    };

GroupScheduleDayRequest _$GroupScheduleDayRequestFromJson(
  Map<String, dynamic> json,
) => GroupScheduleDayRequest(
  workDate: DateTime.parse(json['workDate'] as String),
  shiftId: (json['shiftId'] as num?)?.toInt(),
);

Map<String, dynamic> _$GroupScheduleDayRequestToJson(
  GroupScheduleDayRequest instance,
) => <String, dynamic>{
  'workDate': instance.workDate.toIso8601String(),
  'shiftId': instance.shiftId,
};

GroupBulkAssignRequest _$GroupBulkAssignRequestFromJson(
  Map<String, dynamic> json,
) => GroupBulkAssignRequest(
  workGroupId: (json['workGroupId'] as num?)?.toInt(),
  from: DateTime.parse(json['from'] as String),
  to: DateTime.parse(json['to'] as String),
  shiftId: (json['shiftId'] as num?)?.toInt(),
  days: (json['days'] as List<dynamic>?)
      ?.map((e) => GroupScheduleDayRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$GroupBulkAssignRequestToJson(
  GroupBulkAssignRequest instance,
) => <String, dynamic>{
  'workGroupId': instance.workGroupId,
  'from': instance.from.toIso8601String(),
  'to': instance.to.toIso8601String(),
  'shiftId': instance.shiftId,
  'days': instance.days,
};

EmployeeOverrideItem _$EmployeeOverrideItemFromJson(
  Map<String, dynamic> json,
) => EmployeeOverrideItem(
  employeeId: (json['employeeId'] as num).toInt(),
  workDate: DateTime.parse(json['workDate'] as String),
  overrideShiftId: (json['overrideShiftId'] as num).toInt(),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$EmployeeOverrideItemToJson(
  EmployeeOverrideItem instance,
) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'workDate': instance.workDate.toIso8601String(),
  'overrideShiftId': instance.overrideShiftId,
  'reason': instance.reason,
};

EmployeeOverrideRequest _$EmployeeOverrideRequestFromJson(
  Map<String, dynamic> json,
) => EmployeeOverrideRequest(
  items: (json['items'] as List<dynamic>)
      .map((e) => EmployeeOverrideItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$EmployeeOverrideRequestToJson(
  EmployeeOverrideRequest instance,
) => <String, dynamic>{'items': instance.items};
