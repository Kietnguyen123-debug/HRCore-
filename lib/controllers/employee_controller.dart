import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/system_admin_repository.dart';
import '../repositories/attendance_repository.dart';
import '../data/network/models/employee_admin_models.dart';

class EmployeeController extends GetxController {
  final SystemAdminRepository _repository = SystemAdminRepository();
  final AttendanceRepository _attendanceRepository = AttendanceRepository();

  var employees = <Employee>[].obs;
  var isLoading = false.obs;
  var isMoreLoading = false.obs;
  var currentPage = 1.obs;
  var totalPages = 1.obs;
  var selectedBranchId = RxnInt();
  var searchQuery = ''.obs;

  Future<void> fetchEmployees({
    int? branchId,
    String? search,
    bool refresh = true,
  }) async {
    if (refresh) {
      currentPage.value = 1;
      isLoading.value = true;
    } else {
      if (isMoreLoading.value || currentPage.value >= totalPages.value) return;
      isMoreLoading.value = true;
    }

    try {
      final branch = branchId ?? selectedBranchId.value;
      final response = await _repository.getEmployeeList(
        page: currentPage.value,
        pageSize: 100,
        branchId: branch,
      );

      totalPages.value = response.totalPages;
      final list = response.list;

      final searchText = (search ?? searchQuery.value).trim();
      final filteredList = searchText.isEmpty
          ? list
          : list.where((employee) {
        return (employee.employeeCode ?? '').toLowerCase().contains(searchText.toLowerCase()) ||
               (employee.fullName ?? '').toLowerCase().contains(searchText.toLowerCase());
      }).toList();

      if (refresh) {
        employees.assignAll(filteredList);
      } else {
        employees.addAll(filteredList);
      }
    } catch (e) {
      debugPrint("Lỗi nạp danh sách nhân viên: $e");
    } finally {
      isLoading.value = false;
      isMoreLoading.value = false;
    }
  }

  Future<void> loadMore() async {
    if (currentPage.value < totalPages.value && !isMoreLoading.value && !isLoading.value) {
      currentPage.value++;
      await fetchEmployees(refresh: false);
    }
  }

  Future<bool> createEmployee(
    String code,
    String name,
    int branchId,
    String role,
    String temporaryPassword, {
    int? departmentId,
    String? email,
  }) async {
    isLoading.value = true;
    try {
      await _repository.createEmployeeProfile(CreateEmployeeProfileRequest(
        employeeCode: code,
        fullName: name,
        branchId: branchId,
        departmentId: departmentId,
        role: role,
        email: email,
        baseSalary: 0,
        allowance: 0,
        penaltyPerLateMinute: 0,
        dependentCount: 0,
        totalAnnualLeave: 12,
      ));

      Get.snackbar("Thành công", "Đã tạo nhân viên mới", backgroundColor: Colors.green, colorText: Colors.white);
      try { fetchEmployees(); } catch (_) {}
      return true;
    } catch (e) {
      _handleError(e, 'Lỗi tạo nhân viên');
      return false;
    } finally { isLoading.value = false; }
  }

  Future<bool> updateEmployee(int id, String name, int branchId, String role, {int? departmentId, String? email}) async {
    isLoading.value = true;
    try {
      await _repository.updateEmployee(id, UpdateEmployeeRequest(
        fullName: name,
        branchId: branchId,
        departmentId: departmentId,
        role: role,
      ));
      Get.snackbar("Thành công", "Cập nhật nhân viên thành công", backgroundColor: Colors.green, colorText: Colors.white);
      try { fetchEmployees(); } catch (_) {}
      return true;
    } catch (e) {
      _handleError(e, 'Lỗi cập nhật nhân viên');
      return false;
    } finally { isLoading.value = false; }
  }

  Future<void> toggleStatus(int id) async {
    try {
      await _repository.toggleEmployeeStatus(id);
      Get.snackbar("Thành công", "Đã thay đổi trạng thái tài khoản", backgroundColor: Colors.green, colorText: Colors.white);
      try { fetchEmployees(); } catch (_) {}
    } catch (e) { _handleError(e, 'Lỗi thay đổi trạng thái'); }
  }

  Future<void> unbindDevice(int id) async {
    try {
      await _repository.unbindDevice(id);
      Get.snackbar("Thành công", "Đã gỡ liên kết thiết bị", backgroundColor: Colors.green, colorText: Colors.white);
      try { fetchEmployees(); } catch (_) {}
    } catch (e) { _handleError(e, 'Lỗi gỡ liên kết thiết bị'); }
  }

  Future<void> resetPassword(int id, String newPassword) async {
    try {
      await _repository.resetEmployeePassword(id, newPassword);
      Get.snackbar("Thành công", "Đã đặt lại mật khẩu tạm thành công", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) { _handleError(e, 'Lỗi đặt lại mật khẩu'); }
  }

  Future<void> registerFace(int employeeId, String faceImageBase64) async {
    final cleanImage = faceImageBase64.trim();
    if (cleanImage.isEmpty) {
      Get.snackbar("Lỗi", "Ảnh khuôn mặt không hợp lệ", backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      await _attendanceRepository.registerFace(employeeId, cleanImage);
      Get.snackbar("Thành công", "Đã đăng ký khuôn mặt cho nhân viên thành công", backgroundColor: Colors.green, colorText: Colors.white);
    } catch (e) {
      _handleError(e, 'Lỗi đăng ký khuôn mặt');
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(dynamic e, String defaultTitle) {
    String msg = "Đã có lỗi xảy ra, vui lòng thử lại sau";
    if (e is DioException) {
      msg = e.response?.data?['message'] ?? e.response?.data?['Message'] ?? e.message ?? msg;
    } else if (e is Exception) {
      msg = e.toString().replaceAll('Exception: ', '');
    }
    Get.snackbar(defaultTitle, msg, backgroundColor: Colors.redAccent, colorText: Colors.white);
  }
}
