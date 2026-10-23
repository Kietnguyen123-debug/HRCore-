import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../controllers/payroll_controller.dart';
import '../../core/app_colors.dart';
import '../../models/payroll_model.dart';

class PayslipScreen extends StatefulWidget {
  const PayslipScreen({super.key});

  @override
  State<PayslipScreen> createState() => _PayslipScreenState();
}

class _PayslipScreenState extends State<PayslipScreen> {
  final PayrollController controller = Get.put(PayrollController());
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    controller.fetchMyPayslip(selectedMonth, selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Phiếu lương cá nhân")),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
              final Payslip? data = controller.payslip.value;
              
              if (data == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.money_off, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text("Không có dữ liệu lương tháng $selectedMonth/$selectedYear",
                          style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => controller.fetchMyPayslip(selectedMonth, selectedYear),
                        child: const Text("Thử lại"),
                      )
                    ],
                  ),
                );
              }
              return _buildPayslipContent(data);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selectedMonth,
              decoration: const InputDecoration(labelText: "Tháng", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("Tháng ${i + 1}"))),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedMonth = val);
                  controller.fetchMyPayslip(selectedMonth, selectedYear);
                }
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selectedYear,
              decoration: const InputDecoration(labelText: "Năm", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              items: List.generate(5, (i) => DropdownMenuItem(value: 2023 + i, child: Text("${2023 + i}"))),
              onChanged: (val) {
                if (val != null) {
                  setState(() => selectedYear = val);
                  controller.fetchMyPayslip(selectedMonth, selectedYear);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayslipContent(Payslip data) {
    final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSummaryCard(data.netSalary, currencyFormat),
          const SizedBox(height: 24),
          _buildDetailTile("Họ và tên", data.fullName, isText: true),
          _buildDetailTile("Lương cơ bản", currencyFormat.format(data.baseSalary)),
          _buildDetailTile("Phụ cấp", currencyFormat.format(data.allowance)),
          _buildDetailTile("Số ngày công thực tế", "${data.actualWorkDays} ngày"),
          const Divider(height: 32),
          _buildDetailTile("Tổng số phút đi trễ", "${data.totalLateMinutes} phút", isNegative: true),
          _buildDetailTile("Tiền phạt khấu trừ", currencyFormat.format(data.totalPenalty), isNegative: true),
          const Divider(height: 40),
          _buildDetailTile("THỰC NHẬN", currencyFormat.format(data.netSalary), isBold: true, color: AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(double amount, NumberFormat format) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          const Text("Tổng thu nhập thực nhận", style: TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(height: 8),
          Text(format.format(amount),
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildDetailTile(String label, String value, {bool isNegative = false, bool isBold = false, bool isText = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, fontWeight: isBold ? FontWeight.bold : FontWeight.w500, color: Theme.of(context).textTheme.bodySmall?.color)),
          Text(
            "${isNegative && value != "0" && !isText ? '-' : ''}$value",
            style: TextStyle(
              fontSize: 15,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: color ?? (isNegative && value != "0" ? Colors.red : Theme.of(context).textTheme.bodyLarge?.color),
            ),
          ),
        ],
      ),
    );
  }
}
