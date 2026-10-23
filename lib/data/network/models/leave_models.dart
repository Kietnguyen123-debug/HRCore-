import 'package:json_annotation/json_annotation.dart';

part 'leave_models.g.dart';

@JsonSerializable(createToJson: true)
class CreateLeaveRequest {
  final DateTime startDate;
  final DateTime endDate;
  final String leaveType;
  final String reason;

  const CreateLeaveRequest({
    required this.startDate,
    required this.endDate,
    required this.leaveType,
    required this.reason,
  });

  factory CreateLeaveRequest.fromJson(Map<String, dynamic> json) => _$CreateLeaveRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateLeaveRequestToJson(this);

  // Constants for LeaveType (Strictly Uppercase)
  static const String typeAnnual = 'ANNUAL';
  static const String typeSick = 'SICK';
  static const String typeUnpaid = 'UNPAID';
  static const String typeMaternity = 'MATERNITY';
}

@JsonSerializable(createToJson: false, fieldRename: FieldRename.pascal)
class LeaveRequestCreatedResponse {
  final String? message;
  final int? id;
  final bool? isPaidLeave;
  final DateTime? startDate;
  final DateTime? endDate;

  const LeaveRequestCreatedResponse({
    this.message,
    this.id,
    this.isPaidLeave,
    this.startDate,
    this.endDate,
  });

  factory LeaveRequestCreatedResponse.fromJson(Map<String, dynamic> json) => _$LeaveRequestCreatedResponseFromJson(json);
}

class EmployeeLeaveDto {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String? leaveType;
  final String? reason;
  final String? status;
  final bool isPaidLeave;
  final String? rejectReason;
  final DateTime createdAt;

  const EmployeeLeaveDto({
    required this.id,
    required this.startDate,
    required this.endDate,
    this.leaveType,
    this.reason,
    this.status,
    required this.isPaidLeave,
    this.rejectReason,
    required this.createdAt,
  });

  EmployeeLeaveDto copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    String? leaveType,
    String? reason,
    String? status,
    bool? isPaidLeave,
    String? rejectReason,
    DateTime? createdAt,
  }) {
    return EmployeeLeaveDto(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      leaveType: leaveType ?? this.leaveType,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      isPaidLeave: isPaidLeave ?? this.isPaidLeave,
      rejectReason: rejectReason ?? this.rejectReason,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory EmployeeLeaveDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    bool parseBool(dynamic val, [bool defaultValue = false]) {
      if (val is bool) return val;
      if (val is num) return val != 0;
      if (val is String) {
        final s = val.toLowerCase();
        if (s == 'true' || s == '1') return true;
        if (s == 'false' || s == '0') return false;
      }
      return defaultValue;
    }

    DateTime? parseDate(dynamic val) {
      if (val == null) return null;
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return null;
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    final id = parseInt(findKey(['id', 'Id', 'ID']));
    final startDate = parseDate(findKey(['startDate', 'StartDate', 'from', 'From', 'fromDate', 'FromDate'])) ?? DateTime.now();
    final endDate = parseDate(findKey(['endDate', 'EndDate', 'to', 'To', 'toDate', 'ToDate'])) ?? startDate;
    final leaveType = findKey(['leaveType', 'LeaveType', 'type', 'Type']) as String?;
    final reason = findKey(['reason', 'Reason', 'leaveReason', 'LeaveReason']) as String?;
    final status = findKey(['status', 'Status']) as String?;
    final isPaidLeave = parseBool(findKey(['isPaidLeave', 'IsPaidLeave', 'isPaid', 'IsPaid']), true);
    final rejectReason = findKey(['rejectReason', 'RejectReason', 'reviewNote', 'ReviewNote', 'note', 'Note']) as String?;
    final createdAt = parseDate(findKey(['createdAt', 'CreatedAt', 'createdDate', 'CreatedDate'])) ?? startDate;

    return EmployeeLeaveDto(
      id: id,
      startDate: startDate,
      endDate: endDate,
      leaveType: leaveType,
      reason: reason,
      status: status,
      isPaidLeave: isPaidLeave,
      rejectReason: rejectReason,
      createdAt: createdAt,
    );
  }

  // Constants for Status (Strictly Uppercase)
  static const String statusPending = 'PENDING';
  static const String statusApproved = 'APPROVED';
  static const String statusRejected = 'REJECTED';
  static const String statusCancelled = 'CANCELLED';
}

class LeaveBalanceDto {
  final int totalAnnualLeave;
  final int usedAnnualLeave;
  final int remainingAnnualLeave;

  const LeaveBalanceDto({
    required this.totalAnnualLeave,
    required this.usedAnnualLeave,
    required this.remainingAnnualLeave,
  });

  factory LeaveBalanceDto.fromJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> json = rawJson;
    if (rawJson.containsKey('data') && rawJson['data'] is Map) {
      json = Map<String, dynamic>.from(rawJson['data'] as Map);
    } else if (rawJson.containsKey('result') && rawJson['result'] is Map) {
      json = Map<String, dynamic>.from(rawJson['result'] as Map);
    }

    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    dynamic findValue(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) {
          return json[k];
        }
      }
      return null;
    }

    final totalVal = findValue([
      'totalAnnualLeave', 'TotalAnnualLeave',
      'totalLeave', 'TotalLeave',
      'totalAnnualLeaveDays', 'TotalAnnualLeaveDays',
      'totalDays', 'TotalDays'
    ]);

    final usedVal = findValue([
      'usedAnnualLeave', 'UsedAnnualLeave',
      'usedLeave', 'UsedLeave',
      'usedAnnualLeaveDays', 'UsedAnnualLeaveDays',
      'usedDays', 'UsedDays'
    ]);

    final remainingVal = findValue([
      'remainingAnnualLeave', 'RemainingAnnualLeave',
      'remainingLeave', 'RemainingLeave',
      'remainingAnnualLeaveDays', 'RemainingAnnualLeaveDays',
      'remainingDays', 'RemainingDays'
    ]);

    final total = parseInt(totalVal);
    final used = parseInt(usedVal);

    int remaining;
    if (remainingVal != null) {
      remaining = parseInt(remainingVal);
    } else if (totalVal != null) {
      remaining = total - used;
    } else {
      remaining = 0;
    }

    return LeaveBalanceDto(
      totalAnnualLeave: totalVal != null ? total : 12,
      usedAnnualLeave: used,
      remainingAnnualLeave: remaining,
    );
  }

  Map<String, dynamic> toJson() => {
    'totalAnnualLeave': totalAnnualLeave,
    'usedAnnualLeave': usedAnnualLeave,
    'remainingAnnualLeave': remainingAnnualLeave,
  };
}
