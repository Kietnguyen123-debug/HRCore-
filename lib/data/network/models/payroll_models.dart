import 'package:json_annotation/json_annotation.dart';

part 'payroll_models.g.dart';

@JsonSerializable(createToJson: true)
class PayrollHistoryItemDto {
  final int id;
  final int month;
  final int year;
  final double netSalary;
  final DateTime createdAt;

  const PayrollHistoryItemDto({
    required this.id,
    required this.month,
    required this.year,
    required this.netSalary,
    required this.createdAt,
  });

  factory PayrollHistoryItemDto.fromJson(Map<String, dynamic> json) => _$PayrollHistoryItemDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PayrollHistoryItemDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class ProgressiveTaxBracketDto {
  final String? bracket;
  final double taxableAmount;
  final double rate;
  final double taxAmount;

  const ProgressiveTaxBracketDto({
    this.bracket,
    required this.taxableAmount,
    required this.rate,
    required this.taxAmount,
  });

  factory ProgressiveTaxBracketDto.fromJson(Map<String, dynamic> json) => _$ProgressiveTaxBracketDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ProgressiveTaxBracketDtoToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: true)
class PayslipResponse {
  final int employeeId;
  // Ép kiểu non-nullable với giá trị mặc định để fix lỗi biên dịch tại payslip_screen.dart:113
  final String employeeCode;
  final String fullName;
  final int month;
  final int year;
  final double baseSalary;
  final double allowance;
  final double standardWorkDays;
  final double actualWorkDays;
  final int totalLateMinutes;
  final double totalPenalty;
  final double grossSalary;
  final double netSalary;
  final double overtimeSalary;
  final double overtimeTaxExemptAmount;
  final double insuranceBase;
  final double insuranceDeduction;
  final double taxableIncome;
  final double personalDeduction;
  final double dependentDeduction;
  final int dependentCount;
  final double pit;
  final double salaryAdvanceDeduction;
  final List<ProgressiveTaxBracketDto>? taxBrackets;

  const PayslipResponse({
    required this.employeeId,
    this.employeeCode = '',
    this.fullName = '',
    required this.month,
    required this.year,
    required this.baseSalary,
    required this.allowance,
    required this.standardWorkDays,
    required this.actualWorkDays,
    required this.totalLateMinutes,
    required this.totalPenalty,
    required this.grossSalary,
    required this.netSalary,
    required this.overtimeSalary,
    required this.overtimeTaxExemptAmount,
    required this.insuranceBase,
    required this.insuranceDeduction,
    required this.taxableIncome,
    required this.personalDeduction,
    required this.dependentDeduction,
    required this.dependentCount,
    required this.pit,
    required this.salaryAdvanceDeduction,
    this.taxBrackets,
  });

  factory PayslipResponse.fromJson(Map<String, dynamic> json) {
    // Xử lý thủ công fallback cho các trường String để an toàn tuyệt đối
    final base = _$PayslipResponseFromJson(json);
    return PayslipResponse(
      employeeId: base.employeeId,
      employeeCode: json['employeeCode']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      month: base.month,
      year: base.year,
      baseSalary: base.baseSalary,
      allowance: base.allowance,
      standardWorkDays: base.standardWorkDays,
      actualWorkDays: base.actualWorkDays,
      totalLateMinutes: base.totalLateMinutes,
      totalPenalty: base.totalPenalty,
      grossSalary: base.grossSalary,
      netSalary: base.netSalary,
      overtimeSalary: base.overtimeSalary,
      overtimeTaxExemptAmount: base.overtimeTaxExemptAmount,
      insuranceBase: base.insuranceBase,
      insuranceDeduction: base.insuranceDeduction,
      taxableIncome: base.taxableIncome,
      personalDeduction: base.personalDeduction,
      dependentDeduction: base.dependentDeduction,
      dependentCount: base.dependentCount,
      pit: base.pit,
      salaryAdvanceDeduction: base.salaryAdvanceDeduction,
      taxBrackets: base.taxBrackets,
    );
  }

  Map<String, dynamic> toJson() => _$PayslipResponseToJson(this);

  dynamic operator [](String key) => toJson()[key];
}

@JsonSerializable(createToJson: false)
class MonthlyPayrollSummaryResponse {
  final List<PayslipResponse> items;

  const MonthlyPayrollSummaryResponse({required this.items});

  factory MonthlyPayrollSummaryResponse.fromJson(Map<String, dynamic> json) => _$MonthlyPayrollSummaryResponseFromJson(json);
}

@JsonSerializable(createToJson: true)
class PayrollTaxBracketDto {
  final int sequence;
  final double? upperLimit;
  final double rate;
  final String? name;

  const PayrollTaxBracketDto({
    required this.sequence,
    this.upperLimit,
    required this.rate,
    this.name,
  });

