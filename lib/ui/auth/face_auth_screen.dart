import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'face_ekyc_view.dart';

/// Màn hình xác thực khuôn mặt eKYC chuẩn Ngân hàng
/// Thời gian giữ cố định 2.0s, hỗ trợ chống rung lắc & giao diện hiển thị tiến trình quét mượt mà
class FaceAuthScreen extends StatefulWidget {
  const FaceAuthScreen({super.key});

  @override
  State<FaceAuthScreen> createState() => _FaceAuthScreenState();
}

class _FaceAuthScreenState extends State<FaceAuthScreen> {
  final RxString _prompt = "Đang kiểm tra quyền Camera...".obs;
  final Rx<Color> _borderColor = Colors.cyanAccent.obs;
  final RxDouble _holdProgress = 0.0.obs;
  final RxBool _isSuccess = false.obs;
  final RxBool _isProcessing = false.obs;
  final RxBool _hasPermission = false.obs;

  @override
  void initState() {
    super.initState();
    _requestPermission();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _hasPermission.value = true;
      _prompt.value = "Đưa khuôn mặt vào khung hình";
    } else {
      _prompt.value = "Bạn cần cấp quyền Camera để tiếp tục";
      Get.snackbar(
        "Quyền truy cập",
        "Vui lòng cấp quyền Camera trong cài đặt để thực hiện xác thực khuôn mặt",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    }
  }

  void _onTelemetry(Map data) {
    if (_isProcessing.value) return;
    _analyzeFace(data);
  }

