import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/attendance_explanation_repository.dart';
import '../data/network/models/explanation_models.dart';
import '../core/app_colors.dart';
import 'request_history_controller.dart';

class AttendanceExplanationController extends GetxController {
  final AttendanceExplanationRepository _repository = AttendanceExplanationRepository();
  var isLoading = false.obs;
  var myRequests = <AttendanceExplanationResponse>[].obs;

  Future<void> fetchMyRequests() async {
    isLoading.value = true;
    try {
      final list = await _repository.getMyRequests();
      myRequests.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi tải danh sách giải trình ngầm: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> submitExplanation(
    dynamic targetDate,
    String explanationReason, {
    dynamic missingIn,
    dynamic missingOut,
  }) async {
    isLoading.value = true;
    try {
      DateTime parsedDate = targetDate is String ? DateTime.parse(targetDate) : targetDate;
      DateTime? parsedIn = missingIn is String ? DateTime.tryParse(missingIn) : missingIn;
      DateTime? parsedOut = missingOut is String ? DateTime.tryParse(missingOut) : missingOut;

      await _repository.submitExplanation(
        targetDate: parsedDate,
        explanationReason: explanationReason,
        missingCheckInTime: parsedIn,
        missingCheckOutTime: parsedOut,
      );
      
      isLoading.value = false;
      
      Get.snackbar(
        "Thành công",
        "Đã gửi đơn giải trình chấm công thành công",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      
      // Đồng bộ nạp lại lịch sử cá nhân ngầm
      try {
        fetchMyRequests();
        if (Get.isRegistered<RequestHistoryController>()) {
          Get.find<RequestHistoryController>().fetchAttendanceExplanationHistory(isRefresh: true);
        }
      } catch (_) {}

      return true;
    } catch (e) {
      isLoading.value = false;
      _handleDioError(e, "Gửi đơn giải trình thất bại");
      return false;
    }
  }

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
        final idx = rhCtrl.explanations.indexWhere((e) => e.id == id);
        if (idx != -1) {
          rhCtrl.explanations[idx] = rhCtrl.explanations[idx].copyWith(status: 'CANCELLED');
          rhCtrl.explanations.refresh();
        }
      }

      _showResultDialog("Thành công", "Đã hủy đơn giải trình");
    } catch (e) {
      _handleDioError(e, "Không thể hủy đơn giải trình");
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
