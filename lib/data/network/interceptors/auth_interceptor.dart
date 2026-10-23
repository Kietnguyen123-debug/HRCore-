import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart' hide Response;
import '../../../ui/auth/login_screen.dart';

/// A production-grade [QueuedInterceptor] that sequentially handles Bearer token
/// injection and performs structured logouts/redirects upon 401 Unauthorized signals.
class AuthInterceptor extends QueuedInterceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty) {
      // 1. Kiểm tra thời hạn 5 ngày duy trì đăng nhập (Inactivity timeout)
      final int nowMs = DateTime.now().millisecondsSinceEpoch;
      final int? lastActiveMs = prefs.getInt('session_last_active_time');
      const int fiveDaysMs = 5 * 24 * 60 * 60 * 1000; // 5 ngày tính bằng milliseconds

      if (lastActiveMs != null) {
        final int inactiveDuration = nowMs - lastActiveMs;
        if (inactiveDuration > fiveDaysMs) {
          // Đã quá 5 ngày không có hoạt động sử dụng app -> Hủy phiên đăng nhập
          await prefs.remove('token');
          await prefs.remove('role');
          await prefs.remove('userName');
          await prefs.remove('employeeCode');
          await prefs.remove('branchId');
          await prefs.remove('userId');
          await prefs.remove('session_last_active_time');
          await prefs.remove('remember_me');

          Get.offAll(() => LoginScreen());

          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'Phiên đăng nhập đã hết hạn sau 5 ngày không hoạt động.',
              type: DioExceptionType.cancel,
            ),
          );
        }
      }

      // 2. Người dùng đang sử dụng app -> Reset thời gian về 0 (cập nhật timestamp hoạt động mới nhất)
      await prefs.setInt('session_last_active_time', nowMs);

      options.headers['Authorization'] = 'Bearer $token';
    }

    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Intercept 401 Unauthorized responses to clear stale sessions gracefully
    if (err.response?.statusCode == 401 &&
        !err.requestOptions.path.contains('Auth/login')) {
      
      final prefs = await SharedPreferences.getInstance();
      // Chỉ xóa các key liên quan đến session, giữ lại persistent_device_id
      await prefs.remove('token');
      await prefs.remove('role');
      await prefs.remove('userName');
      await prefs.remove('employeeCode');
      await prefs.remove('branchId');
      await prefs.remove('userId');
      await prefs.remove('session_last_active_time');
      await prefs.remove('remember_me');

      // Maintain consistency with the legacy ApiClient routing pattern
      Get.offAll(() => LoginScreen());
    }
    
    return handler.next(err);
  }
}
