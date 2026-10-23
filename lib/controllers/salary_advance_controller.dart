import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/salary_advance_repository.dart';
import '../data/network/models/salary_advance_models.dart';
import '../core/app_colors.dart';
import 'request_history_controller.dart';

class SalaryAdvanceController extends GetxController {
  final SalaryAdvanceRepository _repository = SalaryAdvanceRepository();
  var isLoading = false.obs;
  var myRequests = <SalaryAdvanceResponse>[].obs;

  Future<void> fetchMyRequests() async {
    isLoading.value = true;
    try {
      final list = await _repository.getMyRequests();
      myRequests.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp danh sách tạm ứng: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createRequest({
    required double amount,
    required String reason,
  }) async {
    isLoading.value = true;
    try {
      await _repository.requestAdvance(
        amount: amount,
        reason: reason,
      );
      
      // Tắt loading ngay lập tức
      isLoading.value = false;

      Get.snackbar(
        "Thành công",
        "Đã gửi yêu cầu tạm ứng lương thành công",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Đồng bộ nạp lại lịch sử cá nhân ngầm
      try {
        fetchMyRequests();
        if (Get.isRegistered<RequestHistoryController>()) {
          Get.find<RequestHistoryController>().fetchSalaryAdvanceHistory(isRefresh: true);
        }
      } catch (_) {}

      return true;
    } catch (e) {
      isLoading.value = false;
      _handleDioError(e, "Gửi yêu cầu tạm ứng thất bại");
      return false;
    }
  }

  Future<bool> submitRequest(double amount, String reason) => createRequest(amount: amount, reason: reason);

  Future<void> cancelRequest(int id) async {
    try {
      await _repository.cancelRequest(id);

      // Cập nhật trạng thái trong RAM local
      final index = myRequests.indexWhere((item) => item.id == id);
      if (index != -1) {
        myRequests[index] = myRequests[index].copyWith(status: 'CANCELLED');
        myRequests.refresh();
      }

      // Đồng bộ nếu RequestHistoryController đang hoạt động
      if (Get.isRegistered<RequestHistoryController>()) {
        final rhCtrl = Get.find<RequestHistoryController>();
        final idx = rhCtrl.salaryAdvances.indexWhere((item) => item.id == id);
        if (idx != -1) {
          rhCtrl.salaryAdvances[idx] = rhCtrl.salaryAdvances[idx].copyWith(status: 'CANCELLED');
          rhCtrl.salaryAdvances.refresh();
        }
      }

      _showResultDialog("Thành công", "Đã hủy yêu cầu");
    } catch (e) {
      _handleDioError(e, "Không thể hủy yêu cầu");
    }
  }

  void _handleDioError(dynamic e, String defaultTitle) {
    String message = "Đã có lỗi xảy ra, vui lòng thử lại";
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        message = data['message'] ?? data['Message'] ?? data['error'] ?? data['Error'] ?? data['title'] ?? data['detail'] ?? message;
        if (data.containsKey('errors') && data['errors'] is Map) {
          final Map<String, dynamic> errors = data['errors'];
          List<String> errList = [];
          errors.forEach((k, v) {
            if (v is List && v.isNotEmpty) errList.add(v.join(', '));
          });
          if (errList.isNotEmpty) message = errList.join('\n');
        }
      } else if (data is String && data.isNotEmpty) {
        message = data;
      } else if (e.message != null && e.message!.isNotEmpty) {
        message = e.message!;
      }
    } else if (e != null) {
      message = e.toString();
    }
    _showResultDialog(defaultTitle, message, isError: true);
  }

  Future<void> _showResultDialog(String title, String message, {bool isError = false}) async {
    return Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, 
                 color: isError ? Colors.red : Colors.green),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("XÁC NHẬN", style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }
}
