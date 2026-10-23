import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/report_controller.dart';
import '../../../controllers/admin_dashboard_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/report_models.dart';

class AttendanceReportScreen extends StatefulWidget {
  const AttendanceReportScreen({super.key});

  @override
  State<AttendanceReportScreen> createState() => _AttendanceReportScreenState();
}

class _AttendanceReportScreenState extends State<AttendanceReportScreen> {
  final ReportController controller = Get.put(ReportController());
  late final AdminDashboardController dashController;

  @override
  void initState() {
    super.initState();
    dashController = Get.find<AdminDashboardController>();
    controller.fetchAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Báo cáo quản trị"),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 20),
              onPressed: () => controller.fetchAllReports(),
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Tổng kết tháng"),
              Tab(text: "Chi tiết chấm công"),
              Tab(text: "Báo cáo nghỉ phép"),
              Tab(text: "Báo cáo tăng ca"),
            ],
          ),
        ),
        body: Column(
          children: [
            _buildFilters(context, controller, dashController),
            Expanded(
              child: TabBarView(
                children: [
                  _buildMonthlySummaryTab(context, controller),
                  _buildAttendanceDetailTab(context, controller),
                  _buildLeaveReportTab(context, controller),
                  _buildOvertimeReportTab(context, controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(BuildContext context, ReportController controller, AdminDashboardController dashController) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Obx(() => DropdownButtonFormField<int>(
                  value: controller.selectedMonth.value,
                  decoration: const InputDecoration(labelText: "Tháng", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("Tháng ${i + 1}"))),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedMonth.value = val;
                      controller.fetchAllReports();
                    }
                  },
                )),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Obx(() => DropdownButtonFormField<int>(
                  value: controller.selectedYear.value,
                  decoration: const InputDecoration(labelText: "Năm", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: List.generate(5, (i) => DropdownMenuItem(value: 2023 + i, child: Text("${2023 + i}"))),
                  onChanged: (val) {
                    if (val != null) {
                      controller.selectedYear.value = val;
                      controller.fetchAllReports();
                    }
                  },
                )),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() => DropdownButtonFormField<int>(
                value: controller.selectedBranchId.value,
                decoration: const InputDecoration(labelText: "Chi nhánh", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                items: [
                  const DropdownMenuItem<int>(value: null, child: Text("Tất cả chi nhánh")),
                  ...dashController.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name ?? ""))),
                ],
                onChanged: (val) {
                  controller.selectedBranchId.value = val;
                  controller.fetchAllReports();
                },
              )),
        ],
      ),
    );
  }

  Widget _buildMonthlySummaryTab(BuildContext context, ReportController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.monthlySummary.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.monthlySummary.isEmpty) return _emptyState("Không có dữ liệu tổng kết tháng");

      return RefreshIndicator(
        onRefresh: controller.fetchAllReports,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.monthlySummary.length,
          itemBuilder: (context, index) {
            final item = controller.monthlySummary[index];
            final name = item.fullName?.isNotEmpty == true ? item.fullName! : (item.employeeCode ?? "NV #${item.employeeId}");
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Theme.of(context).cardColor,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: const Icon(LucideIcons.user, color: AppColors.primary, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text("Tổng ngày công: ${item.totalWorkDays} ngày (${item.totalWorkedHours.toStringAsFixed(1)}h)"),
                          Text(
                            "Đi trễ: ${item.totalLateMinutes}p • Về sớm: ${item.totalEarlyLeaveMinutes}p",
                            style: TextStyle(
                              fontSize: 12,
                              color: item.totalLateMinutes > 0 ? Colors.red : Theme.of(context).textTheme.bodySmall?.color,
                            ),
                          ),
                          if (item.totalApprovedLeaveDays > 0)
                            Text("Nghỉ phép: ${item.totalApprovedLeaveDays} ngày", style: const TextStyle(fontSize: 12, color: Colors.orange)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAttendanceDetailTab(BuildContext context, ReportController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.attendanceReport.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.attendanceReport.isEmpty) return _emptyState("Không có báo cáo chi tiết chấm công");

      return RefreshIndicator(
        onRefresh: controller.fetchAllReports,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.attendanceReport.length,
          itemBuilder: (context, index) {
            final item = controller.attendanceReport[index];
            final name = item.employeeName?.isNotEmpty == true ? item.employeeName! : (item.employeeCode ?? "NV #${item.employeeId}");
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Có mặt: ${item.presentDays}/${item.totalWorkDays} ngày"),
                        Text("Vắng: ${item.absentDays} ngày", style: const TextStyle(color: Colors.red)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text("Tổng thời gian: ${item.totalWorkedHours.toStringAsFixed(1)} giờ", style: const TextStyle(fontSize: 12)),
                    Text("Trễ: ${item.totalLateMinutes} phút | Về sớm: ${item.totalEarlyLeaveMinutes} phút", style: const TextStyle(fontSize: 12, color: Colors.orange)),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildLeaveReportTab(BuildContext context, ReportController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.leaveReport.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.leaveReport.isEmpty) return _emptyState("Không có dữ liệu báo cáo nghỉ phép");

      return RefreshIndicator(
        onRefresh: controller.fetchAllReports,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.leaveReport.length,
          itemBuilder: (context, index) {
            final item = controller.leaveReport[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                title: Text("Trạng thái: ${item.status ?? 'Tất cả'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Tổng số yêu cầu: ${item.requestCount}"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("${item.leaveDays} ngày", style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildOvertimeReportTab(BuildContext context, ReportController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.overtimeReport.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.overtimeReport.isEmpty) return _emptyState("Không có dữ liệu báo cáo tăng ca");

      return RefreshIndicator(
        onRefresh: controller.fetchAllReports,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.overtimeReport.length,
          itemBuilder: (context, index) {
            final item = controller.overtimeReport[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              color: Theme.of(context).cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: ListTile(
                title: Text("Trạng thái: ${item.status ?? 'Tất cả'}", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Số lượng đơn: ${item.requestCount}"),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text("${item.totalHours.toStringAsFixed(1)} giờ", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  Widget _emptyState(String text) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.fileX, size: 64, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          Text(text),
        ],
      ),
    );
  }
}
