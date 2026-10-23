import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/payroll_models.dart';
import '../../../repositories/payroll_repository.dart';

class PayrollPolicyScreen extends StatefulWidget {
  const PayrollPolicyScreen({super.key});

  @override
  State<PayrollPolicyScreen> createState() => _PayrollPolicyScreenState();
}

class _PayrollPolicyScreenState extends State<PayrollPolicyScreen> {
  final PayrollRepository _repository = PayrollRepository();
  bool isLoading = false;

  // Tab 1: Tax & Insurance Policy
  final personalDeductionCtrl = TextEditingController(text: "11000000");
  final dependentDeductionCtrl = TextEditingController(text: "4400000");
  final refInsuranceSalaryCtrl = TextEditingController(text: "5000000");
  final insuranceCeilingCtrl = TextEditingController(text: "36000000");
  final empSocialRateCtrl = TextEditingController(text: "0.08");
  final empHealthRateCtrl = TextEditingController(text: "0.015");
  final empUnempRateCtrl = TextEditingController(text: "0.01");
  final erSocialRateCtrl = TextEditingController(text: "0.175");
  final erHealthRateCtrl = TextEditingController(text: "0.03");
  final erUnempRateCtrl = TextEditingController(text: "0.01");
  final mealExemptCtrl = TextEditingController(text: "730000");
  final sourceRefCtrl = TextEditingController(text: "Nghị định 73/2024/NĐ-CP");
  final changeReasonCtrl = TextEditingController(text: "Cập nhật chính sách công ty");

  // Tab 2: Late Penalty Policy
  final penaltyNameCtrl = TextEditingController(text: "Quy định Phạt đi trễ");
  int penaltyType = 1; // 1 = Fixed, 2 = Ranges
  final amountPerMinuteCtrl = TextEditingController(text: "5000");
  bool isPenaltyActive = true;
  List<LatePenaltyRangeRequest> penaltyRanges = [
    const LatePenaltyRangeRequest(fromMinute: 1, toMinute: 15, penaltyAmount: 50000),
    const LatePenaltyRangeRequest(fromMinute: 16, toMinute: 30, penaltyAmount: 100000),
    const LatePenaltyRangeRequest(fromMinute: 31, toMinute: 60, penaltyAmount: 200000),
  ];

  final currencyFmt = NumberFormat.currency(locale: 'vi_VN', symbol: '₫', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final policy = await _repository.getActivePayrollPolicy();
      personalDeductionCtrl.text = policy.personalDeduction.toStringAsFixed(0);
      dependentDeductionCtrl.text = policy.dependentDeduction.toStringAsFixed(0);
      refInsuranceSalaryCtrl.text = policy.referenceInsuranceSalary.toStringAsFixed(0);
      insuranceCeilingCtrl.text = policy.insuranceCeiling.toStringAsFixed(0);
      empSocialRateCtrl.text = policy.employeeSocialInsuranceRate.toString();
      empHealthRateCtrl.text = policy.employeeHealthInsuranceRate.toString();
      empUnempRateCtrl.text = policy.employeeUnemploymentInsuranceRate.toString();
      erSocialRateCtrl.text = policy.employerSocialInsuranceRate.toString();
      erHealthRateCtrl.text = policy.employerHealthInsuranceRate.toString();
      erUnempRateCtrl.text = policy.employerUnemploymentInsuranceRate.toString();
      mealExemptCtrl.text = policy.mealTaxExemptLimit.toStringAsFixed(0);
      sourceRefCtrl.text = policy.sourceReference ?? "";
      changeReasonCtrl.text = policy.changeReason ?? "";
    } catch (_) {}

