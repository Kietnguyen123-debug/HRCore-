import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/salary_advance_models.dart';
import '../models/common_models.dart';

part 'salary_advance_rest_client.g.dart';

@RestApi()
abstract class SalaryAdvanceRestClient {
  factory SalaryAdvanceRestClient(Dio dio, {String baseUrl}) = _SalaryAdvanceRestClient;

  @POST('SalaryAdvance/request')
  Future<SalaryAdvanceResponse> requestAdvance(@Body() SalaryAdvanceRequest request);

  @GET('SalaryAdvance/my-requests')
  Future<List<SalaryAdvanceResponse>> getMyRequests();

  @PUT('SalaryAdvance/{id}/cancel')
  Future<CancelRequestResponse> cancelRequest(@Path('id') int id);
}
