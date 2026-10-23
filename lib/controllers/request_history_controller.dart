import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../data/network/dio_client.dart';
import '../models/request_history_model.dart';
import '../core/app_colors.dart';

/// Controller chuyên trách quản lý LOGIC LỊCH SỬ ĐƠN TỪ & HỦY ĐƠN (GetX)
class RequestHistoryController extends GetxController {
  final Dio _dio = DioClient().dio;

  // ============================================================
  // 1. OBSERVED STATE VARIABLES (Rx)
  // ============================================================
  /// Tab đang chọn (0: Giải trình, 1: Nghỉ phép, 2: Tăng ca, 3: Tạm ứng)
  final RxInt selectedTab = 0.obs;

  /// Bộ lọc trạng thái: 'ALL', 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'
  final RxString selectedStatusFilter = 'ALL'.obs;

  /// Trạng thái đang tải danh sách
  final RxBool isLoading = false.obs;

  /// ID đơn đang gọi API hủy (dùng để hiện loading spinner riêng)
  final RxnInt cancellingId = RxnInt();

  /// Thông điệp lỗi khi tải dữ liệu
  final RxString errorMessage = ''.obs;

  // Danh sách lưu trữ cục bộ trong RAM cho 4 loại đơn
  final RxList<AttendanceExplanationItem> explanations = <AttendanceExplanationItem>[].obs;
  final RxList<LeaveItem> leaves = <LeaveItem>[].obs;
  final RxList<OvertimeItem> overtimes = <OvertimeItem>[].obs;
  final RxList<SalaryAdvanceItem> salaryAdvances = <SalaryAdvanceItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Tải dữ liệu tab đầu tiên khi khởi tạo controller
    fetchCurrentTabHistory();
  }

  // ============================================================
  // 2. TAB & FILTER LOGIC
  // ============================================================
  /// Chuyển tab đơn từ -> tự động fetch danh sách tương ứng từ API
  void changeTab(int tabIndex) {
    if (selectedTab.value == tabIndex) return;
    selectedTab.value = tabIndex;
    errorMessage.value = '';
    fetchCurrentTabHistory();
  }

  /// Thay đổi bộ lọc trạng thái (ALL, PENDING, APPROVED, REJECTED, CANCELLED)
  void changeStatusFilter(String filterCode) {
    selectedStatusFilter.value = filterCode;
  }

  /// Tải lại dữ liệu khi người dùng kéo RefreshIndicator (Pull-to-refresh)
  Future<void> refreshHistory() async {
    await fetchCurrentTabHistory(isRefresh: true);
  }

  // ============================================================
  // 3. GETTERS (LỌC DANH SÁCH TRỰC TIẾP TRONG RAM)
  // ============================================================
  /// Danh sách Giải trình điểm danh sau khi lọc theo status
  List<AttendanceExplanationItem> get filteredExplanations {
    final filter = selectedStatusFilter.value;
    if (filter == 'ALL') return explanations;
    return explanations.where((e) => e.normalizedStatus == filter).toList();
  }

  /// Danh sách Nghỉ phép sau khi lọc theo status
  List<LeaveItem> get filteredLeaves {
    final filter = selectedStatusFilter.value;
    if (filter == 'ALL') return leaves;
    return leaves.where((e) => e.normalizedStatus == filter).toList();
  }

  /// Danh sách Tăng ca sau khi lọc theo status
  List<OvertimeItem> get filteredOvertimes {
    final filter = selectedStatusFilter.value;
    if (filter == 'ALL') return overtimes;
    return overtimes.where((e) => e.normalizedStatus == filter).toList();
  }

  /// Danh sách Tạm ứng lương sau khi lọc theo status
  List<SalaryAdvanceItem> get filteredSalaryAdvances {
    final filter = selectedStatusFilter.value;
    if (filter == 'ALL') return salaryAdvances;
    return salaryAdvances.where((e) => e.normalizedStatus == filter).toList();
  }

  // ============================================================
  // 4. API FETCH HISTORY (GET MY-REQUESTS)
  // ============================================================
  /// Gọi API tương ứng với Tab đang chọn
  Future<void> fetchCurrentTabHistory({bool isRefresh = false}) async {
    switch (selectedTab.value) {
      case 0:
        await fetchAttendanceExplanationHistory(isRefresh: isRefresh);
        break;
      case 1:
        await fetchLeaveHistory(isRefresh: isRefresh);
        break;
      case 2:
        await fetchOvertimeHistory(isRefresh: isRefresh);
        break;
      case 3:
        await fetchSalaryAdvanceHistory(isRefresh: isRefresh);
        break;
    }
  }

  /// 1. Fetch Giải trình: GET /api/AttendanceExplanation/my-requests
  Future<void> fetchAttendanceExplanationHistory({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get('AttendanceExplanation/my-requests');
      final list = _extractList(response.data);
      final items = list
          .whereType<Map>()
          .map((json) => AttendanceExplanationItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      explanations.assignAll(items);
    } catch (e) {
      _handleFetchError(e, "Không thể tải danh sách giải trình");
    } finally {
      isLoading.value = false;
    }
  }

  /// 2. Fetch Nghỉ phép: GET /api/Leave/my-requests
  Future<void> fetchLeaveHistory({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get('Leave/my-requests');
      final list = _extractList(response.data);
      final items = list
          .whereType<Map>()
          .map((json) => LeaveItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      leaves.assignAll(items);
    } catch (e) {
      _handleFetchError(e, "Không thể tải danh sách đơn nghỉ phép");
    } finally {
      isLoading.value = false;
    }
  }

  /// 3. Fetch Tăng ca: GET /api/Overtime/my-requests
  Future<void> fetchOvertimeHistory({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get('Overtime/my-requests');
      final list = _extractList(response.data);
      final items = list
          .whereType<Map>()
          .map((json) => OvertimeItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      overtimes.assignAll(items);
    } catch (e) {
      _handleFetchError(e, "Không thể tải danh sách tăng ca");
    } finally {
      isLoading.value = false;
    }
  }

  /// 4. Fetch Tạm ứng lương: GET /api/SalaryAdvance/my-requests
  Future<void> fetchSalaryAdvanceHistory({bool isRefresh = false}) async {
    if (!isRefresh) isLoading.value = true;
    errorMessage.value = '';
    try {
      final response = await _dio.get('SalaryAdvance/my-requests');
      final list = _extractList(response.data);
      final items = list
          .whereType<Map>()
          .map((json) => SalaryAdvanceItem.fromJson(Map<String, dynamic>.from(json)))
          .toList();
      salaryAdvances.assignAll(items);
    } catch (e) {
      _handleFetchError(e, "Không thể tải danh sách tạm ứng lương");
    } finally {
      isLoading.value = false;
    }
  }

  // ============================================================
  // 5. API HỦY ĐƠN & CẬP NHẬT TRỰC TIẾP TRONG RAM (200 OK)
  // ============================================================
  /// Gọi lệnh Hủy đơn tương ứng theo loại đơn hiện tại
  Future<void> cancelRequest(int id) async {
    switch (selectedTab.value) {
      case 0:
        await cancelAttendanceExplanation(id);
        break;
      case 1:
        await cancelLeaveRequest(id);
        break;
      case 2:
        await cancelOvertimeRequest(id);
        break;
      case 3:
        await cancelSalaryAdvanceRequest(id);
        break;
    }
  }

  /// 1. Hủy Giải trình: PUT /api/AttendanceExplanation/{id}/cancel
  Future<void> cancelAttendanceExplanation(int id) async {
    cancellingId.value = id;
    try {
      await _dio.put('AttendanceExplanation/$id/cancel');

      // CẬP NHẬT TRỰC TIẾP TRONG RAM KHI THÀNH CÔNG (200 OK)
      final index = explanations.indexWhere((e) => e.id == id);
      if (index != -1) {
        explanations[index] = explanations[index].copyWith(status: 'CANCELLED');
        explanations.refresh(); // Thông báo GetX UI render lại ngay lập tức
      }

      _showSuccessNotification("Đã hủy đơn giải trình điểm danh thành công");
    } catch (e) {
      _handleActionError(e, "Không thể hủy đơn giải trình");
    } finally {
      cancellingId.value = null;
    }
  }

  /// 2. Hủy Nghỉ phép: PUT /api/Leave/{id}/cancel
  Future<void> cancelLeaveRequest(int id) async {
    cancellingId.value = id;
    try {
      await _dio.put('Leave/$id/cancel');

      // CẬP NHẬT TRỰC TIẾP TRONG RAM KHI THÀNH CÔNG (200 OK)
      final index = leaves.indexWhere((e) => e.id == id);
      if (index != -1) {
        leaves[index] = leaves[index].copyWith(status: 'CANCELLED');
        leaves.refresh();
      }

      _showSuccessNotification("Đã hủy đơn nghỉ phép thành công");
    } catch (e) {
      _handleActionError(e, "Không thể hủy đơn nghỉ phép");
    } finally {
      cancellingId.value = null;
    }
  }

  /// 3. Hủy Tăng ca: PUT /api/Overtime/{id}/cancel
  Future<void> cancelOvertimeRequest(int id) async {
    cancellingId.value = id;
    try {
      await _dio.put('Overtime/$id/cancel');

      // CẬP NHẬT TRỰC TIẾP TRONG RAM KHI THÀNH CÔNG (200 OK)
      final index = overtimes.indexWhere((e) => e.id == id);
      if (index != -1) {
        overtimes[index] = overtimes[index].copyWith(status: 'CANCELLED');
        overtimes.refresh();
      }

      _showSuccessNotification("Đã hủy đơn đăng ký tăng ca thành công");
    } catch (e) {
      _handleActionError(e, "Không thể hủy đơn tăng ca");
    } finally {
      cancellingId.value = null;
    }
  }

  /// 4. Hủy Tạm ứng: PUT /api/SalaryAdvance/{id}/cancel
  Future<void> cancelSalaryAdvanceRequest(int id) async {
    cancellingId.value = id;
    try {
      await _dio.put('SalaryAdvance/$id/cancel');

      // CẬP NHẬT TRỰC TIẾP TRONG RAM KHI THÀNH CÔNG (200 OK)
      final index = salaryAdvances.indexWhere((e) => e.id == id);
      if (index != -1) {
        salaryAdvances[index] = salaryAdvances[index].copyWith(status: 'CANCELLED');
        salaryAdvances.refresh();
      }

      _showSuccessNotification("Đã hủy đơn tạm ứng lương thành công");
    } catch (e) {
      _handleActionError(e, "Không thể hủy đơn tạm ứng");
    } finally {
      cancellingId.value = null;
    }
  }

  // ============================================================
  // 6. HELPER EXTRACT JSON LIST & ERROR HANDLING
  // ============================================================
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
      if (map.containsKey('data') && map['data'] is Map) {
        final inner = Map<String, dynamic>.from(map['data'] as Map);
        for (final key in ['items', '\$values', 'data', 'list']) {
          if (inner.containsKey(key) && inner[key] is List) {
            return inner[key] as List;
          }
        }
      }
    }
    return [];
  }

  void _handleFetchError(dynamic e, String defaultMsg) {
    String msg = _parseErrorMessage(e, defaultMsg);
    errorMessage.value = msg;
    debugPrint("Lỗi Fetch Lịch sử API: $msg");
  }

  void _handleActionError(dynamic e, String defaultTitle) {
    String msg = _parseErrorMessage(e, "Đã xảy ra lỗi, vui lòng thử lại");
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.error_outline, color: Colors.red),
            SizedBox(width: 8),
            Text("Không thể thực hiện", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text("XÁC NHẬN", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  String _parseErrorMessage(dynamic e, String defaultMsg) {
    if (e is DioException) {
      if (e.response?.statusCode == 401) {
        return "Phiên đăng nhập hết hạn (401). Vui lòng đăng nhập lại.";
      }
      if (e.response?.statusCode == 500) {
        return "Lỗi máy chủ nội bộ (500). Vui lòng liên hệ quản trị viên.";
      }
      final data = e.response?.data;
      if (data is Map) {
        String? msg = data['message'] ?? data['Message'] ?? data['error'] ?? data['Error'] ?? data['title'] ?? data['detail'];
        if (data.containsKey('errors') && data['errors'] is Map) {
          final Map<String, dynamic> errors = data['errors'];
          List<String> errList = [];
          errors.forEach((k, v) {
            if (v is List && v.isNotEmpty) errList.add(v.join(', '));
          });
          if (errList.isNotEmpty) msg = errList.join('\n');
        }
        if (msg != null && msg.isNotEmpty) return msg;
      } else if (data is String && data.isNotEmpty) {
        return data;
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return "Kết nối máy chủ quá thời gian. Vui lòng kiểm tra lại mạng.";
      }
      if (e.type == DioExceptionType.connectionError) {
        return "Không có kết nối Internet hoặc không thể kết nối server.";
      }
    }
    return defaultMsg;
  }

  void _showSuccessNotification(String message) {
    Get.snackbar(
      "Thành công",
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}
