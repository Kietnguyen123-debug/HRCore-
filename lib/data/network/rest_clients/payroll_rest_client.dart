import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/payroll_models.dart';

part 'payroll_rest_client.g.dart';

@RestApi()
abstract class PayrollRestClient {
  factory PayrollRestClient(Dio dio, {String baseUrl}) = _PayrollRestClient;

  @GET('Payroll/my-history')
  Future<List<PayrollHistoryItemDto>> getMyHistory();

  @GET('Payroll/my-payslip')
  Future<PayslipResponse> getMyPayslip({
    @Query('month') required int month,
    @Query('year') required int year,
  });

  @GET('Payroll/monthly-summary')
  Future<MonthlyPayrollSummaryResponse> getMonthlySummary({
    @Query('month') required int month,
    @Query('year') required int year,
    @Query('standardWorkDays') int standardWorkDays = 26,
  });

  @GET('Payroll/policy')
  Future<PayrollPolicyResponse> getActivePayrollPolicy({
    @Query('payPeriodDate') String? payPeriodDate,
  });

  @POST('Payroll/policy')
  Future<PayrollPolicyResponse> createPayrollPolicy(
    @Body() SavePayrollPolicyRequest request,
  );

  @GET('Payroll/late-penalty-policy')
  Future<LatePenaltyPolicyResponse> getActiveLatePenaltyPolicy();

  @PUT('Payroll/late-penalty-policy')
  Future<LatePenaltyPolicyResponse> saveLatePenaltyPolicy(
    @Body() LatePenaltyPolicyRequest request,
  );
}
