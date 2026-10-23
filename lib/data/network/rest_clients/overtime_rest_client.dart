import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/overtime_models.dart';
import '../models/common_models.dart';

part 'overtime_rest_client.g.dart';

@RestApi()
abstract class OvertimeRestClient {
  factory OvertimeRestClient(Dio dio, {String baseUrl}) = _OvertimeRestClient;

  @POST('Overtime/log')
  Future<OvertimeResponse> logOvertime(@Body() OvertimeRequest request);

  @GET('Overtime/my-requests')
  Future<List<EmployeeOvertimeDto>> getMyRequests();

  @PUT('Overtime/{id}/cancel')
  Future<CancelRequestResponse> cancelRequest(@Path('id') int id);
}
