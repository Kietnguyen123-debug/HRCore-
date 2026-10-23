import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/shift_controller.dart';
import '../../../data/network/models/shift_models.dart';

class AssignShiftScreen extends StatefulWidget {
  final int employeeId;
  final String employeeName;
  const AssignShiftScreen({super.key, required this.employeeId, required this.employeeName});

  @override
  State<AssignShiftScreen> createState() => _AssignShiftScreenState();
}

class _AssignShiftScreenState extends State<AssignShiftScreen> {
  late final ShiftController controller;
  int? selectedShiftId;
  DateTime fromDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ShiftController>() ? Get.find<ShiftController>() : Get.put(ShiftController());
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
      appBar: AppBar(title: const Text("Gán ca làm việc")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Nhân viên: ${widget.employeeName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 24),
            Obx(() {
              final shifts = controller.shifts;
              int? validShiftValue = shifts.any((s) => s.id == selectedShiftId) ? selectedShiftId : null;

              return DropdownButtonFormField<int>(
                value: validShiftValue,
                decoration: const InputDecoration(labelText: "Chọn ca làm việc"),
                items: shifts.map((ShiftDto s) {
                  final start = _formatDuration(s.startTime);
                  final end = _formatDuration(s.endTime);
                  return DropdownMenuItem<int>(
                    value: s.id,
                    child: Text("${s.shiftName ?? 'Ca'} ($start - $end)"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedShiftId = val),
              );
            }),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Ngày hiệu lực"),
              subtitle: Text(DateFormat('dd/MM/yyyy').format(fromDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: fromDate,
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (d != null) setState(() => fromDate = d);
              },
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (selectedShiftId != null) {
                    await controller.assignToEmployee(
                      widget.employeeId,
                      selectedShiftId!,
                      fromDate,
                    );
                    Get.back();
                  } else {
                    Get.snackbar("Lỗi", "Vui lòng chọn ca làm việc");
                  }
                },
                child: const Text("XÁC NHẬN GÁN CA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
