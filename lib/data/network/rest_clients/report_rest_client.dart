import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/report_models.dart';

part 'report_rest_client.g.dart';

@RestApi()
abstract class ReportRestClient {
  factory ReportRestClient(Dio dio, {String baseUrl}) = _ReportRestClient;

  @GET('Report/attendance')
  Future<List<AttendanceReportDto>> getAttendanceReport({
    @Query('month') int? month,
    @Query('year') int? year,
    @Query('branchId') int? branchId,
    @Query('employeeId') int? employeeId,
  });

  @GET('Report/leave')
  Future<List<LeaveReportDto>> getLeaveReport({
    @Query('month') int? month,
    @Query('year') int? year,
    @Query('branchId') int? branchId,
    @Query('employeeId') int? employeeId,
    @Query('status') String? status,
  });

  @GET('Report/overtime')
  Future<List<OvertimeReportDto>> getOvertimeReport({
    @Query('month') int? month,
    @Query('year') int? year,
    @Query('branchId') int? branchId,
    @Query('employeeId') int? employeeId,
    @Query('status') String? status,
  });

  @GET('Report/monthly-summary')
  Future<List<MonthlyAttendanceSummaryResponse>> getMonthlySummary({
    @Query('month') int? month,
    @Query('year') int? year,
    @Query('branchId') int? branchId,
  });
}
