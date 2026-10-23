import 'employee_model.dart';

class LeaveRequest {
  final int id;
  final int employeeId;
  final DateTime startDate;
  final DateTime endDate;
  final String? leaveType;
  final String? reason;
  final String? status;
  final int? approvedByEmployeeId;
  final String? rejectReason;
  final DateTime createdAt;
  final Employee? employee;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.startDate,
    required this.endDate,
    this.leaveType,
    this.reason,
    this.status,
    this.approvedByEmployeeId,
    this.rejectReason,
    required this.createdAt,
    this.employee,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'],
        employeeId: json['employeeId'],
        startDate: DateTime.parse(json['startDate']),
        endDate: DateTime.parse(json['endDate']),
        leaveType: json['leaveType'],
        reason: json['reason'],
        status: json['status'],
        approvedByEmployeeId: json['approvedByEmployeeId'],
        rejectReason: json['rejectReason'],
        createdAt: DateTime.parse(json['createdAt']),
        employee: json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      );
}
