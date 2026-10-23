import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

class FaceEkycView extends StatefulWidget {
  final Function(String base64Image) onCaptured;
  final Function(Map telemetry) onTelemetry;

  const FaceEkycView({
    super.key,
    required this.onCaptured,
    required this.onTelemetry,
  });

  @override
  State<FaceEkycView> createState() => _FaceEkycViewState();
}

class _FaceEkycViewState extends State<FaceEkycView> {
  static const String viewType = 'com.example.app/native_face_view';
  MethodChannel? _methodChannel;
  EventChannel? _eventChannel;
  StreamSubscription? _telemetrySubscription;

  // Throttle để đồng bộ FPS giữa Native và Flutter (~28 FPS)
  int _lastStreamTime = 0;

  @override
  void dispose() {
    _telemetrySubscription?.cancel();
    _methodChannel?.setMethodCallHandler(null);
    super.dispose();
  }

  void _onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('com.example.app/face_engine_$id');
    _eventChannel = EventChannel('com.example.app/face_telemetry_$id');

    _methodChannel?.setMethodCallHandler((call) async {
      if (call.method == 'onCaptured' && call.arguments is String) {
        widget.onCaptured(call.arguments as String);
      }
    });

    _telemetrySubscription?.cancel();
    _telemetrySubscription = _eventChannel?.receiveBroadcastStream().listen(
          (data) {
        if (data != null && data is Map && mounted) {
          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - _lastStreamTime > 35) {
            _lastStreamTime = now;
            widget.onTelemetry(data);
          }
        }
      },
      onError: (error) {
        debugPrint("Lỗi Stream phân tích khuôn mặt: $error");
      },
      cancelOnError: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.android) {
      return const Center(child: Text("Nền tảng không hỗ trợ"));
    }

    return PlatformViewLink(
      viewType: viewType,
      surfaceFactory: (context, controller) {
        return AndroidViewSurface(
          controller: controller as AndroidViewController,
          gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
          hitTestBehavior: PlatformViewHitTestBehavior.opaque,
        );
      },
      onCreatePlatformView: (params) {
        final initView = PlatformViewsService.initExpensiveAndroidView(
          id: params.id,
          viewType: viewType,
          layoutDirection: TextDirection.ltr,
          creationParams: const <String, dynamic>{},
          creationParamsCodec: const StandardMessageCodec(),
        );

        return initView
          ..addOnPlatformViewCreatedListener(params.onPlatformViewCreated)
          ..addOnPlatformViewCreatedListener(_onPlatformViewCreated)
          ..create();
      },
    );
  }
}

/// Painter vẽ khung bầu dục khoét lỗ tối xung quanh chuẩn Ngân hàng có thanh tiến trình
class BankOvalOverlayPainter extends CustomPainter {
  final Color borderColor;
  final bool isSuccess;
  final double progress; // 0.0 -> 1.0

  BankOvalOverlayPainter({
    required this.borderColor,
    this.isSuccess = false,
    this.progress = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Kích thước Khung Bầu Dục (Chiều rộng 72% màn hình, tỷ lệ 1:1.38)
    final double ovalWidth = size.width * 0.72;
    final double ovalHeight = ovalWidth * 1.38;
    final Offset center = Offset(size.width / 2, size.height * 0.40);

    final Rect ovalRect = Rect.fromCenter(
      center: center,
      width: ovalWidth,
      height: ovalHeight,
    );

    // 1. Tạo lớp phủ mờ tối xung quanh (Background Masking)
    final Path backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final Path ovalPath = Path()..addOval(ovalRect);

    final Path maskPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      ovalPath,
    );

    final Paint maskPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;

    canvas.drawPath(maskPath, maskPaint);

    // 2. Viền khung bầu dục
    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSuccess ? 4.5 : 3.0;

    canvas.drawOval(ovalRect, borderPaint);

    // 3. Thanh tiến trình quét khuôn mặt quanh khung bầu dục (Progress Arc)
    if (progress > 0) {
      final Paint progressPaint = Paint()
        ..color = Colors.greenAccent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..strokeCap = StrokeCap.round;

      final double sweepAngle = 2 * 3.141592653589793 * progress.clamp(0.0, 1.0);
      canvas.drawArc(ovalRect, -3.141592653589793 / 2, sweepAngle, false, progressPaint);
    }

    // 4. Vạch định vị góc chuẩn AI (Trên / Dưới)
    final Paint accentPaint = Paint()
      ..color = isSuccess ? Colors.greenAccent : Colors.white70
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawLine(
      Offset(center.dx - 15, center.dy - ovalHeight / 2),
      Offset(center.dx + 15, center.dy - ovalHeight / 2),
      accentPaint,
    );
    canvas.drawLine(
      Offset(center.dx - 15, center.dy + ovalHeight / 2),
      Offset(center.dx + 15, center.dy + ovalHeight / 2),
      accentPaint,
    );
  }

  @override
  bool shouldRepaint(covariant BankOvalOverlayPainter oldDelegate) {
    return oldDelegate.borderColor != borderColor ||
        oldDelegate.isSuccess != isSuccess ||
        oldDelegate.progress != progress;
  }
}