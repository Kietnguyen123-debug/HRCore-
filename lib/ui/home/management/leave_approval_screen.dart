import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/approval_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import '../../../data/network/models/admin_models.dart';

class LeaveApprovalScreen extends StatefulWidget {
  const LeaveApprovalScreen({super.key});

  @override
  State<LeaveApprovalScreen> createState() => _LeaveApprovalScreenState();
}

class _LeaveApprovalScreenState extends State<LeaveApprovalScreen> {
  final ApprovalController controller = Get.put(ApprovalController());

  @override
  void initState() {
    super.initState();
    controller.fetchAllPending();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Phê duyệt nghỉ phép"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => controller.fetchAllPending(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pendingLeaves.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pendingLeaves.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clipboardCheck, size: 64, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                const Text("Không có đơn nghỉ phép nào chờ duyệt"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllPending,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.pendingLeaves.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = controller.pendingLeaves[index];
              return _buildLeaveCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildLeaveCard(AdminLeaveDto item) {
    final dateFmt = DateFormat('dd/MM/yyyy');
    final startStr = dateFmt.format(item.startDate);
    final endStr = dateFmt.format(item.endDate);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: const Icon(LucideIcons.user, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.employeeName ?? "NV #${item.employeeId}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    Text(
                      "Từ $startStr đến $endStr",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  item.leaveType,
                  style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text("Lý do: ${item.reason}", style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showRejectDialog(item.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text("Từ chối"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => controller.approveLeave(item.id, true),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text("Phê duyệt"),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  void _showRejectDialog(int id) {
    final reasonCtrl = TextEditingController();
    Get.defaultDialog(
      title: "Từ chối đơn nghỉ",
      content: TextField(
        controller: reasonCtrl,
        decoration: const InputDecoration(labelText: "Lý do từ chối"),
      ),
      textConfirm: "Xác nhận",
      onConfirm: () {
        Get.back();
        controller.approveLeave(id, false, reason: reasonCtrl.text.trim());
      },
    );
  }
}
