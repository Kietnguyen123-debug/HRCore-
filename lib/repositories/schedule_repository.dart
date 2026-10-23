import '../data/network/dio_client.dart';
import '../data/network/models/schedule_models.dart';
import '../data/network/rest_clients/schedule_rest_client.dart';

class ScheduleRepository {
  final ScheduleRestClient _restClient;

  ScheduleRepository({ScheduleRestClient? restClient})
      : _restClient = restClient ?? ScheduleRestClient(DioClient().dio);

  Future<RosterResponse> getRoster({
    int? departmentId,
    int? workGroupId,
    required DateTime from,
    required DateTime to,
  }) {
    return _restClient.getRoster(
      departmentId: departmentId,
      workGroupId: workGroupId,
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );
  }

  Future<void> bulkAssignGroup(GroupBulkAssignRequest request) {
    return _restClient.bulkAssignGroup(request);
  }

  Future<void> overrideEmployee(EmployeeOverrideRequest request) {
    return _restClient.overrideEmployee(request);
  }

  Future<void> deleteOverride(int id) {
    return _restClient.deleteOverride(id);
  }
}
