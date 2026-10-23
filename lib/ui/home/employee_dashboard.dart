import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_colors.dart';
import '../auth/face_auth_screen.dart';
import '../../controllers/attendance_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/notification_controller.dart';
import '../leave/leave_request_screen.dart';
import '../payroll/payslip_screen.dart';
import '../attendance/attendance_explanation_screen.dart';
import '../attendance/attendance_history_screen.dart';
import '../overtime/overtime_request_screen.dart';
import '../payroll/salary_advance_screen.dart';
import 'department_members_screen.dart';
import 'notification_list_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'shift_schedule_screen.dart';
import 'chatbot_screen.dart';
import '../widgets/email_verification_banner.dart';
import '../../utils/wifi_helper.dart';
import '../../services/wifi_service.dart';
import '../../repositories/branch_repository.dart';
import '../../data/network/models/branch_models.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({super.key});

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> with WidgetsBindingObserver {
  final info = NetworkInfo();
  final AuthController authController = Get.find<AuthController>();
  final AttendanceController attendanceController = Get.put(AttendanceController());
  final NotificationController notificationController = Get.put(NotificationController());
  final BranchRepository _branchRepository = BranchRepository();
  final WifiService _wifiService = WifiService();

  String? ssid;
  String? bssid;
  bool isRefreshingWifi = false;
  String userName = "Nhân viên";
  String? avatarBase64;

  bool _isAiButtonVisible = true;
  Offset? _aiButtonOffset;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _networkCheckTimer;
  bool? _lastGpsStatus;



  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();

    _forceRefreshNetworkAndWifi();

    // 1. LẮNG NGHE SỰ KIỆN MẠNG HỆ THỐNG
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> results) {
      debugPrint("===> SỰ KIỆN THAY ĐỔI MẠNG HỆ THỐNG: $results <===");
      _forceRefreshNetworkAndWifi();
    });

    // 2. TỰ ĐỘNG THEO DÕI VỊ TRÍ & GPS
    _networkCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final isGpsEnabled = await Permission.location.serviceStatus.isEnabled;
      final connectivity = await Connectivity().checkConnectivity();

      bool gpsChanged = (_lastGpsStatus != null && isGpsEnabled != _lastGpsStatus);
      bool isWifi = connectivity.contains(ConnectivityResult.wifi);
      bool bssidMissingInWifi = isWifi && WifiHelper.isInvalidOrDummyBssid(bssid);

      if (gpsChanged || bssidMissingInWifi) {
        debugPrint("===> PHÁT HIỆN THAY ĐỔI VỊ TRÍ/GPS/MẠNG -> TỰ ĐỘNG CẬP NHẬT <===");
        _forceRefreshNetworkAndWifi();
      }

      _lastGpsStatus = isGpsEnabled;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
    _networkCheckTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("===> QUAY LẠI APP -> TỰ ĐỘNG CẬP NHẬT TRẠNG THÁI MẠNG VÀ GPS <===");
      _forceRefreshNetworkAndWifi();
    }
  }

  List<BranchWifiDto> validBranchWifis = [];
  List<BranchIpDto> validBranchIps = [];
  String? currentPublicIp;

  Future<void> _fetchBranchWifisAndIps(int branchId) async {
    try {
      final wifis = await _branchRepository.getWifis(branchId);
      final ips = await _branchRepository.getIps(branchId);
      if (mounted) {
        setState(() {
          validBranchWifis = wifis.where((w) => w.isActive).toList();
          validBranchIps = ips.where((i) => i.isActive).toList();
        });
      }
      debugPrint("===> ĐÃ TẢI ${validBranchWifis.length} WI-FI VÀ ${validBranchIps.length} IP CHO CHI NHÁNH $branchId <===");
    } catch (e) {
      debugPrint("Lỗi tải Wi-Fi/IP chi nhánh từ Server: $e");
    }
  }

  bool _isMatchedBranchWifi(String? currentBssid) {
    if (WifiHelper.isInvalidOrDummyBssid(currentBssid)) return false;
    final normCurrent = WifiHelper.normalizeBssid(currentBssid);

    if (validBranchWifis.isEmpty) return false;

    return validBranchWifis.any((w) {
      final serverBssid = WifiHelper.normalizeBssid(w.bssid);
      return serverBssid.isNotEmpty && serverBssid == normCurrent;
    });
  }

  bool _isMatchedBranchIp(String? currentIp) {
    if (currentIp == null || currentIp.trim().isEmpty) return false;
    final cleanCurrentIp = currentIp.trim();

    if (validBranchIps.isEmpty) return false;

    return validBranchIps.any((i) {
      final serverIp = (i.publicIp ?? '').trim();
      return serverIp.isNotEmpty && serverIp == cleanCurrentIp;
    });
  }

  Future<void> _forceRefreshNetworkAndWifi() async {
    final prefs = await SharedPreferences.getInstance();
    int? branchId = prefs.getInt('branchId');

    // Luôn ưu tiên lấy branchId mới nhất từ Server để tránh cache cũ khi user chuyển chi nhánh
    try {
      final profile = await authController.getMe();
      branchId = profile.branchId;
      await prefs.setInt('branchId', branchId);
    } catch (_) {}

    if (branchId != null) {
      await _fetchBranchWifisAndIps(branchId);
    }

    try {
      attendanceController.getMyToday();
      notificationController.refreshAll();
    } catch (_) {}

    isRefreshingWifi = false;
    await _startWifiProbing();
  }

  Future<void> _startWifiProbing() async {
    if (isRefreshingWifi) return;

    if (mounted) setState(() => isRefreshingWifi = true);

    try {
      currentPublicIp = await _wifiService.getPublicIp();
      final connectivityResults = await Connectivity().checkConnectivity();

      if (connectivityResults.contains(ConnectivityResult.mobile) &&
          !connectivityResults.contains(ConnectivityResult.wifi)) {
        if (mounted) {
          setState(() {
            ssid = "Mạng 4G / Dữ liệu di động";
            bssid = null;
            isRefreshingWifi = false;
          });
        }
        return;
      }

      if (connectivityResults.contains(ConnectivityResult.none) || connectivityResults.isEmpty) {
        if (mounted) {
          setState(() {
            ssid = "Không có kết nối mạng";
            bssid = null;
            isRefreshingWifi = false;
          });
        }
        return;
      }

      if (connectivityResults.contains(ConnectivityResult.wifi)) {
        final isGpsOn = await Permission.location.serviceStatus.isEnabled;
        var status = await Permission.location.status;

        if (!isGpsOn) {
          if (mounted) {
            setState(() {
              ssid = "Vui lòng bật GPS để xác thực WiFi";
              bssid = null;
              isRefreshingWifi = false;
            });
          }
          return;
        }

        if (status.isDenied) {
          status = await Permission.location.request();
        }

        if (!status.isGranted) {
          if (mounted) {
            setState(() {
              ssid = "Cần cấp quyền vị trí để đọc WiFi";
              bssid = null;
              isRefreshingWifi = false;
            });
          }
          return;
        }

        int attempts = 0;
        const int maxAttempts = 8;

        while (attempts < maxAttempts && mounted) {
          final tempSsid = await info.getWifiName();
          final tempBssid = await info.getWifiBSSID();

          if (!WifiHelper.isInvalidOrDummyBssid(tempBssid)) {
            if (mounted) {
              setState(() {
                final cleanedSsid = WifiHelper.cleanSsid(tempSsid);
                ssid = cleanedSsid.isNotEmpty && !cleanedSsid.contains('unknown')
                    ? cleanedSsid
                    : "WiFi Công ty";
                bssid = tempBssid;
              });
            }
            break;
          }

          attempts++;
          await Future.delayed(const Duration(milliseconds: 300));
        }

        if (WifiHelper.isInvalidOrDummyBssid(bssid) && mounted) {
          setState(() {
            ssid = "Chưa xác định (Cần bật GPS)";
            bssid = null;
          });
        }
      }
    } catch (e) {
      debugPrint("Lỗi cập nhật mạng/WiFi: $e");
    } finally {
      if (mounted) setState(() => isRefreshingWifi = false);
    }
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    int? branchId = prefs.getInt('branchId');
    final empCode = prefs.getString('employeeCode') ?? '';
    final userId = prefs.getInt('userId') ?? 0;

    String? savedAvatar;
    if (empCode.isNotEmpty) {
      savedAvatar = prefs.getString('user_avatar_base64_$empCode');
    }
    if (savedAvatar == null && userId > 0) {
      savedAvatar = prefs.getString('user_avatar_base64_$userId');
    }
    savedAvatar ??= prefs.getString('user_avatar_base64');

    if (mounted) {
      setState(() {
        userName = prefs.getString('userName') ?? "Thành viên";
        avatarBase64 = savedAvatar;
      });
    }

    try {
      final profile = await authController.getMe();
      branchId = profile.branchId;
      await prefs.setInt('branchId', branchId);
    } catch (_) {}

    if (branchId != null) {
      await _fetchBranchWifisAndIps(branchId);
    }
  }

  Uint8List? _getAvatarBytes() {
    if (avatarBase64 != null && avatarBase64!.isNotEmpty) {
      try {
        String clean = avatarBase64!;
        if (clean.contains(',')) {
          clean = clean.split(',').last;
        }
        return base64Decode(clean);
      } catch (e) {
        debugPrint("Lỗi decode base64 avatar dashboard: $e");
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    _aiButtonOffset ??= Offset(size.width - 145, size.height - 180);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () async => _forceRefreshNetworkAndWifi(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const EmailVerificationBanner(),
                    const SizedBox(height: 16),
                    _buildWifiStatus(),
                    const SizedBox(height: 32),
                    _buildAttendanceActions(),
                    const SizedBox(height: 40),
                    Text("Dịch vụ nội bộ",
                        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildMenuGrid(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
            _buildDraggableAiButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableAiButton(BuildContext context) {
    if (!_isAiButtonVisible || _aiButtonOffset == null) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;

    return Positioned(
      left: _aiButtonOffset!.dx,
      top: _aiButtonOffset!.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            double newX = _aiButtonOffset!.dx + details.delta.dx;
            double newY = _aiButtonOffset!.dy + details.delta.dy;

            newX = newX.clamp(12.0, size.width - 70.0);
            newY = newY.clamp(60.0, size.height - 100.0);

            _aiButtonOffset = Offset(newX, newY);
          });
        },
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              elevation: 8,
              shape: const CircleBorder(),
              color: AppColors.primary,
              child: InkWell(
                onTap: () => Get.to(() => const ChatbotScreen()),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.smart_toy_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: -2,
              right: -2,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _isAiButtonVisible = false;
                  });
                  Get.snackbar(
                    "Thông báo",
                    "Đã ẩn nút Trợ lý AI. Bạn vẫn có thể mở lại từ mục Dịch vụ nội bộ.",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 3),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: const Icon(LucideIcons.x, color: Colors.white, size: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Xin chào,", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
              Text(userName,
                  style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
        Row(
          children: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(LucideIcons.bell, size: 24),
                  onPressed: () => Get.to(() => const NotificationListScreen()),
                ),
                Obx(() => notificationController.unreadCount.value > 0
                    ? Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      notificationController.unreadCount.value > 9 ? "9+" : "${notificationController.unreadCount.value}",
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
                    : const SizedBox.shrink()),
              ],
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => Get.to(() => const ProfileScreen())?.then((_) => _loadUserInfo()),
              child: Hero(
                tag: 'profile-pic',
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: Builder(
                    builder: (context) {
                      final avatarBytes = _getAvatarBytes();
                      return CircleAvatar(
                        radius: 22,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: avatarBytes != null ? MemoryImage(avatarBytes) : null,
                        child: avatarBytes == null
                            ? const Icon(LucideIcons.user, color: AppColors.primary)
                            : null,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWifiStatus() {
    bool isConnectedWifi = !WifiHelper.isInvalidOrDummyBssid(bssid);
    bool isValidWifi = isConnectedWifi && _isMatchedBranchWifi(bssid);
    bool isValidIp = _isMatchedBranchIp(currentPublicIp);
    bool isValidOffice = isValidWifi && isValidIp;

    BranchWifiDto? matchedWifi;
    if (isValidWifi) {
      final normalizedCurrent = WifiHelper.normalizeBssid(bssid);
      matchedWifi = validBranchWifis.firstWhereOrNull((w) => WifiHelper.normalizeBssid(w.bssid) == normalizedCurrent);
    }

    Color statusColor = isValidOffice ? AppColors.secondary : (isConnectedWifi ? Colors.orange : Colors.grey);
    IconData statusIcon = isValidOffice ? LucideIcons.wifi : LucideIcons.wifiOff;

    String titleText = isValidOffice
        ? "Văn phòng hợp lệ"
        : (isConnectedWifi ? "Wi-Fi / IP chưa hợp lệ" : "Ngoài khu vực chấm công");

    final displaySsid = WifiHelper.cleanSsid(ssid);
    String subTitleText = isRefreshingWifi
        ? "Đang xác thực Wi-Fi & IP..."
        : (isValidOffice
            ? "${matchedWifi?.ssid ?? (displaySsid.isNotEmpty ? displaySsid : "Wi-Fi Chi nhánh")} (IP: ${currentPublicIp ?? 'Đã xác thực'})"
            : (isConnectedWifi
                ? (!isValidWifi && !isValidIp
                    ? "Wi-Fi & IP ($currentPublicIp) đều không thuộc Chi nhánh"
                    : (!isValidWifi
                        ? "${displaySsid.isNotEmpty ? displaySsid : 'Wi-Fi'} không thuộc Chi nhánh"
                        : "IP Mạng ($currentPublicIp) không thuộc Chi nhánh"))
                : (ssid ?? "Vui lòng kết nối Wi-Fi Công ty & bật GPS")));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
            color: statusColor.withValues(alpha: 0.3),
            width: 1.5),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: isRefreshingWifi
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                    : Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(titleText, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(subTitleText,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isValidOffice && !isRefreshingWifi)
                const Icon(LucideIcons.checkCircle2, color: AppColors.secondary, size: 20),
              if (isConnectedWifi && !isValidOffice && !isRefreshingWifi)
                const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 20),
            ],
          ),
          if (isConnectedWifi) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.fingerprint, size: 14, color: isValidWifi ? AppColors.primary : Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "BSSID Wi-Fi: ${WifiHelper.normalizeBssid(bssid)} ${isValidWifi ? '(Hợp lệ)' : '(Không thuộc Chi nhánh)'}",
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: isValidWifi ? Theme.of(context).textTheme.bodyLarge?.color : Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(LucideIcons.globe, size: 14, color: isValidIp ? AppColors.primary : Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Public IP: ${currentPublicIp ?? 'Đang tải...'} ${isValidIp ? '(Hợp lệ)' : '(Không thuộc Chi nhánh)'}",
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w600,
                            color: isValidIp ? Theme.of(context).textTheme.bodyLarge?.color : Colors.orange,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendanceActions() {
    return Obx(() {
      final isLoading = attendanceController.isLoading.value;
      return Row(
        children: [
          Expanded(
            child: _actionButton(
              "VÀO CA",
              AppColors.primary,
              LucideIcons.logIn,
              () => _handleFaceAuth(true),
              isLoading: isLoading,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _actionButton(
              "TAN CA",
              AppColors.secondary,
              LucideIcons.logOut,
              () => _handleFaceAuth(false),
              isLoading: isLoading,
            ),
          ),
        ],
      );
    });
  }

  Future<void> _handleFaceAuth(bool isCheckIn) async {
    final String deviceId = await authController.getDeviceId();

    // 1. Kiểm tra GPS
    final isGpsOn = await Permission.location.serviceStatus.isEnabled;
    if (!isGpsOn) {
      await WifiHelper.showWifiVerificationErrorDialog(
        context: mounted ? context : null,
        title: "Chưa Bật Vị Trí (GPS)",
        errorMessage: "Dịch vụ vị trí (GPS) đang tắt. Vui lòng bật GPS trên thiết bị để thực hiện xác thực điểm danh.",
        ssid: ssid,
        bssid: bssid,
        deviceId: deviceId,
        allowedBranchWifis: validBranchWifis,
      );
      return;
    }

    // 2. Kiểm tra Quyền Location
    var status = await Permission.location.status;
    if (status.isDenied) {
      status = await Permission.location.request();
    }

    if (!status.isGranted) {
      await WifiHelper.showWifiVerificationErrorDialog(
        context: mounted ? context : null,
        title: "Cấp Quyền Vị Trí",
        errorMessage: "Ứng dụng chưa được cấp quyền Vị trí. Vui lòng cấp quyền Vị trí trong Cài đặt thiết bị để tiếp tục.",
        ssid: ssid,
        bssid: bssid,
        deviceId: deviceId,
        allowedBranchWifis: validBranchWifis,
      );
      return;
    }

    // 3. Đọc & Làm sạch BSSID qua WifiHelper
    String? currentBssid = bssid;
    if (WifiHelper.isInvalidOrDummyBssid(currentBssid)) {
      try {
        currentBssid = await info.getWifiBSSID();
      } catch (_) {}
    }

    if (WifiHelper.isInvalidOrDummyBssid(currentBssid)) {
      await WifiHelper.showWifiVerificationErrorDialog(
        context: mounted ? context : null,
        title: "Chưa Kết Nối Wi-Fi",
        errorMessage: "Không thể đọc thông tin mạng Wi-Fi. Vui lòng đảm bảo thiết bị đã bật GPS và kết nối với Wi-Fi công ty.",
        ssid: ssid,
        bssid: currentBssid,
        deviceId: deviceId,
        allowedBranchWifis: validBranchWifis,
      );
      return;
    }

    final normalizedBssid = WifiHelper.normalizeBssid(currentBssid);

    // Lấy Public IP mới nhất
    currentPublicIp = await _wifiService.getPublicIp();

    // 4. Kiểm tra Wi-Fi & Public IP Chi nhánh (BẮT BUỘC HỢP LỆ CẢ 2)
    bool isValidWifi = _isMatchedBranchWifi(normalizedBssid);
    bool isValidIp = _isMatchedBranchIp(currentPublicIp);

    if (!isValidWifi || !isValidIp) {
      String dialogTitle = "";
      String errorMsg = "";

      if (!isValidWifi && !isValidIp) {
        dialogTitle = "Mạng Không Hợp Lệ";
        errorMsg = "Mạng Wi-Fi và địa chỉ IP hiện tại không thuộc chi nhánh làm việc của bạn. Vui lòng kết nối đúng Wi-Fi công ty.";
      } else if (!isValidWifi) {
        dialogTitle = "Wi-Fi Không Hợp Lệ";
        errorMsg = validBranchWifis.isEmpty
            ? "Chi nhánh chưa đăng ký danh sách Wi-Fi trên hệ thống. Vui lòng liên hệ quản lý."
            : "Mạng Wi-Fi hiện tại không thuộc danh sách Wi-Fi của chi nhánh.";
      } else {
        dialogTitle = "IP Mạng Không Hợp Lệ";
        errorMsg = validBranchIps.isEmpty
            ? "Chi nhánh chưa đăng ký danh sách IP trên hệ thống. Vui lòng liên hệ quản lý."
            : "Địa chỉ IP mạng hiện tại không thuộc danh sách IP của chi nhánh.";
      }

      await WifiHelper.showWifiVerificationErrorDialog(
        context: mounted ? context : null,
        title: dialogTitle,
        errorMessage: errorMsg,
        ssid: ssid,
        bssid: normalizedBssid,
        clientPublicIp: currentPublicIp,
        deviceId: deviceId,
        allowedBranchWifis: validBranchWifis,
      );
      return;
    }

    final String? base64Image = await Get.to(() => const FaceAuthScreen());
    if (base64Image != null && base64Image.isNotEmpty) {
      if (isCheckIn) {
        await attendanceController.checkIn(
          base64Image,
          normalizedBssid,
          deviceId,
          ssid: ssid,
          allowedBranchWifis: validBranchWifis,
          context: mounted ? context : null,
        );
      } else {
        await attendanceController.checkOut(
          base64Image,
          normalizedBssid,
          deviceId,
          ssid: ssid,
          allowedBranchWifis: validBranchWifis,
          context: mounted ? context : null,
        );
      }
    }
  }

  Widget _actionButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap, {
    bool isLoading = false,
  }) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: isLoading ? color.withValues(alpha: 0.7) : color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            else
              Icon(icon, size: 28, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              isLoading ? "ĐANG XỬ LÝ..." : label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _menuItem(Icons.smart_toy_rounded, "Trợ lý AI", AppColors.primary,
                () => Get.to(() => const ChatbotScreen())),
        _menuItem(LucideIcons.clipboardCheck, "Lịch sử chấm công", Colors.teal,
                () => Get.to(() => const AttendanceHistoryScreen())),
        _menuItem(LucideIcons.calendarClock, "Lịch làm việc", Colors.orange,
                () => Get.to(() => const ShiftScheduleScreen())),
        _menuItem(LucideIcons.users, "Đồng nghiệp", Colors.indigo,
                () => Get.to(() => const DepartmentMembersScreen())),
        _menuItem(LucideIcons.calendarDays, "Đơn xin nghỉ", Colors.amber,
                () => Get.to(() => const LeaveRequestScreen())),
        _menuItem(LucideIcons.banknote, "Phiếu lương", Colors.green,
                () => Get.to(() => const PayslipScreen())),
        _menuItem(LucideIcons.history, "Giải trình", Colors.blue,
                () => Get.to(() => const AttendanceExplanationScreen())),
        _menuItem(LucideIcons.timer, "Tăng ca", Colors.purple,
                () => Get.to(() => const OvertimeRequestScreen())),
        _menuItem(LucideIcons.wallet, "Tạm ứng", Colors.deepOrange,
                () => Get.to(() => const SalaryAdvanceScreen())),
        _menuItem(LucideIcons.settings, "Cài đặt", Colors.grey,
                () => Get.to(() => const SettingsScreen())),
      ],
    );
  }

  Widget _menuItem(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}