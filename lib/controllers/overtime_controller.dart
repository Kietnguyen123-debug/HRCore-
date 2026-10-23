import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/overtime_repository.dart';
import '../data/network/models/overtime_models.dart';
import '../core/app_colors.dart';
import 'request_history_controller.dart';

class OvertimeController extends GetxController {
  final OvertimeRepository _repository = OvertimeRepository();
  var isLoading = false.obs;
  var myRequests = <EmployeeOvertimeDto>[].obs;

  Future<void> fetchMyRequests() async {
    isLoading.value = true;
    try {
      final list = await _repository.getMyRequests();
      myRequests.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp danh sách tăng ca: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> createRequest({
    required DateTime workDate,
    required double hours,
    required double multiplier,
  }) async {
    isLoading.value = true;
    try {
      await _repository.logOvertime(
        workDate: workDate,
        hours: hours,
        multiplier: multiplier,
      );
      
      isLoading.value = false;

      Get.snackbar(
        "Thành công",
        "Đã gửi yêu cầu tăng ca thành công",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Đồng bộ nạp lại lịch sử cá nhân ngầm
      try {
        fetchMyRequests();
        if (Get.isRegistered<RequestHistoryController>()) {
          Get.find<RequestHistoryController>().fetchOvertimeHistory(isRefresh: true);
        }
      } catch (_) {}

      return true;
    } catch (e) {
      isLoading.value = false;
      _handleDioError(e, "Gửi yêu cầu tăng ca thất bại");
      return false;
    }
  }

  Future<bool> submitRequest(String date, double hrs, double mult) =>
      createRequest(workDate: DateTime.parse(date), hours: hrs, multiplier: mult);

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
        final idx = rhCtrl.overtimes.indexWhere((item) => item.id == id);
        if (idx != -1) {
          rhCtrl.overtimes[idx] = rhCtrl.overtimes[idx].copyWith(status: 'CANCELLED');
          rhCtrl.overtimes.refresh();
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
