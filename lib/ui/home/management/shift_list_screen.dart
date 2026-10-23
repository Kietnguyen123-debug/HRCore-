import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/shift_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/shift_models.dart';

class ShiftListScreen extends StatefulWidget {
  const ShiftListScreen({super.key});

  @override
  State<ShiftListScreen> createState() => _ShiftListScreenState();
}

class _ShiftListScreenState extends State<ShiftListScreen> {
  final ShiftController controller = Get.put(ShiftController());

  @override
  void initState() {
    super.initState();
    controller.fetchAllShifts();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    return "$hours:$minutes";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Quản lý ca làm việc"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => controller.fetchAllShifts(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.shifts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.shifts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.clock, size: 64, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                const Text("Chưa có ca làm việc nào"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAllShifts,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.shifts.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final shift = controller.shifts[index];
              final startStr = _formatDuration(shift.startTime);
              final endStr = _formatDuration(shift.endTime);

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.clock, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shift.shiftName ?? "N/A",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Mã: ${shift.shiftCode ?? ''} • $startStr - $endStr",
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.edit, color: Colors.blue, size: 20),
                      onPressed: () => _showShiftDialog(context, controller, shift: shift),
                    ),
                    if (shift.id != null)
                      IconButton(
                        icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                        onPressed: () => _confirmDelete(shift.id!, controller),
                      ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showShiftDialog(context, controller),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(int id, ShiftController controller) {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText: "Bạn có chắc muốn xóa ca làm việc này?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deleteShift(id);
      },
    );
  }

  void _showShiftDialog(BuildContext context, ShiftController controller, {ShiftDto? shift}) {
    final isEdit = shift != null;
    final codeCtrl = TextEditingController(text: shift?.shiftCode);
    final nameCtrl = TextEditingController(text: shift?.shiftName);
    final startCtrl = TextEditingController(
      text: shift != null ? _formatDuration(shift.startTime) : "08:00",
    );
    final endCtrl = TextEditingController(
      text: shift != null ? _formatDuration(shift.endTime) : "17:00",
    );

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Cập nhật ca làm việc" : "Tạo ca làm việc mới",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Mã ca (VD: CA1)")),
              const SizedBox(height: 12),
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên ca (VD: Ca sáng)")),
              const SizedBox(height: 12),
              TextField(controller: startCtrl, decoration: const InputDecoration(labelText: "Bắt đầu (HH:mm)")),
              const SizedBox(height: 12),
              TextField(controller: endCtrl, decoration: const InputDecoration(labelText: "Kết thúc (HH:mm)")),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (codeCtrl.text.trim().isEmpty || nameCtrl.text.trim().isEmpty) {
                      Get.snackbar("Lỗi", "Vui lòng nhập đầy đủ Mã ca và Tên ca");
                      return;
                    }
                    Get.back();
                    if (isEdit && shift.id != null) {
                      await controller.updateShift(
                        shift.id!,
                        codeCtrl.text.trim(),
                        nameCtrl.text.trim(),
                        startCtrl.text.trim(),
                        endCtrl.text.trim(),
                      );
                    } else {
                      await controller.createShift(
                        codeCtrl.text.trim(),
                        nameCtrl.text.trim(),
                        startCtrl.text.trim(),
                        endCtrl.text.trim(),
                      );
                    }
                  },
                  child: Text(isEdit ? "Cập nhật" : "Tạo mới"),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
