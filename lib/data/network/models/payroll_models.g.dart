// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payroll_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PayrollHistoryItemDto _$PayrollHistoryItemDtoFromJson(
  Map<String, dynamic> json,
) => PayrollHistoryItemDto(
  id: (json['id'] as num).toInt(),
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  netSalary: (json['netSalary'] as num).toDouble(),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PayrollHistoryItemDtoToJson(
  PayrollHistoryItemDto instance,
) => <String, dynamic>{
  'id': instance.id,
  'month': instance.month,
  'year': instance.year,
  'netSalary': instance.netSalary,
  'createdAt': instance.createdAt.toIso8601String(),
};

ProgressiveTaxBracketDto _$ProgressiveTaxBracketDtoFromJson(
  Map<String, dynamic> json,
) => ProgressiveTaxBracketDto(
  bracket: json['bracket'] as String?,
  taxableAmount: (json['taxableAmount'] as num).toDouble(),
  rate: (json['rate'] as num).toDouble(),
  taxAmount: (json['taxAmount'] as num).toDouble(),
);

Map<String, dynamic> _$ProgressiveTaxBracketDtoToJson(
  ProgressiveTaxBracketDto instance,
) => <String, dynamic>{
  'bracket': instance.bracket,
  'taxableAmount': instance.taxableAmount,
  'rate': instance.rate,
  'taxAmount': instance.taxAmount,
};

PayslipResponse _$PayslipResponseFromJson(
  Map<String, dynamic> json,
) => PayslipResponse(
  employeeId: (json['employeeId'] as num).toInt(),
  employeeCode: json['employeeCode'] as String? ?? '',
  fullName: json['fullName'] as String? ?? '',
  month: (json['month'] as num).toInt(),
  year: (json['year'] as num).toInt(),
  baseSalary: (json['baseSalary'] as num).toDouble(),
  allowance: (json['allowance'] as num).toDouble(),
  standardWorkDays: (json['standardWorkDays'] as num).toDouble(),
  actualWorkDays: (json['actualWorkDays'] as num).toDouble(),
  totalLateMinutes: (json['totalLateMinutes'] as num).toInt(),
  totalPenalty: (json['totalPenalty'] as num).toDouble(),
  grossSalary: (json['grossSalary'] as num).toDouble(),
  netSalary: (json['netSalary'] as num).toDouble(),
  overtimeSalary: (json['overtimeSalary'] as num).toDouble(),
  overtimeTaxExemptAmount: (json['overtimeTaxExemptAmount'] as num).toDouble(),
  insuranceBase: (json['insuranceBase'] as num).toDouble(),
  insuranceDeduction: (json['insuranceDeduction'] as num).toDouble(),
  taxableIncome: (json['taxableIncome'] as num).toDouble(),
  personalDeduction: (json['personalDeduction'] as num).toDouble(),
  dependentDeduction: (json['dependentDeduction'] as num).toDouble(),
  dependentCount: (json['dependentCount'] as num).toInt(),
  pit: (json['pit'] as num).toDouble(),
  salaryAdvanceDeduction: (json['salaryAdvanceDeduction'] as num).toDouble(),
  taxBrackets: (json['taxBrackets'] as List<dynamic>?)
      ?.map((e) => ProgressiveTaxBracketDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PayslipResponseToJson(PayslipResponse instance) =>
    <String, dynamic>{
      'employeeId': instance.employeeId,
      'employeeCode': instance.employeeCode,
      'fullName': instance.fullName,
      'month': instance.month,
      'year': instance.year,
      'baseSalary': instance.baseSalary,
      'allowance': instance.allowance,
      'standardWorkDays': instance.standardWorkDays,
      'actualWorkDays': instance.actualWorkDays,
      'totalLateMinutes': instance.totalLateMinutes,
      'totalPenalty': instance.totalPenalty,
      'grossSalary': instance.grossSalary,
      'netSalary': instance.netSalary,
      'overtimeSalary': instance.overtimeSalary,
      'overtimeTaxExemptAmount': instance.overtimeTaxExemptAmount,
      'insuranceBase': instance.insuranceBase,
      'insuranceDeduction': instance.insuranceDeduction,
      'taxableIncome': instance.taxableIncome,
      'personalDeduction': instance.personalDeduction,
      'dependentDeduction': instance.dependentDeduction,
      'dependentCount': instance.dependentCount,
      'pit': instance.pit,
      'salaryAdvanceDeduction': instance.salaryAdvanceDeduction,
      'taxBrackets': instance.taxBrackets,
    };

MonthlyPayrollSummaryResponse _$MonthlyPayrollSummaryResponseFromJson(
  Map<String, dynamic> json,
) => MonthlyPayrollSummaryResponse(
  items: (json['items'] as List<dynamic>)
      .map((e) => PayslipResponse.fromJson(e as Map<String, dynamic>))
      .toList(),
);

PayrollTaxBracketDto _$PayrollTaxBracketDtoFromJson(
  Map<String, dynamic> json,
) => PayrollTaxBracketDto(
  sequence: (json['sequence'] as num?)?.toInt() ?? 1,
  upperLimit: (json['upperLimit'] as num?)?.toDouble(),
  rate: (json['rate'] as num?)?.toDouble() ?? 0.0,
  name: json['name'] as String?,
);

Map<String, dynamic> _$PayrollTaxBracketDtoToJson(
  PayrollTaxBracketDto instance,
) => <String, dynamic>{
  'sequence': instance.sequence,
  'upperLimit': instance.upperLimit,
  'rate': instance.rate,
  'name': instance.name,
};

PayrollPolicyResponse _$PayrollPolicyResponseFromJson(
  Map<String, dynamic> json,
) => PayrollPolicyResponse(
  id: (json['id'] as num?)?.toInt() ?? 0,
  effectiveDate: json['effectiveDate'] != null ? DateTime.parse(json['effectiveDate'] as String) : DateTime.now(),
  referenceInsuranceSalary: (json['referenceInsuranceSalary'] as num?)?.toDouble() ?? 0.0,
  insuranceCeiling: (json['insuranceCeiling'] as num?)?.toDouble() ?? 0.0,
  employeeSocialInsuranceRate: (json['employeeSocialInsuranceRate'] as num?)?.toDouble() ?? 0.0,
  employeeHealthInsuranceRate: (json['employeeHealthInsuranceRate'] as num?)?.toDouble() ?? 0.0,
  employeeUnemploymentInsuranceRate: (json['employeeUnemploymentInsuranceRate'] as num?)?.toDouble() ?? 0.0,
  employerSocialInsuranceRate: (json['employerSocialInsuranceRate'] as num?)?.toDouble() ?? 0.0,
  employerHealthInsuranceRate: (json['employerHealthInsuranceRate'] as num?)?.toDouble() ?? 0.0,
  employerUnemploymentInsuranceRate: (json['employerUnemploymentInsuranceRate'] as num?)?.toDouble() ?? 0.0,
  personalDeduction: (json['personalDeduction'] as num?)?.toDouble() ?? 0.0,
  dependentDeduction: (json['dependentDeduction'] as num?)?.toDouble() ?? 0.0,
  casualIncomeWithholdingThreshold: (json['casualIncomeWithholdingThreshold'] as num?)?.toDouble() ?? 0.0,
  casualIncomeWithholdingRate: (json['casualIncomeWithholdingRate'] as num?)?.toDouble() ?? 0.0,
  mealTaxExemptLimit: (json['mealTaxExemptLimit'] as num?)?.toDouble() ?? 0.0,
  sourceReference: json['sourceReference'] as String?,
  changeReason: json['changeReason'] as String?,
  taxBrackets: (json['taxBrackets'] as List<dynamic>?)
      ?.map((e) => PayrollTaxBracketDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$PayrollPolicyResponseToJson(
  PayrollPolicyResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'referenceInsuranceSalary': instance.referenceInsuranceSalary,
  'insuranceCeiling': instance.insuranceCeiling,
  'employeeSocialInsuranceRate': instance.employeeSocialInsuranceRate,
  'employeeHealthInsuranceRate': instance.employeeHealthInsuranceRate,
  'employeeUnemploymentInsuranceRate': instance.employeeUnemploymentInsuranceRate,
  'employerSocialInsuranceRate': instance.employerSocialInsuranceRate,
  'employerHealthInsuranceRate': instance.employerHealthInsuranceRate,
  'employerUnemploymentInsuranceRate': instance.employerUnemploymentInsuranceRate,
  'personalDeduction': instance.personalDeduction,
  'dependentDeduction': instance.dependentDeduction,
  'casualIncomeWithholdingThreshold': instance.casualIncomeWithholdingThreshold,
  'casualIncomeWithholdingRate': instance.casualIncomeWithholdingRate,
  'mealTaxExemptLimit': instance.mealTaxExemptLimit,
  'sourceReference': instance.sourceReference,
  'changeReason': instance.changeReason,
  'taxBrackets': instance.taxBrackets,
};

SavePayrollPolicyRequest _$SavePayrollPolicyRequestFromJson(
  Map<String, dynamic> json,
) => SavePayrollPolicyRequest(
  effectiveDate: DateTime.parse(json['effectiveDate'] as String),
  referenceInsuranceSalary: (json['referenceInsuranceSalary'] as num).toDouble(),
  insuranceCeiling: (json['insuranceCeiling'] as num).toDouble(),
  employeeSocialInsuranceRate: (json['employeeSocialInsuranceRate'] as num).toDouble(),
  employeeHealthInsuranceRate: (json['employeeHealthInsuranceRate'] as num).toDouble(),
  employeeUnemploymentInsuranceRate: (json['employeeUnemploymentInsuranceRate'] as num).toDouble(),
  employerSocialInsuranceRate: (json['employerSocialInsuranceRate'] as num).toDouble(),
  employerHealthInsuranceRate: (json['employerHealthInsuranceRate'] as num).toDouble(),
  employerUnemploymentInsuranceRate: (json['employerUnemploymentInsuranceRate'] as num).toDouble(),
  personalDeduction: (json['personalDeduction'] as num).toDouble(),
  dependentDeduction: (json['dependentDeduction'] as num).toDouble(),
  casualIncomeWithholdingThreshold: (json['casualIncomeWithholdingThreshold'] as num).toDouble(),
  casualIncomeWithholdingRate: (json['casualIncomeWithholdingRate'] as num).toDouble(),
  mealTaxExemptLimit: (json['mealTaxExemptLimit'] as num).toDouble(),
  sourceReference: json['sourceReference'] as String,
  changeReason: json['changeReason'] as String?,
  taxBrackets: (json['taxBrackets'] as List<dynamic>)
      .map((e) => PayrollTaxBracketDto.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$SavePayrollPolicyRequestToJson(
  SavePayrollPolicyRequest instance,
) => <String, dynamic>{
  'effectiveDate': instance.effectiveDate.toIso8601String(),
  'referenceInsuranceSalary': instance.referenceInsuranceSalary,
  'insuranceCeiling': instance.insuranceCeiling,
  'employeeSocialInsuranceRate': instance.employeeSocialInsuranceRate,
  'employeeHealthInsuranceRate': instance.employeeHealthInsuranceRate,
  'employeeUnemploymentInsuranceRate': instance.employeeUnemploymentInsuranceRate,
  'employerSocialInsuranceRate': instance.employerSocialInsuranceRate,
  'employerHealthInsuranceRate': instance.employerHealthInsuranceRate,
  'employerUnemploymentInsuranceRate': instance.employerUnemploymentInsuranceRate,
  'personalDeduction': instance.personalDeduction,
  'dependentDeduction': instance.dependentDeduction,
  'casualIncomeWithholdingThreshold': instance.casualIncomeWithholdingThreshold,
  'casualIncomeWithholdingRate': instance.casualIncomeWithholdingRate,
  'mealTaxExemptLimit': instance.mealTaxExemptLimit,
  'sourceReference': instance.sourceReference,
  'changeReason': instance.changeReason,
  'taxBrackets': instance.taxBrackets,
};

LatePenaltyRangeRequest _$LatePenaltyRangeRequestFromJson(
  Map<String, dynamic> json,
) => LatePenaltyRangeRequest(
  fromMinute: (json['fromMinute'] as num?)?.toInt() ?? 0,
  toMinute: (json['toMinute'] as num?)?.toInt() ?? 0,
  penaltyAmount: (json['penaltyAmount'] as num?)?.toDouble() ?? 0.0,
);

Map<String, dynamic> _$LatePenaltyRangeRequestToJson(
  LatePenaltyRangeRequest instance,
) => <String, dynamic>{
  'fromMinute': instance.fromMinute,
  'toMinute': instance.toMinute,
  'penaltyAmount': instance.penaltyAmount,
};

LatePenaltyPolicyResponse _$LatePenaltyPolicyResponseFromJson(
  Map<String, dynamic> json,
) => LatePenaltyPolicyResponse(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  type: (json['type'] as num?)?.toInt() ?? 1,
  amountPerMinute: (json['amountPerMinute'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool? ?? true,
  ranges: (json['ranges'] as List<dynamic>?)
      ?.map((e) => LatePenaltyRangeRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LatePenaltyPolicyResponseToJson(
  LatePenaltyPolicyResponse instance,
) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'type': instance.type,
  'amountPerMinute': instance.amountPerMinute,
  'isActive': instance.isActive,
  'ranges': instance.ranges,
};

LatePenaltyPolicyRequest _$LatePenaltyPolicyRequestFromJson(
  Map<String, dynamic> json,
) => LatePenaltyPolicyRequest(
  name: json['name'] as String,
  type: (json['type'] as num).toInt(),
  amountPerMinute: (json['amountPerMinute'] as num?)?.toDouble(),
  isActive: json['isActive'] as bool,
  ranges: (json['ranges'] as List<dynamic>?)
      ?.map((e) => LatePenaltyRangeRequest.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$LatePenaltyPolicyRequestToJson(
  LatePenaltyPolicyRequest instance,
) => <String, dynamic>{
  'name': instance.name,
  'type': instance.type,
  'amountPerMinute': instance.amountPerMinute,
  'isActive': instance.isActive,
  'ranges': instance.ranges,
};
