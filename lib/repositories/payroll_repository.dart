import '../data/network/dio_client.dart';
import '../data/network/models/payroll_models.dart';
import '../data/network/rest_clients/payroll_rest_client.dart';

class PayrollRepository {
  final PayrollRestClient _restClient;

  PayrollRepository({PayrollRestClient? restClient})
      : _restClient = restClient ?? PayrollRestClient(DioClient().dio);

  Future<List<PayrollHistoryItemDto>> getMyHistory() {
    return _restClient.getMyHistory();
  }

  Future<PayslipResponse> getMyPayslip({
    required int month,
    required int year,
  }) {
    return _restClient.getMyPayslip(month: month, year: year);
  }

  // Bổ sung hàm lấy bảng lương tổng hợp cho Admin/HR
  Future<List<PayslipResponse>> getMonthlySummary({
    required int month,
    required int year,
    int standardWorkDays = 26,
  }) async {
    final response = await _restClient.getMonthlySummary(
      month: month,
      year: year,
      standardWorkDays: standardWorkDays,
    );
    return response.items;
  }

  Future<PayrollPolicyResponse> getActivePayrollPolicy({DateTime? payPeriodDate}) {
    return _restClient.getActivePayrollPolicy(payPeriodDate: payPeriodDate?.toIso8601String());
  }

  Future<PayrollPolicyResponse> createPayrollPolicy(SavePayrollPolicyRequest request) {
    return _restClient.createPayrollPolicy(request);
  }

  Future<LatePenaltyPolicyResponse> getActiveLatePenaltyPolicy() {
    return _restClient.getActiveLatePenaltyPolicy();
  }

  Future<LatePenaltyPolicyResponse> saveLatePenaltyPolicy(LatePenaltyPolicyRequest request) {
    return _restClient.saveLatePenaltyPolicy(request);
  }
}