    try {
      final latePolicy = await _repository.getActiveLatePenaltyPolicy();
      penaltyNameCtrl.text = latePolicy.name;
      penaltyType = latePolicy.type;
      amountPerMinuteCtrl.text = (latePolicy.amountPerMinute ?? 5000).toStringAsFixed(0);
      isPenaltyActive = latePolicy.isActive;
      if (latePolicy.ranges != null && latePolicy.ranges!.isNotEmpty) {
        penaltyRanges = latePolicy.ranges!.toList();
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Chính sách Lương & Phạt"),
          bottom: TabBar(
            labelStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 13),
            indicatorColor: AppColors.primary,
            tabs: const [
              Tab(text: "Thuế TNCN & Bảo hiểm"),
              Tab(text: "Quy định Phạt đi trễ"),
            ],
          ),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildTaxInsuranceTab(),
                  _buildLatePenaltyTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildTaxInsuranceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Mức giảm trừ gia cảnh (Thuế TNCN)"),
          const SizedBox(height: 12),
          _field("Giảm trừ bản thân (VNĐ/tháng)", personalDeductionCtrl),
          _field("Giảm trừ người phụ thuộc (VNĐ/tháng)", dependentDeductionCtrl),
          _field("Mức miễn thuế phụ cấp ăn trưa (VNĐ/tháng)", mealExemptCtrl),
          const SizedBox(height: 24),
          _sectionTitle("Tỷ lệ đóng Bảo hiểm (NLĐ & NSDLĐ)"),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _field("Mức tham chiếu (VNĐ)", refInsuranceSalaryCtrl)),
              const SizedBox(width: 12),
              Expanded(child: _field("Mức trần đóng (VNĐ)", insuranceCeilingCtrl)),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Tỷ lệ trừ người lao động (0.08 = 8%):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field("BHXH (NLĐ)", empSocialRateCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _field("BHYT (NLĐ)", empHealthRateCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _field("BHTN (NLĐ)", empUnempRateCtrl)),
            ],
          ),
          const SizedBox(height: 8),
          const Text("Tỷ lệ công ty đóng (0.175 = 17.5%):", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _field("BHXH (Cty)", erSocialRateCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _field("BHYT (Cty)", erHealthRateCtrl)),
              const SizedBox(width: 8),
              Expanded(child: _field("BHTN (Cty)", erUnempRateCtrl)),
            ],
          ),
          const SizedBox(height: 24),
          _sectionTitle("Căn cứ & Ghi chú"),
          const SizedBox(height: 12),
          _field("Văn bản pháp lý tham chiếu", sourceRefCtrl),
          _field("Lý do điều chỉnh", changeReasonCtrl),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveTaxPolicy,
              child: const Text("LƯU CHÍNH SÁCH LƯƠNG & THUẾ"),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLatePenaltyTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle("Cấu hình Phạt Đi trễ"),
          const SizedBox(height: 12),
          _field("Tên quy định", penaltyNameCtrl),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text("Kích hoạt quy định: ", style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: isPenaltyActive,
                onChanged: (v) => setState(() => isPenaltyActive = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _sectionTitle("Hình thức tính tiền phạt"),
          const SizedBox(height: 8),
          RadioListTile<int>(
            title: const Text("Cố định theo số phút trễ (Ví dụ: 5.000đ / phút)"),
            value: 1,
            groupValue: penaltyType,
            onChanged: (v) => setState(() => penaltyType = v!),
          ),
          RadioListTile<int>(
            title: const Text("Theo khung thời gian bậc thang (Ví dụ: 1-15p: 50.000đ)"),
            value: 2,
            groupValue: penaltyType,
            onChanged: (v) => setState(() => penaltyType = v!),
          ),
          const SizedBox(height: 16),
          if (penaltyType == 1) ...[
            _field("Mức tiền phạt cho mỗi phút trễ (VNĐ)", amountPerMinuteCtrl),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _sectionTitle("Các khung thời gian phạt"),
                IconButton.filledTonal(
                  onPressed: _addPenaltyRange,
                  icon: const Icon(Icons.add, size: 18),
                  tooltip: "Thêm khung",
                ),
              ],
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: penaltyRanges.length,
              itemBuilder: (context, index) {
                final r = penaltyRanges[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    title: Text("Từ phút ${r.fromMinute} đến phút ${r.toMinute}"),
                    subtitle: Text("Mức phạt: ${currencyFmt.format(r.penaltyAmount)}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                      onPressed: () {
                        setState(() {
                          penaltyRanges.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveLatePolicy,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary),
              child: const Text("LƯU QUY ĐỊNH PHẠT ĐI TRỄ"),
            ),
          )
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary));
  }

  Widget _field(String label, TextEditingController ctrl) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.text,
      ),
    );
  }

  void _addPenaltyRange() {
    final fromCtrl = TextEditingController();
    final toCtrl = TextEditingController();
    final amountCtrl = TextEditingController();

    Get.defaultDialog(
      title: "Thêm khung phạt trễ",
      content: Column(
        children: [
          TextField(controller: fromCtrl, decoration: const InputDecoration(labelText: "Từ phút thứ"), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: toCtrl, decoration: const InputDecoration(labelText: "Đến phút thứ"), keyboardType: TextInputType.number),
          const SizedBox(height: 8),
          TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: "Mức phạt (VNĐ)"), keyboardType: TextInputType.number),
        ],
      ),
      textConfirm: "Thêm",
      textCancel: "Hủy",
      onConfirm: () {
        int f = int.tryParse(fromCtrl.text) ?? 1;
        int t = int.tryParse(toCtrl.text) ?? 30;
        double a = double.tryParse(amountCtrl.text) ?? 50000;
        setState(() {
          penaltyRanges.add(LatePenaltyRangeRequest(fromMinute: f, toMinute: t, penaltyAmount: a));
        });
        Get.back();
      },
    );
  }

  Future<void> _saveTaxPolicy() async {
    try {
      final req = SavePayrollPolicyRequest(
        effectiveDate: DateTime.now(),
        referenceInsuranceSalary: double.tryParse(refInsuranceSalaryCtrl.text) ?? 5000000,
        insuranceCeiling: double.tryParse(insuranceCeilingCtrl.text) ?? 36000000,
        employeeSocialInsuranceRate: double.tryParse(empSocialRateCtrl.text) ?? 0.08,
        employeeHealthInsuranceRate: double.tryParse(empHealthRateCtrl.text) ?? 0.015,
        employeeUnemploymentInsuranceRate: double.tryParse(empUnempRateCtrl.text) ?? 0.01,
        employerSocialInsuranceRate: double.tryParse(erSocialRateCtrl.text) ?? 0.175,
        employerHealthInsuranceRate: double.tryParse(erHealthRateCtrl.text) ?? 0.03,
        employerUnemploymentInsuranceRate: double.tryParse(erUnempRateCtrl.text) ?? 0.01,
        personalDeduction: double.tryParse(personalDeductionCtrl.text) ?? 11000000,
        dependentDeduction: double.tryParse(dependentDeductionCtrl.text) ?? 4400000,
        casualIncomeWithholdingThreshold: 2000000,
        casualIncomeWithholdingRate: 0.1,
        mealTaxExemptLimit: double.tryParse(mealExemptCtrl.text) ?? 730000,
        sourceReference: sourceRefCtrl.text,
        changeReason: changeReasonCtrl.text,
        taxBrackets: const [
          PayrollTaxBracketDto(sequence: 1, upperLimit: 5000000, rate: 0.05, name: "Bậc 1"),
          PayrollTaxBracketDto(sequence: 2, upperLimit: 10000000, rate: 0.1, name: "Bậc 2"),
          PayrollTaxBracketDto(sequence: 3, upperLimit: 18000000, rate: 0.15, name: "Bậc 3"),
          PayrollTaxBracketDto(sequence: 4, upperLimit: 32000000, rate: 0.2, name: "Bậc 4"),
          PayrollTaxBracketDto(sequence: 5, upperLimit: 52000000, rate: 0.25, name: "Bậc 5"),
          PayrollTaxBracketDto(sequence: 6, upperLimit: 80000000, rate: 0.3, name: "Bậc 6"),
          PayrollTaxBracketDto(sequence: 7, upperLimit: null, rate: 0.35, name: "Bậc 7"),
        ],
      );
      await _repository.createPayrollPolicy(req);
      Get.snackbar("Thành công", "Đã lưu chính sách thuế & bảo hiểm công ty");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu chính sách thuế & bảo hiểm: $e");
    }
  }

  Future<void> _saveLatePolicy() async {
    try {
      final req = LatePenaltyPolicyRequest(
        name: penaltyNameCtrl.text,
        type: penaltyType,
        amountPerMinute: penaltyType == 1 ? double.tryParse(amountPerMinuteCtrl.text) : null,
        isActive: isPenaltyActive,
        ranges: penaltyType == 2 ? penaltyRanges : null,
      );
      await _repository.saveLatePenaltyPolicy(req);
      Get.snackbar("Thành công", "Đã lưu quy định phạt đi trễ công ty");
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể lưu quy định phạt đi trễ: $e");
    }
  }
}
