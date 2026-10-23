import 'package:dio/dio.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/attendance_models.dart';
import '../data/network/rest_clients/attendance_rest_client.dart';
import '../data/network/rest_clients/branch_rest_client.dart';
import '../utils/wifi_helper.dart';

/// Repository quản lý tất cả các thao tác liên quan tới Điểm danh và Mạng Wi-Fi
class AttendanceRepository {
  final AttendanceRestClient _attendanceRestClient;
  final BranchRestClient _branchRestClient;

  AttendanceRepository({
    AttendanceRestClient? attendanceRestClient,
    BranchRestClient? branchRestClient,
  })  : _attendanceRestClient =
            attendanceRestClient ?? AttendanceRestClient(DioClient().dio),
        _branchRestClient =
            branchRestClient ?? BranchRestClient(DioClient().dio);

  /// Chuẩn hóa BSSID về định dạng chuẩn canonical (ví dụ: "5C:18:DD:13:8B:0A")
  String _cleanBssid(String rawBssid) {
    return WifiHelper.formatBssidCanonical(rawBssid);
  }

  /// API 1: Điểm danh vào (POST /api/Attendance/check-in)
  Future<AttendanceActionResponse> checkIn({
    required String bssid,
    required String deviceId,
    required String faceImageBase64,
    String? clientPublicIp,
  }) async {
    try {
      final request = AttendanceRequest(
        bssid: _cleanBssid(bssid),
        deviceId: deviceId.trim(),
        faceImageBase64: faceImageBase64.trim(),
        clientPublicIp: clientPublicIp?.trim(),
      );
      return await _attendanceRestClient.checkIn(request);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Điểm danh vào thất bại.'));
    }
  }

  /// API 2: Điểm danh ra (POST /api/Attendance/check-out)
  Future<AttendanceActionResponse> checkOut({
    required String bssid,
    required String deviceId,
    required String faceImageBase64,
    String? clientPublicIp,
  }) async {
    try {
      final request = AttendanceRequest(
        bssid: _cleanBssid(bssid),
        deviceId: deviceId.trim(),
        faceImageBase64: faceImageBase64.trim(),
        clientPublicIp: clientPublicIp?.trim(),
      );
      return await _attendanceRestClient.checkOut(request);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Điểm danh ra thất bại.'));
    }
  }

  /// API 3: Đăng ký Wi-Fi cho Chi nhánh (POST /api/Attendance/register-wifi)
  Future<MessageResponse> registerWifi({
    required int branchId,
    String? ssid,
    required String bssid,
    bool isAutoCaptured = true,
  }) async {
    try {
      String? cleanSsid = ssid?.trim().replaceAll('"', '');
      if (cleanSsid != null && cleanSsid.length > 32) {
        cleanSsid = cleanSsid.substring(0, 32);
      }

      final request = RegisterWifiRequest(
        branchId: branchId,
        ssid: cleanSsid,
        bssid: _cleanBssid(bssid),
        isAutoCaptured: isAutoCaptured,
      );

      final res = await _attendanceRestClient.registerWifi(request);
      return MessageResponse(message: res.message);
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Đăng ký Wi-Fi chi nhánh thất bại.'));
    }
  }

  /// API 4: Lấy danh sách Wi-Fi chi nhánh (GET /api/Branch/{branchId}/wifis)
  Future<List<BranchWifiDto>> getBranchWifis(int branchId) async {
    try {
      final wifis = await _branchRestClient.getWifis(branchId);
      return wifis
          .map((w) => BranchWifiDto(
                id: w.id,
                branchId: w.branchId,
                ssid: w.ssid,
                bssid: w.bssid,
                description: w.description,
                isActive: w.isActive,
              ))
          .toList();
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Không thể lấy danh sách Wi-Fi của chi nhánh.'));
    }
  }

  // --- Các hàm tiện ích phục vụ các màn hình khác ---

  Future<void> registerFace(int employeeId, String faceImageBase64) async {
    try {
      await _attendanceRestClient.registerFace(RegisterFaceRequest(
        employeeId: employeeId,
        faceImageBase64: faceImageBase64,
      ));
    } on DioException catch (e) {
      throw Exception(_extractErrorMessage(e, 'Đăng ký khuôn mặt cho nhân viên thất bại.'));
    }
  }

  Future<AttendanceItemDto> getMyToday() {
    return _attendanceRestClient.getMyToday();
  }

  Future<AttendanceSummaryDto> getMySummary({int? month, int? year}) {
    return _attendanceRestClient.getMySummary(month: month, year: year);
  }

  Future<List<AttendanceItemDto>> getMyHistory({DateTime? from, DateTime? to}) {
    return _attendanceRestClient.getMyHistory(
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
    );
  }

  Future<AdminAttendanceDtoPagedResponse> getAdminEmployeeAttendance({
    required int employeeId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) {
    return _attendanceRestClient.getAdminEmployeeAttendance(
      employeeId,
      from?.toIso8601String(),
      to?.toIso8601String(),
      page,
      pageSize,
    );
  }

  Future<AdminAttendanceDtoPagedResponse> getAdminDateAttendance({
    required DateTime date,
    int? branchId,
    int page = 1,
    int pageSize = 20,
  }) {
    return _attendanceRestClient.getAdminDateAttendance(
      date.toIso8601String(),
      branchId,
      page,
      pageSize,
    );
  }

  Future<AttendanceItemDto> adjustAttendance(
    int id, {
    DateTime? checkIn,
    DateTime? checkOut,
    required String reason,
  }) {
    return _attendanceRestClient.adjustAttendance(
      id,
      AdjustAttendanceRequest(
        checkInTime: checkIn,
        checkOutTime: checkOut,
        reason: reason,
      ),
    );
  }

  /// Bắt và bóc tách thông báo lỗi chuẩn từ C# ValidationProblemDetails / DioException
  String _extractErrorMessage(DioException e, String defaultMessage) {
    if (e.response?.statusCode == 401) {
      return 'Phiên đăng nhập đã hết hạn (401). Vui lòng đăng nhập lại.';
    }

    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      if (data['message'] != null && data['message'].toString().isNotEmpty) {
        return data['message'].toString();
      }
      if (data['Message'] != null && data['Message'].toString().isNotEmpty) {
        return data['Message'].toString();
      }
      if (data['error'] != null && data['error'].toString().isNotEmpty) {
        return data['error'].toString();
      }
      if (data['errors'] is Map) {
        final Map<String, dynamic> errors = data['errors'];
        final errList = <String>[];
        errors.forEach((key, val) {
          if (val is List && val.isNotEmpty) errList.add(val.join(', '));
        });
        if (errList.isNotEmpty) return errList.join('\n');
      }
      if (data['title'] != null) return data['title'].toString();
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return e.message ?? defaultMessage;
  }
}
