import 'package:json_annotation/json_annotation.dart';

part 'admin_models.g.dart';

@JsonSerializable(createToJson: true)
class TodaySummaryResponse {
  final int totalEmployees;
  final int checkedInCount;
  final int notCheckedInCount;
  final int lateCount;
  final int pendingLeaveRequests;

  const TodaySummaryResponse({
    required this.totalEmployees,
    required this.checkedInCount,
    required this.notCheckedInCount,
    required this.lateCount,
    required this.pendingLeaveRequests,
  });

  factory TodaySummaryResponse.fromJson(Map<String, dynamic> json) => _$TodaySummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$TodaySummaryResponseToJson(this);

  // Thêm toán tử [] để UI cũ không bị lỗi khi truy cập dạng Map
  dynamic operator [](String key) {
    final map = toJson();
    return map[key];
  }
}

@JsonSerializable(createToJson: true)
class DashboardOverviewResponse {
  final int totalEmployees;
  final int activeEmployees;
  final int inactiveEmployees;
  final int activatedEmployees;
  final int notActivatedEmployees;
  final int presentToday;
  final int absentToday;
  final int lateToday;
  final int earlyLeaveToday;
  final int onLeaveToday;
  final int checkedInButNotCheckedOut;
  final int pendingLeaveRequests;
  final int pendingAttendanceExplanations;
  final int pendingOvertimeRequests;
  final int pendingSalaryAdvanceRequests;

  const DashboardOverviewResponse({
    required this.totalEmployees,
    required this.activeEmployees,
    required this.inactiveEmployees,
    required this.activatedEmployees,
    required this.notActivatedEmployees,
    required this.presentToday,
    required this.absentToday,
    required this.lateToday,
    required this.earlyLeaveToday,
    required this.onLeaveToday,
    required this.checkedInButNotCheckedOut,
    required this.pendingLeaveRequests,
    required this.pendingAttendanceExplanations,
    required this.pendingOvertimeRequests,
    required this.pendingSalaryAdvanceRequests,
  });