  void _analyzeFace(Map data) {
    final int faceCount = (data['faceCount'] as num?)?.toInt() ?? 1;

    // 0. Kiểm tra số lượng khuôn mặt
    if (faceCount == 0) {
      _prompt.value = "Vui lòng đưa khuôn mặt vào khung hình";
      _borderColor.value = Colors.cyanAccent;
      _holdProgress.value = 0.0;
      _isSuccess.value = false;
      return;
    }

    if (faceCount > 1) {
      _prompt.value = "Phát hiện nhiều hơn 1 mặt! Vui lòng chỉ đứng 1 mình";
      _borderColor.value = Colors.redAccent;
      _holdProgress.value = 0.0;
      _isSuccess.value = false;
      return;
    }

    final pose = data['pose'] as Map?;
    final prob = data['prob'] as Map?;
    final rect = data['rect'] as Map?;
    final double progress = (data['progress'] as num?)?.toDouble() ?? 0.0;

    _holdProgress.value = progress;

    // 1. Không tìm thấy mặt
    if (pose == null || prob == null || rect == null) {
      _prompt.value = "Vui lòng đưa khuôn mặt vào khung hình";
      _borderColor.value = Colors.cyanAccent;
      _isSuccess.value = false;
      return;
    }

    final double l = (rect['l'] as num?)?.toDouble() ?? 0.0;
    final double t = (rect['t'] as num?)?.toDouble() ?? 0.0;
    final double r = (rect['r'] as num?)?.toDouble() ?? 0.0;
    final double b = (rect['b'] as num?)?.toDouble() ?? 0.0;

    final double faceWidth = (r - l).abs();
    final double faceHeight = (b - t).abs();
    final double faceCenterX = (l + r) / 2;
    final double faceCenterY = (t + b) / 2;

    final double poseX = (pose['x'] as num?)?.toDouble() ?? 0.0; // Ngẩng / Cúi
    final double poseY = (pose['y'] as num?)?.toDouble() ?? 0.0; // Quay Trái / Phải
    final double poseZ = (pose['z'] as num?)?.toDouble() ?? 0.0; // Nghiêng đầu

    final double lEye = (prob['lEye'] as num?)?.toDouble() ?? 1.0;
    final double rEye = (prob['rEye'] as num?)?.toDouble() ?? 1.0;

    // 2. Kiểm tra Vị trí Trung tâm (Khung hình rộng rãi thoải mái)
    if (faceCenterX < 0.20 || faceCenterX > 0.80 || faceCenterY < 0.15 || faceCenterY > 0.80) {
      _prompt.value = "Di chuyển khuôn mặt vào GIỮA khung hình";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    // 3. Kiểm tra Khoảng cách (Gần / Xa)
    if (faceWidth < 0.20 || faceHeight < 0.22) {
      _prompt.value = "Vui lòng di chuyển TIẾN LẠI GẦN hơn";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    if (faceWidth > 0.85 || faceHeight > 0.90) {
      _prompt.value = "Vui lòng LÙI RA XA một chút";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    // 4. Kiểm tra Góc quay / Ngẩng / Nghiêng đầu (Ngưỡng 15.0 độ linh hoạt)
    if (poseY.abs() > 15.0) {
      _prompt.value = poseY > 0
          ? "Vui lòng quay nhẹ mặt sang TRÁI"
          : "Vui lòng quay nhẹ mặt sang PHẢI";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    if (poseX.abs() > 15.0) {
      _prompt.value = poseX > 0
          ? "Vui lòng NGẨNG ĐẦU lên một chút"
          : "Vui lòng CÚI ĐẦU xuống một chút";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    if (poseZ.abs() > 15.0) {
      _prompt.value = "Giữ đầu THẲNG, không nghiêng";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    // 5. Kiểm tra Mở mắt nhẹ nhàng (>= 0.35)
    if (lEye < 0.35 || rEye < 0.35) {
      _prompt.value = "MỞ MẮT THẬT RÕ và nhìn thẳng ống kính";
      _borderColor.value = Colors.amberAccent;
      _isSuccess.value = false;
      return;
    }

    // --- MẶT ĐẠT CHUẨN: Giữ cố định 2s để hoàn thành ---
    final int percent = (progress * 100).toInt();
    if (percent > 0) {
      _prompt.value = "GIỮ CỐ ĐỊNH... ĐANG QUÉT ($percent%)";
    } else {
      _prompt.value = "GIỮ CỐ ĐỊNH KHUÔN MẶT...";
    }
    _borderColor.value = Colors.greenAccent;
    _isSuccess.value = true;
  }

  Future<void> _onCaptured(String base64Image) async {
    if (_isProcessing.value) return;
    _isProcessing.value = true;

    _prompt.value = "XÁC THỰC KHUÔN MẶT THÀNH CÔNG!";
    _borderColor.value = Colors.greenAccent;
    _isSuccess.value = true;

    // Hiển thị kết quả thành công trong 1.0s (1000ms)
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      Get.back(result: base64Image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!_hasPermission.value) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 64),
                const SizedBox(height: 24),
                Text(_prompt.value, style: const TextStyle(color: Colors.white, fontSize: 16)),
                if (_prompt.value.contains("cấp quyền"))
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: ElevatedButton(
                      onPressed: _requestPermission,
                      child: const Text("CẤP QUYỀN LẠI"),
                    ),
                  ),
              ],
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Native Camera Engine
            FaceEkycView(
              onTelemetry: _onTelemetry,
              onCaptured: _onCaptured,
            ),

            // 2. Lớp phủ Khung Bầu Dục Ngân Hàng có Thanh Tiến Trình
            Obx(() => RepaintBoundary(
              child: CustomPaint(
                painter: BankOvalOverlayPainter(
                  borderColor: _borderColor.value,
                  isSuccess: _isSuccess.value,
                  progress: _holdProgress.value,
                ),
              ),
            )),

            // 3. UI Hướng dẫn Cảnh báo bằng chữ
            SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'XÁC THỰC SINH TRẮC HỌC',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),

                  const Spacer(flex: 7),

                  // Hộp Cảnh Báo Chữ
                  Obx(() => AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    margin: const EdgeInsets.symmetric(horizontal: 32),
                    decoration: BoxDecoration(
                      color: _isSuccess.value
                          ? Colors.green.withValues(alpha: 0.85)
                          : Colors.black87,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: _borderColor.value,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _borderColor.value.withValues(alpha: 0.3),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ],
                    ),
                    child: Text(
                      _prompt.value,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )),

                  const Spacer(flex: 2),

                  // Nút Đóng
                  InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: Colors.white24,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 26),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),

            // 4. Visual Overlay khi hoàn tất xác thực thành công
            Obx(() => _isProcessing.value
                ? Container(
                    color: Colors.black.withValues(alpha: 0.35),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
                        margin: const EdgeInsets.symmetric(horizontal: 40),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: Colors.greenAccent, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.greenAccent.withValues(alpha: 0.4),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check, color: Colors.white, size: 36),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              "XÁC THỰC THÀNH CÔNG!",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Đang lưu dữ liệu sinh trắc học...",
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink()),
          ],
        );
      }),
    );
  }
}