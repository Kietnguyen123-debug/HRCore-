import 'package:intl/intl.dart';

/// Các Enum định nghĩa loại Tab và Trạng thái lọc
enum RequestTypeTab {
  explanation('Giải trình'),
  leave('Nghỉ phép'),
  overtime('Tăng ca'),
  salaryAdvance('Tạm ứng');

  final String label;
  const RequestTypeTab(this.label);
}

enum RequestStatusFilter {
  all('ALL', 'Tất cả'),
  pending('PENDING', 'Chờ duyệt'),
  approved('APPROVED', 'Đã duyệt'),
  rejected('REJECTED', 'Từ chối'),
  cancelled('CANCELLED', 'Đã hủy');

  final String code;
  final String label;
  const RequestStatusFilter(this.code, this.label);
}

// ============================================================
// 1. MODEL GIẢI TRÌNH ĐIỂM DANH (Attendance Explanation)
// ============================================================
class AttendanceExplanationItem {
  final int? id;
  final int? employeeId;
  final String? employeeName;
  final DateTime? targetDate;
  final String? explanationReason;
  final DateTime? missingCheckInTime;
  final DateTime? missingCheckOutTime;
  final String? status;
  final String? reviewNote;
  final DateTime? createdAt;

  const AttendanceExplanationItem({
    this.id,
    this.employeeId,
    this.employeeName,
    this.targetDate,
    this.explanationReason,
    this.missingCheckInTime,
    this.missingCheckOutTime,
    this.status,
    this.reviewNote,
    this.createdAt,
  });

  /// Parse JSON an toàn từ ASP.NET Core Web API
  factory AttendanceExplanationItem.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
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

    return AttendanceExplanationItem(
      id: parseInt(findKey(['id', 'Id', 'ID'])),
      employeeId: parseInt(findKey(['employeeId', 'EmployeeId'])),
      employeeName: findKey(['employeeName', 'EmployeeName', 'fullName', 'FullName']) as String?,
      targetDate: parseDate(findKey(['targetDate', 'TargetDate', 'date', 'Date', 'workDate', 'WorkDate'])),
      explanationReason: findKey(['explanationReason', 'ExplanationReason', 'reason', 'Reason', 'explanation', 'Explanation']) as String?,
      missingCheckInTime: parseDate(findKey(['missingCheckInTime', 'MissingCheckInTime', 'missingIn', 'MissingIn', 'checkInTime', 'CheckInTime'])),
      missingCheckOutTime: parseDate(findKey(['missingCheckOutTime', 'MissingCheckOutTime', 'missingOut', 'MissingOut', 'checkOutTime', 'CheckOutTime'])),
      status: findKey(['status', 'Status']) as String?,
      reviewNote: findKey(['reviewNote', 'ReviewNote', 'note', 'Note', 'rejectReason', 'RejectReason']) as String?,
      createdAt: parseDate(findKey(['createdAt', 'CreatedAt', 'createdDate', 'CreatedDate'])),
    );
  }

  /// CopyWith hỗ trợ cập nhật trực tiếp status trong RAM khi Hủy đơn thành công
  AttendanceExplanationItem copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    DateTime? targetDate,
    String? explanationReason,
    DateTime? missingCheckInTime,
    DateTime? missingCheckOutTime,
    String? status,
    String? reviewNote,
    DateTime? createdAt,
  }) {
    return AttendanceExplanationItem(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      targetDate: targetDate ?? this.targetDate,
      explanationReason: explanationReason ?? this.explanationReason,
      missingCheckInTime: missingCheckInTime ?? this.missingCheckInTime,
      missingCheckOutTime: missingCheckOutTime ?? this.missingCheckOutTime,
      status: status ?? this.status,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Trạng thái đã chuẩn hóa (PENDING, APPROVED, REJECTED, CANCELLED)
  String get normalizedStatus {
    final s = (status ?? '').trim().toUpperCase();
    if (s == 'APPROVED' || s == 'ĐÃ DUYỆT') return 'APPROVED';
    if (s == 'REJECTED' || s == 'TỪ CHỐI') return 'REJECTED';
    if (s == 'CANCELLED' || s == 'CANCELED' || s == 'ĐÃ HỦY') return 'CANCELLED';
    return 'PENDING';
  }

  /// Format ngày giải trình (dd/MM/yyyy)
  String get formattedTargetDate =>
      targetDate != null ? DateFormat('dd/MM/yyyy').format(targetDate!) : '';

  /// Format ngày tạo đơn (dd/MM/yyyy HH:mm)
  String get formattedCreatedAt =>
      createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) : '';

  /// Format giờ vào thiếu (HH:mm)
  String? get formattedMissingIn =>
      missingCheckInTime != null ? DateFormat('HH:mm').format(missingCheckInTime!) : null;

  /// Format giờ ra thiếu (HH:mm)
  String? get formattedMissingOut =>
      missingCheckOutTime != null ? DateFormat('HH:mm').format(missingCheckOutTime!) : null;
}

