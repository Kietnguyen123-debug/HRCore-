import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/network/models/attendance_models.dart';
import '../repositories/attendance_repository.dart';
import '../services/wifi_service.dart';
import '../utils/wifi_helper.dart';

/// Controller xử lý luồng Điểm danh (Check-In/Check-Out) và Đăng ký Wi-Fi Chi nhánh (MVVM)
class AttendanceController extends GetxController {
  final AttendanceRepository _repository = AttendanceRepository();
  final WifiService _wifiService = WifiService();

  var isLoading = false.obs;
  var myToday = Rxn<AttendanceItemDto>();
  var historyList = <AttendanceItemDto>[].obs;
  var isHistoryLoading = false.obs;
  var branchWifis = <BranchWifiDto>[].obs;

  @override
  void onInit() {
    super.onInit();
    getMyToday();
  }

  /// Lấy dữ liệu điểm danh hôm nay của nhân viên
  Future<void> getMyToday() async {
    try {
      final item = await _repository.getMyToday();
      myToday.value = item;
    } catch (_) {}
  }

  /// Lấy lịch sử chấm công của cá nhân (GET /api/Attendance/my-history)
  Future<void> fetchMyHistory({DateTime? from, DateTime? to}) async {
    isHistoryLoading.value = true;
    try {
      final list = await _repository.getMyHistory(from: from, to: to);
      historyList.assignAll(list);
    } catch (e) {
      debugPrint("Lỗi nạp lịch sử chấm công: $e");
    } finally {
      isHistoryLoading.value = false;
    }
  }

  /// 🌟 Hàm dịch mã lỗi từ Backend (errorCode) sang thông báo tiếng Việt thân thiện
  String _parseErrorMessage(String? rawError, String? errorCode) {
    if (errorCode != null && errorCode.isNotEmpty) {
      switch (errorCode) {
        case 'FACE_SIMILARITY_LOW':
          return 'Khuôn mặt không trùng khớp với dữ liệu đăng ký. Vui lòng tháo kính, khẩu trang và thử lại ở nơi đủ sáng!';
        case 'NO_REGISTERED_FACE_VECTOR':
          return 'Tài khoản chưa được đăng ký khuôn mặt mẫu. Vui lòng liên hệ Quản lý!';
        case 'NO_FACE_DETECTED':
          return 'Không tìm thấy khuôn mặt trong ảnh chụp. Vui lòng nhìn thẳng vào camera!';
        case 'MULTIPLE_FACES_DETECTED':
          return 'Phát hiện nhiều hơn 1 khuôn mặt. Vui lòng đứng một mình trước camera!';
        case 'INVALID_BASE64_IMAGE':
          return 'Dữ liệu ảnh chụp không hợp lệ. Vui lòng thử chụp lại!';
        case 'WIFI_NOT_FOUND':
        case 'INVALID_WIFI':
        case 'BSSID_NOT_MATCH':
          return 'Mạng Wi-Fi hiện tại không thuộc danh sách Wi-Fi hợp lệ của chi nhánh.';
        case 'INVALID_IP':
        case 'IP_NOT_MATCH':
          return 'Địa chỉ IP mạng hiện tại không thuộc chi nhánh làm việc.';
        case 'DEVICE_NOT_ALLOWED':
        case 'INVALID_DEVICE':
          return 'Thiết bị di động của bạn chưa được cấp phép điểm danh.';
      }
    }

    final msg = rawError ?? '';
    if (msg.contains('FACE_VERIFICATION_FAILED') || msg.contains('FACE_SIMILARITY_LOW')) {
      return 'Khuôn mặt không trùng khớp với dữ liệu đăng ký. Vui lòng thử lại!';
    }
    if (msg.contains('SocketException') ||
        msg.contains('HandshakeException') ||
        msg.contains('TimeoutException') ||
        msg.contains('Failed host lookup') ||
        msg.contains('Connection refused')) {
      return 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại kết nối mạng!';
    }

    String cleanMsg = msg.replaceAll(RegExp(r'^(Exception|DioException|Error):\s*'), '').trim();
    return cleanMsg.isEmpty ? 'Xác thực không thành công. Vui lòng thử lại!' : cleanMsg;
  }

  /// 🌟 HÀM Check-In truyền tay thủ công với BSSID, DeviceId, Public IP
  Future<void> checkIn(
      String faceImageBase64,
      String bssid,
      String deviceId, {
        String? ssid,
        List<dynamic>? allowedBranchWifis,
        BuildContext? context,
      }) async {
    final cleanBssid = WifiHelper.cleanBssid(bssid);

    if (cleanBssid.isEmpty || deviceId.trim().isEmpty || faceImageBase64.trim().isEmpty) {
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Thiếu Thông Tin Điểm Danh",
        errorMessage: "Thiếu thông tin điểm danh (BSSID, Device ID hoặc Ảnh sinh trắc học).",
        bssid: cleanBssid,
        deviceId: deviceId,
        ssid: ssid,
        allowedBranchWifis: allowedBranchWifis,
      );
      return;
    }

