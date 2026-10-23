import 'package:json_annotation/json_annotation.dart';

part 'admin_config_models.g.dart';

@JsonSerializable(createToJson: true)
class FinalizePayrollRequest {
  final int month;
  final int year;
  final int standardWorkDays;

  const FinalizePayrollRequest({
    required this.month,
    required this.year,
    required this.standardWorkDays,
  });

  Map<String, dynamic> toJson() => _$FinalizePayrollRequestToJson(this);
}

@JsonSerializable(createToJson: true)
class UpdateSalaryConfigRequest {
  final double baseSalary;
  final double allowance;
  final double penaltyPerLateMinute;
  final int dependentCount;
  final double? socialInsuranceBase;
  final DateTime effectiveFrom;
  final String? paymentMethod;
  final String? bankName;
  final String? bankAccountNo;
  final String? bankAccountHolder;

  UpdateSalaryConfigRequest({
    required this.baseSalary,
    required this.allowance,
    required this.penaltyPerLateMinute,
    required this.dependentCount,
    this.socialInsuranceBase,
    DateTime? effectiveFrom,
    this.paymentMethod,
    this.bankName,
    this.bankAccountNo,
    this.bankAccountHolder,
  }) : effectiveFrom = effectiveFrom ?? DateTime.now();

  Map<String, dynamic> toJson() => _$UpdateSalaryConfigRequestToJson(this);
}
