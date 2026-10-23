import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:appdiemdanh/controllers/auth_controller.dart';
import 'package:appdiemdanh/controllers/leave_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'package:appdiemdanh/data/network/models/auth_models.dart';
import 'package:appdiemdanh/ui/widgets/email_verification_banner.dart';
import 'package:appdiemdanh/ui/auth/email_verification_sheet.dart';
import 'package:appdiemdanh/ui/auth/change_email_sheet.dart';
import 'package:appdiemdanh/ui/auth/change_password_sheet.dart';
import 'package:appdiemdanh/ui/auth/face_auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthController authController = Get.find<AuthController>();
  final LeaveController leaveController = Get.put(LeaveController());
  
  String? deviceId;
  String? avatarBase64;
  final Rxn<EmployeeMeResponse> profile = Rxn<EmployeeMeResponse>();
  bool isInitialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileFromServer();
    _getDeviceInfo();
    _loadLocalAvatar();
  }

  Future<void> _loadLocalAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = profile.value?.id ?? prefs.getInt('userId') ?? 0;
      final empCode = profile.value?.employeeCode ?? prefs.getString('employeeCode') ?? '';

      String? savedAvatar;
      if (empCode.isNotEmpty) {
        savedAvatar = prefs.getString('user_avatar_base64_$empCode');
      }
      if (savedAvatar == null && userId > 0) {
        savedAvatar = prefs.getString('user_avatar_base64_$userId');
      }
      savedAvatar ??= prefs.getString('user_avatar_base64');

      if (savedAvatar != null && savedAvatar.isNotEmpty) {
        if (mounted) {
          setState(() {
            avatarBase64 = savedAvatar;
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi nạp avatar local: $e");
    }
  }

  Future<void> _saveLocalAvatar(String base64Str) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = profile.value?.id ?? prefs.getInt('userId') ?? 0;
      final empCode = profile.value?.employeeCode ?? prefs.getString('employeeCode') ?? '';

      if (empCode.isNotEmpty) {
        await prefs.setString('user_avatar_base64_$empCode', base64Str);
      }
      if (userId > 0) {
        await prefs.setString('user_avatar_base64_$userId', base64Str);
      }
      await prefs.setString('user_avatar_base64', base64Str);

      if (mounted) {
        setState(() {
          avatarBase64 = base64Str;
        });
      }
    } catch (e) {
      debugPrint("Lỗi lưu avatar local: $e");
    }
  }

  Future<void> _removeAvatar() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = profile.value?.id ?? prefs.getInt('userId') ?? 0;
      final empCode = profile.value?.employeeCode ?? prefs.getString('employeeCode') ?? '';

      if (empCode.isNotEmpty) {
        await prefs.remove('user_avatar_base64_$empCode');
      }
      if (userId > 0) {
        await prefs.remove('user_avatar_base64_$userId');
      }
      await prefs.remove('user_avatar_base64');

      if (mounted) {
        setState(() {
          avatarBase64 = null;
        });
      }
      Get.snackbar(
        "Thông báo",
        "Đã xóa ảnh đại diện",
        backgroundColor: Colors.grey.shade800,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint("Lỗi xóa avatar local: $e");
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        final base64Str = base64Encode(bytes);
        await _saveLocalAvatar(base64Str);
        Get.snackbar(
          "Thành công",
          "Đã cập nhật ảnh đại diện từ thư viện ảnh",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint("Lỗi chọn ảnh từ thư viện: $e");
      Get.snackbar(
        "Lỗi",
        "Không thể chọn ảnh từ thư viện. Vui lòng thử lại.",
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  void _showAvatarOptions(EmployeeMeResponse user) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  "Thay đổi ảnh đại diện",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.teal,
                    child: Icon(LucideIcons.image, color: Colors.white, size: 20),
                  ),
                  title: const Text("Chọn ảnh từ thư viện điện thoại", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Tải ảnh từ Thư viện / Bộ sưu tập"),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImageFromGallery();
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primary,
                    child: Icon(LucideIcons.camera, color: Colors.white, size: 20),
                  ),
                  title: const Text("Chụp ảnh khuôn mặt / Avatar mới", style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text("Sử dụng Camera xác thực eKYC"),
                  onTap: () async {
                    Navigator.pop(ctx);
                    final String? capturedBase64 = await Get.to(() => const FaceAuthScreen());
                    if (capturedBase64 != null && capturedBase64.isNotEmpty) {
                      await _saveLocalAvatar(capturedBase64);
                      Get.snackbar(
                        "Thành công",
                        "Đã cập nhật ảnh đại diện thành công",
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 3),
                      );
                    }
                  },
                ),
                if (avatarBase64 != null && avatarBase64!.isNotEmpty) ...[
                  const Divider(),
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.redAccent,
                      child: Icon(LucideIcons.trash2, color: Colors.white, size: 20),
                    ),
                    title: const Text("Xóa ảnh đại diện", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    subtitle: const Text("Đặt lại về biểu tượng đại diện mặc định"),
                    onTap: () {
                      Navigator.pop(ctx);
                      _removeAvatar();
                    },
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _loadProfileFromServer() async {
    try {
      final data = await authController.getMe();
      profile.value = data;
      
      bool isAdmin = data.role?.toLowerCase().contains('admin') ?? false;
      bool isHR = data.role?.toLowerCase().contains('hr') ?? false;
      
      if (!isAdmin && !isHR) {
        await leaveController.fetchBalance();
      }
      _loadLocalAvatar();
    } catch (e) {
      debugPrint("Lỗi tải hồ sơ: $e");
    } finally {
      if (mounted) setState(() => isInitialLoading = false);
    }
  }

  Future<void> _getDeviceInfo() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var android = await deviceInfo.androidInfo;
      deviceId = android.id;
    } else if (Platform.isIOS) {
      var ios = await deviceInfo.iosInfo;
      deviceId = ios.identifierForVendor;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Hồ sơ cá nhân"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _loadProfileFromServer,
          )
        ],
      ),
      body: isInitialLoading 
        ? const Center(child: CircularProgressIndicator())
        : Obx(() => _buildBody()),
    );
  }

  Widget _buildBody() {
    final user = profile.value;
    if (user == null) return const Center(child: Text("Không thể tải thông tin hồ sơ"));

    bool isAdmin = user.role?.toLowerCase().contains('admin') ?? false;
    bool isHR = user.role?.toLowerCase().contains('hr') ?? false;

    return SingleChildScrollView(
      child: Column(
        children: [
          const EmailVerificationBanner(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Column(
              children: [
                _buildHeader(user, isAdmin || isHR),
                const SizedBox(height: 32),
                _buildInfoCard(context, user, isAdmin || isHR),
                const SizedBox(height: 40),
                _buildLogoutButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(EmployeeMeResponse user, bool isManagement) {
    Uint8List? imageBytes;
    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        String clean = avatarBase64!;
        if (clean.contains(',')) {
          clean = clean.split(',').last;
        }
        imageBytes = base64Decode(clean);
      } catch (e) {
        debugPrint("Lỗi decode base64 avatar: $e");
      }
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: () => _showAvatarOptions(user),
              child: Hero(
                tag: 'profile-pic',
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    backgroundImage: imageBytes != null ? MemoryImage(imageBytes) : null,
                    child: imageBytes == null
                        ? Icon(
                            isManagement ? LucideIcons.shieldCheck : LucideIcons.user,
                            size: 55,
                            color: AppColors.primary,
                          )
                        : null,
                  ),
                ),
              ),
            ),
            PositionStatus(isActive: user.isActivated),
            // Nút Camera Edit Icon đè góc dưới bên phải Avatar
            Positioned(
              bottom: 0,
              right: 4,
              child: GestureDetector(
                onTap: () => _showAvatarOptions(user),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    LucideIcons.camera,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          user.fullName ?? "Thành viên",
          style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isManagement ? Colors.orange.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            user.role?.toUpperCase() ?? "NHÂN VIÊN",
            style: TextStyle(
              color: isManagement ? Colors.orange : AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, EmployeeMeResponse user, bool isManagement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          _infoRow(context, LucideIcons.idCard, "Mã nhân viên", user.employeeCode ?? "N/A"),
          _divider(),
          _infoRow(context, LucideIcons.building, "Phòng ban / Chi nhánh", "Chi nhánh ID: ${user.branchId}"),
          _divider(),
          _infoRow(
            context, 
            LucideIcons.mail, 
            "Email", 
            user.email != null && user.email!.isNotEmpty 
                ? "${user.email} (${user.isEmailVerified ? 'Đã xác minh' : 'Chưa xác minh'})" 
                : "Chưa cập nhật", 
            color: user.isEmailVerified ? Colors.green : Colors.orange,
            action: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.email != null && user.email!.isNotEmpty && !user.isEmailVerified) ...[
                  OutlinedButton.icon(
                    onPressed: () => EmailVerificationSheet.show(context, email: user.email!).then((_) => _loadProfileFromServer()),
                    icon: const Icon(LucideIcons.shieldCheck, size: 12),
                    label: const Text("Xác thực", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      foregroundColor: Colors.orange.shade800,
                      side: BorderSide(color: Colors.orange.shade400),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                OutlinedButton.icon(
                  onPressed: () => ChangeEmailSheet.show(context).then((_) => _loadProfileFromServer()),
                  icon: const Icon(LucideIcons.pencil, size: 12),
                  label: Text(
                    user.email != null && user.email!.isNotEmpty ? "Đổi Email" : "Thêm Email",
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.5)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          _divider(),
          _infoRow(context, LucideIcons.smartphone, "ID Thiết bị hiện tại", deviceId ?? "Đang tải...", isLong: true),
          _divider(),
          if (!isManagement) ...[
            Obx(() {
              final b = leaveController.balance.value;
              String leaveText = "Đang tải...";
              if (b != null) {
                leaveText = "${b.remainingAnnualLeave} ngày";
              } else if (user.remainingAnnualLeave != null) {
                leaveText = "${user.remainingAnnualLeave} ngày";
              }
              return _infoRow(context, LucideIcons.calendarCheck, "Số dư phép năm", leaveText);
            }),
            _divider(),
          ],
          _infoRow(context, LucideIcons.shieldCheck, "Trạng thái tài khoản", 
              user.isActivated ? "Đã kích hoạt" : "Chờ kích hoạt", 
              color: user.isActivated ? Colors.green : Colors.orange),
          _divider(),
          InkWell(
            onTap: () => ChangePasswordSheet.show(context),
            child: _infoRow(context, LucideIcons.keyRound, "Bảo mật tài khoản", "Bấm vào đây để Đổi mật khẩu", 
                color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String val, {Color? color, bool isLong = false, Widget? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: isLong ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                Text(
                  val,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: color,
                  ),
                  maxLines: isLong ? 2 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 8),
            action,
          ],
        ],
      ),
    );
  }

  Widget _divider() => Divider(height: 24, thickness: 0.5, color: Colors.grey.withValues(alpha: 0.1));

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _confirmLogout(),
        icon: const Icon(LucideIcons.logOut, size: 18),
        label: const Text("ĐĂNG XUẤT HỆ THỐNG", style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          foregroundColor: Colors.red,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }





  void _confirmLogout() {
    authController.confirmLogout(context);
  }
}

class PositionStatus extends StatelessWidget {
  final bool isActive;
  const PositionStatus({super.key, required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 5,
      right: 5,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: isActive ? Colors.green : Colors.orange,
          shape: BoxShape.circle,
          border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 3),
        ),
      ),
    );
  }
}
