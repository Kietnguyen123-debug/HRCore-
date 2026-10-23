// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_config_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FinalizePayrollRequest _$FinalizePayrollRequestFromJson(
  Map<String, dynamic> json,
) => FinalizePayrollRequest(
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  standardWorkDays: (json['standardWorkDays'] as num).toInt(),
);

Map<String, dynamic> _$FinalizePayrollRequestToJson(
  FinalizePayrollRequest instance,
) => <String, dynamic>{
  'month': instance.month,
  'year': instance.year,
  'standardWorkDays': instance.standardWorkDays,
};

UpdateSalaryConfigRequest _$UpdateSalaryConfigRequestFromJson(
  Map<String, dynamic> json,
) => UpdateSalaryConfigRequest(
  baseSalary: (json['baseSalary'] as num).toDouble(),
  allowance: (json['allowance'] as num).toDouble(),
  penaltyPerLateMinute: (json['penaltyPerLateMinute'] as num).toDouble(),
  dependentCount: (json['dependentCount'] as num).toInt(),
  socialInsuranceBase: (json['socialInsuranceBase'] as num?)?.toDouble(),
  effectiveFrom: json['effectiveFrom'] != null ? DateTime.parse(json['effectiveFrom'] as String) : DateTime.now(),
  paymentMethod: json['paymentMethod'] as String?,
  bankName: json['bankName'] as String?,
  bankAccountNo: json['bankAccountNo'] as String?,
  bankAccountHolder: json['bankAccountHolder'] as String?,
);

Map<String, dynamic> _$UpdateSalaryConfigRequestToJson(
  UpdateSalaryConfigRequest instance,
) => <String, dynamic>{
  'baseSalary': instance.baseSalary,
  'allowance': instance.allowance,
  'penaltyPerLateMinute': instance.penaltyPerLateMinute,
  'dependentCount': instance.dependentCount,
  'socialInsuranceBase': instance.socialInsuranceBase,
  'effectiveFrom': instance.effectiveFrom.toIso8601String(),
  'paymentMethod': instance.paymentMethod,
  'bankName': instance.bankName,
  'bankAccountNo': instance.bankAccountNo,
  'bankAccountHolder': instance.bankAccountHolder,
};
