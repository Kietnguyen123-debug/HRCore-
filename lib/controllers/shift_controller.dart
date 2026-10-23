import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/shift_repository.dart';
import '../repositories/system_admin_repository.dart';
import '../data/network/models/shift_models.dart';
import '../data/network/models/shift_admin_models.dart';

class ShiftController extends GetxController {
  final ShiftRepository _shiftRepo = ShiftRepository();
  final SystemAdminRepository _adminRepo = SystemAdminRepository();

  var myTodayShift = Rxn<EmployeeShiftScheduleDto>();
  var mySchedule = <EmployeeShiftScheduleDto>[].obs;
  var allShifts = <ShiftDto>[].obs;
  
  var isLoading = false.obs;

  List<ShiftDto> get shifts => allShifts;

  /// Parse chuỗi "HH:mm" hoặc "HH:mm:ss" sang Duration an toàn
  Duration _parseTime(String timeStr) {
    try {
      final parts = timeStr.trim().split(':');
      if (parts.length >= 2) {
        final hours = int.tryParse(parts[0]) ?? 0;
        final minutes = int.tryParse(parts[1]) ?? 0;
        final seconds = parts.length > 2 ? (int.tryParse(parts[2].split('.')[0]) ?? 0) : 0;
        return Duration(hours: hours, minutes: minutes, seconds: seconds);
      }
    } catch (_) {}
    return Duration.zero;
  }

  // --- EMPLOYEE LOGIC ---
  Future<void> fetchMyTodayShift() async {
    isLoading.value = true;
    try {
      final res = await _shiftRepo.getMyToday();
      myTodayShift.value = res;
    } catch (e) {
      debugPrint("Lỗi nạp lịch làm việc hôm nay: $e");
      myTodayShift.value = null; 
    } 
    finally { isLoading.value = false; }
  }

  Future<void> fetchMySchedule({DateTime? from, DateTime? to}) async {
    isLoading.value = true;
    try {
      final list = await _shiftRepo.getMySchedule(from: from, to: to);
      mySchedule.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp lịch ca tuần: $e");
      mySchedule.clear();
    }
    finally { isLoading.value = false; }
  }

  Future<void> fetchAllShifts() async {
    isLoading.value = true;
    try {
      final list = await _shiftRepo.getAllShifts();
      allShifts.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp danh sách ca: $e");
    }
    finally { isLoading.value = false; }
  }

  Future<bool> createShift(
    String code,
    String name,
    String start,
    String end, [
    bool isActive = true,
  ]) async {
    isLoading.value = true;
    try {
      final newShift = CreateShiftRequest(
        shiftCode: code,
        shiftName: name,
        startTime: _parseTime(start),
        endTime: _parseTime(end),
        isActive: isActive,
      );
      await _adminRepo.createShift(newShift);
      _showResultDialog("Thành công", "Đã tạo ca làm việc");
      try { fetchAllShifts(); } catch (_) {}
      return true;
    } catch (e) {
      _handleError(e, "Lỗi tạo ca");
      return false;
    } finally { isLoading.value = false; }
  }

  Future<void> updateShift(
    int id,
    String code,
    String name,
    String start,
    String end, [
    bool isActive = true,
  ]) async {
    isLoading.value = true;
    try {
      final updatedShift = CreateShiftRequest(
        shiftCode: code,
        shiftName: name,
        startTime: _parseTime(start),
        endTime: _parseTime(end),
        isActive: isActive,
      );
      await _adminRepo.updateShift(id, updatedShift);
      _showResultDialog("Thành công", "Cập nhật ca thành công");
      try { fetchAllShifts(); } catch (_) {}
    } catch (e) {
      _handleError(e, "Lỗi cập nhật");
    } finally { isLoading.value = false; }
  }

  Future<void> deleteShift(int id) async {
    try {
      await _adminRepo.deleteShift(id);
      _showResultDialog("Thành công", "Đã xóa ca làm việc");
      try { fetchAllShifts(); } catch (_) {}
    } catch (e) {
      _handleError(e, "Lỗi xóa ca");
    }
  }

  Future<void> assignToEmployee(dynamic employeeId, dynamic shiftId, dynamic fromDate, [dynamic toDate]) async {
    isLoading.value = true;
    try {
      int eId = employeeId is String ? int.parse(employeeId) : employeeId;
      int sId = shiftId is String ? int.parse(shiftId) : shiftId;

      DateTime start;
      if (fromDate is DateTime) {
        start = DateTime.utc(fromDate.year, fromDate.month, fromDate.day);
      } else {
        final dt = DateTime.parse(fromDate.toString());
        start = DateTime.utc(dt.year, dt.month, dt.day);
      }

      DateTime? end;
      if (toDate != null) {
        if (toDate is DateTime) {
          end = DateTime.utc(toDate.year, toDate.month, toDate.day);
        } else {
          final dt = DateTime.tryParse(toDate.toString());
          if (dt != null) {
            end = DateTime.utc(dt.year, dt.month, dt.day);
          }
        }
      }

      await _adminRepo.assignShift(AssignShiftRequest(
        employeeId: eId,
        shiftId: sId,
        effectiveFromDate: start,
        effectiveToDate: end,
      ));
      _showResultDialog("Thành công", "Đã gán ca cho nhân viên");
    } catch (e) {
      _handleError(e, "Gán ca thất bại");
    } finally { isLoading.value = false; }
  }

  void _handleError(dynamic e, String defaultTitle) {
    String msg = defaultTitle;
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        msg = data['message'] ?? data['Message'] ?? data['title'] ?? data['error'] ?? msg;
      } else if (data is String && data.isNotEmpty) {
        msg = data;
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }
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
