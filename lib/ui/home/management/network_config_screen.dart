import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:network_info_plus/network_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:appdiemdanh/controllers/admin_dashboard_controller.dart';
import 'package:appdiemdanh/controllers/network_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'package:appdiemdanh/utils/wifi_helper.dart';
import '../../../data/network/models/branch_models.dart';

class NetworkConfigScreen extends StatefulWidget {
  const NetworkConfigScreen({super.key});

  @override
  State<NetworkConfigScreen> createState() => _NetworkConfigScreenState();
}

class _NetworkConfigScreenState extends State<NetworkConfigScreen> {
  late final NetworkController controller;
  late final AdminDashboardController dashController;

  final ssidCtrl = TextEditingController();
  final bssidCtrl = TextEditingController();
  final ipCtrl = TextEditingController();
  final descCtrl = TextEditingController();
  int? selectedBranchId;

  bool isWifiAuto = false;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<NetworkController>() ? Get.find<NetworkController>() : Get.put(NetworkController());
    dashController = Get.isRegistered<AdminDashboardController>() ? Get.find<AdminDashboardController>() : Get.put(AdminDashboardController());

    if (dashController.branches.isNotEmpty) {
      selectedBranchId = dashController.selectedBranchId.value ?? dashController.branches.first.id;
      controller.fetchBranchNetwork(selectedBranchId!);
    } else {
      dashController.fetchBranches().then((_) {
        if (dashController.branches.isNotEmpty && mounted) {
          setState(() {
            selectedBranchId = dashController.branches.first.id;
          });
          controller.fetchBranchNetwork(selectedBranchId!);
        }
      });
    }
  }

  @override
  void dispose() {
    ssidCtrl.dispose();
    bssidCtrl.dispose();
    ipCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Cấu hình Mạng & IP Chi nhánh"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () {
              dashController.fetchBranches();
              if (selectedBranchId != null) {
                controller.fetchBranchNetwork(selectedBranchId!);
              }
            },
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBranchSelector(),
                const SizedBox(height: 20),
                _buildCurrentConfigs(),
                const SizedBox(height: 28),
                _buildSectionHeader(LucideIcons.wifi, "Cấu hình Wi-Fi Chi nhánh"),
                const SizedBox(height: 12),
                _buildWifiForm(),
                const SizedBox(height: 32),
                _buildSectionHeader(LucideIcons.globe, "Cấu hình IP Public / Tĩnh"),
                const SizedBox(height: 12),
                _buildIpForm(),
              ],
            ),
          ),
          Obx(() => controller.isLoading.value
              ? Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }

  Widget _buildBranchSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Chọn chi nhánh áp dụng", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Obx(() {
          final branches = dashController.branches;
          if (branches.isEmpty) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text("Chưa có danh sách chi nhánh", style: TextStyle(color: Colors.grey)),
            );
          }

          int? validValue = branches.any((b) => b.id == selectedBranchId) ? selectedBranchId : branches.first.id;

          return DropdownButtonFormField<int>(
            value: validValue,
            decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
            items: branches.map((b) => DropdownMenuItem<int>(value: b.id, child: Text(b.name ?? "Chi nhánh #${b.id}"))).toList(),
            onChanged: (val) {
              if (val != null) {
                setState(() => selectedBranchId = val);
                controller.fetchBranchNetwork(val);
                ssidCtrl.clear();
                bssidCtrl.clear();
                ipCtrl.clear();
                descCtrl.clear();
              }
            },
          );
        }),
      ],
    );
  }

  Widget _buildCurrentConfigs() {
    return Obx(() {
      final wifis = controller.branchWifis;
      final ips = controller.branchIps;

      if (wifis.isEmpty && ips.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: const Row(
            children: [
              Icon(LucideIcons.info, size: 18, color: Colors.grey),
              SizedBox(width: 8),
              Text("Chi nhánh này chưa có Wi-Fi hoặc IP đã lưu", style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Cấu hình Wi-Fi & IP hiện tại:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ...wifis.map((w) => _configChip(
                LucideIcons.wifi,
                "${w.ssid ?? 'WiFi'} (${w.bssid ?? ''})",
                Colors.blue,
                onDelete: () => _confirmDeleteWifi(w),
              )),
              ...ips.map((ip) => _configChip(
                LucideIcons.globe,
                "IP: ${ip.publicIp ?? 'N/A'}",
                Colors.teal,
                onDelete: () => _confirmDeleteIp(ip),
              )),
            ],
          ),
        ],
      );
    });
  }

  Widget _configChip(IconData icon, String label, Color color, {VoidCallback? onDelete}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            InkWell(
              onTap: onDelete,
              child: Icon(LucideIcons.x, size: 14, color: color),
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(title, style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildWifiForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          TextField(controller: ssidCtrl, decoration: const InputDecoration(labelText: "Tên WiFi (SSID)")),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: TextField(controller: bssidCtrl, decoration: const InputDecoration(labelText: "Địa chỉ MAC (BSSID)"))),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _getAutoBssid,
                icon: const Icon(LucideIcons.refreshCw, size: 20),
                tooltip: "Quét tự động Wi-Fi",
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Checkbox(value: isWifiAuto, onChanged: (v) => setState(() => isWifiAuto = v ?? false)),
              const Text("Tự động ghi nhận BSSID khi check-in", style: TextStyle(fontSize: 13)),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveWifi,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: const Text("LƯU THÔNG TIN WI-FI"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildIpForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(LucideIcons.info, color: AppColors.primary, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Bấm nút quét bên dưới để ứng dụng tự động xác định địa chỉ IP Public đường truyền kết nối hiện tại.",
                    style: TextStyle(fontSize: 12, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: ipCtrl,
                  decoration: const InputDecoration(labelText: "Địa chỉ IP Public (Ví dụ: 14.232.xxx.xxx)"),
                ),
              ),
              const SizedBox(width: 12),
              IconButton.filled(
                onPressed: _getAutoPublicIp,
                icon: const Icon(LucideIcons.refreshCw, size: 20),
                tooltip: "Lấy IP Public tự động",
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả đường truyền (Ví dụ: Viettel Line 1)")),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _saveIp,
              icon: const Icon(LucideIcons.globe, size: 18),
              label: const Text("NHẬN DIỆN & LƯU IP PUBLIC"),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
            ),
          )
        ],
      ),
    );
  }

  void _getAutoPublicIp() async {
    try {
      final dio = Dio();
      final response = await dio.get('https://api.ipify.org?format=json').timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.data != null) {
        String? ip = response.data['ip']?.toString();
        if (ip != null && ip.isNotEmpty) {
          ipCtrl.text = ip;
          Get.snackbar("Thành công", "Đã lấy địa chỉ IP Public hiện tại: $ip", backgroundColor: Colors.green, colorText: Colors.white);
          return;
        }
      }
    } catch (_) {
      try {
        final dio = Dio();
        final response = await dio.get('https://ifconfig.me/ip').timeout(const Duration(seconds: 5));
        if (response.statusCode == 200 && response.data != null) {
          String ip = response.data.toString().trim();
          if (ip.isNotEmpty) {
            ipCtrl.text = ip;
            Get.snackbar("Thành công", "Đã lấy địa chỉ IP Public hiện tại: $ip", backgroundColor: Colors.green, colorText: Colors.white);
            return;
          }
        }
      } catch (e) {
        Get.snackbar("Lỗi", "Không thể lấy địa chỉ IP Public tự động. Vui lòng kiểm tra kết nối mạng.");
      }
    }
  }

  void _getAutoBssid() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.nearbyWifiDevices,
    ].request();

    if (statuses[Permission.location] != PermissionStatus.granted) {
      Get.snackbar("Lỗi", "Ứng dụng cần quyền Vị trí để lấy thông tin Wi-Fi.");
      return;
    }

    if (!(await Permission.location.serviceStatus.isEnabled)) {
      Get.snackbar("Thông báo", "Vui lòng bật GPS (Vị trí) để lấy đúng địa chỉ BSSID.",
          duration: const Duration(seconds: 5),
          mainButton: TextButton(onPressed: () => openAppSettings(), child: const Text("Cài đặt")));
      return;
    }

    final info = NetworkInfo();
    try {
      String? ssid = await info.getWifiName();
      String? bssid = await info.getWifiBSSID();

      if (!WifiHelper.isInvalidOrDummyBssid(bssid)) {
        String cleanBssid = WifiHelper.normalizeBssid(bssid);
        ssidCtrl.text = WifiHelper.cleanSsid(ssid);
        bssidCtrl.text = cleanBssid;
        Get.snackbar("Thành công", "Đã lấy địa chỉ BSSID Wi-Fi: $cleanBssid");
      } else {
        Get.snackbar("Lỗi", "Không lấy được BSSID chuẩn. Hãy chắc chắn bạn đang kết nối Wi-Fi và đã bật Vị trí.",
            duration: const Duration(seconds: 5));
      }
    } catch (e) {
      Get.snackbar("Lỗi", "Đã xảy ra lỗi khi quét Wi-Fi");
    }
  }

  Future<void> _saveWifi() async {
    if (selectedBranchId == null) {
      Get.snackbar("Lỗi", "Vui lòng chọn chi nhánh");
      return;
    }
    if (ssidCtrl.text.trim().isEmpty || bssidCtrl.text.trim().isEmpty) {
      Get.snackbar("Lỗi", "Vui lòng nhập Tên Wi-Fi và Địa chỉ BSSID");
      return;
    }
    await controller.saveWifi(
      branchId: selectedBranchId!,
      ssid: ssidCtrl.text,
      bssid: bssidCtrl.text,
      isAutoCaptured: isWifiAuto,
    );
  }

  Future<void> _saveIp() async {
    if (selectedBranchId == null) {
      Get.snackbar("Lỗi", "Vui lòng chọn chi nhánh");
      return;
    }
    await controller.saveIp(
      branchId: selectedBranchId!,
      publicIp: ipCtrl.text,
      description: descCtrl.text,
    );
  }

  void _confirmDeleteWifi(BranchWifiDto w) {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText: "Xóa Wi-Fi '${w.ssid}' khỏi chi nhánh này?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      onConfirm: () {
        Get.back();
        controller.deleteWifi(branchId: selectedBranchId!, id: w.id);
      },
    );
  }

  void _confirmDeleteIp(BranchIpDto ip) {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText: "Xóa IP '${ip.publicIp}' khỏi chi nhánh này?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      onConfirm: () {
        Get.back();
        controller.deleteIp(branchId: selectedBranchId!, id: ip.id);
      },
    );
  }
}
