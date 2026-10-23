import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';

import '../repositories/auth_repository.dart';
import '../data/network/models/auth_models.dart';
import '../ui/auth/login_screen.dart';
import '../ui/home/employee_dashboard.dart';
import '../ui/home/admin_dashboard.dart';

import '../controllers/notification_controller.dart';
import '../core/theme_service.dart';

class AuthController extends GetxController with WidgetsBindingObserver {
  final AuthRepository _repository = AuthRepository();
  final RxBool isLoading = false.obs;
  final RxBool rememberMe = false.obs;
  final Rxn<EmployeeMeResponse> currentUser = Rxn<EmployeeMeResponse>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _loadRememberMe();
    refreshProfile();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  bool isManagementRole(String? roleStr) {
    if (roleStr == null || roleStr.trim().isEmpty) return false;
    final r = roleStr.toLowerCase().trim();
    return r.contains('admin') ||
           r.contains('hr') ||
           r.contains('manager') ||
           r.contains('quanly') ||
           r.contains('quản lý') ||
           r.contains('truongphong') ||
           r.contains('trưởng phòng');
  }

  Future<void> _loadRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    rememberMe.value = prefs.getBool('remember_me') ?? false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.detached) {
      final prefs = await SharedPreferences.getInstance();
      final isRemember = prefs.getBool('remember_me') ?? false;
      if (!isRemember) {
        await _clearAuthSession(prefs);
      }
    }
  }

  Future<void> checkInitialAuth() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final isRememberMe = prefs.getBool('remember_me') ?? false;

    if (token == null || token.isEmpty) {
      Get.offAll(() => LoginScreen());
      return;
    }

    if (!isRememberMe) {
      await _clearAuthSession(prefs);
      Get.offAll(() => LoginScreen());
      return;
    }

    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    final int? lastActiveMs = prefs.getInt('session_last_active_time');
    const int fiveDaysMs = 5 * 24 * 60 * 60 * 1000;

    if (lastActiveMs != null && (nowMs - lastActiveMs) > fiveDaysMs) {
      await _clearAuthSession(prefs);
      Get.offAll(() => LoginScreen());
      return;
    }

    await prefs.setInt('session_last_active_time', nowMs);

    try {
      final freshProfile = await refreshProfile();
      if (freshProfile != null) {
        await ThemeService().updateThemeOnLogin();
        String roleLower = (freshProfile.role ?? prefs.getString('role') ?? '').toLowerCase().trim();
        if (isManagementRole(roleLower)) {
          Get.offAll(() => const AdminDashboard());
        } else {
          Get.offAll(() => const EmployeeDashboard());
        }
        return;
      }
    } catch (e) {
      debugPrint("Lỗi xác thực profile tự động khi khởi chạy: $e");
    }

    await _clearAuthSession(prefs);
    Get.offAll(() => LoginScreen());
  }

  Future<EmployeeMeResponse?> refreshProfile() async {
    try {
      final freshProfile = await _repository.getMe();
      currentUser.value = freshProfile;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('role', freshProfile.role ?? 'Employee');
      await prefs.setString('userName', freshProfile.fullName ?? 'Thành viên');
      await prefs.setString('employeeCode', freshProfile.employeeCode ?? '');
      await prefs.setInt('branchId', freshProfile.branchId);
      await prefs.setInt('userId', freshProfile.id);
      return freshProfile;
    } catch (e) {
      debugPrint("Lỗi refresh profile: $e");
      return currentUser.value;
    }
  }

  Future<bool> verifyCurrentPassword(String currentPassword) async {
    final cleanPass = currentPassword.trim();
    if (cleanPass.isEmpty) {
      _showErrorSnackBar("Thông báo", "Vui lòng nhập Mật khẩu hiện tại");
      return false;
    }

    isLoading.value = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      String code = currentUser.value?.employeeCode ?? prefs.getString('employeeCode') ?? '';
      if (code.isEmpty) {
        final me = await refreshProfile();
        code = me?.employeeCode ?? '';
      }

      if (code.isEmpty) {
        _showErrorSnackBar("Lỗi hệ thống", "Không tìm thấy thông tin tài khoản.");
        return false;
      }

      String deviceId = await getDeviceId();
      final response = await _repository.login(
        employeeCode: code,
        password: cleanPass,
        deviceId: deviceId,
      );

      if (response.success && response.token != null) {
        await prefs.setString('token', response.token!);
        return true;
      } else {
        _showErrorSnackBar("Mật khẩu không đúng", response.message ?? "Mật khẩu hiện tại không chính xác");
        return false;
      }
    } catch (e) {
      String serverError = "Mật khẩu hiện tại không chính xác. Vui lòng kiểm tra lại.";
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          serverError = data['message'] ?? data['Message'] ?? serverError;
        }
      }
      _showErrorSnackBar("Xác minh thất bại", serverError);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  static const String _keyPersistentDeviceId = 'app_persistent_device_id';

  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();

    try {
      final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        if (androidInfo.id.isNotEmpty) {
          debugPrint("===> DEVICE ID (ANDROID HARDWARE): android_${androidInfo.id} <===");
          return "android_${androidInfo.id}";
        }
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        if (iosInfo.identifierForVendor != null && iosInfo.identifierForVendor!.isNotEmpty) {
          debugPrint("===> DEVICE ID (IOS HARDWARE): ios_${iosInfo.identifierForVendor} <===");
          return "ios_${iosInfo.identifierForVendor}";
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy DeviceInfo phần cứng: $e");
    }

    String? persistentId = prefs.getString(_keyPersistentDeviceId);
    if (persistentId != null && persistentId.isNotEmpty && !persistentId.contains("unknown")) {
      return persistentId;
    }

    final int now = DateTime.now().millisecondsSinceEpoch;
    final String uniqueSuffix = (1000 + (DateTime.now().microsecond % 9000)).toString();
    String newId = "device_${now}_$uniqueSuffix";

    await prefs.setString(_keyPersistentDeviceId, newId);
    debugPrint("===> ĐÃ KHỞI TẠO ID DỰ PHÒNG MỚI: $newId <===");

    return newId;
  }

  Future<void> resetLocalDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyPersistentDeviceId);
  }

  Future<void> _clearAuthSession(SharedPreferences prefs) async {
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('userName');
    await prefs.remove('employeeCode');
    await prefs.remove('branchId');
    await prefs.remove('userId');
    await prefs.remove('session_last_active_time');
    await prefs.remove('remember_me');
  }

  Future<void> login(String employeeCode, String password) async {
    final cleanCode = employeeCode.trim();
    if (cleanCode.isEmpty || password.trim().isEmpty) {
      _showErrorSnackBar("Thông báo", "Vui lòng nhập đầy đủ Mã nhân viên và Mật khẩu");
      return;
    }

    isLoading.value = true;
    try {
      String deviceId = await getDeviceId();
      debugPrint("Đang đăng nhập với DeviceID: $deviceId");

      final response = await _repository.login(
        employeeCode: cleanCode,
        password: password,
        deviceId: deviceId,
      );

      if (response.success && response.token != null) {
        final prefs = await SharedPreferences.getInstance();

        await _clearAuthSession(prefs);
        await prefs.setString('token', response.token!);
        await prefs.setBool('remember_me', rememberMe.value);
        await prefs.setInt('session_last_active_time', DateTime.now().millisecondsSinceEpoch);

        try {
          final freshProfile = await getMe();

          await prefs.setString('role', freshProfile.role ?? 'Employee');
          await prefs.setString('userName', freshProfile.fullName ?? 'Thành viên');
          await prefs.setString('employeeCode', freshProfile.employeeCode ?? cleanCode);
          await prefs.setInt('branchId', freshProfile.branchId);
          await prefs.setInt('userId', freshProfile.id);

          await ThemeService().updateThemeOnLogin();

          Get.snackbar(
            "Thành công",
            "Đăng nhập thành công! Chào ${freshProfile.fullName}",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );

          String roleLower = (freshProfile.role ?? '').toLowerCase().trim();
          if (isManagementRole(roleLower)) {
            Get.offAll(() => const AdminDashboard());
          } else {
            Get.offAll(() => const EmployeeDashboard());
          }
        } catch (e) {
          debugPrint("Lỗi nạp hồ sơ sau đăng nhập: $e");
          _showErrorSnackBar("Lỗi đồng bộ", "Đăng nhập thành công nhưng không thể nạp hồ sơ. Vui lòng thử lại.");
        }
      } else {
        _showErrorSnackBar("Lỗi đăng nhập", response.message ?? "Mã nhân viên hoặc mật khẩu không chính xác");
      }
    } catch (e) {
      _handleError(e, "Lỗi kết nối máy chủ");
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyActivationCredentials(String code, String tempPass) async {
    isLoading.value = true;
    try {
      String deviceId = await getDeviceId();

      final response = await _repository.login(
        employeeCode: code.trim(),
        password: tempPass,
        deviceId: deviceId,
      );

      if (response.isActivated == false || (response.message ?? '').toLowerCase().contains("chưa được kích hoạt")) {
        debugPrint("===> Mật khẩu tạm ĐÚNG & Chưa kích hoạt -> Cho phép đi tiếp bước eKYC!");
        return true;
      }

      if (response.isActivated == true || response.success || (response.message ?? '').toLowerCase().contains("đã được kích hoạt")) {
        _showErrorSnackBar(
            "Tài khoản đã được kích hoạt",
            "Tài khoản của bạn đã được kích hoạt thành công trước đó. Vui lòng quay lại màn hình Đăng nhập."
        );
        return false;
      }

      _showErrorSnackBar("Lỗi xác thực", response.message ?? "Mã nhân viên hoặc mật khẩu tạm thời không chính xác.");
      return false;
    } catch (e) {
      if (e is DioException && e.response != null) {
        final data = e.response?.data;

        if (data is Map) {
          bool? isActivated = data['isActivated'] ?? data['IsActivated'];
          String message = data['message'] ?? data['Message'] ?? '';

          if (isActivated == false || message.toLowerCase().contains("chưa được kích hoạt")) {
            debugPrint("===> Mật khẩu tạm ĐÚNG & Chưa kích hoạt (qua Exception) -> Cho phép đi tiếp bước eKYC!");
            return true;
          }

          if (isActivated == true || message.toLowerCase().contains("đã được kích hoạt")) {
            _showErrorSnackBar(
                "Tài khoản đã được kích hoạt",
                "Tài khoản này đã được kích hoạt từ trước. Vui lòng quay lại màn hình Đăng nhập."
            );
            return false;
          }

          _showErrorSnackBar("Lỗi xác thực", message.isNotEmpty ? message : "Mã nhân viên hoặc mật khẩu tạm thời không chính xác.");
          return false;
        }
      }

      _handleError(e, "Mã nhân viên hoặc mật khẩu tạm thời không chính xác.");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activate(
      String employeeCode,
      String temporaryPassword,
      String newPassword,
      String faceImageBase64,
      ) async {
    final cleanCode = employeeCode.trim();
    isLoading.value = true;

    try {
      String deviceId = await getDeviceId();

      final response = await _repository.activateFirstTime(
        FirstTimeActivationRequest(
          employeeCode: cleanCode,
          temporaryPassword: temporaryPassword,
          newPassword: newPassword,
          deviceId: deviceId,
          faceImageBase64: faceImageBase64,
        ),
      );

      if (response.success && response.token != null) {
        final prefs = await SharedPreferences.getInstance();

        await _clearAuthSession(prefs);
        await prefs.setString('token', response.token!);
        await prefs.setInt('session_last_active_time', DateTime.now().millisecondsSinceEpoch);

        try {
          final freshProfile = await getMe();

          await prefs.setString('role', freshProfile.role ?? 'Employee');
          await prefs.setString('userName', freshProfile.fullName ?? 'Thành viên');
          await prefs.setString('employeeCode', freshProfile.employeeCode ?? cleanCode);
          await prefs.setInt('branchId', freshProfile.branchId);
          await prefs.setInt('userId', freshProfile.id);

          await ThemeService().updateThemeOnLogin();

          Get.snackbar(
            "Thành công",
            "Kích hoạt tài khoản thành công!",
            backgroundColor: Colors.green,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          Get.offAll(() => const EmployeeDashboard());
        } catch (e) {
          debugPrint("Lỗi nạp hồ sơ sau kích hoạt: $e");
          _showErrorSnackBar("Lỗi đồng bộ", "Kích hoạt thành công nhưng không thể nạp hồ sơ. Vui lòng đăng nhập lại.");
        }
      } else {
        String msg = response.message ?? "Kích hoạt thất bại";
        if (msg.toLowerCase().contains("đã được kích hoạt")) {
          _showErrorSnackBar("Tài khoản đã được kích hoạt", "Tài khoản này đã được kích hoạt trước đó. Vui lòng quay lại màn hình Đăng nhập.");
        } else {
          _showErrorSnackBar("Lỗi kích hoạt", msg);
        }
      }
    } catch (e) {
      String msg = "Kích hoạt tài khoản thất bại";
      if (e is DioException) {
        final data = e.response?.data;
        if (data is Map) {
          msg = data['message'] ?? data['Message'] ?? msg;
        }
      }
      if (msg.toLowerCase().contains("đã được kích hoạt")) {
        _showErrorSnackBar("Tài khoản đã được kích hoạt", "Tài khoản này đã được kích hoạt trước đó. Vui lòng đăng nhập bằng mật khẩu của bạn.");
      } else {
        _handleError(e, msg);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    final cleanCurrent = currentPassword.trim();
    final cleanNew = newPassword.trim();
    final cleanConfirm = confirmPassword.trim();

    if (cleanCurrent.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập Mật khẩu hiện tại",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    if (cleanNew.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập Mật khẩu mới",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    if (cleanNew.length < 6 || cleanNew.length > 128) {
      Get.snackbar("Thông báo", "Mật khẩu mới phải từ 6 đến 128 ký tự",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    if (cleanConfirm != cleanNew) {
      Get.snackbar("Thông báo", "Mật khẩu xác nhận không trùng khớp với Mật khẩu mới",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    if (cleanNew == cleanCurrent) {
      Get.snackbar("Thông báo", "Mật khẩu mới không được trùng với Mật khẩu hiện tại",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    isLoading.value = true;
    try {
      final res = await _repository.changePassword(cleanCurrent, cleanNew);

      Get.snackbar(
        "Thành công",
        res.message ?? "Đổi mật khẩu thành công! Mật khẩu mới đã được cập nhật trên Server.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return true;
    } catch (e) {
      String serverError = "Mật khẩu hiện tại không chính xác. Vui lòng kiểm tra lại.";
      if (e is DioException) {
        if (e.response?.statusCode == 401) {
          serverError = "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
        } else {
          final data = e.response?.data;
          if (data is Map) {
            serverError = data['message'] ?? data['Message'] ?? data['error'] ?? serverError;
          } else if (data is String && data.isNotEmpty) {
            serverError = data;
          }
        }
      }

      _showErrorSnackBar("Đổi mật khẩu thất bại", serverError);
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> requestEmailVerify(String email) async {
    final cleanEmail = email.trim();
    if (cleanEmail.isEmpty || !GetUtils.isEmail(cleanEmail)) {
      Get.snackbar("Thông báo", "Vui lòng nhập địa chỉ Email hợp lệ",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    isLoading.value = true;
    try {
      final res = await _repository.requestEmailVerify(cleanEmail);
      if (res.success) {
        Get.snackbar(
          "Thành công",
          res.message ?? "Đã gửi mã OTP xác minh tới $cleanEmail",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        _showErrorSnackBar("Lỗi gửi Email", res.message ?? "Không thể gửi mã OTP xác minh");
        return false;
      }
    } catch (e) {
      _handleError(e, "Gửi yêu cầu xác minh email thất bại");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyEmailOtp(String otp) async {
    final cleanOtp = otp.trim();
    if (cleanOtp.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập mã OTP xác minh",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent, colorText: Colors.white);
      return false;
    }

    isLoading.value = true;
    try {
      final res = await _repository.verifyEmailOtp(cleanOtp);
      if (res.success) {
        Get.snackbar(
          "Thành công",
          res.message ?? "Xác minh Email thành công!",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        await refreshProfile();
        return true;
      } else {
        _showErrorSnackBar("Mã OTP không hợp lệ", res.message ?? "Xác minh Email thất bại");
        return false;
      }
    } catch (e) {
      _handleError(e, "Xác minh OTP thất bại");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> forgotPassword(String employeeCodeOrEmail) async {
    final cleanInput = employeeCodeOrEmail.trim();
    if (cleanInput.isEmpty) {
      _showErrorSnackBar("Thông báo", "Vui lòng nhập Email hoặc Mã nhân viên");
      return false;
    }

    isLoading.value = true;
    try {
      final res = await _repository.forgotPassword(cleanInput);
      if (res.success) {
        Get.snackbar(
          "Thành công",
          res.message ?? "Đã gửi mã OTP khôi phục mật khẩu tới email của bạn",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return true;
      } else {
        _showErrorSnackBar("Lỗi gửi yêu cầu", res.message ?? "Không tìm thấy tài khoản trong hệ thống");
        return false;
      }
    } catch (e) {
      _handleError(e, "Gửi yêu cầu khôi phục mật khẩu thất bại");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPassword({
    required String employeeCodeOrEmail,
    required String otp,
    required String newPassword,
  }) async {
    final cleanInput = employeeCodeOrEmail.trim();
    final cleanOtp = otp.trim();
    final cleanPass = newPassword.trim();

    if (cleanInput.isEmpty || cleanOtp.isEmpty) {
      _showErrorSnackBar("Thông báo", "Vui lòng nhập đầy đủ thông tin mã OTP");
      return false;
    }

    if (cleanPass.length < 6 || cleanPass.length > 128) {
      _showErrorSnackBar("Thông báo", "Mật khẩu mới phải từ 6 đến 128 ký tự");
      return false;
    }

    isLoading.value = true;
    try {
      final res = await _repository.resetPassword(
        employeeCodeOrEmail: cleanInput,
        otp: cleanOtp,
        newPassword: cleanPass,
      );

      if (res.success) {
        Get.snackbar(
          "Thành công",
          res.message ?? "Đặt lại mật khẩu thành công! Vui lòng đăng nhập lại.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
        return true;
      } else {
        _showErrorSnackBar("Lỗi đặt lại mật khẩu", res.message ?? "Mã OTP không hợp lệ hoặc đã hết hạn");
        return false;
      }
    } catch (e) {
      _handleError(e, "Đặt lại mật khẩu thất bại");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().clearData();
      }

      // 1. Xóa phiên đăng nhập cục bộ ngay lập tức để người dùng phản hồi tức thì
      final prefs = await SharedPreferences.getInstance();
      await _clearAuthSession(prefs);
      await _repository.clearAuth();
      rememberMe.value = false;
      currentUser.value = null;

      // 2. Gửi request đăng xuất API bất đồng bộ ở background, không làm treo UI người dùng
      _repository.logout().catchError((e) {
        debugPrint("Lỗi đăng xuất API background: $e");
      });
    } catch (e) {
      debugPrint("Lỗi khi xử lý đăng xuất: $e");
    } finally {
      isLoading.value = false;
      // Chuyển hướng ngay lập tức về màn hình đăng nhập với hiệu ứng mượt mà
      Get.offAll(() => LoginScreen(), transition: Transition.fadeIn);
    }
  }

  void confirmLogout([BuildContext? context]) {
    final ctx = context ?? Get.context;
    if (ctx == null) {
      logout();
      return;
    }

    showDialog(
      context: ctx,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 10,
          backgroundColor: Theme.of(ctx).cardColor,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    LucideIcons.logOut,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "Đăng xuất hệ thống",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(ctx).textTheme.titleLarge?.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Bạn có chắc chắn muốn thoát khỏi tài khoản hiện tại không?",
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(ctx).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                            side: BorderSide(
                              color: isDark ? Colors.white24 : Colors.black12,
                            ),
                          ),
                        ),
                        child: Text(
                          "Hủy",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(ctx).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          logout();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Đăng xuất",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<EmployeeMeResponse> getMe() {
    return _repository.getMe();
  }

  void _showErrorSnackBar(String title, String message) {
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(12),
      borderRadius: 12,
      icon: const Icon(Icons.error_outline, color: Colors.white),
    );
  }

  /// 🌟 Hàm xử lý lỗi an toàn tuyệt đối, phân loại đúng Map, List, String từ Server Response
  void _handleError(dynamic e, String defaultMessage) {
    String msg = defaultMessage;

    if (e is DioException) {
      final dynamic responseData = e.response?.data;

      if (responseData != null) {
        if (responseData is Map) {
          msg = responseData['message'] ??
              responseData['Message'] ??
              responseData['title'] ??
              responseData['error'] ??
              msg;
        } else if (responseData is List && responseData.isNotEmpty) {
          msg = responseData.first.toString();
        } else if (responseData is String && responseData.trim().isNotEmpty) {
          msg = responseData;
        }
      } else if (e.message != null && e.message!.isNotEmpty) {
        msg = e.message!;
      }

      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        msg = "Mã nhân viên hoặc mật khẩu không chính xác.";
      } else if (statusCode == 500) {
        msg = "Lỗi máy chủ (500). Vui lòng kiểm tra lại kết nối Database.";
      }
    } else if (e != null) {
      final rawMsg = e.toString().replaceAll('Exception: ', '').trim();
      if (rawMsg.isNotEmpty) msg = rawMsg;
    }

    _showErrorSnackBar("Lỗi hệ thống", msg);
  }
}