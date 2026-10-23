// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceItemDto _$AttendanceItemDtoFromJson(Map<String, dynamic> json) =>
    AttendanceItemDto(
      id: (json['id'] as num).toInt(),
      workDate: DateTime.parse(json['workDate'] as String),
      checkInTime: DateTime.parse(json['checkInTime'] as String),
      checkOutTime: json['checkOutTime'] == null
          ? null
          : DateTime.parse(json['checkOutTime'] as String),
      lateMinutes: (json['lateMinutes'] as num?)?.toInt() ?? 0,
      earlyLeaveMinutes: (json['earlyLeaveMinutes'] as num?)?.toInt() ?? 0,
      workedMinutes: (json['workedMinutes'] as num?)?.toInt() ?? 0,
      overtimeMinutes: (json['overtimeMinutes'] as num?)?.toInt() ?? 0,
      status: json['status'] as String?,
      note: json['note'] as String?,
    );

AdjustAttendanceRequest _$AdjustAttendanceRequestFromJson(
  Map<String, dynamic> json,
) => AdjustAttendanceRequest(
  checkInTime: json['checkInTime'] == null
      ? null
      : DateTime.parse(json['checkInTime'] as String),
  checkOutTime: json['checkOutTime'] == null
      ? null
      : DateTime.parse(json['checkOutTime'] as String),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$AdjustAttendanceRequestToJson(
  AdjustAttendanceRequest instance,
) => <String, dynamic>{
  'checkInTime': instance.checkInTime?.toIso8601String(),
  'checkOutTime': instance.checkOutTime?.toIso8601String(),
  'reason': instance.reason,
};

AttendanceSummaryDto _$AttendanceSummaryDtoFromJson(
  Map<String, dynamic> json,
) => AttendanceSummaryDto(
  totalDays: (json['totalDays'] as num).toInt(),
  presentDays: (json['presentDays'] as num).toInt(),
  totalWorkedMinutes: (json['totalWorkedMinutes'] as num).toInt(),
  totalLateMinutes: (json['totalLateMinutes'] as num).toInt(),
  totalEarlyLeaveMinutes: (json['totalEarlyLeaveMinutes'] as num).toInt(),
);

RegisterFaceRequest _$RegisterFaceRequestFromJson(Map<String, dynamic> json) =>
    RegisterFaceRequest(
      employeeId: (json['employeeId'] as num?)?.toInt(),
      faceImageBase64: json['faceImageBase64'] as String,
    );

Map<String, dynamic> _$RegisterFaceRequestToJson(
  RegisterFaceRequest instance,
) => <String, dynamic>{
  'employeeId': instance.employeeId,
  'faceImageBase64': instance.faceImageBase64,
};

AttendanceActionResponse _$AttendanceActionResponseFromJson(
  Map<String, dynamic> json,
) => AttendanceActionResponse(
  success: json['success'] as bool,
  message: json['message'] as String?,
  errorCode: json['errorCode'] as String?,
);
