import 'dart:async';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/wifi_helper.dart';

/// Class chứa thông tin Wi-Fi và thiết bị thu thập được từ máy Mobile
class WifiInfoResult {
  final String ssid;
  final String bssid;
  final String deviceId;
  final String? clientPublicIp;

  WifiInfoResult({
    required this.ssid,
    required this.bssid,
    required this.deviceId,
    this.clientPublicIp,
  });

  @override
  String toString() {
    return 'WifiInfoResult(ssid: $ssid, bssid: $bssid, deviceId: $deviceId, clientPublicIp: $clientPublicIp)';
  }
}

/// Service xử lý việc xin quyền Location, kiểm tra GPS, đọc Wi-Fi SSID/BSSID,
/// Device ID và Public IP.
class WifiService {
  final NetworkInfo _networkInfo = NetworkInfo();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 4),
    receiveTimeout: const Duration(seconds: 4),
  ));

  /// Xin cấp quyền Location (`Permission.locationWhenInUse` / `Permission.location`)
  /// Android/iOS bắt buộc phải có quyền Vị trí mới cho phép ứng dụng đọc BSSID và SSID thực tế.
  Future<bool> requestLocationPermission() async {
    var status = await Permission.locationWhenInUse.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      status = await Permission.locationWhenInUse.request();
      if (status.isGranted) return true;
    }

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return status.isGranted;
  }

  /// Kiểm tra trạng thái GPS/Location Service đã được bật trên thiết bị hay chưa
  Future<bool> isGpsEnabled() async {
    return await Permission.location.serviceStatus.isEnabled;
  }

  /// Chuẩn hóa BSSID về định dạng chuẩn canonical (ví dụ: "5C:18:DD:13:8B:0A")
  String normalizeBssid(String? rawBssid) {
    return WifiHelper.formatBssidCanonical(rawBssid);
  }

  /// Kiểm tra BSSID có hợp lệ hay không (loại bỏ giá trị null, rác hoặc dummy MAC "02:00:00:00:00:00")
  bool isValidBssid(String? rawBssid) {
    return !WifiHelper.isInvalidOrDummyBssid(rawBssid);
  }

  /// Lấy ID duy nhất của thiết bị bằng device_info_plus
  Future<String> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id.isNotEmpty ? androidInfo.id : 'unknown_android_device';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'unknown_ios_device';
      }
    } catch (_) {}
    return 'unknown_device';
  }

  /// Tự đọc Public IP hiện tại của thiết bị (Nullable, timeout 4 giây)
  Future<String?> getPublicIp() async {
    try {
      final response = await _dio.get('https://api.ipify.org?format=json');
      if (response.statusCode == 200 && response.data != null) {
        if (response.data is Map) {
          return response.data['ip']?.toString().trim();
        } else if (response.data is String) {
          return response.data.toString().trim();
        }
      }
    } catch (_) {}
    return null;
  }

  /// Đọc thông tin Wi-Fi và thiết bị thực tế đầy đủ kèm xử lý lỗi Edge Cases
  Future<WifiInfoResult> getConnectedWifiInfo() async {
    // 1. Xin quyền Location
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('Ứng dụng cần quyền Vị trí (Location) để đọc Wi-Fi. Vui lòng cấp quyền trong Cài đặt.');
    }

    // 2. Kiểm tra GPS/Location Service
    final gpsOn = await isGpsEnabled();
    if (!gpsOn) {
      throw Exception('Dịch vụ vị trí (GPS) đang tắt. Vui lòng bật GPS trên thiết bị trước khi thực hiện.');
    }

    // 3. Đọc SSID và BSSID từ thiết bị
    String? rawSsid = await _networkInfo.getWifiName();
    String? rawBssid = await _networkInfo.getWifiBSSID();

    // Làm sạch SSID (xóa dấu ngoặc kép do hệ điều hành tự chèn)
    String cleanSsid = WifiHelper.cleanSsid(rawSsid);

    // Chuẩn hóa BSSID
    String formattedBssid = normalizeBssid(rawBssid);

    // 4. Bắt lỗi không kết nối Wi-Fi hoặc BSSID dummy
    if (!isValidBssid(rawBssid) || formattedBssid.isEmpty) {
      throw Exception('Vui lòng bật Wi-Fi và kết nối với mạng công ty.');
    }

    // 5. Lấy Device ID và Public IP
    final deviceId = await getDeviceId();
    final publicIp = await getPublicIp();

    return WifiInfoResult(
      ssid: cleanSsid,
      bssid: formattedBssid,
      deviceId: deviceId,
      clientPublicIp: publicIp,
    );
  }
}
