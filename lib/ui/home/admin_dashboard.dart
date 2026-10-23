import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/admin_dashboard_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'package:appdiemdanh/controllers/auth_controller.dart';
import 'management/employee_list_screen.dart';
import 'management/department_list_screen.dart';
import 'management/approval_center_screen.dart';
import 'management/network_config_screen.dart';
import 'management/payroll_summary_screen.dart';
import 'management/attendance_report_screen.dart';
import 'management/shift_list_screen.dart';
import 'management/admin_attendance_screen.dart';
import 'management/payroll_policy_screen.dart';
import 'management/branch_list_screen.dart';
import 'management/role_management_screen.dart';
import 'management/admin_chatbot_screen.dart';
import 'settings_screen.dart';
import '../widgets/email_verification_banner.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(LucideIcons.shieldCheck, color: AppColors.primary),
            const SizedBox(width: 8),
            Text("Admin Panel", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.settings),
            onPressed: () => Get.to(() => const SettingsScreen()),
          ),
          IconButton(
            icon: const Icon(LucideIcons.logOut),
            onPressed: () => _confirmLogout(context),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const EmailVerificationBanner(),
                  _buildBranchFilter(context, controller),
                  const SizedBox(height: 24),
                  Text(
                    "Thống kê thời gian thực",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 16),
                  Obx(() {
                    if (controller.isLoading.value && controller.summaryData.isEmpty) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return _buildStatCards(context, controller.summaryData);
                  }),
                  const SizedBox(height: 32),
                  Text(
                    "Phân hệ quản lý",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _buildGridMenu(context, controller),
                  const SizedBox(height: 32),
                  Text(
                    "Danh sách check-in gần đây",
                    style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 12),
                  _buildLiveAttendanceList(context, controller),
                ],
              ),
            ),
            
            Obx(() => controller.isLoading.value && controller.summaryData.isNotEmpty
                ? const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: LinearProgressIndicator(minHeight: 2, backgroundColor: Colors.transparent),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchFilter(BuildContext context, AdminDashboardController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: controller.selectedBranchId.value,
              dropdownColor: Theme.of(context).cardColor,
              hint: const Text("Tất cả chi nhánh"),
              isExpanded: true,
              items: [
                const DropdownMenuItem<int>(value: null, child: Text("Tất cả chi nhánh", overflow: TextOverflow.ellipsis)),
                ...controller.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name ?? "", overflow: TextOverflow.ellipsis))),
              ],
              onChanged: controller.onBranchChanged,
            ),
          )),
    );
  }

  Widget _buildStatCards(BuildContext context, Map<String, dynamic>? data) {
    if (data == null) return const SizedBox();
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _statTile(context, "Nhân viên", "${data['totalEmployees'] ?? 0}", Colors.blue, LucideIcons.users),
        _statTile(context, "Check-in", "${data['checkedInCount'] ?? 0}", AppColors.secondary, LucideIcons.userCheck),
        _statTile(context, "Đi trễ", "${data['lateCount'] ?? 0}", Colors.orange, LucideIcons.timer),
        _statTile(context, "Chưa check-in", "${data['notCheckedInCount'] ?? 0}", Colors.red, LucideIcons.userX),
      ],
    );
  }

  Widget _statTile(BuildContext context, String title, String val, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(title, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildGridMenu(BuildContext context, AdminDashboardController controller) {
    return Obx(() {
      int totalPending = controller.totalPendingCount;

      final menuItems = <Widget>[];

      if (controller.hasPermission('employee')) {
        menuItems.add(_menuItem(context, LucideIcons.users, "Nhân sự", AppColors.primary, () => Get.to(() => const EmployeeListScreen())));
      }
      if (controller.hasPermission('department')) {
        menuItems.add(_menuItem(context, LucideIcons.building, "Phòng ban", Colors.indigo, () => Get.to(() => const DepartmentListScreen())));
      }
      if (controller.hasPermission('branch')) {
        menuItems.add(_menuItem(context, LucideIcons.building2, "Chi nhánh", Colors.cyan, () => Get.to(() => const BranchListScreen())));
      }
      if (controller.hasPermission('approval')) {
        menuItems.add(_menuItem(context, LucideIcons.clipboardCheck, "Phê duyệt", Colors.orange, () => Get.to(() => const ApprovalCenterScreen()), badgeCount: totalPending));
      }
      if (controller.hasPermission('payroll')) {
        menuItems.add(_menuItem(context, LucideIcons.banknote, "Lương", Colors.green, () => Get.to(() => const PayrollSummaryScreen())));
      }
      if (controller.hasPermission('report')) {
        menuItems.add(_menuItem(context, LucideIcons.fileText, "Báo cáo", Colors.purple, () => Get.to(() => const AttendanceReportScreen())));
      }
      if (controller.hasPermission('shift')) {
        menuItems.add(_menuItem(context, LucideIcons.clock, "Quản lý Ca", Colors.teal, () => Get.to(() => const ShiftListScreen())));
      }
      if (controller.hasPermission('attendance')) {
        menuItems.add(_menuItem(context, LucideIcons.calendarCheck, "Chấm công", Colors.deepOrange, () => Get.to(() => const AdminAttendanceScreen())));
      }
      if (controller.hasPermission('policy')) {
        menuItems.add(_menuItem(context, LucideIcons.sliders, "Chính sách", Colors.pink, () => Get.to(() => const PayrollPolicyScreen())));
      }
      if (controller.hasPermission('role')) {
        menuItems.add(_menuItem(context, LucideIcons.shieldCheck, "Vai trò/Quyền", Colors.brown, () => Get.to(() => const RoleManagementScreen())));
      }
      if (controller.hasPermission('chatbot')) {
        menuItems.add(_menuItem(context, LucideIcons.bot, "AI Admin", Colors.amber.shade800, () => Get.to(() => const AdminChatbotScreen())));
      }
      if (controller.hasPermission('network')) {
        menuItems.add(_menuItem(context, LucideIcons.wifi, "Mạng/WiFi", AppColors.secondary, () => Get.to(() => const NetworkConfigScreen())));
      }

      if (menuItems.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
          ),
          child: const Center(
            child: Text("Tài khoản của bạn chưa được phân quyền sử dụng phân hệ nào."),
          ),
        );
      }

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: menuItems,
      );
    });
  }

  Widget _menuItem(BuildContext context, IconData icon, String label, Color color, VoidCallback onTap, {int badgeCount = 0}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Stack(
          children: [
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            if (badgeCount > 0)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "$badgeCount",
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAttendanceList(BuildContext context, AdminDashboardController controller) {
    return Obx(() {
      final list = controller.recentAttendance;
      if (list.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text("Chưa có dữ liệu check-in hôm nay", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
          ),
        );
      }
      
      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length > 5 ? 5 : list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = list[index];
          final timeStr = item.checkInTime != null ? DateFormat('HH:mm:ss').format(item.checkInTime!) : 'Chưa CI';
          final isLate = item.lateMinutes > 0;

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            tileColor: Theme.of(context).cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.05)),
            ),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
            ),
            title: Text(item.employeeName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            subtitle: Text("Giờ CI: $timeStr${item.branchName != null ? ' • ${item.branchName}' : ''}", style: const TextStyle(fontSize: 12)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isLate ? Colors.red.withValues(alpha: 0.1) : Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isLate ? "Trễ ${item.lateMinutes}p" : "Đúng giờ",
                style: TextStyle(color: isLate ? Colors.red : Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      );
    });
  }

  void _confirmLogout(BuildContext context) {
    final authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    authController.confirmLogout(context);
  }
}
