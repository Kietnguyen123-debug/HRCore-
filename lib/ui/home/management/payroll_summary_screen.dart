import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/payroll_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import 'package:appdiemdanh/core/api_client.dart';
import '../../../data/network/models/payroll_models.dart';

class PayrollSummaryScreen extends StatefulWidget {
  const PayrollSummaryScreen({super.key});

  @override
  State<PayrollSummaryScreen> createState() => _PayrollSummaryScreenState();
}

class _PayrollSummaryScreenState extends State<PayrollSummaryScreen> {
  final PayrollController controller = Get.put(PayrollController());
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    controller.fetchMonthlySummary(selectedMonth, selectedYear);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Tổng hợp lương tháng"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.checkSquare, size: 20),
            onPressed: _showFinalizeDialog,
            tooltip: "Chốt lương tháng",
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.monthlySummary.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              final list = controller.monthlySummary;
              if (list.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.banknote, size: 64, color: Theme.of(context).disabledColor),
                      const SizedBox(height: 16),
                      Text("Không có dữ liệu lương tháng $selectedMonth/$selectedYear"),
                    ],
                  ),
                );
              }

              double totalPayroll = list.fold(0, (sum, p) => sum + p.netSalary);

              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("Tổng quỹ lương (${list.length} NV):", style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(
                          currencyFmt.format(totalPayroll),
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text("Mã NV")),
                            DataColumn(label: Text("Họ tên")),
                            DataColumn(label: Text("Lương CB")),
                            DataColumn(label: Text("Phụ cấp")),
                            DataColumn(label: Text("Phạt")),
                            DataColumn(label: Text("Thực nhận")),
                          ],
                          rows: list.map((PayslipResponse item) {
                            return DataRow(cells: [
                              DataCell(Text(item.employeeCode.isNotEmpty ? item.employeeCode : "${item.employeeId}")),
                              DataCell(Text(item.fullName.isNotEmpty ? item.fullName : "N/A", style: const TextStyle(fontWeight: FontWeight.w600))),
                              DataCell(Text(currencyFmt.format(item.baseSalary))),
                              DataCell(Text(currencyFmt.format(item.allowance))),
                              DataCell(Text(currencyFmt.format(item.totalPenalty), style: const TextStyle(color: Colors.red))),
                              DataCell(Text(
                                currencyFmt.format(item.netSalary),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
                              )),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              value: selectedMonth,
              decoration: const InputDecoration(labelText: "Tháng", contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              items: List.generate(12, (i) => DropdownMenuItem(value: i + 1, child: Text("Tháng ${i + 1}"))),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedMonth = val;
                  });
                  controller.fetchMonthlySummary(selectedMonth, selectedYear);
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
                  setState(() {
                    selectedYear = val;
                  });
                  controller.fetchMonthlySummary(selectedMonth, selectedYear);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showFinalizeDialog() {
    Get.defaultDialog(
      title: "Chốt sổ lương",
      middleText: "Bạn có chắc chắn muốn chốt lương cho tháng $selectedMonth/$selectedYear? Sau khi chốt, dữ liệu sẽ không thể chỉnh sửa.",
      textConfirm: "Chốt lương",
      textCancel: "Hủy",
      onConfirm: () async {
        try {
          final api = ApiClient();
          await api.finalizePayroll(selectedMonth, selectedYear, 26);
          Get.back();
          Get.snackbar("Thành công", "Đã chốt sổ lương thành công!");
        } catch (e) {
          Get.snackbar("Lỗi", "Không thể chốt sổ lương");
        }
      },
    );
  }
}
