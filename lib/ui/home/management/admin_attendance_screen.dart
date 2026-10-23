import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/admin_dashboard_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/admin_models.dart';
import '../../../repositories/admin_repository.dart';

class AdminAttendanceScreen extends StatefulWidget {
  const AdminAttendanceScreen({super.key});

  @override
  State<AdminAttendanceScreen> createState() => _AdminAttendanceScreenState();
}

class _AdminAttendanceScreenState extends State<AdminAttendanceScreen> {
  final AdminRepository _adminRepo = AdminRepository();
  final AdminDashboardController dashController = Get.find<AdminDashboardController>();

  var attendanceList = <AdminAttendanceDto>[].obs;
  var isLoading = false.obs;
  int? selectedBranchId;
  String? selectedStatus;
  DateTime fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime toDate = DateTime.now();

  final dateFmt = DateFormat('dd/MM/yyyy');
  final timeFmt = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    selectedBranchId = dashController.selectedBranchId.value;
    fetchAttendance();
  }

  Future<void> fetchAttendance() async {
    isLoading.value = true;
    try {
      final paged = await _adminRepo.getAttendanceList(
        branchId: selectedBranchId,
        status: selectedStatus,
        from: fromDate,
        to: toDate,
        page: 1,
        pageSize: 50,
      );
      attendanceList.assignAll(paged.list);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải danh sách chấm công");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Quản lý & Điều chỉnh Chấm công"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: fetchAttendance,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: Obx(() {
              if (isLoading.value && attendanceList.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (attendanceList.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.calendarX, size: 64, color: Theme.of(context).disabledColor),
                      const SizedBox(height: 16),
                      const Text("Không có dữ liệu chấm công phù hợp"),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: fetchAttendance,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: attendanceList.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = attendanceList[index];
                    return _buildAttendanceCard(item);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<int>(
                  value: selectedBranchId,
                  decoration: const InputDecoration(labelText: "Chi nhánh", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: [
                    const DropdownMenuItem<int>(value: null, child: Text("Tất cả chi nhánh")),
                    ...dashController.branches.map((b) => DropdownMenuItem(value: b.id, child: Text(b.name ?? ""))),
                  ],
                  onChanged: (val) {
                    setState(() => selectedBranchId = val);
                    fetchAttendance();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedStatus,
                  decoration: const InputDecoration(labelText: "Trạng thái", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
                  items: const [
                    DropdownMenuItem(value: null, child: Text("Tất cả")),
                    DropdownMenuItem(value: "PRESENT", child: Text("Có mặt")),
                    DropdownMenuItem(value: "LATE", child: Text("Đi trễ")),
                    DropdownMenuItem(value: "EARLY_LEAVE", child: Text("Về sớm")),
                    DropdownMenuItem(value: "ABSENT", child: Text("Vắng mặt")),
                  ],
                  onChanged: (val) {
                    setState(() => selectedStatus = val);
                    fetchAttendance();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: _selectDateRange,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).dividerColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(LucideIcons.calendar, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text("Thời gian: ${dateFmt.format(fromDate)} - ${dateFmt.format(toDate)}"),
                  const Spacer(),
                  const Icon(LucideIcons.chevronDown, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AdminAttendanceDto item) {
    final checkInStr = item.checkInTime != null ? timeFmt.format(item.checkInTime!) : "--:--";
    final checkOutStr = item.checkOutTime != null ? timeFmt.format(item.checkOutTime!) : "--:--";
    final workDateStr = dateFmt.format(item.workDate);

    bool isLate = item.lateMinutes > 0;
    bool isEarly = item.earlyLeaveMinutes > 0;

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
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      "Mã NV: ${item.employeeCode ?? 'N/A'} • ${item.branchName ?? ''}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Text(
                workDateStr,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _timeCol("Vào", checkInStr, isLate ? Colors.red : Colors.green),
              _timeCol("Ra", checkOutStr, isEarly ? Colors.orange : Colors.blue),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (isLate) Text("Trễ: ${item.lateMinutes}p", style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                  if (isEarly) Text("Về sớm: ${item.earlyLeaveMinutes}p", style: const TextStyle(color: Colors.orange, fontSize: 11, fontWeight: FontWeight.bold)),
                  if (!isLate && !isEarly) const Text("Chuẩn giờ", style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          if (item.note != null && item.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text("Ghi chú: ${item.note}", style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showAdjustModal(item),
              icon: const Icon(LucideIcons.edit3, size: 16),
              label: const Text("Điều chỉnh giờ chấm công"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _timeCol(String label, String time, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(height: 2),
        Text(time, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: color)),
      ],
    );
  }

  void _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2023),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      initialDateRange: DateTimeRange(start: fromDate, end: toDate),
    );
    if (picked != null) {
      setState(() {
        fromDate = picked.start;
        toDate = picked.end;
      });
      fetchAttendance();
    }
  }

  void _showAdjustModal(AdminAttendanceDto item) {
    if (item.attendanceId == null) {
      Get.snackbar("Lỗi", "Bản ghi chấm công không có ID hợp lệ");
      return;
    }

    DateTime checkIn = item.checkInTime ?? item.workDate;
    DateTime checkOut = item.checkOutTime ?? item.workDate.add(const Duration(hours: 9));
    final reasonCtrl = TextEditingController();

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
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
                  Text("Điều chỉnh giờ chấm công", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("Nhân viên: ${item.employeeName} (${dateFmt.format(item.workDate)})", style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Giờ Check-in mới"),
                    subtitle: Text("${dateFmt.format(checkIn)} ${timeFmt.format(checkIn)}"),
                    trailing: const Icon(LucideIcons.clock),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(checkIn),
                      );
                      if (t != null) {
                        setModalState(() {
                          checkIn = DateTime(checkIn.year, checkIn.month, checkIn.day, t.hour, t.minute);
                        });
                      }
                    },
                  ),
                  const Divider(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text("Giờ Check-out mới"),
                    subtitle: Text("${dateFmt.format(checkOut)} ${timeFmt.format(checkOut)}"),
                    trailing: const Icon(LucideIcons.clock),
                    onTap: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(checkOut),
                      );
                      if (t != null) {
                        setModalState(() {
                          checkOut = DateTime(checkOut.year, checkOut.month, checkOut.day, t.hour, t.minute);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(
                      labelText: "Lý do điều chỉnh (Bắt buộc)",
                      hintText: "Nhập lý do điều chỉnh giờ công...",
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (reasonCtrl.text.trim().isEmpty) {
                          Get.snackbar("Lỗi", "Vui lòng nhập lý do điều chỉnh");
                          return;
                        }
                        Get.back();
                        try {
                          await _adminRepo.adjustAttendance(
                            attendanceId: item.attendanceId!,
                            checkInTime: checkIn,
                            checkOutTime: checkOut,
                            reason: reasonCtrl.text.trim(),
                          );
                          Get.snackbar("Thành công", "Đã điều chỉnh giờ chấm công");
                          fetchAttendance();
                        } catch (e) {
                          Get.snackbar("Lỗi", "Không thể điều chỉnh giờ chấm công");
                        }
                      },
                      child: const Text("XÁC NHẬN ĐIỀU CHỈNH"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