  factory DashboardOverviewResponse.fromJson(Map<String, dynamic> json) => _$DashboardOverviewResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardOverviewResponseToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class DashboardPendingCountsResponse {
  final int pendingLeave;
  final int pendingAttendanceExplanation;
  final int pendingOvertime;
  final int pendingSalaryAdvance;

  const DashboardPendingCountsResponse({
    required this.pendingLeave,
    required this.pendingAttendanceExplanation,
    required this.pendingOvertime,
    required this.pendingSalaryAdvance,
  });

  factory DashboardPendingCountsResponse.fromJson(Map<String, dynamic> json) => _$DashboardPendingCountsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardPendingCountsResponseToJson(this);
  
  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class DashboardAttendanceSummaryResponse {
  final int totalEmployees;
  final int checkedIn;
  final int checkedOut;
  final int absent;
  final int late;
  final int earlyLeave;
  final int missingCheckIn;
  final int missingCheckOut;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;

  const DashboardAttendanceSummaryResponse({
    required this.totalEmployees,
    required this.checkedIn,
    required this.checkedOut,
    required this.absent,
    required this.late,
    required this.earlyLeave,
    required this.missingCheckIn,
    required this.missingCheckOut,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
  });

  factory DashboardAttendanceSummaryResponse.fromJson(Map<String, dynamic> json) => _$DashboardAttendanceSummaryResponseFromJson(json);
  Map<String, dynamic> toJson() => _$DashboardAttendanceSummaryResponseToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class AdminAttendanceDto {
  final int? attendanceId;
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final int branchId;
  final String? branchName;
  final DateTime workDate;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final int lateMinutes;
  final int earlyLeaveMinutes;
  final String? status;
  final String? note;

  const AdminAttendanceDto({
    this.attendanceId,
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    required this.branchId,
    this.branchName,
    required this.workDate,
    this.checkInTime,
    this.checkOutTime,
    required this.lateMinutes,
    required this.earlyLeaveMinutes,
    this.status,
    this.note,
  });

  factory AdminAttendanceDto.fromJson(Map<String, dynamic> json) => _$AdminAttendanceDtoFromJson(json);
  Map<String, dynamic> toJson() => _$AdminAttendanceDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class AdminLeaveDto {
  final int id;
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final int branchId;
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType;
  final String reason;
  final String status;
  final int? reviewerId;
  final String? reviewNote;
  final DateTime createdAt;

  const AdminLeaveDto({
    required this.id,
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    required this.branchId,
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
    required this.status,
    this.reviewerId,
    this.reviewNote,
    required this.createdAt,
  });

  factory AdminLeaveDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    return AdminLeaveDto(
      id: parseInt(findKey(['id', 'Id', 'ID'])),
      employeeId: parseInt(findKey(['employeeId', 'EmployeeId'])),
      employeeCode: findKey(['employeeCode', 'EmployeeCode', 'code', 'Code'])?.toString(),
      employeeName: findKey(['employeeName', 'EmployeeName', 'fullName', 'FullName', 'name', 'Name'])?.toString(),
      branchId: parseInt(findKey(['branchId', 'BranchId'])),
      startDate: parseDate(findKey(['startDate', 'StartDate'])),
      endDate: parseDate(findKey(['endDate', 'EndDate'])),
      leaveType: findKey(['leaveType', 'LeaveType'])?.toString() ?? 'Phép',
      reason: findKey(['reason', 'Reason'])?.toString() ?? 'Không có lý do',
      status: findKey(['status', 'Status'])?.toString() ?? 'PENDING',
      reviewerId: findKey(['reviewerId', 'ReviewerId']) != null ? parseInt(findKey(['reviewerId', 'ReviewerId'])) : null,
      reviewNote: findKey(['reviewNote', 'ReviewNote'])?.toString(),
      createdAt: parseDate(findKey(['createdAt', 'CreatedAt'])),
    );
  }

  Map<String, dynamic> toJson() => _$AdminLeaveDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class AdminOvertimeDto {
  final int id;
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final int branchId;
  final DateTime workDate;
  final double hours;
  final double multiplier;
  final String status;

  const AdminOvertimeDto({
    required this.id,
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    required this.branchId,
    required this.workDate,
    required this.hours,
    required this.multiplier,
    required this.status,
  });

  factory AdminOvertimeDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    return AdminOvertimeDto(
      id: parseInt(findKey(['id', 'Id', 'ID'])),
      employeeId: parseInt(findKey(['employeeId', 'EmployeeId'])),
      employeeCode: findKey(['employeeCode', 'EmployeeCode', 'code', 'Code'])?.toString(),
      employeeName: findKey(['employeeName', 'EmployeeName', 'fullName', 'FullName', 'name', 'Name'])?.toString(),
      branchId: parseInt(findKey(['branchId', 'BranchId'])),
      workDate: parseDate(findKey(['workDate', 'WorkDate'])),
      hours: parseDouble(findKey(['hours', 'Hours'])),
      multiplier: parseDouble(findKey(['multiplier', 'Multiplier'])) == 0.0 ? 1.5 : parseDouble(findKey(['multiplier', 'Multiplier'])),
      status: findKey(['status', 'Status'])?.toString() ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() => _$AdminOvertimeDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class AdminSalaryAdvanceDto {
  final int id;
  final int employeeId;
  final String? employeeCode;
  final String? employeeName;
  final int branchId;
  final double amount;
  final String reason;
  final DateTime requestDate;
  final String status;
  final int? approvedById;
  final String? reviewNote;
  final DateTime createdAt;

  const AdminSalaryAdvanceDto({
    required this.id,
    required this.employeeId,
    this.employeeCode,
    this.employeeName,
    required this.branchId,
    required this.amount,
    required this.reason,
    required this.requestDate,
    required this.status,
    this.approvedById,
    this.reviewNote,
    required this.createdAt,
  });

  factory AdminSalaryAdvanceDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val == null) return 0;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    return AdminSalaryAdvanceDto(
      id: parseInt(findKey(['id', 'Id', 'ID'])),
      employeeId: parseInt(findKey(['employeeId', 'EmployeeId'])),
      employeeCode: findKey(['employeeCode', 'EmployeeCode', 'code', 'Code'])?.toString(),
      employeeName: findKey(['employeeName', 'EmployeeName', 'fullName', 'FullName', 'name', 'Name'])?.toString(),
      branchId: parseInt(findKey(['branchId', 'BranchId'])),
      amount: parseDouble(findKey(['amount', 'Amount'])),
      reason: findKey(['reason', 'Reason', 'note', 'Note'])?.toString() ?? 'Chưa có lý do',
      requestDate: parseDate(findKey(['requestDate', 'RequestDate', 'createdAt', 'CreatedAt'])),
      status: findKey(['status', 'Status'])?.toString() ?? 'PENDING',
      approvedById: findKey(['approvedById', 'ApprovedById']) != null ? parseInt(findKey(['approvedById', 'ApprovedById'])) : null,
      reviewNote: findKey(['reviewNote', 'ReviewNote'])?.toString(),
      createdAt: parseDate(findKey(['createdAt', 'CreatedAt', 'requestDate', 'RequestDate'])),
    );
  }

  Map<String, dynamic> toJson() => _$AdminSalaryAdvanceDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class OvertimeReviewRequest {
  final bool isApproved;

  const OvertimeReviewRequest({required this.isApproved});

  Map<String, dynamic> toJson() => _$OvertimeReviewRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class SalaryAdvanceReviewRequest {
  final bool isApproved;
  final String? reviewNote;

  const SalaryAdvanceReviewRequest({
    required this.isApproved,
    this.reviewNote,
  });

  Map<String, dynamic> toJson() => _$SalaryAdvanceReviewRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class ReviewAttendanceExplanationRequest {
  final String status;
  final String? reviewNote;

  const ReviewAttendanceExplanationRequest({
    required this.status,
    this.reviewNote,
  });

  Map<String, dynamic> toJson() => _$ReviewAttendanceExplanationRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class LeaveApprovalResponse {
  final String message;
  final String status;

  const LeaveApprovalResponse({
    required this.message,
    required this.status,
  });

  factory LeaveApprovalResponse.fromJson(Map<String, dynamic> json) => _$LeaveApprovalResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LeaveApprovalResponseToJson(this);
  
  dynamic operator [](String key) => toJson()[key];
}
