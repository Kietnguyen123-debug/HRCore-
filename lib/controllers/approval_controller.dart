import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/admin_repository.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/admin_models.dart';
import '../data/network/models/explanation_models.dart';

class ApprovalController extends GetxController {
  final AdminRepository _adminRepo = AdminRepository();
  final Dio _dio = DioClient().dio;

  var pendingLeaves = <AdminLeaveDto>[].obs;
  var pendingOvertimes = <AdminOvertimeDto>[].obs;
  var pendingAdvances = <AdminSalaryAdvanceDto>[].obs;
  var pendingExplanations = <AttendanceExplanationResponse>[].obs;

  var isLoading = false.obs;
  var historyRecords = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllPending();
  }

  Future<void> fetchAllPending() async {
    isLoading.value = true;
    try {
      await Future.wait([
        fetchPendingLeavesFromServer(),
        fetchPendingOvertimesFromServer(),
        fetchPendingAdvancesFromServer(),
        fetchPendingExplanationsFromServer(),
        fetchHistoryFromServer(),
      ]);
    } catch (e) {
      debugPrint("Lỗi nạp danh sách phê duyệt từ server: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPendingLeavesFromServer() async {
    try {
      final res = await _adminRepo.getPendingLeaves();
      pendingLeaves.assignAll(res.list);
    } catch (e) {
      try {
        final res = await _dio.get('Leave/admin/pending', queryParameters: {'page': 1, 'pageSize': 50});
        final list = _extractList(res.data);
        final List<AdminLeaveDto> parsed = list
            .whereType<Map>()
            .map<AdminLeaveDto>((json) => AdminLeaveDto.fromJson(Map<String, dynamic>.from(json)))
            .where((item) => item.status.toUpperCase() == 'PENDING')
            .toList();
        pendingLeaves.assignAll(parsed);
      } catch (_) {}
    }
  }

  Future<void> fetchPendingOvertimesFromServer() async {
    try {
      final res = await _adminRepo.getPendingOvertimes();
      pendingOvertimes.assignAll(res.list);
    } catch (e) {
      try {
        final res = await _dio.get('Overtime/admin/pending', queryParameters: {'page': 1, 'pageSize': 50});
        final list = _extractList(res.data);
        final List<AdminOvertimeDto> parsed = list
            .whereType<Map>()
            .map<AdminOvertimeDto>((json) => AdminOvertimeDto.fromJson(Map<String, dynamic>.from(json)))
            .where((item) => item.status.toUpperCase() == 'PENDING')
            .toList();
        pendingOvertimes.assignAll(parsed);
      } catch (_) {}
    }
  }

  Future<void> fetchPendingAdvancesFromServer() async {
    try {
      final res = await _adminRepo.getPendingAdvances();
      pendingAdvances.assignAll(res);
    } catch (e) {
      try {
        final res = await _dio.get('SalaryAdvance/pending');
        final list = _extractList(res.data);
        final List<AdminSalaryAdvanceDto> parsed = list
            .whereType<Map>()
            .map<AdminSalaryAdvanceDto>((json) => AdminSalaryAdvanceDto.fromJson(Map<String, dynamic>.from(json)))
            .where((item) => item.status.toUpperCase() == 'PENDING')
            .toList();
        pendingAdvances.assignAll(parsed);
      } catch (_) {}
    }
  }

  Future<void> fetchPendingExplanationsFromServer() async {
    try {
      final res = await _adminRepo.getPendingExplanations();
      pendingExplanations.assignAll(res);
    } catch (e) {
      try {
        final res = await _dio.get('AttendanceExplanation/pending');
        final list = _extractList(res.data);
        final List<AttendanceExplanationResponse> parsed = list
            .whereType<Map>()
            .map<AttendanceExplanationResponse>((json) => AttendanceExplanationResponse.fromJson(Map<String, dynamic>.from(json)))
            .where((item) => (item.status ?? '').toUpperCase() == 'PENDING')
            .toList();
        pendingExplanations.assignAll(parsed);
      } catch (_) {}
    }
  }

  Future<void> fetchHistoryFromServer() async {
    List<Map<String, dynamic>> serverHistory = [];

    // 1. Fetch Leave History
    try {
      final res = await _dio.get('Leave/admin/pending', queryParameters: {'page': 1, 'pageSize': 50});
      final list = _extractList(res.data);
      for (var item in list) {
        if (item is Map) {
          String st = (item['status'] ?? item['Status'] ?? '').toString().toUpperCase();
          if (st != 'PENDING' && st.isNotEmpty) {
            serverHistory.add({
              'id': item['id'] ?? item['Id'],
              'type': 'Leave',
              'employeeName': item['employeeName'] ?? item['fullName'] ?? item['EmployeeName'] ?? 'NV #${item['employeeId'] ?? item['EmployeeId'] ?? ''}',
              'status': st == 'APPROVED' ? 'Đã duyệt' : 'Từ chối',
              'note': item['reviewNote'] ?? item['reason'] ?? 'N/A',
              'processedAt': item['createdAt'] ?? item['startDate'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (_) {}

    // 2. Fetch Overtime History
    try {
      final res = await _dio.get('Overtime/admin/pending', queryParameters: {'page': 1, 'pageSize': 50});
      final list = _extractList(res.data);
      for (var item in list) {
        if (item is Map) {
          String st = (item['status'] ?? item['Status'] ?? '').toString().toUpperCase();
          if (st != 'PENDING' && st.isNotEmpty) {
            serverHistory.add({
              'id': item['id'] ?? item['Id'],
              'type': 'Overtime',
              'employeeName': item['employeeName'] ?? item['fullName'] ?? item['EmployeeName'] ?? 'NV #${item['employeeId'] ?? item['EmployeeId'] ?? ''}',
              'status': st == 'APPROVED' ? 'Đã duyệt' : 'Từ chối',
              'note': "Tăng ca ${item['hours'] ?? item['Hours'] ?? 0}h",
              'processedAt': item['workDate'] ?? item['createdAt'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (_) {}

    // 3. Fetch Salary Advance History
    try {
      final res = await _dio.get('SalaryAdvance/pending');
      final list = _extractList(res.data);
      for (var item in list) {
        if (item is Map) {
          String st = (item['status'] ?? item['Status'] ?? '').toString().toUpperCase();
          if (st != 'PENDING' && st.isNotEmpty) {
            serverHistory.add({
              'id': item['id'] ?? item['Id'],
              'type': 'Advance',
              'employeeName': item['employeeName'] ?? item['fullName'] ?? item['EmployeeName'] ?? 'NV #${item['employeeId'] ?? item['EmployeeId'] ?? ''}',
              'status': st == 'APPROVED' ? 'Đã duyệt' : 'Từ chối',
              'note': item['reviewNote'] ?? item['reason'] ?? 'N/A',
              'processedAt': item['requestDate'] ?? item['createdAt'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (_) {}

    // 4. Fetch Attendance Explanation History
    try {
      final res = await _dio.get('AttendanceExplanation/pending');
      final list = _extractList(res.data);
      for (var item in list) {
        if (item is Map) {
          String st = (item['status'] ?? item['Status'] ?? '').toString().toUpperCase();
          if (st != 'PENDING' && st.isNotEmpty) {
            serverHistory.add({
              'id': item['id'] ?? item['Id'],
              'type': 'Explanation',
              'employeeName': item['employeeName'] ?? item['fullName'] ?? item['EmployeeName'] ?? 'NV #${item['employeeId'] ?? item['EmployeeId'] ?? ''}',
              'status': st == 'APPROVED' ? 'Đã duyệt' : 'Từ chối',
              'note': item['reviewNote'] ?? item['explanationReason'] ?? 'N/A',
              'processedAt': item['targetDate'] ?? item['createdAt'] ?? DateTime.now().toIso8601String(),
            });
          }
        }
      }
    } catch (_) {}

    // Re-merge all local historyRecords so previously approved/rejected items in session are retained!
    for (var localItem in historyRecords) {
      bool exists = serverHistory.any((s) => s['id'] == localItem['id'] && s['type'] == localItem['type']);
      if (!exists) {
        serverHistory.add(localItem);
      }
    }

    serverHistory.sort((a, b) {
      String da = a['processedAt'].toString();
      String db = b['processedAt'].toString();
      return db.compareTo(da);
    });

    historyRecords.assignAll(serverHistory);
  }

  List<dynamic> _extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map) {
      final map = Map<String, dynamic>.from(rawData);
      for (final key in ['data', 'items', 'result', '\$values', 'list']) {
        if (map.containsKey(key) && map[key] is List) {
          return map[key] as List;
        }
      }
    }
    return [];
  }

  Future<void> approveLeave(int id, bool isApproved, {String? reason}) async {
    isLoading.value = true;
    AdminLeaveDto? matched = pendingLeaves.firstWhereOrNull((e) => e.id == id);
    try {
      await _adminRepo.approveLeave(
        id: id,
        isApproved: isApproved,
        rejectReason: reason,
      );

      historyRecords.insert(0, {
        'id': id,
        'type': 'Leave',
        'employeeName': matched?.employeeName ?? "NV #${matched?.employeeId ?? id}",
        'status': isApproved ? "Đã duyệt" : "Từ chối",
        'note': reason ?? matched?.reason ?? "N/A",
        'processedAt': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Thành công",
        isApproved ? "Đã phê duyệt đơn nghỉ phép" : "Đã từ chối đơn nghỉ phép",
        backgroundColor: isApproved ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
      try { await fetchAllPending(); } catch (_) {}
    } catch (e) {
      _handleError(e, "Xử lý duyệt phép thất bại");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveOvertime(int id, bool isApproved, {String? reason}) async {
    isLoading.value = true;
    AdminOvertimeDto? matched = pendingOvertimes.firstWhereOrNull((e) => e.id == id);
    try {
      await _adminRepo.approveOvertime(id: id, isApproved: isApproved);

      historyRecords.insert(0, {
        'id': id,
        'type': 'Overtime',
        'employeeName': matched?.employeeName ?? "NV #${matched?.employeeId ?? id}",
        'status': isApproved ? "Đã duyệt" : "Từ chối",
        'note': reason ?? "Tăng ca ${matched?.hours ?? 0}h",
        'processedAt': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Thành công",
        isApproved ? "Đã phê duyệt yêu cầu tăng ca" : "Đã từ chối yêu cầu tăng ca",
        backgroundColor: isApproved ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
      try { await fetchAllPending(); } catch (_) {}
    } catch (e) {
      _handleError(e, "Xử lý duyệt tăng ca thất bại");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> approveAdvance(int id, bool isApproved, {String? note}) async {
    isLoading.value = true;
    AdminSalaryAdvanceDto? matched = pendingAdvances.firstWhereOrNull((e) => e.id == id);
    try {
      await _adminRepo.approveSalaryAdvance(id: id, isApproved: isApproved, reviewNote: note);

      historyRecords.insert(0, {
        'id': id,
        'type': 'Advance',
        'employeeName': matched?.employeeName ?? "NV #${matched?.employeeId ?? id}",
        'status': isApproved ? "Đã duyệt" : "Từ chối",
        'note': note ?? matched?.reason ?? "N/A",
        'processedAt': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Thành công",
        isApproved ? "Đã phê duyệt yêu cầu tạm ứng" : "Đã từ chối yêu cầu tạm ứng",
        backgroundColor: isApproved ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
      try { await fetchAllPending(); } catch (_) {}
    } catch (e) {
      _handleError(e, "Xử lý duyệt tạm ứng thất bại");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> reviewExplanation(int id, String status, {String? note}) async {
    isLoading.value = true;
    AttendanceExplanationResponse? matched = pendingExplanations.firstWhereOrNull((e) => e.id == id);
    bool isApproved = status == "APPROVED";
    try {
      await _adminRepo.reviewExplanation(id: id, status: status, reviewNote: note);

      historyRecords.insert(0, {
        'id': id,
        'type': 'Explanation',
        'employeeName': matched?.employeeName ?? "NV #${matched?.employeeId ?? id}",
        'status': isApproved ? "Đã duyệt" : "Từ chối",
        'note': note ?? matched?.explanationReason ?? "N/A",
        'processedAt': DateTime.now().toIso8601String(),
      });

      Get.snackbar(
        "Thành công",
        isApproved ? "Đã phê duyệt giải trình" : "Đã từ chối giải trình",
        backgroundColor: isApproved ? Colors.green : Colors.orange,
        colorText: Colors.white,
      );
      try { await fetchAllPending(); } catch (_) {}
    } catch (e) {
      _handleError(e, "Xử lý duyệt giải trình thất bại");
    } finally {
      isLoading.value = false;
    }
  }

  void _handleError(dynamic e, String defaultTitle) {
    String msg = defaultTitle;
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        msg = data['message'] ?? data['Message'] ?? data['error'] ?? data['Error'] ?? data['title'] ?? data['detail'] ?? msg;
        if (data.containsKey('errors') && data['errors'] is Map) {
          final Map<String, dynamic> errors = data['errors'];
          List<String> errList = [];
          errors.forEach((k, v) {
            if (v is List && v.isNotEmpty) errList.add(v.join(', '));
          });
          if (errList.isNotEmpty) msg = errList.join('\n');
        }
      } else if (data is String && data.isNotEmpty) {
        msg = data;
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }
    }
    Get.snackbar(
      defaultTitle,
      msg,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
    );
  }
}
