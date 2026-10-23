import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/attendance_explanation_controller.dart';
import 'package:appdiemdanh/data/network/models/explanation_models.dart';
import '../../core/app_colors.dart';

class AttendanceExplanationScreen extends StatefulWidget {
  const AttendanceExplanationScreen({super.key});

  @override
  State<AttendanceExplanationScreen> createState() => _AttendanceExplanationScreenState();
}

class _AttendanceExplanationScreenState extends State<AttendanceExplanationScreen> {
  final AttendanceExplanationController controller = Get.put(AttendanceExplanationController());
  final reasonCtrl = TextEditingController();
  
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimeOfDay? missingIn;
  TimeOfDay? missingOut;

  @override
  void initState() {
    super.initState();
    controller.fetchMyRequests();
  }

  Future<void> _submit(TabController tabController) async {
    if (reasonCtrl.text.trim().isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập lý do giải trình", 
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent);
      return;
    }

    String targetDateStr = DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedDate);

    String? formatDateTime(DateTime date, TimeOfDay? time) {
      if (time == null) return null;
      final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
      return DateFormat('yyyy-MM-ddTHH:mm:ss').format(dt);
    }

    final success = await controller.submitExplanation(
      targetDateStr,
      reasonCtrl.text.trim(),
      missingIn: formatDateTime(selectedDate, missingIn),
      missingOut: formatDateTime(selectedDate, missingOut),
    );
    
    if (success) {
      reasonCtrl.clear();
      setState(() {
        missingIn = null;
        missingOut = null;
      });
      tabController.animateTo(1); // Chuyển sang Tab Lịch sử
    }
  }

  @override
  void dispose() {
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
              title: const Text("Giải trình công"),
              bottom: const TabBar(
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Giải trình chấm công"),
                  Tab(text: "Lịch sử giải trình"),
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
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Chọn ngày cần giải trình", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 24),
              const Text("Bổ sung giờ thiếu (nếu có)", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: _buildTimePicker("Giờ vào", missingIn, (t) => setState(() => missingIn = t))),
                  const SizedBox(width: 16),
                  Expanded(child: _buildTimePicker("Giờ ra", missingOut, (t) => setState(() => missingOut = t))),
                ],
              ),
              const SizedBox(height: 24),
              const Text("Lý do giải trình", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: "Ví dụ: Quên check-in do vội họp, mất kết nối WiFi..."),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => _submit(tabController),
                  child: const Text("GỬI GIẢI TRÌNH"),
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
                Icon(LucideIcons.fileQuestion, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                const SizedBox(height: 16),
                Text("Chưa có đơn giải trình nào", 
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
            return _buildExplanationCard(context, item);
          },
        );
      }),
    );
  }

  Widget _buildExplanationCard(BuildContext context, AttendanceExplanationResponse item) {
    final targetDateStr = item.targetDate != null ? DateFormat('dd/MM/yyyy').format(item.targetDate!) : "";
    final inStr = item.missingCheckInTime != null ? DateFormat('HH:mm').format(item.missingCheckInTime!) : null;
    final outStr = item.missingCheckOutTime != null ? DateFormat('HH:mm').format(item.missingCheckOutTime!) : null;

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
              Text("Giải trình ngày $targetDateStr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              _buildStatusChip(item.status),
            ],
          ),
          if (inStr != null || outStr != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(LucideIcons.clock, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  "Bổ sung: ${inStr != null ? "Vào: $inStr" : ""} ${outStr != null ? "Ra: $outStr" : ""}",
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
          if (item.explanationReason != null && item.explanationReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Lý do: ${item.explanationReason}", style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
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
                label: const Text("Hủy đơn", style: TextStyle(color: Colors.red, fontSize: 12)),
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now(),
        );
        if (d != null) setState(() => selectedDate = d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd/MM/yyyy').format(selectedDate)),
            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay) onPick) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(context: context, initialTime: time ?? TimeOfDay.now());
        if (t != null) onPick(t);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
            const SizedBox(height: 4),
            Text(time?.format(context) ?? "--:--", style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
