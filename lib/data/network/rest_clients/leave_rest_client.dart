import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/leave_models.dart';
import '../models/common_models.dart';

part 'leave_rest_client.g.dart';

@RestApi()
abstract class LeaveRestClient {
  factory LeaveRestClient(Dio dio, {String baseUrl}) = _LeaveRestClient;

  @POST('Leave/request')
  Future<LeaveRequestCreatedResponse> createRequest(@Body() CreateLeaveRequest request);

  @GET('Leave/my-requests')
  Future<List<EmployeeLeaveDto>> getMyRequests();

  @GET('Leave/my-balance')
  Future<LeaveBalanceDto> getMyBalance();

  @PUT('Leave/{id}/cancel')
  Future<CancelRequestResponse> cancelRequest(@Path('id') int id);
}
