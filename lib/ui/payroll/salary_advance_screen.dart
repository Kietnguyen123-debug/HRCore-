import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/salary_advance_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';

class SalaryAdvanceScreen extends StatefulWidget {
  const SalaryAdvanceScreen({super.key});

  @override
  State<SalaryAdvanceScreen> createState() => _SalaryAdvanceScreenState();
}

class _SalaryAdvanceScreenState extends State<SalaryAdvanceScreen> {
  final SalaryAdvanceController controller = Get.put(SalaryAdvanceController());
  final amountCtrl = TextEditingController();
  final reasonCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.fetchMyRequests();
  }

  Future<void> _submit(TabController tabController) async {
    final amount = double.tryParse(amountCtrl.text.replaceAll(',', '').replaceAll('.', ''));
    if (amount == null || amount <= 0 || reasonCtrl.text.trim().isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập số tiền hợp lệ và lý do");
      return;
    }

    final success = await controller.submitRequest(amount, reasonCtrl.text.trim());
    if (success) {
      amountCtrl.clear();
      reasonCtrl.clear();
      tabController.animateTo(1); // Tự động chuyển sang Tab Lịch sử
    }
  }

  @override
  void dispose() {
    amountCtrl.dispose();
    reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text("Tạm ứng lương"),
              bottom: const TabBar(
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Tạm ứng lương"),
                  Tab(text: "Lịch sử tạm ứng"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildFormTab(context, tabController),
                _buildHistoryTab(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormTab(BuildContext context, TabController tabController) {
    return Obx(() => Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Số tiền muốn ứng (VNĐ)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(hintText: "Ví dụ: 2000000"),
              ),
              const SizedBox(height: 24),
              const Text("Lý do tạm ứng", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(hintText: "Nhập lý do cụ thể..."),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => _submit(tabController),
                  child: const Text("GỬI YÊU CẦU TẠM ỨNG"),
                ),
              ),
            ],
          ),
        ),
        if (controller.isLoading.value)
          Container(
            color: Colors.black12,
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    ));
  }

  Widget _buildHistoryTab(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => controller.fetchMyRequests(),
      child: Obx(() {
        if (controller.isLoading.value && controller.myRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = controller.myRequests;

        if (requests.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.walletCards, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                const SizedBox(height: 16),
                Text("Chưa có yêu cầu tạm ứng lương nào", 
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: requests.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = requests[index];
            return _buildAdvanceCard(context, item);
          },
        );
      }),
    );
  }

  Widget _buildAdvanceCard(BuildContext context, dynamic item) {
    final formatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'VNĐ');
    final amountStr = item.amount != null ? formatter.format(item.amount) : "0 VNĐ";
    final dateStr = item.requestDate != null ? DateFormat('dd/MM/yyyy').format(item.requestDate!) : "";

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(amountStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
              _buildStatusChip(item.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14, color: Colors.grey),
              const SizedBox(width: 6),
              Text("Ngày gửi: $dateStr", style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          if (item.reason != null && item.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Lý do: ${item.reason}", style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
          ],
          if (item.reviewNote != null && item.reviewNote!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Phản hồi: ${item.reviewNote}", style: const TextStyle(fontSize: 13, color: Colors.orangeAccent)),
          ],
          if ((item.status ?? '').toUpperCase() == 'PENDING' || (item.status ?? '').toLowerCase() == 'pending') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => controller.cancelRequest(item.id!),
                icon: const Icon(LucideIcons.x, size: 14, color: Colors.red),
                label: const Text("Hủy yêu cầu", style: TextStyle(color: Colors.red, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    final s = (status ?? '').toUpperCase();
    Color bg;
    Color fg;
    String text;

    if (s == 'APPROVED') {
      bg = Colors.green.withValues(alpha: 0.15);
      fg = Colors.green;
      text = "Đã duyệt";
    } else if (s == 'REJECTED') {
      bg = Colors.red.withValues(alpha: 0.15);
      fg = Colors.red;
      text = "Từ chối";
    } else if (s == 'CANCELLED') {
      bg = Colors.grey.withValues(alpha: 0.15);
      fg = Colors.grey;
      text = "Đã hủy";
    } else {
      bg = Colors.orange.withValues(alpha: 0.15);
      fg = Colors.orange;
      text = "Chờ duyệt";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
