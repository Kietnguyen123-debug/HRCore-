import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/explanation_models.dart';
import '../models/common_models.dart';

part 'explanation_rest_client.g.dart';

@RestApi()
abstract class ExplanationRestClient {
  factory ExplanationRestClient(Dio dio, {String baseUrl}) = _ExplanationRestClient;

  @POST('AttendanceExplanation')
  Future<AttendanceExplanationResponse> submitExplanation(@Body() SubmitAttendanceExplanationRequest request);

  @GET('AttendanceExplanation/my-requests')
  Future<List<AttendanceExplanationResponse>> getMyRequests();

  @PUT('AttendanceExplanation/{id}/cancel')
  Future<CancelRequestResponse> cancelRequest(@Path('id') int id);
}
