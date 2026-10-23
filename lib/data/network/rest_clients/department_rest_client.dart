import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/department_models.dart';

part 'department_rest_client.g.dart';

@RestApi()
abstract class DepartmentRestClient {
  factory DepartmentRestClient(Dio dio, {String baseUrl}) = _DepartmentRestClient;

  @GET('Department')
  Future<DepartmentListResponse> getAll();

  @POST('Department')
  Future<DepartmentResponse> create(@Body() DepartmentRequest request);

  @GET('Department/{id}')
  Future<DepartmentResponse> getById(@Path('id') int id);

  @PUT('Department/{id}')
  Future<DepartmentResponse> update(@Path('id') int id, @Body() DepartmentRequest request);

  @DELETE('Department/{id}')
  Future<void> delete(@Path('id') int id);

  @PUT('Department/{id}/toggle-status')
  Future<DepartmentResponse> toggleStatus(@Path('id') int id);
}
