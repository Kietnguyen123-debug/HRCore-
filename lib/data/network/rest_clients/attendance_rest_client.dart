import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/attendance_models.dart';
import '../models/common_models.dart';
import '../models/admin_models.dart';

part 'attendance_rest_client.g.dart';

@RestApi()
abstract class AttendanceRestClient {
  factory AttendanceRestClient(Dio dio, {String baseUrl}) = _AttendanceRestClient;

  @POST('Attendance/check-in')
  Future<AttendanceActionResponse> checkIn(@Body() AttendanceRequest request);

  @POST('Attendance/check-out')
  Future<AttendanceActionResponse> checkOut(@Body() AttendanceRequest request);

  @POST('Attendance/register-face')
  Future<void> registerFace(@Body() RegisterFaceRequest request);

  @POST('Attendance/register-wifi')
  Future<ApiMessageResponse> registerWifi(@Body() RegisterWifiRequest request);

  @GET('Attendance/my-today')
  Future<AttendanceItemDto> getMyToday();

  @GET('Attendance/my-summary')
  Future<AttendanceSummaryDto> getMySummary({
    @Query('month') int? month,
    @Query('year') int? year,
  });

  @GET('Attendance/my-history')
  Future<List<AttendanceItemDto>> getMyHistory({
    @Query('from') String? from,
    @Query('to') String? to,
  });

  @GET('Attendance/admin/employee/{employeeId}')
  Future<PagedResponse<AdminAttendanceDto>> getAdminEmployeeAttendance(
    @Path('employeeId') int employeeId,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('page') int page,
    @Query('pageSize') int pageSize,
  );

  @GET('Attendance/admin/date')
  Future<PagedResponse<AdminAttendanceDto>> getAdminDateAttendance(
    @Query('date') String date,
    @Query('branchId') int? branchId,
    @Query('page') int page,
    @Query('pageSize') int pageSize,
  );

  @PUT('Attendance/{id}/adjust')
  Future<AttendanceItemDto> adjustAttendance(
    @Path('id') int id,
    @Body() AdjustAttendanceRequest request,
  );
}
