import 'package:json_annotation/json_annotation.dart';

part 'report_models.g.dart';

@JsonSerializable(createToJson: false)
class AttendanceReportDto {
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final int totalWorkDays;
  final int presentDays;
  final int absentDays;
  final int approvedLeaveDays;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;
  final double totalWorkedHours;
  final int missingCheckInCount;
  final int missingCheckOutCount;

  const AttendanceReportDto({
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    required this.totalWorkDays,
    required this.presentDays,
    required this.absentDays,
    required this.approvedLeaveDays,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
    required this.totalWorkedHours,
    required this.missingCheckInCount,
    required this.missingCheckOutCount,
  });

  factory AttendanceReportDto.fromJson(Map<String, dynamic> json) => _$AttendanceReportDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class LeaveReportDto {
  final String? status;
  final int requestCount;
  final int leaveDays;

  const LeaveReportDto({
    this.status,
    required this.requestCount,
    required this.leaveDays,
  });

  factory LeaveReportDto.fromJson(Map<String, dynamic> json) => _$LeaveReportDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class OvertimeReportDto {
  final String? status;
  final double totalHours;
  final int requestCount;

  const OvertimeReportDto({
    this.status,
    required this.totalHours,
    required this.requestCount,
  });

  factory OvertimeReportDto.fromJson(Map<String, dynamic> json) => _$OvertimeReportDtoFromJson(json);
}

@JsonSerializable(createToJson: false)
class MonthlyAttendanceSummaryResponse {
  final int employeeId;
  final String? employeeCode;
  final String? fullName;
  final int totalWorkDays;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;
  final double totalWorkedHours;
  final int totalApprovedLeaveDays;

  const MonthlyAttendanceSummaryResponse({
    required this.employeeId,
    this.employeeCode,
    this.fullName,
    required this.totalWorkDays,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
    required this.totalWorkedHours,
    required this.totalApprovedLeaveDays,
  });

  factory MonthlyAttendanceSummaryResponse.fromJson(Map<String, dynamic> json) => _$MonthlyAttendanceSummaryResponseFromJson(json);
}
