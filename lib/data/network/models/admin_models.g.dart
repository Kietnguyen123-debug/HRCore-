// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodaySummaryResponse _$TodaySummaryResponseFromJson(
  Map<String, dynamic> json,
) => TodaySummaryResponse(
  totalEmployees: (json['totalEmployees'] as num).toInt(),
  checkedInCount: (json['checkedInCount'] as num).toInt(),
  notCheckedInCount: (json['notCheckedInCount'] as num).toInt(),
  lateCount: (json['lateCount'] as num).toInt(),
  pendingLeaveRequests: (json['pendingLeaveRequests'] as num).toInt(),
);

Map<String, dynamic> _$TodaySummaryResponseToJson(
  TodaySummaryResponse instance,
) => <String, dynamic>{
  'totalEmployees': instance.totalEmployees,
  'checkedInCount': instance.checkedInCount,
  'notCheckedInCount': instance.notCheckedInCount,
  'lateCount': instance.lateCount,
  'pendingLeaveRequests': instance.pendingLeaveRequests,
};

DashboardOverviewResponse _$DashboardOverviewResponseFromJson(
  Map<String, dynamic> json,
) => DashboardOverviewResponse(
  totalEmployees: (json['totalEmployees'] as num).toInt(),
  activeEmployees: (json['activeEmployees'] as num).toInt(),
  inactiveEmployees: (json['inactiveEmployees'] as num).toInt(),
  activatedEmployees: (json['activatedEmployees'] as num).toInt(),
  notActivatedEmployees: (json['notActivatedEmployees'] as num).toInt(),
  presentToday: (json['presentToday'] as num).toInt(),
  absentToday: (json['absentToday'] as num).toInt(),
  lateToday: (json['lateToday'] as num).toInt(),
  earlyLeaveToday: (json['earlyLeaveToday'] as num).toInt(),
  onLeaveToday: (json['onLeaveToday'] as num).toInt(),
  checkedInButNotCheckedOut: (json['checkedInButNotCheckedOut'] as num).toInt(),
  pendingLeaveRequests: (json['pendingLeaveRequests'] as num).toInt(),
  pendingAttendanceExplanations: (json['pendingAttendanceExplanations'] as num)
      .toInt(),
  pendingOvertimeRequests: (json['pendingOvertimeRequests'] as num).toInt(),
  pendingSalaryAdvanceRequests: (json['pendingSalaryAdvanceRequests'] as num)
      .toInt(),
);

Map<String, dynamic> _$DashboardOverviewResponseToJson(
  DashboardOverviewResponse instance,
) => <String, dynamic>{
  'totalEmployees': instance.totalEmployees,
  'activeEmployees': instance.activeEmployees,
  'inactiveEmployees': instance.inactiveEmployees,
  'activatedEmployees': instance.activatedEmployees,
  'notActivatedEmployees': instance.notActivatedEmployees,
  'presentToday': instance.presentToday,
  'absentToday': instance.absentToday,
  'lateToday': instance.lateToday,
  'earlyLeaveToday': instance.earlyLeaveToday,
  'onLeaveToday': instance.onLeaveToday,
  'checkedInButNotCheckedOut': instance.checkedInButNotCheckedOut,
  'pendingLeaveRequests': instance.pendingLeaveRequests,
  'pendingAttendanceExplanations': instance.pendingAttendanceExplanations,
  'pendingOvertimeRequests': instance.pendingOvertimeRequests,
  'pendingSalaryAdvanceRequests': instance.pendingSalaryAdvanceRequests,
};

DashboardPendingCountsResponse _$DashboardPendingCountsResponseFromJson(
  Map<String, dynamic> json,
) => DashboardPendingCountsResponse(
  pendingLeave: (json['pendingLeave'] as num).toInt(),
  pendingAttendanceExplanation: (json['pendingAttendanceExplanation'] as num)
      .toInt(),
  pendingOvertime: (json['pendingOvertime'] as num).toInt(),
  pendingSalaryAdvance: (json['pendingSalaryAdvance'] as num).toInt(),
);

