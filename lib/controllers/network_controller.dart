import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../repositories/branch_repository.dart';
import '../data/network/models/branch_models.dart';
import '../utils/wifi_helper.dart';

class NetworkController extends GetxController {
  final BranchRepository _repository = BranchRepository();
  var isLoading = false.obs;

  var branchIps = <BranchIpDto>[].obs;
  var branchWifis = <BranchWifiDto>[].obs;

  Future<void> fetchBranchNetwork(int branchId) async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _repository.getIps(branchId),
        _repository.getWifis(branchId),
      ]);
      branchIps.assignAll(results[0] as List<BranchIpDto>);
      branchWifis.assignAll(results[1] as List<BranchWifiDto>);
    } catch (e) {
      _handleError(e, "Không thể tải thông tin mạng");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveWifi({
    required int branchId,
    required String ssid,
    required String bssid,
    bool isAutoCaptured = false,
  }) async {
    // 1. Chuẩn hóa BSSID bằng WifiHelper
    final cleanSsid = WifiHelper.cleanSsid(ssid);
    final formattedBssid = WifiHelper.normalizeBssid(bssid);

    // 2. Kiểm tra BSSID bị ẩn do thiếu quyền Location trên Android/iOS
    if (WifiHelper.isInvalidOrDummyBssid(bssid)) {
      _showResultDialog(
        "Lỗi thiết bị",
        "Không thể lấy địa chỉ MAC (BSSID) thực tế. Vui lòng bật Bật vị trí (GPS) và cấp quyền Vị trí cho ứng dụng.",
        isError: true,
      );
      return;
    }

    try {
      await _repository.addWifi(branchId, cleanSsid, formattedBssid, "Thêm từ App");
      _showResultDialog("Thành công", "Đã lưu thông tin Wifi công ty");
      try {
        fetchBranchNetwork(branchId);
      } catch (_) {}
    } catch (e) {
      _handleError(e, "Thêm Wifi thất bại");
    }
  }

  Future<void> saveIp({
    required int branchId,
    String publicIp = "",
    String? description,
  }) async {
    final cleanIp = publicIp.trim();

    try {
      await _repository.addIp(branchId, ip: cleanIp, description: description?.trim());
      _showResultDialog("Thành công", "Đã lưu địa chỉ IP Public cho Chi nhánh");
      try {
        fetchBranchNetwork(branchId);
      } catch (_) {}
    } catch (e) {
      _handleError(e, "Thêm IP thất bại");
    }
  }

  Future<void> updateWifi({
    required int branchId,
    required int id,
    required String ssid,
    required String bssid,
    String? description,
  }) async {
    final cleanSsid = ssid.trim();
    final formattedBssid = _normalizeBssid(bssid);

    try {
      await _repository.updateWifi(branchId, id, cleanSsid, formattedBssid, description);
      _showResultDialog("Thành công", "Đã cập nhật thông tin Wi-Fi");
      try {
        fetchBranchNetwork(branchId);
      } catch (_) {}
    } catch (e) {
      _handleError(e, "Cập nhật Wi-Fi thất bại");
    }
  }

  Future<void> deleteWifi({
    required int branchId,
    required int id,
  }) async {
    try {
      await _repository.deleteWifi(branchId, id);
      _showResultDialog("Thành công", "Đã xóa Wi-Fi");
      try {
        fetchBranchNetwork(branchId);
      } catch (_) {}
    } catch (e) {
      _handleError(e, "Xóa Wi-Fi thất bại");
    }
  }

  Future<void> deleteIp({
    required int branchId,
    required int id,
  }) async {
    try {
      await _repository.deleteIp(branchId, id);
      _showResultDialog("Thành công", "Đã xóa địa chỉ IP");
      try {
        fetchBranchNetwork(branchId);
      } catch (_) {}
    } catch (e) {
      _handleError(e, "Xóa IP thất bại");
    }
  }

  Future<void> toggleWifi({
    required int branchId,
    required int id,
  }) async {
    try {
      await _repository.toggleWifi(branchId, id);
      try {
        fetchBranchNetwork(branchId);
      } catch (_) {}
    } catch (e) {
      _handleError(e, "Thay đổi trạng thái Wi-Fi thất bại");
    }
  }

  /// Chuẩn hóa BSSID bằng WifiHelper
  String _normalizeBssid(String rawBssid) {
    return WifiHelper.normalizeBssid(rawBssid);
  }

  /// Bắt và trích xuất chính xác thông báo lỗi từ ValidationProblemDetails của ASP.NET Core
  void _handleError(dynamic e, String defaultTitle) {
    String msg = defaultTitle;

    if (e is DioException) {
      final responseData = e.response?.data;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('message') && responseData['message'] != null && responseData['message'].toString().isNotEmpty) {
          msg = responseData['message'].toString();
        } else if (responseData.containsKey('Message') && responseData['Message'] != null && responseData['Message'].toString().isNotEmpty) {
          msg = responseData['Message'].toString();
        } else if (responseData.containsKey('error') && responseData['error'] != null && responseData['error'].toString().isNotEmpty) {
          msg = responseData['error'].toString();
        } else if (responseData.containsKey('errors') && responseData['errors'] is Map) {
          final Map<String, dynamic> errors = responseData['errors'];
          List<String> errorMessages = [];

          errors.forEach((key, value) {
            if (value is List && value.isNotEmpty) {
              errorMessages.add(value.join(', '));
            }
          });

          if (errorMessages.isNotEmpty) {
            msg = errorMessages.join('\n');
          }
        } else if (responseData.containsKey('title')) {
          msg = responseData['title'].toString();
        }
      } else if (responseData is String && responseData.isNotEmpty) {
        msg = responseData;
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
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.green,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
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