// ============================================================
// 2. MODEL NGHỈ PHÉP (Leave)
// ============================================================
class LeaveItem {
  final int id;
  final DateTime startDate;
  final DateTime endDate;
  final String? leaveType;
  final String? reason;
  final String? status;
  final bool isPaidLeave;
  final String? rejectReason;
  final DateTime createdAt;

  const LeaveItem({
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

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
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

    return LeaveItem(
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

  /// CopyWith hỗ trợ cập nhật trực tiếp status trong RAM
  LeaveItem copyWith({
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
    return LeaveItem(
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

  String get normalizedStatus {
    final s = (status ?? '').trim().toUpperCase();
    if (s == 'APPROVED' || s == 'ĐÃ DUYỆT') return 'APPROVED';
    if (s == 'REJECTED' || s == 'TỪ CHỐI') return 'REJECTED';
    if (s == 'CANCELLED' || s == 'CANCELED' || s == 'ĐÃ HỦY') return 'CANCELLED';
    return 'PENDING';
  }

  String get formattedStartDate => DateFormat('dd/MM/yyyy').format(startDate);
  String get formattedEndDate => DateFormat('dd/MM/yyyy').format(endDate);

  String get formattedDateRange {
    final startStr = formattedStartDate;
    final endStr = formattedEndDate;
    return startStr == endStr ? startStr : '$startStr - $endStr';
  }

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  String get leaveTypeVietnamese {
    final t = (leaveType ?? '').toUpperCase();
    if (t == 'ANNUAL') return 'Nghỉ phép năm';
    if (t == 'SICK') return 'Nghỉ ốm';
    if (t == 'UNPAID') return 'Nghỉ không lương';
    if (t == 'MATERNITY') return 'Nghỉ thai sản';
    return leaveType ?? 'Nghỉ phép';
  }
}

// ============================================================
// 3. MODEL TĂNG CA (Overtime)
// ============================================================
class OvertimeItem {
  final int id;
  final DateTime workDate;
  final double hours;
  final double multiplier;
  final String? status;

  const OvertimeItem({
    required this.id,
    required this.workDate,
    required this.hours,
    required this.multiplier,
    this.status,
  });

  factory OvertimeItem.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    double parseDouble(dynamic val, [double defaultValue = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? defaultValue;
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
    final workDate = parseDate(findKey(['workDate', 'WorkDate', 'date', 'Date', 'createdAt', 'CreatedAt'])) ?? DateTime.now();
    final hours = parseDouble(findKey(['hours', 'Hours', 'overtimeHours', 'OvertimeHours', 'numHours', 'NumHours']));
    final multiplier = parseDouble(findKey(['multiplier', 'Multiplier', 'rate', 'Rate']), 1.0);
    final status = findKey(['status', 'Status']) as String?;

    return OvertimeItem(
      id: id,
      workDate: workDate,
      hours: hours,
      multiplier: multiplier,
      status: status,
    );
  }

  OvertimeItem copyWith({
    int? id,
    DateTime? workDate,
    double? hours,
    double? multiplier,
    String? status,
  }) {
    return OvertimeItem(
      id: id ?? this.id,
      workDate: workDate ?? this.workDate,
      hours: hours ?? this.hours,
      multiplier: multiplier ?? this.multiplier,
      status: status ?? this.status,
    );
  }

  String get normalizedStatus {
    final s = (status ?? '').trim().toUpperCase();
    if (s == 'APPROVED' || s == 'ĐÃ DUYỆT') return 'APPROVED';
    if (s == 'REJECTED' || s == 'TỪ CHỐI') return 'REJECTED';
    if (s == 'CANCELLED' || s == 'CANCELED' || s == 'ĐÃ HỦY') return 'CANCELLED';
    return 'PENDING';
  }

  String get formattedWorkDate => DateFormat('dd/MM/yyyy').format(workDate);

  String get formattedHours {
    final isInt = hours.truncateToDouble() == hours;
    return '${isInt ? hours.toInt() : hours.toStringAsFixed(1)} giờ';
  }

  String get formattedMultiplier {
    final isInt = multiplier.truncateToDouble() == multiplier;
    return 'x${isInt ? multiplier.toInt() : multiplier.toStringAsFixed(1)}';
  }
}

// ============================================================
// 4. MODEL TẠM ỨNG LƯƠNG (Salary Advance)
// ============================================================
class SalaryAdvanceItem {
  final int? id;
  final double? amount;
  final String? reason;
  final DateTime? requestDate;
  final String? status;
  final String? reviewNote;
  final DateTime? createdAt;

  const SalaryAdvanceItem({
    this.id,
    this.amount,
    this.reason,
    this.requestDate,
    this.status,
    this.reviewNote,
    this.createdAt,
  });

  factory SalaryAdvanceItem.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val);
      return null;
    }

    double? parseDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
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
    final amount = parseDouble(findKey(['amount', 'Amount', 'advanceAmount', 'AdvanceAmount']));
    final reason = findKey(['reason', 'Reason', 'advanceReason', 'AdvanceReason']) as String?;
    final reqDate = parseDate(findKey(['requestDate', 'RequestDate', 'createdDate', 'CreatedDate', 'createdAt', 'CreatedAt', 'date', 'Date']));
    final status = findKey(['status', 'Status']) as String?;
    final reviewNote = findKey(['reviewNote', 'ReviewNote', 'note', 'Note', 'rejectReason', 'RejectReason']) as String?;
    final createdAt = parseDate(findKey(['createdAt', 'CreatedAt', 'createdDate', 'CreatedDate'])) ?? reqDate;

    return SalaryAdvanceItem(
      id: id,
      amount: amount,
      reason: reason,
      requestDate: reqDate ?? createdAt,
      status: status,
      reviewNote: reviewNote,
      createdAt: createdAt,
    );
  }

  SalaryAdvanceItem copyWith({
    int? id,
    double? amount,
    String? reason,
    DateTime? requestDate,
    String? status,
    String? reviewNote,
    DateTime? createdAt,
  }) {
    return SalaryAdvanceItem(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  String get normalizedStatus {
    final s = (status ?? '').trim().toUpperCase();
    if (s == 'APPROVED' || s == 'ĐÃ DUYỆT') return 'APPROVED';
    if (s == 'REJECTED' || s == 'TỪ CHỐI') return 'REJECTED';
    if (s == 'CANCELLED' || s == 'CANCELED' || s == 'ĐÃ HỦY') return 'CANCELLED';
    return 'PENDING';
  }

  /// Format tiền tệ VND (ví dụ: 2.000.000 đ)
  String get formattedAmount {
    if (amount == null) return '0 đ';
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ', decimalDigits: 0);
    return formatter.format(amount);
  }

  String get formattedRequestDate =>
      requestDate != null ? DateFormat('dd/MM/yyyy').format(requestDate!) : '';

  String get formattedCreatedAt =>
      createdAt != null ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!) : '';
}
