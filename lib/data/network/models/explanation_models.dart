import 'package:json_annotation/json_annotation.dart';

part 'explanation_models.g.dart';

@JsonSerializable(createToJson: true)
class SubmitAttendanceExplanationRequest {
  final DateTime targetDate;
  final String explanationReason;
  final DateTime? missingCheckInTime;
  final DateTime? missingCheckOutTime;

  const SubmitAttendanceExplanationRequest({
    required this.targetDate,
    required this.explanationReason,
    this.missingCheckInTime,
    this.missingCheckOutTime,
  });

  factory SubmitAttendanceExplanationRequest.fromJson(Map<String, dynamic> json) => _$SubmitAttendanceExplanationRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SubmitAttendanceExplanationRequestToJson(this);
}

class AttendanceExplanationResponse {
  final int? id;
  final int? employeeId;
  final String? employeeName;
  final DateTime? targetDate;
  final String? explanationReason;
  final DateTime? missingCheckInTime;
  final DateTime? missingCheckOutTime;
  final String? status;
  final int? reviewerId;
  final String? reviewNote;
  final DateTime? createdAt;

  const AttendanceExplanationResponse({
    this.id,
    this.employeeId,
    this.employeeName,
    this.targetDate,
    this.explanationReason,
    this.missingCheckInTime,
    this.missingCheckOutTime,
    this.status,
    this.reviewerId,
    this.reviewNote,
    this.createdAt,
  });

  AttendanceExplanationResponse copyWith({
    int? id,
    int? employeeId,
    String? employeeName,
    DateTime? targetDate,
    String? explanationReason,
    DateTime? missingCheckInTime,
    DateTime? missingCheckOutTime,
    String? status,
    int? reviewerId,
    String? reviewNote,
    DateTime? createdAt,
  }) {
    return AttendanceExplanationResponse(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      targetDate: targetDate ?? this.targetDate,
      explanationReason: explanationReason ?? this.explanationReason,
      missingCheckInTime: missingCheckInTime ?? this.missingCheckInTime,
      missingCheckOutTime: missingCheckOutTime ?? this.missingCheckOutTime,
      status: status ?? this.status,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AttendanceExplanationResponse.fromJson(Map<String, dynamic> json) {
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

    final id = parseInt(findKey(['id', 'Id', 'ID']));
    final employeeId = parseInt(findKey(['employeeId', 'EmployeeId']));
    final employeeName = findKey(['employeeName', 'EmployeeName', 'fullName', 'FullName']) as String?;
    final targetDate = parseDate(findKey(['targetDate', 'TargetDate', 'date', 'Date', 'workDate', 'WorkDate']));
    final explanationReason = findKey(['explanationReason', 'ExplanationReason', 'reason', 'Reason', 'explanation', 'Explanation']) as String?;
    final missingIn = parseDate(findKey(['missingCheckInTime', 'MissingCheckInTime', 'missingIn', 'MissingIn', 'checkInTime', 'CheckInTime']));
    final missingOut = parseDate(findKey(['missingCheckOutTime', 'MissingCheckOutTime', 'missingOut', 'MissingOut', 'checkOutTime', 'CheckOutTime']));
    final status = findKey(['status', 'Status']) as String?;
    final reviewerId = parseInt(findKey(['reviewerId', 'ReviewerId', 'approvedById', 'ApprovedById']));
    final reviewNote = findKey(['reviewNote', 'ReviewNote', 'note', 'Note', 'rejectReason', 'RejectReason']) as String?;
    final createdAt = parseDate(findKey(['createdAt', 'CreatedAt', 'createdDate', 'CreatedDate']));

    return AttendanceExplanationResponse(
      id: id,
      employeeId: employeeId,
      employeeName: employeeName,
      targetDate: targetDate,
      explanationReason: explanationReason,
      missingCheckInTime: missingIn,
      missingCheckOutTime: missingOut,
      status: status,
      reviewerId: reviewerId,
      reviewNote: reviewNote,
      createdAt: createdAt,
    );
  }

  // Constants for Status (Strictly Uppercase)
  static const String statusPending = 'PENDING';
  static const String statusApproved = 'APPROVED';
  static const String statusRejected = 'REJECTED';
}
