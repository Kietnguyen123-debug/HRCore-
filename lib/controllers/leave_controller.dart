import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../repositories/leave_repository.dart';
import '../data/network/models/leave_models.dart';
import '../core/app_colors.dart';
import 'request_history_controller.dart';

class LeaveController extends GetxController {
  final LeaveRepository _repository = LeaveRepository();
  var isLoading = false.obs;
  var myRequests = <EmployeeLeaveDto>[].obs;
  var balance = Rxn<LeaveBalanceDto>();

  Future<void> fetchMyRequests() async {
    isLoading.value = true;
    try {
      final list = await _repository.getMyRequests();
      myRequests.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp danh sách nghỉ phép: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchBalance() async {
    try {
      final data = await _repository.getMyBalance();
      balance.value = data;
      debugPrint("Cập nhật số dư phép năm thành công: Còn ${data.remainingAnnualLeave}/${data.totalAnnualLeave} ngày");
    } catch (e) {
      debugPrint("Lỗi nạp số dư phép năm từ máy chủ: $e");
    }
  }

  Future<bool> createRequest({
    required DateTime startDate,
    required DateTime endDate,
    required String leaveType,
    required String reason,
  }) async {
    isLoading.value = true;
    try {
      final normalizedStart = DateTime(startDate.year, startDate.month, startDate.day);
      final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);

      await _repository.createRequest(
        startDate: normalizedStart,
        endDate: normalizedEnd,
        leaveType: leaveType,
        reason: reason,
      );
      
      isLoading.value = false;

      Get.snackbar(
        "Thành công",
        "Đã gửi đơn xin nghỉ phép thành công",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );

      // Đồng bộ nạp lại lịch sử cá nhân ngầm
      try {
        fetchMyRequests();
        if (Get.isRegistered<RequestHistoryController>()) {
          Get.find<RequestHistoryController>().fetchLeaveHistory(isRefresh: true);
        }
      } catch (_) {}

      return true;
    } catch (e) {
      isLoading.value = false;
      _handleDioError(e, "Gửi đơn nghỉ phép thất bại");
      return false;
    }
  }

  Future<bool> submitLeaveRequest(String reason, String start, String end, String type) =>
      createRequest(
        startDate: DateTime.parse(start),
        endDate: DateTime.parse(end),
        leaveType: type,
        reason: reason,
      );

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
        final idx = rhCtrl.leaves.indexWhere((item) => item.id == id);
        if (idx != -1) {
          rhCtrl.leaves[idx] = rhCtrl.leaves[idx].copyWith(status: 'CANCELLED');
          rhCtrl.leaves.refresh();
        }
      }

      _showResultDialog("Thành công", "Đã hủy đơn");
    } catch (e) {
      _handleDioError(e, "Không thể hủy đơn");
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
