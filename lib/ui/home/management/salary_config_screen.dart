import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appdiemdanh/controllers/payroll_controller.dart';
import 'package:appdiemdanh/repositories/system_admin_repository.dart';
import '../../../core/app_colors.dart';

class SalaryConfigScreen extends StatefulWidget {
  final int employeeId;
  const SalaryConfigScreen({super.key, required this.employeeId});

  @override
  State<SalaryConfigScreen> createState() => _SalaryConfigScreenState();
}

class _SalaryConfigScreenState extends State<SalaryConfigScreen> {
  final PayrollController controller = Get.isRegistered<PayrollController>() ? Get.find<PayrollController>() : Get.put(PayrollController());
  final SystemAdminRepository _adminRepo = SystemAdminRepository();

  final baseCtrl = TextEditingController();
  final allowanceCtrl = TextEditingController();
  final penaltyCtrl = TextEditingController();
  final dependentsCtrl = TextEditingController(text: "0");
  final insuranceCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final bankAccNoCtrl = TextEditingController();
  final bankAccHolderCtrl = TextEditingController();

  bool isLoading = true;
  String? employeeName;

  @override
  void initState() {
    super.initState();
    _loadEmployeeData();
  }

  Future<void> _loadEmployeeData() async {
    setState(() => isLoading = true);
    try {
      final detail = await _adminRepo.getEmployeeById(widget.employeeId);
      employeeName = detail.fullName;
      baseCtrl.text = detail.baseSalary.toStringAsFixed(0);
      allowanceCtrl.text = detail.allowance.toStringAsFixed(0);
      penaltyCtrl.text = detail.penaltyPerLateMinute.toStringAsFixed(0);
      dependentsCtrl.text = detail.dependentCount.toString();
      if (detail.socialInsuranceBase != null) {
        insuranceCtrl.text = detail.socialInsuranceBase!.toStringAsFixed(0);
      }
    } catch (e) {
      Get.snackbar("Thông báo", "Chưa có dữ liệu cấu hình lương cũ, vui lòng tạo mới");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    baseCtrl.dispose();
    allowanceCtrl.dispose();
    penaltyCtrl.dispose();
    dependentsCtrl.dispose();
    insuranceCtrl.dispose();
    bankNameCtrl.dispose();
    bankAccNoCtrl.dispose();
    bankAccHolderCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: Text(employeeName != null ? "Cấu hình lương • $employeeName" : "Cấu hình lương")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Mức lương & Phụ cấp", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextField(controller: baseCtrl, decoration: const InputDecoration(labelText: "Lương cơ bản (VNĐ)"), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: allowanceCtrl, decoration: const InputDecoration(labelText: "Phụ cấp cố định (VNĐ)"), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: penaltyCtrl, decoration: const InputDecoration(labelText: "Tiền phạt đi trễ (VNĐ / phút)"), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: dependentsCtrl, decoration: const InputDecoration(labelText: "Số người phụ thuộc (Giảm trừ gia cảnh)"), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: insuranceCtrl, decoration: const InputDecoration(labelText: "Mức lương đóng BHXH (Tùy chọn)"), keyboardType: TextInputType.number),
                  const SizedBox(height: 24),
                  Text("Thông tin Ngân hàng", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 12),
                  TextField(controller: bankNameCtrl, decoration: const InputDecoration(labelText: "Tên ngân hàng (VD: Vietcombank)")),
                  const SizedBox(height: 12),
                  TextField(controller: bankAccNoCtrl, decoration: const InputDecoration(labelText: "Số tài khoản ngân hàng"), keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  TextField(controller: bankAccHolderCtrl, decoration: const InputDecoration(labelText: "Tên chủ tài khoản")),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _saveConfig,
                      child: const Text("LƯU CẤU HÌNH LƯƠNG", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _saveConfig() async {
    final base = double.tryParse(baseCtrl.text) ?? 0;
    final allowance = double.tryParse(allowanceCtrl.text) ?? 0;
    final penalty = double.tryParse(penaltyCtrl.text) ?? 0;
    final dependents = int.tryParse(dependentsCtrl.text) ?? 0;
    final insurance = double.tryParse(insuranceCtrl.text);
    final bankName = bankNameCtrl.text.trim();
    final bankAccNo = bankAccNoCtrl.text.trim();
    final bankAccHolder = bankAccHolderCtrl.text.trim();

    await controller.updateSalaryConfig(
      widget.employeeId,
      base,
      allowance,
      penalty,
      dependents,
      insurance,
      bankName.isNotEmpty ? bankName : null,
      bankAccNo.isNotEmpty ? bankAccNo : null,
      bankAccHolder.isNotEmpty ? bankAccHolder : null,
    );
  }
}
