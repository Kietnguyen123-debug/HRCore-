// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceReportDto _$AttendanceReportDtoFromJson(Map<String, dynamic> json) =>
    AttendanceReportDto(
      employeeId: (json['employeeId'] as num).toInt(),
      employeeCode: json['employeeCode'] as String?,
      employeeName: json['employeeName'] as String?,
      totalWorkDays: (json['totalWorkDays'] as num).toInt(),
      presentDays: (json['presentDays'] as num).toInt(),
      absentDays: (json['absentDays'] as num).toInt(),
      approvedLeaveDays: (json['approvedLeaveDays'] as num).toInt(),
      totalLateMinutes: (json['totalLateMinutes'] as num).toInt(),
      totalEarlyLeaveMinutes: (json['totalEarlyLeaveMinutes'] as num).toInt(),
      totalWorkedHours: (json['totalWorkedHours'] as num).toDouble(),
      missingCheckInCount: (json['missingCheckInCount'] as num).toInt(),
      missingCheckOutCount: (json['missingCheckOutCount'] as num).toInt(),
    );

LeaveReportDto _$LeaveReportDtoFromJson(Map<String, dynamic> json) =>
    LeaveReportDto(
      status: json['status'] as String?,
      requestCount: (json['requestCount'] as num).toInt(),
      leaveDays: (json['leaveDays'] as num).toInt(),
    );

OvertimeReportDto _$OvertimeReportDtoFromJson(Map<String, dynamic> json) =>
    OvertimeReportDto(
      status: json['status'] as String?,
      totalHours: (json['totalHours'] as num).toDouble(),
      requestCount: (json['requestCount'] as num).toInt(),
    );

MonthlyAttendanceSummaryResponse _$MonthlyAttendanceSummaryResponseFromJson(
  Map<String, dynamic> json,
) => MonthlyAttendanceSummaryResponse(
  employeeId: (json['employeeId'] as num).toInt(),
  employeeCode: json['employeeCode'] as String?,
  fullName: json['fullName'] as String?,
  totalWorkDays: (json['totalWorkDays'] as num).toInt(),
  totalLateMinutes: (json['totalLateMinutes'] as num).toInt(),
  totalEarlyLeaveMinutes: (json['totalEarlyLeaveMinutes'] as num).toInt(),
  totalWorkedHours: (json['totalWorkedHours'] as num).toDouble(),
  totalApprovedLeaveDays: (json['totalApprovedLeaveDays'] as num).toInt(),
);
