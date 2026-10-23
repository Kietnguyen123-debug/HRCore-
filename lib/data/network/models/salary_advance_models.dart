import 'package:json_annotation/json_annotation.dart';

part 'salary_advance_models.g.dart';

@JsonSerializable(createToJson: true)
class SalaryAdvanceRequest {
  final double amount;
  final String reason;

  const SalaryAdvanceRequest({
    required this.amount,
    required this.reason,
  });

  factory SalaryAdvanceRequest.fromJson(Map<String, dynamic> json) => _$SalaryAdvanceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SalaryAdvanceRequestToJson(this);
}

class SalaryAdvanceResponse {
  final int? id;
  final int? employeeId;
  final double? amount;
  final String? reason;
  final DateTime? requestDate;
  final String? status;
  final int? approvedById;
  final String? reviewNote;
  final DateTime? createdAt;

  const SalaryAdvanceResponse({
    this.id,
    this.employeeId,
    this.amount,
    this.reason,
    this.requestDate,
    this.status,
    this.approvedById,
    this.reviewNote,
    this.createdAt,
  });

  SalaryAdvanceResponse copyWith({
    int? id,
    int? employeeId,
    double? amount,
    String? reason,
    DateTime? requestDate,
    String? status,
    int? approvedById,
    String? reviewNote,
    DateTime? createdAt,
  }) {
    return SalaryAdvanceResponse(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      requestDate: requestDate ?? this.requestDate,
      status: status ?? this.status,
      approvedById: approvedById ?? this.approvedById,
      reviewNote: reviewNote ?? this.reviewNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory SalaryAdvanceResponse.fromJson(Map<String, dynamic> json) {
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
    final employeeId = parseInt(findKey(['employeeId', 'EmployeeId']));
    final amount = parseDouble(findKey(['amount', 'Amount', 'advanceAmount', 'AdvanceAmount']));
    final reason = findKey(['reason', 'Reason', 'advanceReason', 'AdvanceReason']) as String?;
    final reqDate = parseDate(findKey(['requestDate', 'RequestDate', 'createdDate', 'CreatedDate', 'createdAt', 'CreatedAt', 'date', 'Date']));
    final status = findKey(['status', 'Status']) as String?;
    final approvedById = parseInt(findKey(['approvedById', 'ApprovedById', 'reviewerId', 'ReviewerId']));
    final reviewNote = findKey(['reviewNote', 'ReviewNote', 'note', 'Note', 'rejectReason', 'RejectReason']) as String?;
    final createdAt = parseDate(findKey(['createdAt', 'CreatedAt', 'createdDate', 'CreatedDate'])) ?? reqDate;

    return SalaryAdvanceResponse(
      id: id,
      employeeId: employeeId,
      amount: amount,
      reason: reason,
      requestDate: reqDate ?? createdAt,
      status: status,
      approvedById: approvedById,
      reviewNote: reviewNote,
      createdAt: createdAt,
    );
  }

  // Constants for Status (Strictly PascalCase)
  static const String statusPending = 'Pending';
  static const String statusApproved = 'Approved';
  static const String statusRejected = 'Rejected';
}