  factory PayrollTaxBracketDto.fromJson(Map<String, dynamic> json) => _$PayrollTaxBracketDtoFromJson(json);
  Map<String, dynamic> toJson() => _$PayrollTaxBracketDtoToJson(this);
}

@JsonSerializable(createToJson: true)
class PayrollPolicyResponse {
  final int id;
  final DateTime effectiveDate;
  final double referenceInsuranceSalary;
  final double insuranceCeiling;
  final double employeeSocialInsuranceRate;
  final double employeeHealthInsuranceRate;
  final double employeeUnemploymentInsuranceRate;
  final double employerSocialInsuranceRate;
  final double employerHealthInsuranceRate;
  final double employerUnemploymentInsuranceRate;
  final double personalDeduction;
  final double dependentDeduction;
  final double casualIncomeWithholdingThreshold;
  final double casualIncomeWithholdingRate;
  final double mealTaxExemptLimit;
  final String? sourceReference;
  final String? changeReason;
  final List<PayrollTaxBracketDto>? taxBrackets;

  const PayrollPolicyResponse({
    required this.id,
    required this.effectiveDate,
    required this.referenceInsuranceSalary,
    required this.insuranceCeiling,
    required this.employeeSocialInsuranceRate,
    required this.employeeHealthInsuranceRate,
    required this.employeeUnemploymentInsuranceRate,
    required this.employerSocialInsuranceRate,
    required this.employerHealthInsuranceRate,
    required this.employerUnemploymentInsuranceRate,
    required this.personalDeduction,
    required this.dependentDeduction,
    required this.casualIncomeWithholdingThreshold,
    required this.casualIncomeWithholdingRate,
    required this.mealTaxExemptLimit,
    this.sourceReference,
    this.changeReason,
    this.taxBrackets,
  });

  factory PayrollPolicyResponse.fromJson(Map<String, dynamic> json) => _$PayrollPolicyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$PayrollPolicyResponseToJson(this);
}

@JsonSerializable(createToJson: true)
class SavePayrollPolicyRequest {
  final DateTime effectiveDate;
  final double referenceInsuranceSalary;
  final double insuranceCeiling;
  final double employeeSocialInsuranceRate;
  final double employeeHealthInsuranceRate;
  final double employeeUnemploymentInsuranceRate;
  final double employerSocialInsuranceRate;
  final double employerHealthInsuranceRate;
  final double employerUnemploymentInsuranceRate;
  final double personalDeduction;
  final double dependentDeduction;
  final double casualIncomeWithholdingThreshold;
  final double casualIncomeWithholdingRate;
  final double mealTaxExemptLimit;
  final String sourceReference;
  final String? changeReason;
  final List<PayrollTaxBracketDto> taxBrackets;

  const SavePayrollPolicyRequest({
    required this.effectiveDate,
    required this.referenceInsuranceSalary,
    required this.insuranceCeiling,
    required this.employeeSocialInsuranceRate,
    required this.employeeHealthInsuranceRate,
    required this.employeeUnemploymentInsuranceRate,
    required this.employerSocialInsuranceRate,
    required this.employerHealthInsuranceRate,
    required this.employerUnemploymentInsuranceRate,
    required this.personalDeduction,
    required this.dependentDeduction,
    required this.casualIncomeWithholdingThreshold,
    required this.casualIncomeWithholdingRate,
    required this.mealTaxExemptLimit,
    required this.sourceReference,
    this.changeReason,
    required this.taxBrackets,
  });

  factory SavePayrollPolicyRequest.fromJson(Map<String, dynamic> json) => _$SavePayrollPolicyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$SavePayrollPolicyRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class LatePenaltyRangeRequest {
  final int fromMinute;
  final int toMinute;
  final double penaltyAmount;

  const LatePenaltyRangeRequest({
    required this.fromMinute,
    required this.toMinute,
    required this.penaltyAmount,
  });

  factory LatePenaltyRangeRequest.fromJson(Map<String, dynamic> json) => _$LatePenaltyRangeRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LatePenaltyRangeRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class LatePenaltyPolicyResponse {
  final int id;
  final String name;
  final int type;
  final double? amountPerMinute;
  final bool isActive;
  final List<LatePenaltyRangeRequest>? ranges;

  const LatePenaltyPolicyResponse({
    required this.id,
    required this.name,
    required this.type,
    this.amountPerMinute,
    required this.isActive,
    this.ranges,
  });

  factory LatePenaltyPolicyResponse.fromJson(Map<String, dynamic> json) => _$LatePenaltyPolicyResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LatePenaltyPolicyResponseToJson(this);
}

@JsonSerializable(createToJson: true)
class LatePenaltyPolicyRequest {
  final String name;
  final int type;
  final double? amountPerMinute;
  final bool isActive;
  final List<LatePenaltyRangeRequest>? ranges;

  const LatePenaltyPolicyRequest({
    required this.name,
    required this.type,
    this.amountPerMinute,
    required this.isActive,
    this.ranges,
  });

  factory LatePenaltyPolicyRequest.fromJson(Map<String, dynamic> json) => _$LatePenaltyPolicyRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LatePenaltyPolicyRequestToJson(this);
}
