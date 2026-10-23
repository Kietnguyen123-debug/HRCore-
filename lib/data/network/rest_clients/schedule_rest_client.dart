import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/schedule_models.dart';

part 'schedule_rest_client.g.dart';

@RestApi()
abstract class ScheduleRestClient {
  factory ScheduleRestClient(Dio dio, {String baseUrl}) = _ScheduleRestClient;

  @POST('v1/schedules/groups/bulk-assign')
  Future<void> bulkAssignGroup(@Body() GroupBulkAssignRequest request);

  @POST('v1/schedules/employees/override')
  Future<void> overrideEmployee(@Body() EmployeeOverrideRequest request);

  @DELETE('v1/schedules/employees/override/{id}')
  Future<void> deleteOverride(@Path('id') int id);

  @GET('v1/schedules/roster')
  Future<RosterResponse> getRoster({
    @Query('DepartmentId') int? departmentId,
    @Query('WorkGroupId') int? workGroupId,
    @Query('From') required String from,
    @Query('To') required String to,
  });
}
