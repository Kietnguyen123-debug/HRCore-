import 'package:flutter/foundation.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/branch_models.dart';
import '../data/network/rest_clients/branch_rest_client.dart';
import '../utils/wifi_helper.dart';

class BranchRepository {
  final BranchRestClient _restClient;

  BranchRepository({BranchRestClient? restClient})
      : _restClient = restClient ?? BranchRestClient(DioClient().dio);

  /// Chuẩn hóa BSSID về định dạng chuẩn canonical trước khi lưu lên Database Server C#
  String _cleanBssid(String rawBssid) {
    return WifiHelper.formatBssidCanonical(rawBssid);
  }

  Future<List<BranchListItemResponse>> getAll() async {
    try {
      final response = await _restClient.getAll();
      return response.data ?? [];
    } catch (e) {
      debugPrint("❌ [BranchRepository] Lỗi getAll: $e");
      return [];
    }
  }

  Future<BranchResponse> getById(int id) {
    return _restClient.getById(id);
  }

  Future<BranchResponse> create(String name) {
    return _restClient.create(BranchRequest(name: name));
  }

  Future<BranchResponse> update(int id, String name) {
    return _restClient.update(id, BranchRequest(name: name));
  }

  Future<void> delete(int id) {
    return _restClient.delete(id);
  }

  Future<BranchStatusResponse> toggleStatus(int id) {
    return _restClient.toggleStatus(id);
  }

  // IP Management
  Future<List<BranchIpDto>> getIps(int branchId) async {
    try {
      return await _restClient.getIps(branchId);
    } catch (e) {
      debugPrint("❌ [BranchRepository] Lỗi getIps: $e");
      return [];
    }
  }

  Future<dynamic> addIp(int branchId, {String ip = "", String? description}) async {
    final cleanIp = ip.trim();
    final req = BranchIpRequest(publicIp: cleanIp, description: description);
    try {
      return await _restClient.addIp(branchId, req);
    } catch (e) {
      debugPrint("⚠️ Thử addIp qua Attendance/add-ip-manual: $e");
      final dio = DioClient().dio;
      final res = await dio.post('Attendance/add-ip-manual', data: {
        'branchId': branchId,
        'publicIp': cleanIp,
        'description': description ?? '',
      });
      return res.data;
    }
  }

  Future<void> deleteIp(int branchId, int id) {
    return _restClient.deleteIp(branchId, id);
  }

  // Wifi Management
  /// 🌟 ĐÃ SỬA: Xử lý bóc tách an toàn và Log kết quả trả về từ API
  Future<List<BranchWifiDto>> getWifis(int branchId) async {
    try {
      debugPrint("===> [BranchRepository] Đang gọi API getWifis cho branchId: $branchId");

      final resultList = await _restClient.getWifis(branchId);

      debugPrint("===> [BranchRepository] Nhận được ${resultList.length} Wi-Fi từ Server");
      for (var w in resultList) {
        debugPrint("   • SSID: ${w.ssid} | BSSID: ${w.bssid} | IsActive: ${w.isActive}");
      }

      return resultList;
    } catch (e, stackTrace) {
      debugPrint("❌ [BranchRepository] LỖI GỌI API getWifis($branchId): $e");
      debugPrint("Stack trace: $stackTrace");
      return [];
    }
  }

  Future<dynamic> addWifi(int branchId, String ssid, String bssid, String? description, {bool isAutoCaptured = false}) async {
    final cleanBssid = _cleanBssid(bssid);
    final req = BranchWifiRequest(ssid: ssid.trim(), bssid: cleanBssid, description: description);
    try {
      return await _restClient.addWifi(branchId, req);
    } catch (e) {
      debugPrint("⚠️ Thử addWifi qua Attendance/register-wifi: $e");
      final dio = DioClient().dio;
      final res = await dio.post('Attendance/register-wifi', data: {
        'branchId': branchId,
        'ssid': ssid.trim(),
        'bssid': cleanBssid,
        'isAutoCaptured': isAutoCaptured,
      });
      return res.data;
    }
  }

  Future<BranchWifiDto> updateWifi(int branchId, int id, String ssid, String bssid, String? description) {
    final cleanBssid = _cleanBssid(bssid);
    return _restClient.updateWifi(branchId, id, BranchWifiRequest(ssid: ssid.trim(), bssid: cleanBssid, description: description));
  }

  Future<void> deleteWifi(int branchId, int id) {
    return _restClient.deleteWifi(branchId, id);
  }

  Future<BranchWifiStatusResponse> toggleWifi(int branchId, int id) {
    return _restClient.toggleWifi(branchId, id);
  }
}