class AttendanceRequest {
  final String? bssid;
  final String? deviceId;
  final String? faceImageBase64;

  AttendanceRequest({this.bssid, this.deviceId, this.faceImageBase64});

  Map<String, dynamic> toJson() => {
        "bssid": bssid,
        "deviceId": deviceId,
        "faceImageBase64": faceImageBase64,
      };
}

class RegisterFaceRequest {
  final int employeeId;
  final String? faceImageBase64;

  RegisterFaceRequest({required this.employeeId, this.faceImageBase64});

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "faceImageBase64": faceImageBase64,
      };
}

class RegisterWifiRequest {
  final int branchId;
  final String? ssid;
  final String? bssid;
  final bool isAutoCaptured;

  RegisterWifiRequest({
    required this.branchId,
    this.ssid,
    this.bssid,
    required this.isAutoCaptured,
  });

  Map<String, dynamic> toJson() => {
        "branchId": branchId,
        "ssid": ssid,
        "bssid": bssid,
        "isAutoCaptured": isAutoCaptured,
      };
}
