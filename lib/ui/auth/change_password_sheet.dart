import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/auth_controller.dart';
import '../../core/app_colors.dart';
import '../../utils/password_utils.dart';
import 'forgot_password_screen.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: const ChangePasswordSheet(),
      ),
    );
  }

  @override
  State<ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends State<ChangePasswordSheet> {
  final AuthController authController = Get.find<AuthController>();

  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  final FocusNode _currentPassFocus = FocusNode();
  final FocusNode _newPassFocus = FocusNode();
  final FocusNode _confirmPassFocus = FocusNode();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _logoutOtherDevices = true;
  bool _isLoading = false;

  String? _currentPassError;
  String? _confirmPassError;
  String? _newPassError;

  PasswordCriteria _criteria = PasswordUtils.evaluateCriteria("");
  PasswordStrengthLevel _strength = PasswordStrengthLevel.empty;

  @override
  void initState() {
    super.initState();
    _newPassCtrl.addListener(_onNewPasswordChanged);
    _confirmPassCtrl.addListener(_onConfirmPasswordChanged);
  }

  @override
  void dispose() {
    _newPassCtrl.removeListener(_onNewPasswordChanged);
    _confirmPassCtrl.removeListener(_onConfirmPasswordChanged);

    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();

    _currentPassFocus.dispose();
    _newPassFocus.dispose();
    _confirmPassFocus.dispose();
    super.dispose();
  }

  void _onNewPasswordChanged() {
    final text = _newPassCtrl.text;
    setState(() {
      _criteria = PasswordUtils.evaluateCriteria(text);
      _strength = PasswordUtils.calculateStrength(text);

      if (text.isNotEmpty && text == _currentPassCtrl.text.trim()) {
        _newPassError = "Mật khẩu mới không được trùng với mật khẩu hiện tại";
      } else {
        _newPassError = null;
      }
    });
    _validateConfirmPassword();
  }

  void _onConfirmPasswordChanged() {
    _validateConfirmPassword();
  }

  void _validateConfirmPassword() {
    final confirm = _confirmPassCtrl.text;
    final newPass = _newPassCtrl.text;

    setState(() {
      if (confirm.isNotEmpty && confirm != newPass) {
        _confirmPassError = "Mật khẩu xác nhận không trùng khớp";
      } else {
        _confirmPassError = null;
      }
    });
  }

  bool get _isFormValid {
    final current = _currentPassCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (current.isEmpty) return false;
    if (!_criteria.isAllSatisfied) return false;
    if (newPass == current) return false;
    if (confirm.isEmpty || confirm != newPass) return false;

    return true;
  }

  Future<void> _handleSubmit() async {
    final current = _currentPassCtrl.text.trim();
    final newPass = _newPassCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (!_isFormValid) return;

    setState(() {
      _isLoading = true;
      _currentPassError = null;
      _confirmPassError = null;
      _newPassError = null;
    });

    final success = await authController.changePassword(
      currentPassword: current,
      newPassword: newPass,
      confirmPassword: confirm,
    );

    if (!mounted) return;

    if (success) {
      if (_logoutOtherDevices) {
        await authController.resetLocalDeviceId();
      }

      if (!mounted) return;

      Navigator.of(context).pop();

      _showSuccessDialog();
    } else {
      setState(() {
        _isLoading = false;
        _currentPassError = "Mật khẩu hiện tại không chính xác. Vui lòng kiểm tra lại.";
      });
    }
  }

  void _showSuccessDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.circleCheck, size: 48, color: Colors.green),
              ),
              const SizedBox(height: 16),
              const Text(
                "Đổi mật khẩu thành công!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 8),
              const Text(
                "Mật khẩu tài khoản của bạn đã được cập nhật thành công trên hệ thống. Vui lòng sử dụng mật khẩu mới cho các lần đăng nhập tiếp theo.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Đã hiểu", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Sheet Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(LucideIcons.keyRound, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Đổi mật khẩu tài khoản",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        "Cập nhật mật khẩu định kỳ để bảo mật thông tin cá nhân",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // FIELD 1: Current Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Mật khẩu hiện tại *",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Get.to(() => const ForgotPasswordScreen());
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    "Quên mật khẩu?",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _currentPassCtrl,
              focusNode: _currentPassFocus,
              obscureText: _obscureCurrent,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: "Nhập mật khẩu hiện tại trên server",
                prefixIcon: const Icon(LucideIcons.lock, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscureCurrent ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                  onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              onChanged: (_) {
                if (_currentPassError != null) {
                  setState(() => _currentPassError = null);
                }
              },
            ),
            if (_currentPassError != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.circleAlert, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _currentPassError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 20),

            // FIELD 2: New Password
            const Text(
              "Mật khẩu mới *",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _newPassCtrl,
              focusNode: _newPassFocus,
              obscureText: _obscureNew,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: "Nhập mật khẩu mới an toàn",
                prefixIcon: const Icon(LucideIcons.key, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscureNew ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                  onPressed: () => setState(() => _obscureNew = !_obscureNew),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            if (_newPassError != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.circleAlert, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _newPassError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],

            // Password Strength Meter
            if (_newPassCtrl.text.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildStrengthMeter(),
            ],

            const SizedBox(height: 14),

            // Live Checklist
            _buildLiveChecklist(),

            const SizedBox(height: 20),

            // FIELD 3: Confirm New Password
            const Text(
              "Xác nhận mật khẩu mới *",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _confirmPassCtrl,
              focusNode: _confirmPassFocus,
              obscureText: _obscureConfirm,
              enabled: !_isLoading,
              decoration: InputDecoration(
                hintText: "Nhập lại chính xác mật khẩu mới",
                prefixIcon: const Icon(LucideIcons.checkCheck, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirm ? LucideIcons.eyeOff : LucideIcons.eye, size: 18),
                  onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),

            if (_confirmPassError != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(LucideIcons.circleAlert, size: 14, color: Colors.red),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _confirmPassError!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 16),

            // Security Option Checkbox
            InkWell(
              onTap: _isLoading
                  ? null
                  : () {
                      setState(() {
                        _logoutOtherDevices = !_logoutOtherDevices;
                      });
                    },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _logoutOtherDevices,
                        activeColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: _isLoading
                            ? null
                            : (val) {
                                setState(() {
                                  _logoutOtherDevices = val ?? true;
                                });
                              },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        "Đăng xuất khỏi tất cả các thiết bị khác sau khi đổi mật khẩu",
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (_isLoading || !_isFormValid) ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : const Text(
                        "Cập nhật mật khẩu",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthMeter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Độ mạnh mật khẩu:",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              _strength.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _strength.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _strength.ratio,
            backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(_strength.color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildLiveChecklist() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Yêu cầu mật khẩu an toàn:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          _checkItem("Ít nhất 8 ký tự", _criteria.hasMin8Chars),
          _checkItem("Có ít nhất 1 chữ hoa (A-Z)", _criteria.hasUppercase),
          _checkItem("Có ít nhất 1 chữ thường (a-z)", _criteria.hasLowercase),
          _checkItem("Có ít nhất 1 chữ số (0-9)", _criteria.hasDigit),
          _checkItem("Có ít nhất 1 ký tự đặc biệt (@, #, \$, %,...)", _criteria.hasSpecialChar),
        ],
      ),
    );
  }

  Widget _checkItem(String label, bool isSatisfied) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(
            isSatisfied ? LucideIcons.circleCheck : LucideIcons.circle,
            size: 15,
            color: isSatisfied ? Colors.green : Colors.grey.shade400,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSatisfied ? FontWeight.w600 : FontWeight.normal,
                color: isSatisfied
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
