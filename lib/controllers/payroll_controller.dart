import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/payroll_repository.dart';
import '../repositories/system_admin_repository.dart';
import '../data/network/models/payroll_models.dart';
import '../data/network/models/admin_config_models.dart';

typedef Payslip = PayslipResponse;

class PayrollController extends GetxController {
  final PayrollRepository _repository = PayrollRepository();
  final SystemAdminRepository _adminRepo = SystemAdminRepository();

  var isLoading = false.obs;
  var history = <PayrollHistoryItemDto>[].obs;
  
  final currentPayslip = Rx<PayslipResponse>(const PayslipResponse(
    employeeId: 0,
    month: 0,
    year: 0,
    baseSalary: 0,
    allowance: 0,
    standardWorkDays: 26,
    actualWorkDays: 0,
    totalLateMinutes: 0,
    totalPenalty: 0,
    grossSalary: 0,
    netSalary: 0,
    overtimeSalary: 0,
    overtimeTaxExemptAmount: 0,
    insuranceBase: 0,
    insuranceDeduction: 0,
    taxableIncome: 0,
    personalDeduction: 0,
    dependentDeduction: 0,
    dependentCount: 0,
    pit: 0,
    salaryAdvanceDeduction: 0,
  ));

  var monthlySummaryList = <PayslipResponse>[].obs;

  // UI gọi: controller.monthlySummary (để lấy List)
  List<PayslipResponse> get monthlySummary => monthlySummaryList;
  
  // UI gọi: controller.payslip.value (để lấy PayslipResponse)
  Rx<PayslipResponse> get payslip => currentPayslip;

  Future<void> fetchHistory() async {
    isLoading.value = true;
    try {
      final list = await _repository.getMyHistory();
      history.assignAll(list);
    } catch (e) {
      _handleError(e, "Lỗi tải lịch sử lương");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPayslip(int month, int year) async {
    isLoading.value = true;
    try {
      final data = await _repository.getMyPayslip(month: month, year: year);
      currentPayslip.value = data;
    } catch (e) {
      _handleError(e, "Lỗi tải phiếu lương");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMyPayslip(int month, int year) => fetchPayslip(month, year);

  // Implement thực tế API lấy bảng lương tổng hợp
  Future<void> fetchMonthlySummary(int month, int year) async {
    isLoading.value = true;
    try {
      final list = await _repository.getMonthlySummary(month: month, year: year);
      monthlySummaryList.assignAll(list);
    } catch (e) {
      _handleError(e, "Lỗi tải bảng lương tổng hợp");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateSalaryConfig(
    int employeeId,
    double baseSalary,
    double allowance,
    double penaltyPerLateMinute,
    int dependentCount, [
    double? socialInsuranceBase,
    String? bankName,
    String? bankAccountNo,
    String? bankAccountHolder,
  ]) async {
    isLoading.value = true;
    try {
      await _adminRepo.configSalary(employeeId, UpdateSalaryConfigRequest(
        baseSalary: baseSalary,
        allowance: allowance,
        penaltyPerLateMinute: penaltyPerLateMinute,
        dependentCount: dependentCount,
        socialInsuranceBase: socialInsuranceBase,
        bankName: bankName,
        bankAccountNo: bankAccountNo,
        bankAccountHolder: bankAccountHolder,
      ));
      _showResultDialog("Thành công", "Cập nhật cấu hình lương cho nhân viên thành công");
    } catch (e) {
      _handleError(e, "Cập nhật thất bại");
    } finally { isLoading.value = false; }
  }

  void _handleError(dynamic e, String defaultTitle) {
    String msg = defaultTitle;
    if (e is DioException) {
      msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối máy chủ';
    }
    _showResultDialog(defaultTitle, msg, isError: true);
  }

  void _showResultDialog(String title, String message, {bool isError = false}) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, 
                 color: isError ? Colors.red : Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("OK")),
        ],
      ),
    );
  }
}
