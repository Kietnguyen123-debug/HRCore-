import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appdiemdanh/controllers/auth_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'login_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final AuthController authController = Get.put(AuthController());
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPassCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  int _currentStep = 0; // 0: Request OTP by Email, 1: Enter OTP & New Password

  Future<void> _requestReset() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập địa chỉ Email đăng ký");
      return;
    }

    final success = await authController.forgotPassword(email);
    if (success && mounted) {
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _resetPassword() async {
    final otp = _otpCtrl.text.trim();
    final newPass = _newPassCtrl.text.trim();
    final confirmPass = _confirmPassCtrl.text.trim();

    if (otp.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập mã OTP đã nhận qua Email");
      return;
    }

    if (newPass.length < 6) {
      Get.snackbar("Thông báo", "Mật khẩu mới phải có ít nhất 6 ký tự");
      return;
    }

    if (newPass != confirmPass) {
      Get.snackbar("Thông báo", "Mật khẩu xác nhận không trùng khớp");
      return;
    }

    final success = await authController.resetPassword(
      employeeCodeOrEmail: _emailCtrl.text.trim(),
      otp: otp,
      newPassword: newPass,
    );

    if (success) {
      Get.offAll(() => LoginScreen());
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Khôi phục mật khẩu")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(LucideIcons.shieldQuestion, size: 64, color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              _currentStep == 0 ? "Bước 1: Nhập Email đăng ký" : "Bước 2: Xác minh OTP & Đặt mật khẩu mới",
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            if (_currentStep == 0) _buildRequestUI(),
            if (_currentStep == 1) _buildResetUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestUI() {
    return Column(
      children: [
        const Text("Nhập địa chỉ Email đăng ký tài khoản nhân viên để nhận mã OTP khôi phục mật khẩu.", textAlign: TextAlign.center),
        const SizedBox(height: 24),
        TextField(
          controller: _emailCtrl, 
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: "Địa chỉ Email", prefixIcon: Icon(LucideIcons.mail)),
        ),
        const SizedBox(height: 32),
        _btn("GỬI MÃ OTP KHÔI PHỤC", _requestReset),
      ],
    );
  }

  Widget _buildResetUI() {
    return Column(
      children: [
        Text("Mã OTP đã được gửi tới hòm thư email:\n${_emailCtrl.text}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 24),
        TextField(
          controller: _otpCtrl, 
          keyboardType: TextInputType.number, 
          decoration: const InputDecoration(labelText: "Mã OTP (6 chữ số)", prefixIcon: Icon(LucideIcons.key)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _newPassCtrl, 
          obscureText: true, 
          decoration: const InputDecoration(labelText: "Mật khẩu mới (Tối thiểu 6 ký tự)", prefixIcon: Icon(LucideIcons.lock)),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _confirmPassCtrl, 
          obscureText: true, 
          decoration: const InputDecoration(labelText: "Xác nhận mật khẩu mới", prefixIcon: Icon(LucideIcons.checkCheck)),
        ),
        const SizedBox(height: 32),
        _btn("CẬP NHẬT MẬT KHẨU", _resetPassword),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () => setState(() => _currentStep = 0), 
          child: const Text("Gửi lại mã OTP / Đổi địa chỉ Email"),
        ),
      ],
    );
  }

  Widget _btn(String label, VoidCallback onPress) {
    return SizedBox(
      width: double.infinity,
      child: Obx(() {
        final isLoading = authController.isLoading.value;
        return ElevatedButton(
          onPressed: isLoading ? null : onPress,
          child: isLoading 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) 
              : Text(label),
        );
      }),
    );
  }
}
