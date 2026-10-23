import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/admin_models.dart';
import '../models/attendance_models.dart';
import '../models/common_models.dart';
import '../models/overtime_models.dart';
import '../models/salary_advance_models.dart';
import '../models/explanation_models.dart';

part 'admin_rest_client.g.dart';

@RestApi()
abstract class AdminRestClient {
  factory AdminRestClient(Dio dio, {String baseUrl}) = _AdminRestClient;

  @GET('AdminDashboard/today-summary')
  Future<TodaySummaryResponse> getTodaySummary({
    @Query('branchId') int? branchId,
  });

  @GET('AdminDashboard/overview')
  Future<DashboardOverviewResponse> getOverview({
    @Query('branchId') int? branchId,
    @Query('date') String? date,
  });

  @GET('AdminDashboard/pending-counts')
  Future<DashboardPendingCountsResponse> getPendingCounts({
    @Query('branchId') int? branchId,
  });

  @GET('AdminDashboard/attendance-summary')
  Future<DashboardAttendanceSummaryResponse> getAttendanceSummary({
    @Query('branchId') int? branchId,
    @Query('date') String? date,
  });

  @GET('Attendance/admin')
  Future<PagedResponse<AdminAttendanceDto>> getAttendanceList({
    @Query('branchId') int? branchId,
    @Query('employeeId') int? employeeId,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('status') String? status,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @GET('Attendance/admin/employee/{employeeId}')
  Future<PagedResponse<AdminAttendanceDto>> getAttendanceByEmployee(
    @Path('employeeId') int employeeId, {
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @GET('Attendance/admin/date')
  Future<PagedResponse<AdminAttendanceDto>> getAttendanceByDate({
    @Query('date') String? date,
    @Query('branchId') int? branchId,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @PUT('Attendance/{id}/adjust')
  Future<AttendanceItemDto> adjustAttendance(
    @Path('id') int id,
    @Body() AdjustAttendanceRequest request,
  );

  @POST('Attendance/add-ip-manual')
  Future<MessageResponse> addPublicIpManual(
    @Body() Map<String, dynamic> request,
  );

  // Admin Pending Lists
  @GET('Leave/admin/pending')
  Future<PagedResponse<AdminLeaveDto>> getPendingLeaves({
    @Query('branchId') int? branchId,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @GET('Overtime/admin/pending')
  Future<PagedResponse<AdminOvertimeDto>> getPendingOvertimes({
    @Query('branchId') int? branchId,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @GET('SalaryAdvance/pending')
  Future<List<AdminSalaryAdvanceDto>> getPendingAdvances(); // Backend verification: Advance pending is direct list

  @GET('AttendanceExplanation/pending')
  Future<List<AttendanceExplanationResponse>> getPendingExplanations();

  @PUT('Leave/approve/{id}')
  Future<LeaveApprovalResponse> approveLeave(
    @Path('id') int id, {
    @Query('isApproved') required bool isApproved,
    @Query('rejectReason') String? rejectReason,
  });

  @PUT('Overtime/{id}/approve')
  Future<OvertimeResponse> approveOvertime(
    @Path('id') int id,
    @Body() OvertimeReviewRequest request,
  );

  @PUT('SalaryAdvance/{id}/approve')
  Future<SalaryAdvanceResponse> approveSalaryAdvance(
    @Path('id') int id,
    @Body() SalaryAdvanceReviewRequest request,
  );

  @PUT('AttendanceExplanation/{id}/review')
  Future<AttendanceExplanationResponse> reviewExplanation(
    @Path('id') int id,
    @Body() ReviewAttendanceExplanationRequest request,
  );
}
