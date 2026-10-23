import 'package:json_annotation/json_annotation.dart';

/// Request DTO cho API Check-In / Check-Out
/// POST /api/Attendance/check-in & POST /api/Attendance/check-out
@JsonSerializable(createToJson: true, createFactory: true)
class AttendanceRequest {
  /// BSSID địa chỉ MAC của Wi-Fi đang kết nối (bắt buộc)
  final String bssid;

  /// ID duy nhất của thiết bị mobile (bắt buộc)
  final String deviceId;

  /// Ảnh khuôn mặt dạng Base64 (bắt buộc)
  final String faceImageBase64;

  /// IP Public hiện tại do App tự đọc (tùy chọn / nullable)
  final String? clientPublicIp;

  const AttendanceRequest({
    required this.bssid,
    required this.deviceId,
    required this.faceImageBase64,
    this.clientPublicIp,
  });

  factory AttendanceRequest.fromJson(Map<String, dynamic> json) {
    return AttendanceRequest(
      bssid: json['bssid'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      faceImageBase64: json['faceImageBase64'] as String? ?? '',
      clientPublicIp: json['clientPublicIp'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'bssid': bssid,
        'deviceId': deviceId,
        'faceImageBase64': faceImageBase64,
        if (clientPublicIp != null) 'clientPublicIp': clientPublicIp,
      };
}

/// Response DTO xử lý kết quả Điểm danh từ Server
@JsonSerializable(createToJson: false, createFactory: true)
class AttendanceActionResponse {
  final bool success;
  final String? message;
  final DateTime? timestamp;
  final String? action;
  final double? faceConfidence;

  const AttendanceActionResponse({
    this.success = false,
    this.message,
    this.timestamp,
    this.action,
    this.faceConfidence,
  });

  factory AttendanceActionResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceActionResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String?,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString())
          : null,
      action: json['action'] as String?,
      faceConfidence: (json['faceConfidence'] as num?)?.toDouble(),
    );
  }
}

/// Request DTO gửi Đăng ký Wi-Fi cho Chi nhánh
/// POST /api/Attendance/register-wifi
@JsonSerializable(createToJson: true, createFactory: true)
class RegisterWifiRequest {
  /// ID Chi nhánh (int, bắt buộc)
  final int branchId;

  /// SSID tên Wi-Fi (max 32 ký tự, tùy chọn)
  final String? ssid;

  /// BSSID địa chỉ MAC của Wi-Fi (bắt buộc)
  final String bssid;

  /// true nếu app tự động đọc từ thiết bị
  final bool isAutoCaptured;

  const RegisterWifiRequest({
    required this.branchId,
    this.ssid,
    required this.bssid,
    this.isAutoCaptured = true,
  });

  factory RegisterWifiRequest.fromJson(Map<String, dynamic> json) {
    return RegisterWifiRequest(
      branchId: json['branchId'] as int? ?? 0,
      ssid: json['ssid'] as String?,
      bssid: json['bssid'] as String? ?? '',
      isAutoCaptured: json['isAutoCaptured'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    String? cleanSsid = ssid?.trim();
    if (cleanSsid != null && cleanSsid.length > 32) {
      cleanSsid = cleanSsid.substring(0, 32);
    }
    return {
      'branchId': branchId,
      'ssid': ?cleanSsid,
      'bssid': bssid,
      'isAutoCaptured': isAutoCaptured,
    };
  }
}

/// DTO thông tin Wi-Fi Chi nhánh
/// GET /api/Branch/{branchId}/wifis
@JsonSerializable(createToJson: false, createFactory: true)
class BranchWifiDto {
  final int id;
  final int branchId;
  final String? ssid;
  final String? bssid;
  final String? description;
  final bool isActive;

  const BranchWifiDto({
    required this.id,
    required this.branchId,
    this.ssid,
    this.bssid,
    this.description,
    this.isActive = true,
  });

  factory BranchWifiDto.fromJson(Map<String, dynamic> json) {
    return BranchWifiDto(
      id: json['id'] as int? ?? 0,
      branchId: json['branchId'] as int? ?? 0,
      ssid: json['ssid'] as String?,
      bssid: json['bssid'] as String?,
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}
