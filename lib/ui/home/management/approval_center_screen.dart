import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/approval_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/admin_models.dart';
import '../../../data/network/models/explanation_models.dart';

class ApprovalCenterScreen extends StatelessWidget {
  const ApprovalCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ApprovalController());

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Trung tâm phê duyệt"),
          actions: [
            IconButton(
              icon: const Icon(LucideIcons.refreshCw, size: 20),
              onPressed: () => controller.fetchAllPending(),
            )
          ],
          bottom: TabBar(
            isScrollable: true,
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Nghỉ phép"),
              Tab(text: "Tăng ca"),
              Tab(text: "Giải trình"),
              Tab(text: "Tạm ứng"),
              Tab(text: "Lịch sử"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildLeaveList(context, controller),
            _buildOvertimeList(context, controller),
            _buildExplanationList(context, controller),
            _buildAdvanceList(context, controller),
            _buildHistory(context, controller),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // 1. NGHIÊM VỤ NGHỈ PHÉP (LEAVE)
  // --------------------------------------------------------------------------
  Widget _buildLeaveList(BuildContext context, ApprovalController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingLeaves.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = controller.pendingLeaves;
      if (list.isEmpty) return _buildRefreshableEmptyState(context, controller, "đơn nghỉ phép");

      final dateFmt = DateFormat('dd/MM/yyyy');
      return RefreshIndicator(
        onRefresh: controller.fetchAllPending,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final startStr = dateFmt.format(item.startDate);
            final endStr = dateFmt.format(item.endDate);

            return _buildApprovalCard(
              context,
              typeBadge: "Nghỉ phép",
              badgeColor: Colors.purple,
              employeeName: item.employeeName ?? "NV #${item.employeeId}",
              employeeCode: item.employeeCode,
              details: [
                "Loại nghỉ: ${item.leaveType}",
                "Thời gian: Từ $startStr đến $endStr",
                "Lý do: ${item.reason}",
              ],
              onTapCard: () => _showLeaveDetailModal(context, controller, item),
              onApprove: () => controller.approveLeave(item.id, true),
              onReject: () => _showRejectModal(
                context,
                title: "Từ chối nghỉ phép (${item.employeeName ?? 'NV'})",
                onSubmit: (reason) => controller.approveLeave(item.id, false, reason: reason),
              ),
            );
          },
        ),
      );
    });
  }

  void _showLeaveDetailModal(BuildContext context, ApprovalController controller, AdminLeaveDto item) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    _showDetailBottomSheet(
      context,
      title: "Chi tiết Đơn nghỉ phép",
      typeBadge: "Nghỉ phép",
      badgeColor: Colors.purple,
      employeeName: item.employeeName ?? "NV #${item.employeeId}",
      employeeCode: item.employeeCode,
      infoRows: [
        MapEntry("Mã NV", item.employeeCode ?? "N/A"),
        MapEntry("Loại nghỉ phép", item.leaveType),
        MapEntry("Từ ngày", dateFmt.format(item.startDate)),
        MapEntry("Đến ngày", dateFmt.format(item.endDate)),
        MapEntry("Lý do nghỉ", item.reason),
        MapEntry("Thời gian gửi", dateFmt.format(item.createdAt)),
      ],
      onApprove: () {
        Get.back();
        controller.approveLeave(item.id, true);
      },
      onReject: () {
        Get.back();
        _showRejectModal(
          context,
          title: "Từ chối nghỉ phép (${item.employeeName ?? 'NV'})",
          onSubmit: (reason) => controller.approveLeave(item.id, false, reason: reason),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 2. NGHIỆM VỤ TĂNG CA (OVERTIME)
  // --------------------------------------------------------------------------
  Widget _buildOvertimeList(BuildContext context, ApprovalController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingOvertimes.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = controller.pendingOvertimes;
      if (list.isEmpty) return _buildRefreshableEmptyState(context, controller, "yêu cầu tăng ca");

      final dateFmt = DateFormat('dd/MM/yyyy');
      return RefreshIndicator(
        onRefresh: controller.fetchAllPending,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final dateStr = dateFmt.format(item.workDate);

            return _buildApprovalCard(
              context,
              typeBadge: "Tăng ca",
              badgeColor: Colors.orange,
              employeeName: item.employeeName ?? "NV #${item.employeeId}",
              employeeCode: item.employeeCode,
              details: [
                "Ngày tăng ca: $dateStr",
                "Số giờ: ${item.hours}h (Hệ số ${item.multiplier}x)",
              ],
              onTapCard: () => _showOvertimeDetailModal(context, controller, item),
              onApprove: () => controller.approveOvertime(item.id, true),
              onReject: () => _showRejectModal(
                context,
                title: "Từ chối tăng ca (${item.employeeName ?? 'NV'})",
                onSubmit: (reason) => controller.approveOvertime(item.id, false, reason: reason),
              ),
            );
          },
        ),
      );
    });
  }

  void _showOvertimeDetailModal(BuildContext context, ApprovalController controller, AdminOvertimeDto item) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    _showDetailBottomSheet(
      context,
      title: "Chi tiết Yêu cầu Tăng ca",
      typeBadge: "Tăng ca",
      badgeColor: Colors.orange,
      employeeName: item.employeeName ?? "NV #${item.employeeId}",
      employeeCode: item.employeeCode,
      infoRows: [
        MapEntry("Mã NV", item.employeeCode ?? "N/A"),
        MapEntry("Ngày làm tăng ca", dateFmt.format(item.workDate)),
        MapEntry("Số giờ tăng ca", "${item.hours} giờ"),
        MapEntry("Hệ số lương", "${item.multiplier}x"),
        MapEntry("Trạng thái", item.status),
      ],
      onApprove: () {
        Get.back();
        controller.approveOvertime(item.id, true);
      },
      onReject: () {
        Get.back();
        _showRejectModal(
          context,
          title: "Từ chối tăng ca (${item.employeeName ?? 'NV'})",
          onSubmit: (reason) => controller.approveOvertime(item.id, false, reason: reason),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 3. NGHIỆM VỤ GIẢI TRÌNH (ATTENDANCE EXPLANATION)
  // --------------------------------------------------------------------------
  Widget _buildExplanationList(BuildContext context, ApprovalController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingExplanations.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = controller.pendingExplanations;
      if (list.isEmpty) return _buildRefreshableEmptyState(context, controller, "yêu cầu giải trình");

      final dateFmt = DateFormat('dd/MM/yyyy');
      return RefreshIndicator(
        onRefresh: controller.fetchAllPending,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final dateStr = item.targetDate != null ? dateFmt.format(item.targetDate!) : 'N/A';

            return _buildApprovalCard(
              context,
              typeBadge: "Giải trình",
              badgeColor: Colors.teal,
              employeeName: item.employeeName ?? "NV #${item.employeeId ?? 0}",
              details: [
                "Ngày cần giải trình: $dateStr",
                "Lý do: ${item.explanationReason ?? 'Chưa nhập'}",
              ],
              onTapCard: () => _showExplanationDetailModal(context, controller, item),
              onApprove: () => controller.reviewExplanation(item.id!, "APPROVED"),
              onReject: () => _showRejectModal(
                context,
                title: "Từ chối giải trình (${item.employeeName ?? 'NV'})",
                onSubmit: (note) => controller.reviewExplanation(item.id!, "REJECTED", note: note),
              ),
            );
          },
        ),
      );
    });
  }

  void _showExplanationDetailModal(BuildContext context, ApprovalController controller, AttendanceExplanationResponse item) {
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    _showDetailBottomSheet(
      context,
      title: "Chi tiết Đơn Giải trình Chấm công",
      typeBadge: "Giải trình",
      badgeColor: Colors.teal,
      employeeName: item.employeeName ?? "NV #${item.employeeId ?? 0}",
      infoRows: [
        MapEntry("Ngày cần giải trình", item.targetDate != null ? dateFmt.format(item.targetDate!) : 'N/A'),
        MapEntry("Giờ Check-in bổ sung", item.missingCheckInTime != null ? dateFmt.format(item.missingCheckInTime!) : 'Không có'),
        MapEntry("Giờ Check-out bổ sung", item.missingCheckOutTime != null ? dateFmt.format(item.missingCheckOutTime!) : 'Không có'),
        MapEntry("Lý do giải trình", item.explanationReason ?? 'Chưa nhập'),
        MapEntry("Thời gian tạo", item.createdAt != null ? dateFmt.format(item.createdAt!) : 'N/A'),
      ],
      onApprove: () {
        Get.back();
        controller.reviewExplanation(item.id!, "APPROVED");
      },
      onReject: () {
        Get.back();
        _showRejectModal(
          context,
          title: "Từ chối giải trình (${item.employeeName ?? 'NV'})",
          onSubmit: (note) => controller.reviewExplanation(item.id!, "REJECTED", note: note),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 4. NGHIỆM VỤ TẠM ỨNG LƯƠNG (SALARY ADVANCE)
  // --------------------------------------------------------------------------
  Widget _buildAdvanceList(BuildContext context, ApprovalController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.pendingAdvances.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      final list = controller.pendingAdvances;
      if (list.isEmpty) return _buildRefreshableEmptyState(context, controller, "yêu cầu tạm ứng");

      final moneyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
      final dateFmt = DateFormat('dd/MM/yyyy');

      return RefreshIndicator(
        onRefresh: controller.fetchAllPending,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final item = list[index];
            final amountStr = moneyFmt.format(item.amount);
            final dateStr = dateFmt.format(item.requestDate);

            return _buildApprovalCard(
              context,
              typeBadge: "Tạm ứng",
              badgeColor: Colors.blue,
              employeeName: item.employeeName ?? "NV #${item.employeeId}",
              employeeCode: item.employeeCode,
              details: [
                "Số tiền tạm ứng: $amountStr",
                "Ngày yêu cầu: $dateStr",
                "Lý do: ${item.reason}",
              ],
              onTapCard: () => _showAdvanceDetailModal(context, controller, item),
              onApprove: () => controller.approveAdvance(item.id, true),
              onReject: () => _showRejectModal(
                context,
                title: "Từ chối tạm ứng (${item.employeeName ?? 'NV'})",
                onSubmit: (note) => controller.approveAdvance(item.id, false, note: note),
              ),
            );
          },
        ),
      );
    });
  }

  void _showAdvanceDetailModal(BuildContext context, ApprovalController controller, AdminSalaryAdvanceDto item) {
    final moneyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);
    final dateFmt = DateFormat('dd/MM/yyyy');
    _showDetailBottomSheet(
      context,
      title: "Chi tiết Yêu cầu Tạm ứng Lương",
      typeBadge: "Tạm ứng",
      badgeColor: Colors.blue,
      employeeName: item.employeeName ?? "NV #${item.employeeId}",
      employeeCode: item.employeeCode,
      infoRows: [
        MapEntry("Mã NV", item.employeeCode ?? "N/A"),
        MapEntry("Số tiền xin tạm ứng", moneyFmt.format(item.amount)),
        MapEntry("Ngày yêu cầu", dateFmt.format(item.requestDate)),
        MapEntry("Lý do xin tạm ứng", item.reason),
      ],
      onApprove: () {
        Get.back();
        controller.approveAdvance(item.id, true);
      },
      onReject: () {
        Get.back();
        _showRejectModal(
          context,
          title: "Từ chối tạm ứng (${item.employeeName ?? 'NV'})",
          onSubmit: (note) => controller.approveAdvance(item.id, false, note: note),
        );
      },
    );
  }

  // --------------------------------------------------------------------------
  // 5. LỊCH SỬ PHÊ DUYỆT (GIỮ NGUYÊN HOÀN TOÀN)
  // --------------------------------------------------------------------------
  Widget _buildHistory(BuildContext context, ApprovalController controller) {
    return Obx(() {
      if (controller.isLoading.value && controller.historyRecords.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.historyRecords.isEmpty) return _buildRefreshableEmptyState(context, controller, "đã phê duyệt");

      return RefreshIndicator(
        onRefresh: controller.fetchAllPending,
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.historyRecords.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final h = controller.historyRecords[index];
            bool isApproved = h['status'] == "Đã duyệt";
            final timeStr = h['processedAt'] != null && h['processedAt'].toString().length >= 16
                ? h['processedAt'].toString().substring(11, 16)
                : 'Vừa xong';
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
              ),
              child: Row(
                children: [
                  Icon(isApproved ? LucideIcons.checkCircle : LucideIcons.xCircle, color: isApproved ? Colors.green : Colors.red),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${h['employeeName'] ?? 'NV'} • ${_getTypeLabel(h['type'])}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        Text("Trạng thái: ${h['status']}", style: TextStyle(color: isApproved ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                        if (h['note'] != null && h['note'].toString().isNotEmpty && h['note'] != 'N/A')
                          Text("Nội dung: ${h['note']}", style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
                      ],
                    ),
                  ),
                  Text(timeStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case "Leave": return "Nghỉ phép";
      case "Overtime": return "Tăng ca";
      case "Explanation": return "Giải trình";
      case "Advance": return "Tạm ứng";
      default: return type;
    }
  }

  Widget _buildRefreshableEmptyState(BuildContext context, ApprovalController controller, String suffix) {
    return RefreshIndicator(
      onRefresh: controller.fetchAllPending,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clipboardList, color: Theme.of(context).textTheme.bodySmall?.color, size: 64),
                const SizedBox(height: 16),
                Text("Không có $suffix đang chờ duyệt", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () => controller.fetchAllPending(),
                  icon: const Icon(LucideIcons.refreshCw, size: 16),
                  label: const Text("Tải lại"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------------------------------
  // SHARED CARD & MODAL BUILDERS
  // --------------------------------------------------------------------------
  Widget _buildApprovalCard(
    BuildContext context, {
    required String typeBadge,
    required Color badgeColor,
    required String employeeName,
    String? employeeCode,
    required List<String> details,
    required VoidCallback onTapCard,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    return InkWell(
      onTap: onTapCard,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        margin: const EdgeInsets.only(bottom: 12),
        color: Theme.of(context).cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                          child: const Icon(LucideIcons.user, size: 18, color: AppColors.primary),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(employeeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              if (employeeCode != null && employeeCode.isNotEmpty)
                                Text("Mã NV: $employeeCode", style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      typeBadge,
                      style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              ...details.map((d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(d, style: TextStyle(fontSize: 13, height: 1.3, color: Theme.of(context).textTheme.bodyMedium?.color)),
                  )),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text("Từ chối"),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: onApprove,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    ),
                    child: const Text("Phê duyệt"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailBottomSheet(
    BuildContext context, {
    required String title,
    required String typeBadge,
    required Color badgeColor,
    required String employeeName,
    String? employeeCode,
    required List<MapEntry<String, String>> infoRows,
    required VoidCallback onApprove,
    required VoidCallback onReject,
  }) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: badgeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(typeBadge, style: TextStyle(color: badgeColor, fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text("Nhân viên: $employeeName", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              const Divider(height: 24),
              ...infoRows.map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 130,
                          child: Text(e.key, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                        ),
                        Expanded(
                          child: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("TỪ CHỐI", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onApprove,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("PHÊ DUYỆT", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showRejectModal(
    BuildContext context, {
    required String title,
    required Function(String) onSubmit,
  }) {
    final ctrl = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.xCircle, color: Colors.red, size: 22),
                const SizedBox(width: 8),
                Expanded(child: Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold))),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Lý do từ chối (Tùy chọn)",
                hintText: "Nhập phản hồi/lý do từ chối yêu cầu...",
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("HỦY"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final reason = ctrl.text.trim();
                      Get.back(); // Đóng modal từ chối
                      onSubmit(reason);
                    },
                    child: const Text("XÁC NHẬN TỪ CHỐI", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
