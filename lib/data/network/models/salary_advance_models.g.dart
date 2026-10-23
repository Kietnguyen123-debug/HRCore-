// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'salary_advance_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalaryAdvanceRequest _$SalaryAdvanceRequestFromJson(
  Map<String, dynamic> json,
) => SalaryAdvanceRequest(
  amount: (json['amount'] as num).toDouble(),
  reason: json['reason'] as String,
);

Map<String, dynamic> _$SalaryAdvanceRequestToJson(
  SalaryAdvanceRequest instance,
) => <String, dynamic>{'amount': instance.amount, 'reason': instance.reason};

SalaryAdvanceResponse _$SalaryAdvanceResponseFromJson(
  Map<String, dynamic> json,
) => SalaryAdvanceResponse(
  id: (json['Id'] as num?)?.toInt(),
  employeeId: (json['EmployeeId'] as num?)?.toInt(),
  amount: (json['Amount'] as num?)?.toDouble(),
  reason: json['Reason'] as String?,
  requestDate: json['RequestDate'] == null
      ? null
      : DateTime.parse(json['RequestDate'] as String),
  status: json['Status'] as String?,
  approvedById: (json['ApprovedById'] as num?)?.toInt(),
  reviewNote: json['ReviewNote'] as String?,
  createdAt: json['CreatedAt'] == null
      ? null
      : DateTime.parse(json['CreatedAt'] as String),
);
