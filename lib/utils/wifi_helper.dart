import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WifiHelper {
  /// Làm sạch SSID (xóa hoàn toàn dấu ngoặc kép " hoặc ' do Android/iOS tự chèn)
  static String cleanSsid(String? rawSsid) {
    if (rawSsid == null) return '';
    return rawSsid.replaceAll('"', '').replaceAll("'", '').replaceAll('`', '').trim();
  }
  static String cleanBssid(String? bssid) {
    if (bssid == null || bssid.isEmpty) return '';
    return bssid
        .replaceAll('"', '')
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll(' ', '')
        .trim()
        .toLowerCase();
  }

  /// Chuẩn hóa BSSID về định dạng chuẩn duy nhất: 5C:18:DD:13:8B:0A (không chứa dấu ngoặc kép)
  static String formatBssidCanonical(String? rawBssid) {
    if (rawBssid == null || rawBssid.trim().isEmpty) return '';

    // 1. Loại bỏ tất cả ngoặc kép ", ngoặc đơn ', backtick, khoảng trắng, gạch ngang, chấm.
    // Chuyển thành chữ HOA và thay chữ O gõ nhầm thành số 0
    String clean = rawBssid
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('`', '')
        .replaceAll(' ', '')
        .replaceAll('-', ':')
        .replaceAll('.', '')
        .trim()
        .toUpperCase()
        .replaceAll('O', '0');

    // 2. Tách thành các octet theo dấu ':'
    List<String> parts = clean.split(':').where((p) => p.isNotEmpty).toList();

    // Trường hợp chuỗi liền không có dấu ':' (ví dụ "5C18DD138B0A")
    if (parts.length == 1 && clean.length == 12) {
      List<String> formattedParts = [];
      for (int i = 0; i < 12; i += 2) {
        formattedParts.add(clean.substring(i, i + 2));
      }
      return formattedParts.join(':');
    }

    // 3. Đảm bảo mỗi octet đủ 2 ký tự Hex (Zero Padding)
    if (parts.length == 6) {
      for (int i = 0; i < parts.length; i++) {
        if (parts[i].length == 1) {
          parts[i] = '0${parts[i]}';
        }
      }
      return parts.join(':');
    }

    // Đảm bảo kết quả trả về không bao giờ có ngoặc kép
    return clean.replaceAll('"', '').replaceAll("'", '');
  }

  /// Chuẩn hóa BSSID bằng cách ủy quyền cho formatBssidCanonical
  static String normalizeBssid(String? rawBssid) {
    return formatBssidCanonical(rawBssid);
  }

  /// Chuyển BSSID về dạng chuẩn có dấu : và viết HOA (VD: 5C:18:DD:13:8B:0A)
  static String formatWithColons(String? rawBssid) {
    return formatBssidCanonical(rawBssid);
  }

  /// Kiểm tra BSSID có phải là BSSID rác/dummy do thiếu GPS hay không
  static bool isInvalidOrDummyBssid(String? rawBssid) {
    if (rawBssid == null || rawBssid.trim().isEmpty) return true;
    final clean = rawBssid
        .replaceAll(':', '')
        .replaceAll('-', '')
        .replaceAll('.', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .trim()
        .toLowerCase();

    return clean.isEmpty ||
        clean == '020000000000' ||
        clean == '000000000000' ||
        clean.contains('unknown') ||
        clean.contains('error');
  }

  /// Hiển thị hộp thoại (Dialog) thông báo đơn giản, chỉ hiển thị thông báo chữ cho người dùng
  static Future<void> showWifiVerificationErrorDialog({
    BuildContext? context,
    String title = "Xác Thực Không Thành Công",
    required String errorMessage,
    String? ssid,
    String? bssid,
    String? clientPublicIp,
    String? deviceId,
    List<dynamic>? allowedBranchWifis,
  }) async {
    final dialogWidget = Builder(
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: Colors.red.shade700,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: () {
                  if (context != null && context.mounted) {
                    Navigator.of(context).pop();
                  } else {
                    Get.back();
                  }
                },
                child: const Text("Đã Hiểu", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ),
          ],
        );
      },
    );

    final ctx = context ?? Get.context;
    if (ctx != null && ctx.mounted) {
      await showDialog(
        context: ctx,
        builder: (_) => dialogWidget,
      );
    } else {
      await Get.dialog(dialogWidget);
    }
  }
}
