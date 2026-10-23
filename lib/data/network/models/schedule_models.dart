import 'package:json_annotation/json_annotation.dart';

part 'schedule_models.g.dart';

@JsonSerializable(createToJson: true)
class ResolvedShiftDto {
  final int? assignmentId;
  final DateTime workDate;
  final int? shiftId;
  final String? shiftCode;
  final String? shiftName;
  final String? startTime;
  final String? endTime;
  final String? source;
  final int? exceptionId;

  const ResolvedShiftDto({
    this.assignmentId,
    required this.workDate,
    this.shiftId,
    this.shiftCode,
    this.shiftName,
    this.startTime,
    this.endTime,
    this.source,
    this.exceptionId,
  });

  factory ResolvedShiftDto.fromJson(Map<String, dynamic> json) => _$ResolvedShiftDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ResolvedShiftDtoToJson(this);
}

@JsonSerializable(createToJson: true)
class RosterEmployeeDto {
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final String? workGroupName;
  final List<ResolvedShiftDto>? days;

  const RosterEmployeeDto({
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    this.workGroupName,
    this.days,
  });

  factory RosterEmployeeDto.fromJson(Map<String, dynamic> json) => _$RosterEmployeeDtoFromJson(json);
  Map<String, dynamic> toJson() => _$RosterEmployeeDtoToJson(this);
}

@JsonSerializable(createToJson: true)
class RosterResponse {
  final DateTime from;
  final DateTime to;
  final List<RosterEmployeeDto>? employees;

  const RosterResponse({
    required this.from,
    required this.to,
    this.employees,
  });

  factory RosterResponse.fromJson(Map<String, dynamic> json) => _$RosterResponseFromJson(json);
  Map<String, dynamic> toJson() => _$RosterResponseToJson(this);
}

@JsonSerializable(createToJson: true)
class GroupScheduleDayRequest {
  final DateTime workDate;
  final int? shiftId;

  const GroupScheduleDayRequest({
    required this.workDate,
    this.shiftId,
  });

  factory GroupScheduleDayRequest.fromJson(Map<String, dynamic> json) => _$GroupScheduleDayRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GroupScheduleDayRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class GroupBulkAssignRequest {
  final int? workGroupId;
  final DateTime from;
  final DateTime to;
  final int? shiftId;
  final List<GroupScheduleDayRequest>? days;

  const GroupBulkAssignRequest({
    this.workGroupId,
    required this.from,
    required this.to,
    this.shiftId,
    this.days,
  });

  factory GroupBulkAssignRequest.fromJson(Map<String, dynamic> json) => _$GroupBulkAssignRequestFromJson(json);
  Map<String, dynamic> toJson() => _$GroupBulkAssignRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class EmployeeOverrideItem {
  final int employeeId;
  final DateTime workDate;
  final int overrideShiftId;
  final String reason;

  const EmployeeOverrideItem({
    required this.employeeId,
    required this.workDate,
    required this.overrideShiftId,
    required this.reason,
  });

  factory EmployeeOverrideItem.fromJson(Map<String, dynamic> json) => _$EmployeeOverrideItemFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeOverrideItemToJson(this);
}

@JsonSerializable(createToJson: true)
class EmployeeOverrideRequest {
  final List<EmployeeOverrideItem> items;

  const EmployeeOverrideRequest({required this.items});

  factory EmployeeOverrideRequest.fromJson(Map<String, dynamic> json) => _$EmployeeOverrideRequestFromJson(json);
  Map<String, dynamic> toJson() => _$EmployeeOverrideRequestToJson(this);
}
