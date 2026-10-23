import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/overtime_controller.dart';
import 'package:appdiemdanh/data/network/models/overtime_models.dart';
import '../../core/app_colors.dart';

class OvertimeRequestScreen extends StatefulWidget {
  const OvertimeRequestScreen({super.key});

  @override
  State<OvertimeRequestScreen> createState() => _OvertimeRequestScreenState();
}

class _OvertimeRequestScreenState extends State<OvertimeRequestScreen> {
  final OvertimeController controller = Get.put(OvertimeController());
  
  DateTime selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  TimeOfDay? startTime;
  TimeOfDay? endTime;
  
  static const List<Map<String, dynamic>> _dayTypes = [
    {'label': 'Ngày làm việc bình thường', 'multiplier': 1.5},
    {'label': 'Ngày nghỉ hàng tuần (Thứ 7/CN)', 'multiplier': 2.0},
    {'label': 'Ngày Lễ, Tết có hưởng lương', 'multiplier': 3.0},
  ];

  late Map<String, dynamic> _selectedDayType;

  @override
  void initState() {
    super.initState();
    _selectedDayType = _dayTypes[0];
    controller.fetchMyRequests();
  }

  double _calculateHours() {
    if (startTime == null || endTime == null) return 0.0;

    final double startDecimal = startTime!.hour + (startTime!.minute / 60.0);
    final double endDecimal = endTime!.hour + (endTime!.minute / 60.0);

    double diff = endDecimal - startDecimal;
    if (diff < 0) {
      diff += 24.0;
    }
    return (diff * 2).round() / 2;
  }

  Future<void> _submit(TabController tabController) async {
    if (startTime == null || endTime == null) {
      Get.snackbar("Thông báo", "Vui lòng chọn đầy đủ giờ bắt đầu và kết thúc",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orangeAccent);
      return;
    }

    final double finalHours = _calculateHours();
    if (finalHours <= 0) {
      Get.snackbar("Lỗi", "Thời gian tăng ca không hợp lệ",
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    final double finalMultiplier = (_selectedDayType['multiplier'] as num).toDouble();

    final success = await controller.submitRequest(
      DateFormat('yyyy-MM-ddTHH:mm:ss').format(selectedDate),
      finalHours,
      finalMultiplier,
    );
    
    if (success) {
      setState(() {
        startTime = null;
        endTime = null;
      });
      tabController.animateTo(1); // Chuyển sang Tab Lịch sử
    }
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
              title: const Text("Tăng ca"),
              bottom: const TabBar(
                indicatorColor: AppColors.primary,
                labelStyle: TextStyle(fontWeight: FontWeight.bold),
                tabs: [
                  Tab(text: "Đăng ký tăng ca"),
                  Tab(text: "Lịch sử tăng ca"),
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
    final double calculatedHours = _calculateHours();

    return Obx(() => Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Ngày làm tăng ca", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 24),
              const Text("Khoảng thời gian", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      "Giờ bắt đầu", 
                      startTime, 
                      (t) => setState(() => startTime = t)
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTimePicker(
                      "Giờ kết thúc", 
                      endTime, 
                      (t) => setState(() => endTime = t)
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text("Chọn loại ngày làm tăng ca", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              _buildDayTypeSelector(),
              const Spacer(),
              if (startTime != null && endTime != null)
                _buildSummaryInfo(calculatedHours),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value ? null : () => _submit(tabController),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("GỬI YÊU CẦU TĂNG CA", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
        if (controller.isLoading.value)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
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
                Icon(LucideIcons.timerReset, size: 64, color: Theme.of(context).textTheme.bodySmall?.color),
                const SizedBox(height: 16),
                Text("Chưa có yêu cầu tăng ca nào", 
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
            return _buildOvertimeCard(context, item);
          },
        );
      }),
    );
  }

  Widget _buildOvertimeCard(BuildContext context, EmployeeOvertimeDto item) {
    final dateStr = DateFormat('dd/MM/yyyy').format(item.workDate);

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
              Text("Tăng ca ngày $dateStr", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              _buildStatusChip(item.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(LucideIcons.clock, size: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text("Thời gian: ${item.hours} giờ  |  Hệ số: x${item.multiplier}", style: const TextStyle(fontSize: 13)),
            ],
          ),
          if ((item.status ?? '').toUpperCase() == 'PENDING' || (item.status ?? '').toLowerCase() == 'pending') ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => controller.cancelRequest(item.id),
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

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 30)),
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
            Text(DateFormat('dd/MM/yyyy').format(selectedDate), style: const TextStyle(fontSize: 16)),
            const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePicker(String label, TimeOfDay? time, Function(TimeOfDay) onPick) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context, 
          initialTime: time ?? const TimeOfDay(hour: 18, minute: 0)
        );
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
            Text(
              time?.format(context) ?? "--:--", 
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayTypeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedDayType,
          isExpanded: true,
          dropdownColor: Theme.of(context).cardColor,
          items: _dayTypes.map((type) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: type,
              child: Text(type['label'], style: const TextStyle(fontSize: 15)),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedDayType = val);
          },
        ),
      ),
    );
  }

  Widget _buildSummaryInfo(double calculatedHours) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.timer_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Tổng thời gian: ${calculatedHours.toStringAsFixed(2)} giờ",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Hệ số lương áp dụng: x${_selectedDayType['multiplier']}",
                  style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
