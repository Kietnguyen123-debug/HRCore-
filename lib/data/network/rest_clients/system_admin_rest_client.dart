import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/employee_admin_models.dart';
import '../models/shift_models.dart';
import '../models/shift_admin_models.dart';
import '../models/admin_config_models.dart';
import '../models/payroll_models.dart';
import '../models/common_models.dart';
import '../models/attendance_models.dart';

part 'system_admin_rest_client.g.dart';

@RestApi()
abstract class SystemAdminRestClient {
  factory SystemAdminRestClient(Dio dio, {String baseUrl}) = _SystemAdminRestClient;

  // Employee Administration
  @GET('Employee')
  Future<PagedResponse<EmployeeListItemResponse>> getEmployeeList({
    @Query('branchId') int? branchId,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 100,
  });

  @GET('Employee/{id}')
  Future<EmployeeDetailResponse> getEmployeeById(@Path('id') int id);

  @POST('Employee')
  Future<void> createEmployeeProfile(@Body() CreateEmployeeProfileRequest request);

  @PUT('Employee/{id}')
  Future<void> updateEmployee(@Path('id') int id, @Body() UpdateEmployeeRequest request);

  @POST('Employee/{id}/unbind-device')
  Future<void> unbindDevice(@Path('id') int id);

  @PUT('Employee/{id}/toggle-status')
  Future<StatusMessageResponse> toggleEmployeeStatus(@Path('id') int id);

  @POST('Employee/{id}/reset-password')
  Future<void> resetEmployeePassword(@Path('id') int id, @Body() AdminResetPasswordRequest request);

  // Shift Administration
  @POST('Shift')
  Future<ShiftDto> createShift(@Body() CreateShiftRequest request);

  @PUT('Shift/{id}')
  Future<ShiftDto> updateShift(@Path('id') int id, @Body() CreateShiftRequest request);

  @DELETE('Shift/{id}')
  Future<void> deleteShift(@Path('id') int id);

  @GET('Shift/assignments')
  Future<PagedResponse<AdminShiftAssignmentDto>> getShiftAssignments({
    @Query('branchId') int? branchId,
    @Query('employeeId') int? employeeId,
    @Query('shiftId') int? shiftId,
    @Query('from') String? from,
    @Query('to') String? to,
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @POST('Shift/assignments')
  Future<void> assignShift(@Body() AssignShiftRequest request);

  @PUT('Shift/assignments/{id}')
  Future<void> updateShiftAssignment(@Path('id') int id, @Body() UpdateShiftAssignmentRequest request);

  @DELETE('Shift/assignments/{id}')
  Future<void> deleteShiftAssignment(@Path('id') int id);

  // Payroll Config & Administration
  @POST('Payroll/finalize')
  Future<void> finalizePayroll(@Body() FinalizePayrollRequest request);

  @PUT('Payroll/config-salary/{employeeId}')
  Future<void> configSalary(@Path('employeeId') int employeeId, @Body() UpdateSalaryConfigRequest request);
}
