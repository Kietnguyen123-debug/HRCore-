import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/report_repository.dart';
import '../data/network/models/report_models.dart';

class ReportController extends GetxController {
  final ReportRepository _repository = ReportRepository();
  var isLoading = false.obs;

  var attendanceReport = <AttendanceReportDto>[].obs;
  var leaveReport = <LeaveReportDto>[].obs;
  var overtimeReport = <OvertimeReportDto>[].obs;
  var monthlySummary = <MonthlyAttendanceSummaryResponse>[].obs;

  // State variables for UI backward compatibility
  var selectedMonth = DateTime.now().month.obs;
  var selectedYear = DateTime.now().year.obs;
  var selectedBranchId = RxnInt();

  // Getter for UI backward compatibility
  List<MonthlyAttendanceSummaryResponse> get reportData => monthlySummary;

  Future<void> fetchAttendanceReport({int? month, int? year, int? branchId}) async {
    isLoading.value = true;
    try {
      final m = month ?? selectedMonth.value;
      final y = year ?? selectedYear.value;
      final b = branchId ?? selectedBranchId.value;

      final res = await _repository.getAttendanceReport(month: m, year: y, branchId: b);
      attendanceReport.assignAll(res);
    } catch (e) {
      debugPrint("Lỗi nạp báo cáo chấm công: $e");
    } finally { isLoading.value = false; }
  }

  Future<void> fetchLeaveReport({int? month, int? year, int? branchId}) async {
    isLoading.value = true;
    try {
      final m = month ?? selectedMonth.value;
      final y = year ?? selectedYear.value;
      final b = branchId ?? selectedBranchId.value;

      final res = await _repository.getLeaveReport(month: m, year: y, branchId: b);
      leaveReport.assignAll(res);
    } catch (e) {
      debugPrint("Lỗi nạp báo cáo nghỉ phép: $e");
    } finally { isLoading.value = false; }
  }

  Future<void> fetchOvertimeReport({int? month, int? year, int? branchId}) async {
    isLoading.value = true;
    try {
      final m = month ?? selectedMonth.value;
      final y = year ?? selectedYear.value;
      final b = branchId ?? selectedBranchId.value;

      final res = await _repository.getOvertimeReport(month: m, year: y, branchId: b);
      overtimeReport.assignAll(res);
    } catch (e) {
      debugPrint("Lỗi nạp báo cáo tăng ca: $e");
    } finally { isLoading.value = false; }
  }

  Future<void> fetchMonthlySummary({int? month, int? year, int? branchId}) async {
    isLoading.value = true;
    try {
      final m = month ?? selectedMonth.value;
      final y = year ?? selectedYear.value;
      final b = branchId ?? selectedBranchId.value;

      final res = await _repository.getMonthlySummary(month: m, year: y, branchId: b);
      monthlySummary.assignAll(res);
    } catch (e) {
      debugPrint("Lỗi nạp tổng kết tháng: $e");
    } finally { isLoading.value = false; }
  }

  Future<void> fetchAllReports() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchMonthlySummary(),
        fetchAttendanceReport(),
        fetchLeaveReport(),
        fetchOvertimeReport(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  // Alias for UI backward compatibility
  Future<void> fetchReport() => fetchAllReports();
}
