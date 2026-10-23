import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/auth_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'package:appdiemdanh/core/theme_service.dart';
import 'package:appdiemdanh/ui/widgets/email_verification_banner.dart';
import 'package:appdiemdanh/ui/auth/change_email_sheet.dart';
import 'package:appdiemdanh/ui/auth/change_password_sheet.dart';
import 'profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Tự động khởi tạo nếu chưa có trong bộ nhớ để tránh crash Get.find()
  late final AuthController authController;
  bool _notificationsEnabled = true;
  bool _isDarkMode = Get.isDarkMode;

  @override
  void initState() {
    super.initState();
    authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    bool dark = await ThemeService().loadThemeFromPrefs();
    setState(() {
      _isDarkMode = dark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cài đặt hệ thống"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const EmailVerificationBanner(),
            _buildSection(
              "Tài khoản & Bảo mật",
              [
                _buildSettingItem(
                  icon: LucideIcons.user,
                  title: "Thông tin cá nhân",
                  subtitle: "Xem và cập nhật thông tin hồ sơ",
                  onTap: () => Get.to(() => const ProfileScreen()),
                ),
                _buildSettingItem(
                  icon: LucideIcons.mail,
                  title: "Cập nhật Email",
                  subtitle: "Email dùng để nhận OTP khôi phục mật khẩu",
                  onTap: () => ChangeEmailSheet.show(context),
                ),
                _buildSettingItem(
                  icon: LucideIcons.lock,
                  title: "Đổi mật khẩu",
                  subtitle: "Cập nhật mật khẩu định kỳ để bảo mật",
                  onTap: () => ChangePasswordSheet.show(context),
                ),
                _buildSettingItem(
                  icon: LucideIcons.logOut,
                  title: "Đăng xuất",
                  subtitle: "Thoát khỏi tài khoản trên thiết bị này",
                  onTap: () => authController.confirmLogout(context),
                  iconColor: Colors.red,
                  textColor: Colors.red,
                ),
              ],
            ),
            _buildSection(
              "Thông báo & Hiển thị",
              [
                _buildToggleItem(
                  icon: LucideIcons.bell,
                  title: "Thông báo đẩy",
                  subtitle: "Nhận tin nhắn khi có phê duyệt đơn",
                  value: _notificationsEnabled,
                  onChanged: (val) => setState(() => _notificationsEnabled = val),
                ),
                _buildThemeToggle(),
              ],
            ),
            _buildSection(
              "Hệ thống",
              [
                _buildSettingItem(
                  icon: LucideIcons.info,
                  title: "Phiên bản ứng dụng",
                  subtitle: "1.0.0 (Build 2026.09)",
                  onTap: null,
                ),
                _buildSettingItem(
                  icon: LucideIcons.shieldCheck,
                  title: "Điều khoản & Chính sách",
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                "Mọi thay đổi sẽ được đồng bộ hóa với hệ thống quản lý nhân sự.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor != null
              ? iconColor.withValues(alpha: 0.1)
              : Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: iconColor ?? Theme.of(context).iconTheme.color),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: textColor ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle, style: const TextStyle(fontSize: 12)) : null,
      trailing: onTap != null ? Icon(Icons.chevron_right, size: 20, color: textColor) : null,
    );
  }

  Widget _buildToggleItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Theme.of(context).iconTheme.color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      activeTrackColor: AppColors.primary,
    );
  }

  Widget _buildThemeToggle() {
    return SwitchListTile(
      value: _isDarkMode,
      onChanged: (val) async {
        ThemeService().switchTheme();
        setState(() {
          _isDarkMode = val;
        });
      },
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(_isDarkMode ? LucideIcons.moon : LucideIcons.sun, size: 20),
      ),
      title: const Text("Chế độ tối", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      subtitle: const Text("Giao diện dịu mắt vào ban đêm", style: TextStyle(fontSize: 12)),
      activeTrackColor: AppColors.primary,
    );
  }




}