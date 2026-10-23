// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CreateLeaveRequest _$CreateLeaveRequestFromJson(Map<String, dynamic> json) =>
    CreateLeaveRequest(
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      leaveType: json['leaveType'] as String,
      reason: json['reason'] as String,
    );

Map<String, dynamic> _$CreateLeaveRequestToJson(CreateLeaveRequest instance) =>
    <String, dynamic>{
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'leaveType': instance.leaveType,
      'reason': instance.reason,
    };

LeaveRequestCreatedResponse _$LeaveRequestCreatedResponseFromJson(
  Map<String, dynamic> json,
) => LeaveRequestCreatedResponse(
  message: json['Message'] as String?,
  id: (json['Id'] as num?)?.toInt(),
  isPaidLeave: json['IsPaidLeave'] as bool?,
  startDate: json['StartDate'] == null
      ? null
      : DateTime.parse(json['StartDate'] as String),
  endDate: json['EndDate'] == null
      ? null
      : DateTime.parse(json['EndDate'] as String),
);

EmployeeLeaveDto _$EmployeeLeaveDtoFromJson(Map<String, dynamic> json) =>
    EmployeeLeaveDto(
      id: (json['Id'] as num).toInt(),
      startDate: DateTime.parse(json['StartDate'] as String),
      endDate: DateTime.parse(json['EndDate'] as String),
      leaveType: json['LeaveType'] as String?,
      reason: json['Reason'] as String?,
      status: json['Status'] as String?,
      isPaidLeave: json['IsPaidLeave'] as bool,
      rejectReason: json['RejectReason'] as String?,
      createdAt: DateTime.parse(json['CreatedAt'] as String),
    );

LeaveBalanceDto _$LeaveBalanceDtoFromJson(Map<String, dynamic> json) =>
    LeaveBalanceDto(
      totalAnnualLeave: (json['TotalAnnualLeave'] as num).toInt(),
      usedAnnualLeave: (json['UsedAnnualLeave'] as num).toInt(),
      remainingAnnualLeave: (json['RemainingAnnualLeave'] as num).toInt(),
    );