Map<String, dynamic> _$DashboardPendingCountsResponseToJson(
  DashboardPendingCountsResponse instance,
) => <String, dynamic>{
  'pendingLeave': instance.pendingLeave,
  'pendingAttendanceExplanation': instance.pendingAttendanceExplanation,
  'pendingOvertime': instance.pendingOvertime,
  'pendingSalaryAdvance': instance.pendingSalaryAdvance,
};

DashboardAttendanceSummaryResponse _$DashboardAttendanceSummaryResponseFromJson(
  Map<String, dynamic> json,
) => DashboardAttendanceSummaryResponse(
  totalEmployees: (json['totalEmployees'] as num?)?.toInt() ?? 0,
  checkedIn: (json['checkedIn'] as num?)?.toInt() ?? 0,
  checkedOut: (json['checkedOut'] as num?)?.toInt() ?? 0,
  absent: (json['absent'] as num?)?.toInt() ?? 0,
  late: (json['late'] as num?)?.toInt() ?? 0,
  earlyLeave: (json['earlyLeave'] as num?)?.toInt() ?? 0,
  missingCheckIn: (json['missingCheckIn'] as num?)?.toInt() ?? 0,
  missingCheckOut: (json['missingCheckOut'] as num?)?.toInt() ?? 0,
  totalLateMinutes: (json['totalLateMinutes'] as num?)?.toInt() ?? 0,
  totalEarlyLeaveMinutes: (json['totalEarlyLeaveMinutes'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DashboardAttendanceSummaryResponseToJson(
  DashboardAttendanceSummaryResponse instance,
) => <String, dynamic>{
  'totalEmployees': instance.totalEmployees,
  'checkedIn': instance.checkedIn,
  'checkedOut': instance.checkedOut,
  'absent': instance.absent,
  'late': instance.late,
  'earlyLeave': instance.earlyLeave,
  'missingCheckIn': instance.missingCheckIn,
  'missingCheckOut': instance.missingCheckOut,
  'totalLateMinutes': instance.totalLateMinutes,
  'totalEarlyLeaveMinutes': instance.totalEarlyLeaveMinutes,
};

AdminAttendanceDto _$AdminAttendanceDtoFromJson(Map<String, dynamic> json) =>
    AdminAttendanceDto(
      attendanceId: (json['attendanceId'] as num?)?.toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      employeeCode: json['employeeCode'] as String?,
      employeeName: json['employeeName'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      branchName: json['branchName'] as String?,
      workDate: DateTime.parse(json['workDate'] as String),
      checkInTime: json['checkInTime'] == null
          ? null
          : DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] == null
          ? null
          : DateTime.parse(json['checkOutTime'] as String),
      lateMinutes: (json['lateMinutes'] as num).toInt(),
      earlyLeaveMinutes: (json['earlyLeaveMinutes'] as num).toInt(),
      status: json['status'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$AdminAttendanceDtoToJson(AdminAttendanceDto instance) =>
    <String, dynamic>{
      'attendanceId': instance.attendanceId,
      'employeeId': instance.employeeId,
      'employeeCode': instance.employeeCode,
      'employeeName': instance.employeeName,
      'branchId': instance.branchId,
      'branchName': instance.branchName,
      'workDate': instance.workDate.toIso8601String(),
      'checkInTime': instance.checkInTime?.toIso8601String(),
      'checkOutTime': instance.checkOutTime?.toIso8601String(),
      'lateMinutes': instance.lateMinutes,
      'earlyLeaveMinutes': instance.earlyLeaveMinutes,
      'status': instance.status,
      'note': instance.note,
    };

AdminLeaveDto _$AdminLeaveDtoFromJson(Map<String, dynamic> json) =>
    AdminLeaveDto(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      employeeCode: json['employeeCode'] as String?,
      employeeName: json['employeeName'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      leaveType: json['leaveType'] as String,
      reason: json['reason'] as String,
      status: json['status'] as String,
      reviewerId: (json['reviewerId'] as num?)?.toInt(),
      reviewNote: json['reviewNote'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$AdminLeaveDtoToJson(AdminLeaveDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeCode': instance.employeeCode,
      'employeeName': instance.employeeName,
      'branchId': instance.branchId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'leaveType': instance.leaveType,
      'reason': instance.reason,
      'status': instance.status,
      'reviewerId': instance.reviewerId,
      'reviewNote': instance.reviewNote,
      'createdAt': instance.createdAt.toIso8601String(),
    };

AdminOvertimeDto _$AdminOvertimeDtoFromJson(Map<String, dynamic> json) =>
    AdminOvertimeDto(
      id: (json['id'] as num).toInt(),
      employeeId: (json['employeeId'] as num).toInt(),
      employeeCode: json['employeeCode'] as String?,
      employeeName: json['employeeName'] as String?,
      branchId: (json['branchId'] as num).toInt(),
      workDate: DateTime.parse(json['workDate'] as String),
      hours: (json['hours'] as num).toDouble(),
      multiplier: (json['multiplier'] as num).toDouble(),
      status: json['status'] as String,
    );

Map<String, dynamic> _$AdminOvertimeDtoToJson(AdminOvertimeDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'employeeCode': instance.employeeCode,
      'employeeName': instance.employeeName,
      'branchId': instance.branchId,
      'workDate': instance.workDate.toIso8601String(),
      'hours': instance.hours,
      'multiplier': instance.multiplier,
      'status': instance.status,
    };

AdminSalaryAdvanceDto _$AdminSalaryAdvanceDtoFromJson(
  Map<String, dynamic> json,
) => AdminSalaryAdvanceDto(
  id: (json['id'] as num).toInt(),
  employeeId: (json['employeeId'] as num).toInt(),
  employeeCode: json['employeeCode'] as String?,
  employeeName: json['employeeName'] as String?,
  branchId: (json['branchId'] as num).toInt(),
  amount: (json['amount'] as num).toDouble(),
  reason: json['reason'] as String,
  requestDate: DateTime.parse(json['requestDate'] as String),
  status: json['status'] as String,
  approvedById: (json['approvedById'] as num?)?.toInt(),
  reviewNote: json['reviewNote'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$AdminSalaryAdvanceDtoToJson(
  AdminSalaryAdvanceDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'employeeId': instance.employeeId,
  'employeeCode': instance.employeeCode,
  'employeeName': instance.employeeName,
  'branchId': instance.branchId,
  'amount': instance.amount,
  'reason': instance.reason,
  'requestDate': instance.requestDate.toIso8601String(),
  'status': instance.status,
  'approvedById': instance.approvedById,
  'reviewNote': instance.reviewNote,
  'createdAt': instance.createdAt.toIso8601String(),
};

OvertimeReviewRequest _$OvertimeReviewRequestFromJson(
  Map<String, dynamic> json,
) => OvertimeReviewRequest(isApproved: json['isApproved'] as bool);

Map<String, dynamic> _$OvertimeReviewRequestToJson(
  OvertimeReviewRequest instance,
) => <String, dynamic>{'isApproved': instance.isApproved};

SalaryAdvanceReviewRequest _$SalaryAdvanceReviewRequestFromJson(
  Map<String, dynamic> json,
) => SalaryAdvanceReviewRequest(
  isApproved: json['isApproved'] as bool,
  reviewNote: json['reviewNote'] as String?,
);

Map<String, dynamic> _$SalaryAdvanceReviewRequestToJson(
  SalaryAdvanceReviewRequest instance,
) => <String, dynamic>{
  'isApproved': instance.isApproved,
  'reviewNote': instance.reviewNote,
};

ReviewAttendanceExplanationRequest _$ReviewAttendanceExplanationRequestFromJson(
  Map<String, dynamic> json,
) => ReviewAttendanceExplanationRequest(
  status: json['status'] as String,
  reviewNote: json['reviewNote'] as String?,
);

Map<String, dynamic> _$ReviewAttendanceExplanationRequestToJson(
  ReviewAttendanceExplanationRequest instance,
) => <String, dynamic>{
  'status': instance.status,
  'reviewNote': instance.reviewNote,
};

LeaveApprovalResponse _$LeaveApprovalResponseFromJson(
  Map<String, dynamic> json,
) => LeaveApprovalResponse(
  message: json['message'] as String,
  status: json['status'] as String,
);

Map<String, dynamic> _$LeaveApprovalResponseToJson(
  LeaveApprovalResponse instance,
) => <String, dynamic>{'message': instance.message, 'status': instance.status};
