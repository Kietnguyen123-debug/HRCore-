import 'package:json_annotation/json_annotation.dart';
export 'admin_models.dart';
export 'common_models.dart';
export 'attendance_request_dto.dart';

part 'attendance_models.g.dart';

class AttendanceItemDto {
  final int id;
  final DateTime workDate;
  final DateTime checkInTime;
  final DateTime? checkOutTime;
  final int lateMinutes;
  final int earlyLeaveMinutes;
  final int workedMinutes;
  final int overtimeMinutes;
  final String? status;
  final String? note;

  const AttendanceItemDto({
    required this.id,
    required this.workDate,
    required this.checkInTime,
    this.checkOutTime,
    this.lateMinutes = 0,
    this.earlyLeaveMinutes = 0,
    this.workedMinutes = 0,
    this.overtimeMinutes = 0,
    this.status,
    this.note,
  });

  factory AttendanceItemDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
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

    final id = parseInt(findKey(['id', 'Id']));
    final workDate = parseDate(findKey(['workDate', 'WorkDate', 'date', 'Date'])) ?? DateTime.now();
    final checkIn = parseDate(findKey(['checkInTime', 'CheckInTime', 'checkIn', 'CheckIn'])) ?? workDate;
    final checkOut = parseDate(findKey(['checkOutTime', 'CheckOutTime', 'checkOut', 'CheckOut']));

    return AttendanceItemDto(
      id: id,
      workDate: workDate,
      checkInTime: checkIn,
      checkOutTime: checkOut,
      lateMinutes: parseInt(findKey(['lateMinutes', 'LateMinutes'])),
      earlyLeaveMinutes: parseInt(findKey(['earlyLeaveMinutes', 'EarlyLeaveMinutes'])),
      workedMinutes: parseInt(findKey(['workedMinutes', 'WorkedMinutes'])),
      overtimeMinutes: parseInt(findKey(['overtimeMinutes', 'OvertimeMinutes'])),
      status: findKey(['status', 'Status']) as String?,
      note: findKey(['note', 'Note']) as String?,
    );
  }

  // UI helper for legacy Map-based code
  dynamic operator [](String key) {
    final map = {
      'id': id,
      'workDate': workDate.toIso8601String(),
      'checkInTime': checkInTime.toIso8601String(),
      'checkOutTime': checkOutTime?.toIso8601String(),
      'lateMinutes': lateMinutes,
      'status': status,
    };
    return map[key];
  }
}

@JsonSerializable(createToJson: true)
class AdjustAttendanceRequest {
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final String reason;

  const AdjustAttendanceRequest({
    this.checkInTime,
    this.checkOutTime,
    required this.reason,
  });

  factory AdjustAttendanceRequest.fromJson(Map<String, dynamic> json) => _$AdjustAttendanceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AdjustAttendanceRequestToJson(this);
}

@JsonSerializable(createToJson: false)
class AttendanceSummaryDto {
  final int totalDays;
  final int presentDays;
  final int totalWorkedMinutes;
  final int totalLateMinutes;
  final int totalEarlyLeaveMinutes;

  const AttendanceSummaryDto({
    required this.totalDays,
    required this.presentDays,
    required this.totalWorkedMinutes,
    required this.totalLateMinutes,
    required this.totalEarlyLeaveMinutes,
  });

  factory AttendanceSummaryDto.fromJson(Map<String, dynamic> json) => _$AttendanceSummaryDtoFromJson(json);
}

@JsonSerializable(createToJson: true)
class RegisterFaceRequest {
  final int? employeeId;
  final String faceImageBase64;

  const RegisterFaceRequest({this.employeeId, required this.faceImageBase64});
  factory RegisterFaceRequest.fromJson(Map<String, dynamic> json) => _$RegisterFaceRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterFaceRequestToJson(this);
}

/// Class phản hồi kết quả điểm danh (Check-In / Check-Out) từ Backend
/// (Không dùng @JsonSerializable để tránh xung đột với build_runner)
class AttendanceActionResponse {
  final bool success;
  final String? message;
  final String? errorCode;

  const AttendanceActionResponse({
    required this.success,
    this.message,
    this.errorCode,
  });

  factory AttendanceActionResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceActionResponse(
      success: json['success'] as bool? ?? json['Success'] as bool? ?? false,
      message: json['message'] as String? ?? json['Message'] as String?,
      errorCode: json['errorCode'] as String? ?? json['ErrorCode'] as String?,
    );
  }
}