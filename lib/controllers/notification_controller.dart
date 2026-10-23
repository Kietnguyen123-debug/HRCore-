import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../repositories/notification_repository.dart';
import '../data/network/models/notification_models.dart';
import '../controllers/auth_controller.dart';
import '../ui/home/notification_list_screen.dart';

class NotificationController extends GetxController with WidgetsBindingObserver {
  static const _channel = MethodChannel('com.example.appdiemdanh/notification');
  final NotificationRepository _repository = NotificationRepository();

  var notifications = <NotificationLogDto>[].obs;
  var unreadCount = 0.obs;
  var isLoading = false.obs;

  final Set<int> _notifiedIds = {};
  Timer? _timer;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    requestNotificationPermission();
    registerDeviceToken();
    refreshAll();
    
    // Tự động kiểm tra thông báo định kỳ 30 giây
    _startTimer();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopTimer();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi mở lại app hoặc bật sáng màn hình, lập tức tải thông báo mới & bật lại timer 30s
      refreshAll();
      _startTimer();
    }
  }

  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => refreshAll());
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  /// Bắn thông báo trực tiếp lên thanh thông báo hệ thống Android (màn hình khóa / ngoài điện thoại)
  Future<void> showSystemNotification({
    required String title,
    required String body,
    int? id,
  }) async {
    try {
      await _channel.invokeMethod('showSystemNotification', {
        'title': title,
        'body': body,
        'id': id ?? DateTime.now().millisecondsSinceEpoch ~/ 1000,
      });
      debugPrint("===> ĐÃ BẮN THÔNG BÁO NÀY RA MÀN HÌNH NGOÀI ĐIỆN THOẠI: $title - $body <===");
    } catch (e) {
      debugPrint("Lỗi bắn thông báo hệ thống ra ngoài điện thoại: $e");
    }
  }

  /// Đăng ký Token thiết bị tài khoản với Server C# để nhận thông báo Push khi đóng app
  Future<void> registerDeviceToken() async {
    try {
      if (Get.isRegistered<AuthController>()) {
        final authController = Get.find<AuthController>();
        String deviceId = await authController.getDeviceId();
        if (deviceId.isNotEmpty) {
          String fcmToken = "token_$deviceId";
          await _repository.registerToken(fcmToken: fcmToken, deviceId: deviceId);
          debugPrint("===> ĐÃ ĐĂNG KÝ TOKEN THIẾT BỊ LÊN SERVER: $fcmToken <===");
        }
      }
    } catch (e) {
      debugPrint("Lỗi đăng ký Token thiết bị với Server: $e");
    }
  }

  /// Yêu cầu cấp quyền thông báo hệ thống (Android 13+ & iOS)
  Future<void> requestNotificationPermission() async {
    try {
      var status = await Permission.notification.status;
      if (status.isDenied) {
        status = await Permission.notification.request();
        debugPrint("===> KẾT QUẢ XIN QUYỀN THÔNG BÁO HỆ THỐNG: $status <===");
      }
    } catch (e) {
      debugPrint("Lỗi xin quyền thông báo hệ thống: $e");
    } finally {
      refreshAll();
    }
  }

  /// Làm mới toàn bộ dữ liệu thông báo theo tài khoản hiện tại
  Future<void> refreshAll() async {
    await Future.wait([
      fetchNotifications(),
      fetchUnreadCount(),
    ]);
  }

  Future<void> fetchNotifications() async {
    isLoading.value = true;
    try {
      final response = await _repository.getMyNotifications();
      notifications.assignAll(response.list);

      // Phát thông báo ra thanh trạng thái ngoài điện thoại cho các thông báo chưa đọc mới
      for (final n in response.list) {
        if (!n.isRead && !_notifiedIds.contains(n.id)) {
          _notifiedIds.add(n.id);
          showSystemNotification(
            title: n.title ?? "Thông báo mới",
            body: n.body ?? "",
            id: n.id,
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      if (count > unreadCount.value && unreadCount.value > 0) {
        Get.snackbar(
          "Thông báo mới",
          "Bạn có $count thông báo chưa đọc. Chạm để xem chi tiết.",
          backgroundColor: const Color(0xFF2563EB),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
          onTap: (_) => Get.to(() => const NotificationListScreen()),
        );

        // Bắn thông báo tổng hợp ra ngoài hệ thống
        showSystemNotification(
          title: "Thông báo mới",
          body: "Bạn có $count thông báo mới chưa đọc",
          id: 99999,
        );
      }
      unreadCount.value = count;
    } catch (_) {}
  }

  Future<void> markAsRead(int id) async {
    try {
      await _repository.markAsRead(id);
      final index = notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        final updated = notifications[index].copyWith(isRead: true);
        notifications[index] = updated;
      }
      fetchUnreadCount();
    } catch (_) {}
  }

  Future<void> markAllAsRead() async {
    try {
      await _repository.readAll();
      fetchNotifications();
      fetchUnreadCount();
    } catch (_) {}
  }

  void clearData() {
    notifications.clear();
    unreadCount.value = 0;
    _notifiedIds.clear();
  }
}

extension NotificationLogDtoExt on NotificationLogDto {
  NotificationLogDto copyWith({bool? isRead}) {
    return NotificationLogDto(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }
}
