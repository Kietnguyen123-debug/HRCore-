import '../data/network/dio_client.dart';
import '../data/network/models/admin_models.dart';
import '../data/network/models/attendance_models.dart';
import '../data/network/models/common_models.dart';
import '../data/network/models/overtime_models.dart';
import '../data/network/models/salary_advance_models.dart';
import '../data/network/models/explanation_models.dart';
import '../data/network/rest_clients/admin_rest_client.dart';

class AdminRepository {
  final AdminRestClient _restClient;

  AdminRepository({AdminRestClient? restClient})
      : _restClient = restClient ?? AdminRestClient(DioClient().dio);

  Future<TodaySummaryResponse> getTodaySummary({int? branchId}) {
    return _restClient.getTodaySummary(branchId: branchId);
  }

  Future<DashboardOverviewResponse> getOverview({int? branchId, DateTime? date}) {
    return _restClient.getOverview(
      branchId: branchId,
      date: date?.toIso8601String(),
    );
  }

  Future<DashboardPendingCountsResponse> getPendingCounts({int? branchId}) {
    return _restClient.getPendingCounts(branchId: branchId);
  }

  Future<DashboardAttendanceSummaryResponse> getAttendanceSummary({int? branchId, DateTime? date}) {
    return _restClient.getAttendanceSummary(
      branchId: branchId,
      date: date?.toIso8601String(),
    );
  }

  Future<PagedResponse<AdminAttendanceDto>> getAttendanceList({
    int? branchId,
    int? employeeId,
    DateTime? from,
    DateTime? to,
    String? status,
    int page = 1,
    int pageSize = 20,
  }) {
    return _restClient.getAttendanceList(
      branchId: branchId,
      employeeId: employeeId,
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
      status: status,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<PagedResponse<AdminAttendanceDto>> getAttendanceByEmployee({
    required int employeeId,
    DateTime? from,
    DateTime? to,
    int page = 1,
    int pageSize = 20,
  }) {
    return _restClient.getAttendanceByEmployee(
      employeeId,
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
      page: page,
      pageSize: pageSize,
    );
  }

  Future<PagedResponse<AdminAttendanceDto>> getAttendanceByDate({
    DateTime? date,
    int? branchId,
    int page = 1,
    int pageSize = 20,
  }) {
    return _restClient.getAttendanceByDate(
      date: date?.toIso8601String(),
      branchId: branchId,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<AttendanceItemDto> adjustAttendance({
    required int attendanceId,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    required String reason,
  }) {
    return _restClient.adjustAttendance(
      attendanceId,
      AdjustAttendanceRequest(
        checkInTime: checkInTime,
        checkOutTime: checkOutTime,
        reason: reason,
      ),
    );
  }

  Future<MessageResponse> addPublicIpManual({
    int? branchId,
    String? publicIp,
    String? description,
  }) {
    return _restClient.addPublicIpManual({
      'branchId': branchId,
      'publicIp': publicIp,
      'description': description,
    });
  }

  // Admin Listing Methods
  Future<PagedResponse<AdminLeaveDto>> getPendingLeaves({int? branchId, int page = 1}) {
    return _restClient.getPendingLeaves(branchId: branchId, page: page);
  }

  Future<PagedResponse<AdminOvertimeDto>> getPendingOvertimes({int? branchId, int page = 1}) {
    return _restClient.getPendingOvertimes(branchId: branchId, page: page);
  }

  Future<List<AdminSalaryAdvanceDto>> getPendingAdvances() {
    return _restClient.getPendingAdvances();
  }

  Future<List<AttendanceExplanationResponse>> getPendingExplanations() {
    return _restClient.getPendingExplanations();
  }

  Future<LeaveApprovalResponse> approveLeave({
    required int id,
    required bool isApproved,
    String? rejectReason,
  }) {
    return _restClient.approveLeave(
      id,
      isApproved: isApproved,
      rejectReason: rejectReason,
    );
  }

  Future<OvertimeResponse> approveOvertime({
    required int id,
    required bool isApproved,
  }) {
    return _restClient.approveOvertime(
      id,
      OvertimeReviewRequest(isApproved: isApproved),
    );
  }

  Future<SalaryAdvanceResponse> approveSalaryAdvance({
    required int id,
    required bool isApproved,
    String? reviewNote,
  }) {
    return _restClient.approveSalaryAdvance(
      id,
      SalaryAdvanceReviewRequest(isApproved: isApproved, reviewNote: reviewNote),
    );
  }

  Future<AttendanceExplanationResponse> reviewExplanation({
    required int id,
    required String status,
    String? reviewNote,
  }) {
    return _restClient.reviewExplanation(
      id,
      ReviewAttendanceExplanationRequest(status: status, reviewNote: reviewNote),
    );
  }
}
