import '../data/network/dio_client.dart';
import '../data/network/models/employee_admin_models.dart';
import '../data/network/models/shift_models.dart';
import '../data/network/models/shift_admin_models.dart';
import '../data/network/models/admin_config_models.dart';
import '../data/network/models/common_models.dart';
import '../data/network/rest_clients/system_admin_rest_client.dart';

class SystemAdminRepository {
  final SystemAdminRestClient _restClient;

  SystemAdminRepository({SystemAdminRestClient? restClient})
      : _restClient = restClient ?? SystemAdminRestClient(DioClient().dio);

  // Employee Admin
  Future<PagedResponse<EmployeeListItemResponse>> getEmployeeList({
    int? branchId,
    int page = 1,
    int pageSize = 100,
  }) {
    return _restClient.getEmployeeList(
      branchId: branchId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<EmployeeDetailResponse> getEmployeeById(int id) {
    return _restClient.getEmployeeById(id);
  }

  Future<void> createEmployeeProfile(CreateEmployeeProfileRequest request) {
    return _restClient.createEmployeeProfile(request);
  }

  Future<void> updateEmployee(int id, UpdateEmployeeRequest request) {
    return _restClient.updateEmployee(id, request);
  }

  Future<void> unbindDevice(int id) {
    return _restClient.unbindDevice(id);
  }

  Future<StatusMessageResponse> toggleEmployeeStatus(int id) {
    return _restClient.toggleEmployeeStatus(id);
  }

  Future<void> resetEmployeePassword(int id, String newPassword) {
    return _restClient.resetEmployeePassword(id, AdminResetPasswordRequest(newTemporaryPassword: newPassword));
  }

  // Shift Admin
  Future<ShiftDto> createShift(CreateShiftRequest request) {
    return _restClient.createShift(request);
  }

  Future<ShiftDto> updateShift(int id, CreateShiftRequest request) {
    return _restClient.updateShift(id, request);
  }

  Future<void> deleteShift(int id) {
    return _restClient.deleteShift(id);
  }

  Future<PagedResponse<AdminShiftAssignmentDto>> getShiftAssignments({
    int? branchId,
    int? employeeId,
    int? shiftId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) {
    return _restClient.getShiftAssignments(
      branchId: branchId,
      employeeId: employeeId,
      shiftId: shiftId,
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
      page: page,
      pageSize: pageSize,
    );
  }

  Future<void> assignShift(AssignShiftRequest request) {
    return _restClient.assignShift(request);
  }

  // Payroll Admin
  Future<void> finalizePayroll({required int month, required int year, int standardWorkDays = 26}) {
    return _restClient.finalizePayroll(FinalizePayrollRequest(
      month: month,
      year: year,
      standardWorkDays: standardWorkDays,
    ));
  }

  Future<void> configSalary(int employeeId, UpdateSalaryConfigRequest request) {
    return _restClient.configSalary(employeeId, request);
  }
}
