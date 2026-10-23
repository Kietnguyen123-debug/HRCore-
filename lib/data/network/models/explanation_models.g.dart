// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explanation_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmitAttendanceExplanationRequest _$SubmitAttendanceExplanationRequestFromJson(
  Map<String, dynamic> json,
) => SubmitAttendanceExplanationRequest(
  targetDate: DateTime.parse(json['targetDate'] as String),
  explanationReason: json['explanationReason'] as String,
  missingCheckInTime: json['missingCheckInTime'] == null
      ? null
      : DateTime.parse(json['missingCheckInTime'] as String),
  missingCheckOutTime: json['missingCheckOutTime'] == null
      ? null
      : DateTime.parse(json['missingCheckOutTime'] as String),
);

Map<String, dynamic> _$SubmitAttendanceExplanationRequestToJson(
  SubmitAttendanceExplanationRequest instance,
) => <String, dynamic>{
  'targetDate': instance.targetDate.toIso8601String(),
  'explanationReason': instance.explanationReason,
  'missingCheckInTime': instance.missingCheckInTime?.toIso8601String(),
  'missingCheckOutTime': instance.missingCheckOutTime?.toIso8601String(),
};

AttendanceExplanationResponse _$AttendanceExplanationResponseFromJson(
  Map<String, dynamic> json,
) => AttendanceExplanationResponse(
  id: (json['Id'] as num?)?.toInt(),
  employeeId: (json['EmployeeId'] as num?)?.toInt(),
  employeeName: json['EmployeeName'] as String?,
  targetDate: json['TargetDate'] == null
      ? null
      : DateTime.parse(json['TargetDate'] as String),
  explanationReason: json['ExplanationReason'] as String?,
  missingCheckInTime: json['MissingCheckInTime'] == null
      ? null
      : DateTime.parse(json['MissingCheckInTime'] as String),
  missingCheckOutTime: json['MissingCheckOutTime'] == null
      ? null
      : DateTime.parse(json['MissingCheckOutTime'] as String),
  status: json['Status'] as String?,
  reviewerId: (json['ReviewerId'] as num?)?.toInt(),
  reviewNote: json['ReviewNote'] as String?,
  createdAt: json['CreatedAt'] == null
      ? null
      : DateTime.parse(json['CreatedAt'] as String),
);
