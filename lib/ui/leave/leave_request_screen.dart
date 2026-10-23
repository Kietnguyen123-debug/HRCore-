import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'package:appdiemdanh/controllers/leave_controller.dart';
import 'package:appdiemdanh/data/network/models/leave_models.dart';
import 'package:appdiemdanh/core/app_colors.dart';

class LeaveRequestScreen extends StatefulWidget {
  const LeaveRequestScreen({super.key});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  final LeaveController controller = Get.put(LeaveController());
  final reasonCtrl = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String leaveTypeLabel = "Nghỉ phép năm";

  @override
  void initState() {
    super.initState();
    controller.fetchMyRequests();
    controller.fetchBalance();
  }

  Future<void> _submit(TabController tabController) async {
    if (startDate == null || endDate == null || reasonCtrl.text.trim().isEmpty) {
      Get.snackbar("Thông báo", "Vui lòng nhập đầy đủ thông tin và lý do", 
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent);
      return;
    }

    if (endDate!.isBefore(startDate!)) {
      Get.snackbar("Lỗi", "Ngày kết thúc không thể trước ngày bắt đầu", 
        snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    String mappedType = CreateLeaveRequest.typeAnnual;
    if (leaveTypeLabel == "Nghỉ ốm") mappedType = CreateLeaveRequest.typeSick;
    if (leaveTypeLabel == "Nghỉ không lương") mappedType = CreateLeaveRequest.typeUnpaid;
    if (leaveTypeLabel == "Nghỉ thai sản") mappedType = CreateLeaveRequest.typeMaternity;

    final success = await controller.createRequest(
      startDate: startDate!,
      endDate: endDate!,
      leaveType: mappedType,
      reason: reasonCtrl.text.trim(),
    );
    
    if (success) {
      reasonCtrl.clear();
      setState(() {
        startDate = null;
        endDate = null;
      });
      tabController.animateTo(1); // Tự động chuyển qua tab Lịch sử
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
              title: const Text("Nghỉ phép"),
              bottom: const TabBar(
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Tạo đơn xin nghỉ"),
                  Tab(text: "Lịch sử đơn nghỉ"),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildCreateForm(context, tabController),
                _buildHistoryList(context),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCreateForm(BuildContext context, TabController tabController) {
    return Obx(() => Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Thông tin nghỉ phép"),
              const SizedBox(height: 16),
              _buildDropdown(),
              const SizedBox(height: 20),
              _buildDatePicker("Từ ngày", startDate, (d) => setState(() => startDate = d)),
              const SizedBox(height: 16),
              _buildDatePicker("Đến ngày", endDate, (d) => setState(() => endDate = d)),
              const SizedBox(height: 20),
              _buildSectionHeader("Lý do nghỉ"),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 4,
                decoration: const InputDecoration(hintText: "Nhập lý do chi tiết..."),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => _submit(tabController),
                  child: const Text("GỬI ĐƠN XIN NGHỈ"),
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

  Widget _buildHistoryList(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        await controller.fetchMyRequests();
        await controller.fetchBalance();
      },
      child: Obx(() {
        if (controller.isLoading.value && controller.myRequests.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = controller.myRequests;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (controller.balance.value != null) _buildBalanceCard(context, controller.balance.value!),
            const SizedBox(height: 16),
            if (requests.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(LucideIcons.calendarX2, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                      const SizedBox(height: 16),
                      Text("Chưa có đơn xin nghỉ phép nào", 
                        style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color)),
                    ],
                  ),
                ),
              )
            else
              ...requests.map((item) => _buildLeaveCard(context, item)),
          ],
        );
      }),
    );
  }

  Widget _buildBalanceCard(BuildContext context, LeaveBalanceDto bal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _balanceInfo("Tổng số ngày", "${bal.totalAnnualLeave} ngày", Colors.blue),
          _balanceInfo("Đã nghỉ", "${bal.usedAnnualLeave} ngày", Colors.orange),
          _balanceInfo("Còn lại", "${bal.remainingAnnualLeave} ngày", Colors.green),
        ],
      ),
    );
  }

  Widget _balanceInfo(String title, String val, Color color) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildLeaveCard(BuildContext context, EmployeeLeaveDto item) {
    final startStr = DateFormat('dd/MM/yyyy').format(item.startDate);
    final endStr = DateFormat('dd/MM/yyyy').format(item.endDate);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
              Text(_getLeaveTypeTitle(item.leaveType), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              _buildStatusChip(item.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("$startStr - $endStr", style: const TextStyle(fontSize: 13)),
            ],
          ),
          if (item.reason != null && item.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Lý do: ${item.reason}", style: TextStyle(fontSize: 13, color: Theme.of(context).textTheme.bodySmall?.color)),
          ],
          if (item.rejectReason != null && item.rejectReason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Lý do từ chối: ${item.rejectReason}", style: const TextStyle(fontSize: 13, color: Colors.redAccent)),
          ],
          if ((item.status ?? '').toUpperCase() == 'PENDING') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => controller.cancelRequest(item.id),
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

  String _getLeaveTypeTitle(String? type) {
    final t = (type ?? '').toUpperCase();
    if (t == 'ANNUAL') return "Nghỉ phép năm";
    if (t == 'SICK') return "Nghỉ ốm";
    if (t == 'UNPAID') return "Nghỉ không lương";
    if (t == 'MATERNITY') return "Nghỉ thai sản";
    return type ?? "Nghỉ phép";
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

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15));
  }

  Widget _buildDropdown() {
    return DropdownButtonFormField<String>(
      value: leaveTypeLabel,
      decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 16)),
      items: ["Nghỉ phép năm", "Nghỉ ốm", "Nghỉ không lương", "Nghỉ thai sản"]
          .map((t) => DropdownMenuItem(value: t, child: Text(t)))
          .toList(),
      onChanged: (val) {
        if (val != null) setState(() => leaveTypeLabel = val);
      },
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, Function(DateTime) onPick) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now().subtract(const Duration(days: 1)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (d != null) onPick(d);
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
            Text(date == null ? label : DateFormat('dd/MM/yyyy').format(date),
                style: TextStyle(color: date == null ? Theme.of(context).textTheme.bodySmall?.color : Theme.of(context).textTheme.bodyLarge?.color)),
            const Icon(LucideIcons.calendar, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