    isLoading.value = true;
    String? publicIp;
    try {
      publicIp = await _wifiService.getPublicIp();
      final response = await _repository.checkIn(
        bssid: cleanBssid,
        deviceId: deviceId,
        faceImageBase64: faceImageBase64,
        clientPublicIp: publicIp,
      );

      if (response.success) {
        await getMyToday();
        _showSnackBar(
          "Thành công",
          response.message ?? "Điểm danh vào thành công!",
          isError: false,
          context: (context != null && context.mounted) ? context : null,
        );
      } else {
        final displayMsg = _parseErrorMessage(response.message, response.errorCode);
        await WifiHelper.showWifiVerificationErrorDialog(
          context: (context != null && context.mounted) ? context : null,
          title: "Xác Thực Điểm Danh Thất Bại",
          errorMessage: displayMsg,
          bssid: cleanBssid,
          clientPublicIp: publicIp,
          deviceId: deviceId,
          ssid: ssid,
          allowedBranchWifis: allowedBranchWifis,
        );
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e.toString().replaceAll('Exception: ', ''), null);
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Lỗi Xác Thực / Máy Chủ",
        errorMessage: errorMsg,
        bssid: cleanBssid,
        clientPublicIp: publicIp,
        deviceId: deviceId,
        ssid: ssid,
        allowedBranchWifis: allowedBranchWifis,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🌟 HÀM Check-Out truyền tay thủ công với BSSID, DeviceId, Public IP
  Future<void> checkOut(
      String faceImageBase64,
      String bssid,
      String deviceId, {
        String? ssid,
        List<dynamic>? allowedBranchWifis,
        BuildContext? context,
      }) async {
    final cleanBssid = WifiHelper.cleanBssid(bssid);

    if (cleanBssid.isEmpty || deviceId.trim().isEmpty || faceImageBase64.trim().isEmpty) {
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Thiếu Thông Tin Điểm Danh",
        errorMessage: "Thiếu thông tin điểm danh (BSSID, Device ID hoặc Ảnh sinh trắc học).",
        bssid: cleanBssid,
        deviceId: deviceId,
        ssid: ssid,
        allowedBranchWifis: allowedBranchWifis,
      );
      return;
    }

    isLoading.value = true;
    String? publicIp;
    try {
      publicIp = await _wifiService.getPublicIp();
      final response = await _repository.checkOut(
        bssid: cleanBssid,
        deviceId: deviceId,
        faceImageBase64: faceImageBase64,
        clientPublicIp: publicIp,
      );

      if (response.success) {
        await getMyToday();
        _showSnackBar(
          "Thành công",
          response.message ?? "Điểm danh ra thành công!",
          isError: false,
          context: (context != null && context.mounted) ? context : null,
        );
      } else {
        final displayMsg = _parseErrorMessage(response.message, response.errorCode);
        await WifiHelper.showWifiVerificationErrorDialog(
          context: (context != null && context.mounted) ? context : null,
          title: "Xác Thực Điểm Danh Thất Bại",
          errorMessage: displayMsg,
          bssid: cleanBssid,
          clientPublicIp: publicIp,
          deviceId: deviceId,
          ssid: ssid,
          allowedBranchWifis: allowedBranchWifis,
        );
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e.toString().replaceAll('Exception: ', ''), null);
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Lỗi Xác Thực / Máy Chủ",
        errorMessage: errorMsg,
        bssid: cleanBssid,
        clientPublicIp: publicIp,
        deviceId: deviceId,
        ssid: ssid,
        allowedBranchWifis: allowedBranchWifis,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🌟 HÀM XỬ LÝ NÚT BẤM "ĐIỂM DANH VÀO" TỰ ĐỘNG (onCheckInPressed)
  Future<void> onCheckInPressed(
      String faceImageBase64, {
        BuildContext? context,
      }) async {
    if (faceImageBase64.trim().isEmpty) {
      _showSnackBar(
        "Lỗi",
        "Chưa chụp ảnh khuôn mặt xác thực.",
        isError: true,
        context: (context != null && context.mounted) ? context : null,
      );
      return;
    }

    isLoading.value = true;
    WifiInfoResult? wifiInfo;
    try {
      wifiInfo = await _wifiService.getConnectedWifiInfo();
      final cleanBssid = WifiHelper.cleanBssid(wifiInfo.bssid);

      final response = await _repository.checkIn(
        bssid: cleanBssid,
        deviceId: wifiInfo.deviceId,
        faceImageBase64: faceImageBase64.trim(),
        clientPublicIp: wifiInfo.clientPublicIp,
      );

      if (response.success) {
        await getMyToday();
        _showSnackBar(
          "Thành công",
          response.message ?? "Điểm danh vào thành công!",
          isError: false,
          context: (context != null && context.mounted) ? context : null,
        );
      } else {
        final displayMsg = _parseErrorMessage(response.message, response.errorCode);
        await WifiHelper.showWifiVerificationErrorDialog(
          context: (context != null && context.mounted) ? context : null,
          title: "Xác Thực Điểm Danh Thất Bại",
          errorMessage: displayMsg,
          ssid: wifiInfo.ssid,
          bssid: cleanBssid,
          clientPublicIp: wifiInfo.clientPublicIp,
          deviceId: wifiInfo.deviceId,
        );
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e.toString().replaceAll('Exception: ', ''), null);
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Lỗi Xác Thực / Máy Chủ",
        errorMessage: errorMsg,
        ssid: wifiInfo?.ssid,
        bssid: WifiHelper.cleanBssid(wifiInfo?.bssid),
        clientPublicIp: wifiInfo?.clientPublicIp,
        deviceId: wifiInfo?.deviceId,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🌟 HÀM XỬ LÝ NÚT BẤM "ĐIỂM DANH RA" TỰ ĐỘNG (onCheckOutPressed)
  Future<void> onCheckOutPressed(
      String faceImageBase64, {
        BuildContext? context,
      }) async {
    if (faceImageBase64.trim().isEmpty) {
      _showSnackBar(
        "Lỗi",
        "Chưa chụp ảnh khuôn mặt xác thực.",
        isError: true,
        context: (context != null && context.mounted) ? context : null,
      );
      return;
    }

    isLoading.value = true;
    WifiInfoResult? wifiInfo;
    try {
      wifiInfo = await _wifiService.getConnectedWifiInfo();
      final cleanBssid = WifiHelper.cleanBssid(wifiInfo.bssid);

      final response = await _repository.checkOut(
        bssid: cleanBssid,
        deviceId: wifiInfo.deviceId,
        faceImageBase64: faceImageBase64.trim(),
        clientPublicIp: wifiInfo.clientPublicIp,
      );

      if (response.success) {
        await getMyToday();
        _showSnackBar(
          "Thành công",
          response.message ?? "Điểm danh ra thành công!",
          isError: false,
          context: (context != null && context.mounted) ? context : null,
        );
      } else {
        final displayMsg = _parseErrorMessage(response.message, response.errorCode);
        await WifiHelper.showWifiVerificationErrorDialog(
          context: (context != null && context.mounted) ? context : null,
          title: "Xác Thực Điểm Danh Thất Bại",
          errorMessage: displayMsg,
          ssid: wifiInfo.ssid,
          bssid: cleanBssid,
          clientPublicIp: wifiInfo.clientPublicIp,
          deviceId: wifiInfo.deviceId,
        );
      }
    } catch (e) {
      final errorMsg = _parseErrorMessage(e.toString().replaceAll('Exception: ', ''), null);
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Lỗi Xác Thực / Máy Chủ",
        errorMessage: errorMsg,
        ssid: wifiInfo?.ssid,
        bssid: WifiHelper.cleanBssid(wifiInfo?.bssid),
        clientPublicIp: wifiInfo?.clientPublicIp,
        deviceId: wifiInfo?.deviceId,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// 🌟 HÀM XỬ LÝ NÚT BẤM "ĐĂNG KÝ WI-FI CHI NHÁNH" (onRegisterWifiPressed)
  Future<void> onRegisterWifiPressed(
      int branchId, {
        String? customSsid,
        BuildContext? context,
      }) async {
    isLoading.value = true;
    WifiInfoResult? wifiInfo;
    try {
      wifiInfo = await _wifiService.getConnectedWifiInfo();
      final ssidToRegister = customSsid?.isNotEmpty == true ? customSsid : wifiInfo.ssid;
      final cleanBssid = WifiHelper.cleanBssid(wifiInfo.bssid);

      final response = await _repository.registerWifi(
        branchId: branchId,
        ssid: ssidToRegister,
        bssid: cleanBssid,
        isAutoCaptured: true,
      );

      _showSnackBar(
        "Thành công",
        response.message ?? "Đăng ký Wi-Fi chi nhánh thành công!",
        isError: false,
        context: (context != null && context.mounted) ? context : null,
      );

      fetchBranchWifis(branchId);
    } catch (e) {
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      await WifiHelper.showWifiVerificationErrorDialog(
        context: (context != null && context.mounted) ? context : null,
        title: "Đăng Ký Wi-Fi Thất Bại",
        errorMessage: errorMsg,
        ssid: wifiInfo?.ssid ?? customSsid,
        bssid: WifiHelper.cleanBssid(wifiInfo?.bssid),
        clientPublicIp: wifiInfo?.clientPublicIp,
        deviceId: wifiInfo?.deviceId,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy danh sách Wi-Fi của chi nhánh (GET /api/Branch/{branchId}/wifis)
  Future<void> fetchBranchWifis(int branchId) async {
    try {
      final list = await _repository.getBranchWifis(branchId);
      branchWifis.assignAll(list);
    } catch (_) {}
  }

  /// Hiển thị thông báo SnackBar cho người dùng
  void _showSnackBar(
      String title,
      String message, {
        required bool isError,
        BuildContext? context,
      }) {
    final ctx = (context != null && context.mounted) ? context : Get.context;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).hideCurrentSnackBar();
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 2),
              Text(message),
            ],
          ),
          backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 4),
        ),
      );
    } else {
      Get.snackbar(
        title,
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 10,
        duration: const Duration(seconds: 4),
      );
    }
  }
}