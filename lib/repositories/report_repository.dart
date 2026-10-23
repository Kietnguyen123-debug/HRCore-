import '../data/network/dio_client.dart';
import '../data/network/models/report_models.dart';
import '../data/network/rest_clients/report_rest_client.dart';

class ReportRepository {
  final ReportRestClient _restClient;

  ReportRepository({ReportRestClient? restClient})
      : _restClient = restClient ?? ReportRestClient(DioClient().dio);

  Future<List<AttendanceReportDto>> getAttendanceReport({
    int? month,
    int? year,
    int? branchId,
    int? employeeId,
  }) {
    return _restClient.getAttendanceReport(
      month: month,
      year: year,
      branchId: branchId,
      employeeId: employeeId,
    );
  }

  Future<List<LeaveReportDto>> getLeaveReport({
    int? month,
    int? year,
    int? branchId,
    int? employeeId,
    String? status,
  }) {
    return _restClient.getLeaveReport(
      month: month,
      year: year,
      branchId: branchId,
      employeeId: employeeId,
      status: status,
    );
  }

  Future<List<OvertimeReportDto>> getOvertimeReport({
    int? month,
    int? year,
    int? branchId,
    int? employeeId,
    String? status,
  }) {
    return _restClient.getOvertimeReport(
      month: month,
      year: year,
      branchId: branchId,
      employeeId: employeeId,
      status: status,
    );
  }

  Future<List<MonthlyAttendanceSummaryResponse>> getMonthlySummary({
    int? month,
    int? year,
    int? branchId,
  }) {
    return _restClient.getMonthlySummary(
      month: month,
      year: year,
      branchId: branchId,
    );
  }
}
