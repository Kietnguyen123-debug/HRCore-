import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/attendance_controller.dart';
import 'package:appdiemdanh/data/network/models/attendance_models.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'attendance_explanation_screen.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final AttendanceController controller = Get.find<AttendanceController>();

  DateTime fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime toDate = DateTime.now();
  String selectedFilter = "Tháng này";

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    controller.fetchMyHistory(from: fromDate, to: toDate);
  }

  void _onFilterChanged(String filter) {
    final now = DateTime.now();
    setState(() {
      selectedFilter = filter;
      if (filter == "Tháng này") {
        fromDate = DateTime(now.year, now.month, 1);
        toDate = now;
      } else if (filter == "7 ngày qua") {
        fromDate = now.subtract(const Duration(days: 7));
        toDate = now;
      } else if (filter == "30 ngày qua") {
        fromDate = now.subtract(const Duration(days: 30));
        toDate = now;
      }
    });
    _loadHistory();
  }

  Future<void> _selectCustomRange() async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
      locale: const Locale('vi', 'VN'),
      saveText: "XÁC NHẬN",
      helpText: "CHỌN KHOẢNG THỜI GIAN",
      cancelText: "HỦY",
      confirmText: "XÁC NHẬN",
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppColors.primary,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (range != null) {
      setState(() {
        selectedFilter = "Tùy chọn";
        fromDate = range.start;
        toDate = range.end;
      });
      _loadHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Lịch sử chấm công"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: _loadHistory,
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => _loadHistory(),
              child: Obx(() {
                if (controller.isHistoryLoading.value && controller.historyList.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final history = controller.historyList;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _buildSummaryCard(history),
                    const SizedBox(height: 20),
                    if (history.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                LucideIcons.calendarX2,
                                size: 64,
                                color: Theme.of(context).textTheme.bodySmall?.color,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                "Không tìm thấy dữ liệu chấm công",
                                style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...history.map((item) => _buildHistoryCard(context, item)),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final dateStr = "${DateFormat('dd/MM/yyyy').format(fromDate)} - ${DateFormat('dd/MM/yyyy').format(toDate)}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh cuộn ngang các nút thao tác chọn ngày
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _filterChip("Tháng này"),
                const SizedBox(width: 8),
                _filterChip("7 ngày qua"),
                const SizedBox(width: 8),
                _filterChip("30 ngày qua"),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _selectCustomRange,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedFilter == "Tùy chọn"
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: selectedFilter == "Tùy chọn" ? AppColors.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          LucideIcons.calendar,
                          size: 15,
                          color: selectedFilter == "Tùy chọn" ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Chọn khoảng ngày",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selectedFilter == "Tùy chọn" ? AppColors.primary : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Icon(LucideIcons.clock, size: 13, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  "Khoảng thời gian: $dateStr",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChip(String label) {
    final isSelected = selectedFilter == label;
    return InkWell(
      onTap: () => _onFilterChanged(label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(List<AttendanceItemDto> history) {
    int totalDays = history.length;
    int onTimeDays = history.where((e) => e.lateMinutes <= 0 && e.earlyLeaveMinutes <= 0 && e.checkOutTime != null).length;
    int lateMinutes = history.fold<int>(0, (sum, e) => sum + e.lateMinutes);
    int totalWorkedMins = history.fold<int>(0, (sum, e) => sum + e.workedMinutes);

    String workedHoursStr = (totalWorkedMins / 60.0).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem("Ngày công", "$totalDays ngày", AppColors.primary),
          _statItem("Đúng giờ", "$onTimeDays ngày", Colors.green),
          _statItem("Đi muộn", "$lateMinutes phút", lateMinutes > 0 ? Colors.orange : Colors.grey),
          _statItem("Tổng giờ", "${workedHoursStr}h", Colors.blue),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildHistoryCard(BuildContext context, AttendanceItemDto item) {
    final dayOfWeek = _formatDayOfWeek(item.workDate);
    final dateStr = DateFormat('dd/MM/yyyy').format(item.workDate);
    final inStr = DateFormat('HH:mm').format(item.checkInTime);
    final outStr = item.checkOutTime != null ? DateFormat('HH:mm').format(item.checkOutTime!) : "Chưa ra";

    bool isLate = item.lateMinutes > 0;
    bool isEarly = item.earlyLeaveMinutes > 0;
    bool isMissingOut = item.checkOutTime == null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    "$dayOfWeek, $dateStr",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              _buildStatusBadge(isLate, isEarly, isMissingOut),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _timeBox(
                  context,
                  "VÀO CA",
                  inStr,
                  LucideIcons.logIn,
                  isLate ? Colors.orange : Colors.green,
                  subLabel: isLate ? "Trễ ${item.lateMinutes}p" : "Đúng giờ",
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _timeBox(
                  context,
                  "TAN CA",
                  outStr,
                  LucideIcons.logOut,
                  isMissingOut ? Colors.grey : (isEarly ? Colors.orange : Colors.blue),
                  subLabel: isMissingOut ? "Chưa check-out" : (isEarly ? "Sớm ${item.earlyLeaveMinutes}p" : "Đúng giờ"),
                ),
              ),
            ],
          ),
          if (item.workedMinutes > 0 || (item.note != null && item.note!.isNotEmpty) || isLate || isEarly || isMissingOut) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (item.workedMinutes > 0)
                  Text(
                    "Thời gian làm: ${item.workedMinutes ~/ 60}h ${item.workedMinutes % 60}m",
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color),
                  )
                else
                  const SizedBox.shrink(),
                if (isLate || isEarly || isMissingOut)
                  InkWell(
                    onTap: () => Get.to(() => const AttendanceExplanationScreen()),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Row(
                        children: const [
                          Icon(LucideIcons.history, size: 13, color: AppColors.primary),
                          SizedBox(width: 4),
                          Text(
                            "Tạo giải trình",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _timeBox(
    BuildContext context,
    String label,
    String time,
    IconData icon,
    Color color, {
    required String subLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(time, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                Text(subLabel, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool isLate, bool isEarly, bool isMissingOut) {
    if (isMissingOut) {
      return _badge("Chưa check-out", Colors.orange);
    }
    if (isLate || isEarly) {
      return _badge("Cần giải trình", Colors.redAccent);
    }
    return _badge("Đúng giờ", Colors.green);
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  String _formatDayOfWeek(DateTime date) {
    switch (date.weekday) {
      case DateTime.monday:
        return "Thứ 2";
      case DateTime.tuesday:
        return "Thứ 3";
      case DateTime.wednesday:
        return "Thứ 4";
      case DateTime.thursday:
        return "Thứ 5";
      case DateTime.friday:
        return "Thứ 6";
      case DateTime.saturday:
        return "Thứ 7";
      case DateTime.sunday:
        return "Chủ Nhật";
      default:
        return "";
    }
  }
}
