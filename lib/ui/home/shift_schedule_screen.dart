import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../controllers/shift_controller.dart';
import '../../data/network/models/shift_models.dart';
import '../../core/app_colors.dart';

class ShiftScheduleScreen extends StatefulWidget {
  const ShiftScheduleScreen({super.key});

  @override
  State<ShiftScheduleScreen> createState() => _ShiftScheduleScreenState();
}

class _ShiftScheduleScreenState extends State<ShiftScheduleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ShiftController controller = Get.put(ShiftController());
  
  DateTime _currentWeekStart = _getStartOfWeek(DateTime.now());
  DateTime _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime? _selectedMonthlyDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    controller.fetchMyTodayShift();
    _loadCurrentWeek();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == 1) {
      _loadCurrentWeek();
    } else if (_tabController.index == 2) {
      _loadCurrentMonth();
    }
  }

  static DateTime _getStartOfWeek(DateTime date) {
    // Monday as start of week
    return date.subtract(Duration(days: date.weekday - 1));
  }

  void _loadCurrentWeek() {
    final DateTime start = DateTime(_currentWeekStart.year, _currentWeekStart.month, _currentWeekStart.day, 0, 0, 0);
    final DateTime end = start.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    controller.fetchMySchedule(from: start, to: end);
  }

  void _changeWeek(int step) {
    setState(() {
      _currentWeekStart = _currentWeekStart.add(Duration(days: 7 * step));
    });
    _loadCurrentWeek();
  }

  void _resetToCurrentWeek() {
    setState(() {
      _currentWeekStart = _getStartOfWeek(DateTime.now());
    });
    _loadCurrentWeek();
  }

  void _loadCurrentMonth() {
    final DateTime start = DateTime(_currentMonth.year, _currentMonth.month, 1, 0, 0, 0);
    final DateTime end = DateTime(_currentMonth.year, _currentMonth.month + 1, 0, 23, 59, 59);
    controller.fetchMySchedule(from: start, to: end);
  }

  void _changeMonth(int step) {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + step, 1);
      _selectedMonthlyDate = null;
    });
    _loadCurrentMonth();
  }

  void _resetToCurrentMonth() {
    setState(() {
      _currentMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
      _selectedMonthlyDate = null;
    });
    _loadCurrentMonth();
  }

  DateTime get _effectiveSelectedDate {
    if (_selectedMonthlyDate != null) return _selectedMonthlyDate!;
    final now = DateTime.now();
    if (_currentMonth.year == now.year && _currentMonth.month == now.month) {
      return DateTime(now.year, now.month, now.day);
    }
    return DateTime(_currentMonth.year, _currentMonth.month, 1);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Lịch làm việc", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
          unselectedLabelStyle: GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 13),
          tabs: const [
            Tab(text: "Ca hôm nay"),
            Tab(text: "Lịch tuần"),
            Tab(text: "Lịch tháng"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTodayTab(),
          _buildWeeklyTab(),
          _buildMonthlyTab(),
        ],
      ),
    );
  }

  Widget _buildTodayTab() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchMyTodayShift(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Container(
          // Đảm bảo phần chứa có chiều cao tối thiểu để SingleChildScrollView hoạt động và căn giữa chính xác
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - AppBar().preferredSize.height - kToolbarHeight - 100,
          ),
          padding: const EdgeInsets.all(24),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final assignment = controller.myTodayShift.value;
            final now = DateTime.now();
            final dateStr = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(now);

            // Kiểm tra an toàn: Nếu không có phân ca HOẶC thông tin đối tượng ca (shift) bên trong bằng null
            final bool hasNoShift = assignment == null || assignment.shift == null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hôm nay", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 14)),
                Text(dateStr, style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 24),
                if (hasNoShift)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: _buildNoShiftState("Hôm nay không có ca làm"),
                  )
                else
                  _buildShiftCard(assignment),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildWeeklyTab() {
    return Column(
      children: [
        _buildWeekNavigation(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            if (controller.mySchedule.isEmpty) {
              return RefreshIndicator(
                onRefresh: () async => _loadCurrentWeek(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: _buildNoShiftState("Không có lịch ca trong tuần này"),
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async => _loadCurrentWeek(),
              child: ListView.separated(
                padding: const EdgeInsets.all(24),
                itemCount: 7, // Monday to Sunday
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final dayDate = _currentWeekStart.add(Duration(days: index));
                  
                  // Chỉ lấy những phân ca thực sự hợp lệ và có thông tin ca
                  final dayAssignments = controller.mySchedule.where((s) {
                    if (s.shift == null) return false;
                    
                    // Chuẩn hóa ngày để so sánh (bỏ qua giờ phút giây)
                    final dateOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);
                    final effectiveFrom = DateTime(s.effectiveFromDate.year, s.effectiveFromDate.month, s.effectiveFromDate.day);
                    
                    if (dateOnly.isBefore(effectiveFrom)) return false;
                    
                    if (s.effectiveToDate != null) {
                      final effectiveTo = DateTime(s.effectiveToDate!.year, s.effectiveToDate!.month, s.effectiveToDate!.day);
                      if (dateOnly.isAfter(effectiveTo)) return false;
                    }
                    return true;
                  }).toList();

                  return _buildWeeklyDayRow(dayDate, dayAssignments);
                },
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildWeekNavigation() {
    final endOfWeek = _currentWeekStart.add(const Duration(days: 6));
    final rangeStr = "${DateFormat('dd/MM').format(_currentWeekStart)} - ${DateFormat('dd/MM').format(endOfWeek)}";
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () => _changeWeek(-1),
          ),
          Column(
            children: [
              Text(rangeStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              InkWell(
                onTap: _resetToCurrentWeek,
                child: Text("Tuần này", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: () => _changeWeek(1),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyDayRow(DateTime date, List<EmployeeShiftScheduleDto> assignments) {
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    final dayLabel = _getShortDayLabel(date.weekday);
    final dateLabel = DateFormat('dd/MM').format(date);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isToday ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text(dayLabel, style: TextStyle(fontWeight: FontWeight.bold, color: isToday ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
              Text(dateLabel, style: TextStyle(fontSize: 12, color: isToday ? Colors.white70 : Theme.of(context).textTheme.bodySmall?.color)),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: assignments.isEmpty
              ? Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text("Không có ca", style: TextStyle(color: Colors.grey.shade400, fontStyle: FontStyle.italic)),
                )
              : Column(
                  children: assignments.map((s) => _buildMiniShiftCard(s.shift!)).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildMiniShiftCard(ShiftDto shift) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 30,
            decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shift.shiftName ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("${_formatDuration(shift.startTime)} - ${_formatDuration(shift.endTime)}", 
                    style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodySmall?.color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftCard(EmployeeShiftScheduleDto assignment) {
    final shift = assignment.shift!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(LucideIcons.clock, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shift.shiftName ?? "Tên ca chưa đặt", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text("Mã ca: ${shift.shiftCode ?? '---'}", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          _buildInfoRow(LucideIcons.timer, "Giờ làm việc", "${_formatDuration(shift.startTime)} - ${_formatDuration(shift.endTime)}"),
          const SizedBox(height: 16),
          _buildInfoRow(LucideIcons.calendarRange, "Hiệu lực", _formatValidity(assignment)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).textTheme.bodySmall?.color)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
      ],
    );
  }

  Widget _buildNoShiftState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(LucideIcons.calendarX2, size: 64, color: Colors.grey.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  String _formatValidity(EmployeeShiftScheduleDto s) {
    final start = DateFormat('dd/MM/yyyy').format(s.effectiveFromDate);
    if (s.effectiveToDate == null) return "Từ $start";
    final end = DateFormat('dd/MM/yyyy').format(s.effectiveToDate!);
    return "$start - $end";
  }

  String _getShortDayLabel(int weekday) {
    switch (weekday) {
      case 1: return "T2";
      case 2: return "T3";
      case 3: return "T4";
      case 4: return "T5";
      case 5: return "T6";
      case 6: return "T7";
      case 7: return "CN";
      default: return "";
    }
  }

  Widget _buildMonthlyTab() {
    return Column(
      children: [
        _buildMonthNavigation(),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: () async => _loadCurrentMonth(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildMonthCalendarGrid(),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    _buildSelectedDayShiftDetails(),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildMonthNavigation() {
    final monthStr = "Tháng ${DateFormat('MM/yyyy').format(_currentMonth)}";

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(bottom: BorderSide(color: Theme.of(context).dividerColor.withOpacity(0.1))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(LucideIcons.chevronLeft),
            onPressed: () => _changeMonth(-1),
          ),
          Column(
            children: [
              Text(monthStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              InkWell(
                onTap: _resetToCurrentMonth,
                child: Text("Tháng này", style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(LucideIcons.chevronRight),
            onPressed: () => _changeMonth(1),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthCalendarGrid() {
    final daysOfWeek = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];
    final daysInMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final leadingOffset = firstDay.weekday - 1;
    final totalGridItems = leadingOffset + daysInMonth;

    return Column(
      children: [
        Row(
          children: daysOfWeek.map((day) {
            final isWeekend = day == "T7" || day == "CN";
            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isWeekend ? Colors.redAccent : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: totalGridItems,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            if (index < leadingOffset) {
              return const SizedBox.shrink();
            }

            final dayNumber = index - leadingOffset + 1;
            final dayDate = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
            final isToday = DateUtils.isSameDay(dayDate, DateTime.now());
            final isSelected = DateUtils.isSameDay(dayDate, _effectiveSelectedDate);

            final dayAssignments = controller.mySchedule.where((s) {
              if (s.shift == null) return false;
              final dateOnly = DateTime(dayDate.year, dayDate.month, dayDate.day);
              final effectiveFrom = DateTime(s.effectiveFromDate.year, s.effectiveFromDate.month, s.effectiveFromDate.day);
              if (dateOnly.isBefore(effectiveFrom)) return false;
              if (s.effectiveToDate != null) {
                final effectiveTo = DateTime(s.effectiveToDate!.year, s.effectiveToDate!.month, s.effectiveToDate!.day);
                if (dateOnly.isAfter(effectiveTo)) return false;
              }
              return true;
            }).toList();

            final bool hasShift = dayAssignments.isNotEmpty;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedMonthlyDate = dayDate;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary
                      : (isSelected
                          ? AppColors.primary.withOpacity(0.15)
                          : Theme.of(context).cardColor),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected && !isToday
                        ? AppColors.primary
                        : Theme.of(context).dividerColor.withOpacity(0.1),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "$dayNumber",
                      style: TextStyle(
                        fontWeight: (isToday || isSelected) ? FontWeight.bold : FontWeight.normal,
                        color: isToday
                            ? Colors.white
                            : (isSelected
                                ? AppColors.primary
                                : Theme.of(context).textTheme.bodyLarge?.color),
                        fontSize: 14,
                      ),
                    ),
                    if (hasShift) ...[
                      const SizedBox(height: 2),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isToday ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectedDayShiftDetails() {
    final targetDate = _effectiveSelectedDate;
    final dateLabel = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(targetDate);

    final dayAssignments = controller.mySchedule.where((s) {
      if (s.shift == null) return false;
      final dateOnly = DateTime(targetDate.year, targetDate.month, targetDate.day);
      final effectiveFrom = DateTime(s.effectiveFromDate.year, s.effectiveFromDate.month, s.effectiveFromDate.day);
      if (dateOnly.isBefore(effectiveFrom)) return false;
      if (s.effectiveToDate != null) {
        final effectiveTo = DateTime(s.effectiveToDate!.year, s.effectiveToDate!.month, s.effectiveToDate!.day);
        if (dateOnly.isAfter(effectiveTo)) return false;
      }
      return true;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Ca làm ngày: $dateLabel",
              style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (dayAssignments.isEmpty)
          _buildNoShiftState("Không có ca làm việc trong ngày này")
        else
          Column(
            children: dayAssignments.map((s) => _buildShiftCard(s)).toList(),
          ),
      ],
    );
  }
}
