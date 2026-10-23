import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/department_repository.dart';
import '../data/network/models/department_models.dart';

class DepartmentController extends GetxController {
  final DepartmentRepository _repository = DepartmentRepository();

  var departments = <DepartmentListItemResponse>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDepartments();
  }

  Future<void> fetchDepartments() async {
    isLoading.value = true;
    try {
      final list = await _repository.getAll();
      departments.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp danh sách phòng ban: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createDepartment(String name) async {
    isLoading.value = true;
    try {
      await _repository.create(name);
      Get.snackbar(
        "Thành công",
        "Đã tạo phòng ban mới",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      try { await fetchDepartments(); } catch (_) {}
      return true;
    } catch (e) {
      _handleError(e, 'Lỗi tạo phòng ban');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> updateDepartment(int id, String name) async {
    isLoading.value = true;
    try {
      await _repository.update(id, name);
      Get.snackbar(
        "Thành công",
        "Đã cập nhật phòng ban",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      try { await fetchDepartments(); } catch (_) {}
      return true;
    } catch (e) {
      _handleError(e, 'Lỗi cập nhật phòng ban');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      await _repository.delete(id);
      Get.snackbar(
        "Thành công",
        "Đã xóa phòng ban",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      try { await fetchDepartments(); } catch (_) {}
    } catch (e) {
      _handleError(e, 'Lỗi xóa phòng ban');
    }
  }

  Future<void> toggleStatus(int id) async {
    try {
      await _repository.toggleStatus(id);
      Get.snackbar(
        "Thành công",
        "Đã thay đổi trạng thái phòng ban",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      try { await fetchDepartments(); } catch (_) {}
    } catch (e) {
      _handleError(e, 'Lỗi thay đổi trạng thái');
    }
  }

  void _handleError(dynamic e, String defaultTitle) {
    String msg = defaultTitle;
    if (e is DioException) {
      msg = e.response?.data?['message'] ?? e.message ?? 'Lỗi kết nối';
    }
    Get.snackbar(
      defaultTitle,
      msg,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
    );
  }
}
