import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/auth_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'face_auth_screen.dart';

class ActivationScreen extends StatefulWidget {
  const ActivationScreen({super.key});

  @override
  State<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends State<ActivationScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController codeCtrl = TextEditingController();
  final TextEditingController tempPassCtrl = TextEditingController();
  final TextEditingController newPassCtrl = TextEditingController();

  Future<void> _startFaceCapture() async {
    final String code = codeCtrl.text.trim();
    final String tempPass = tempPassCtrl.text.trim();
    final String newPass = newPassCtrl.text.trim();

    if (code.isEmpty || tempPass.isEmpty || newPass.isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập đầy đủ thông tin tài khoản");
      return;
    }

    if (newPass.length < 6) {
      Get.snackbar("Thông báo", "Mật khẩu mới phải có ít nhất 6 ký tự");
      return;
    }

    // 1. Kiểm tra tài khoản trên server trước khi cho qua bước xác thực mặt
    final bool isValid = await authController.verifyActivationCredentials(code, tempPass);
    if (!isValid) return;

    // 2. Nếu thông tin đúng, chuyển sang màn hình xác thực khuôn mặt eKYC
    final String? base64 = await Get.to(() => const FaceAuthScreen());
    
    if (base64 != null) {
      await authController.activate(code, tempPass, newPass, base64);
    }
  }

  @override
  void dispose() {
    codeCtrl.dispose();
    tempPassCtrl.dispose();
    newPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Kích hoạt tài khoản"),
      ),
      body: Obx(() => authController.isLoading.value 
        ? const Center(child: CircularProgressIndicator()) 
        : _buildInputUI()),
    );
  }

  Widget _buildInputUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(LucideIcons.shieldCheck, color: AppColors.primary, size: 64),
          const SizedBox(height: 16),
          Text("Bước 1: Thông tin tài khoản", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildField("Mã nhân viên", codeCtrl, LucideIcons.user),
          const SizedBox(height: 16),
          _buildField("Mật khẩu tạm thời", tempPassCtrl, LucideIcons.key, isObscure: true),
          const SizedBox(height: 16),
          _buildField("Mật khẩu mới", newPassCtrl, LucideIcons.lock, isObscure: true),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startFaceCapture,
              child: const Text("TIẾP THEO (XÁC THỰC MẶT)"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, {bool isObscure = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: isObscure,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
            hintText: "Nhập $label",
          ),
        ),
      ],
    );
  }
}
