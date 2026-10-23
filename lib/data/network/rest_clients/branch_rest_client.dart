import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/branch_models.dart';

part 'branch_rest_client.g.dart';

@RestApi()
abstract class BranchRestClient {
  factory BranchRestClient(Dio dio, {String baseUrl}) = _BranchRestClient;

  @GET('Branch')
  Future<BranchListResponse> getAll();

  @POST('Branch')
  Future<BranchResponse> create(@Body() BranchRequest request);

  @GET('Branch/{id}')
  Future<BranchResponse> getById(@Path('id') int id);

  @PUT('Branch/{id}')
  Future<BranchResponse> update(@Path('id') int id, @Body() BranchRequest request);

  @DELETE('Branch/{id}')
  Future<void> delete(@Path('id') int id);

  @PUT('Branch/{id}/toggle-status')
  Future<BranchStatusResponse> toggleStatus(@Path('id') int id);

  // Branch IP Management
  @GET('Branch/{branchId}/ips')
  Future<List<BranchIpDto>> getIps(@Path('branchId') int branchId);

  @POST('Branch/{branchId}/ips')
  Future<BranchIpDto> addIp(
    @Path('branchId') int branchId,
    @Body() BranchIpRequest request,
  );

  @PUT('Branch/{branchId}/ips/{id}')
  Future<BranchIpDto> updateIp(
    @Path('branchId') int branchId,
    @Path('id') int id,
    @Body() BranchIpRequest request,
  );

  @DELETE('Branch/{branchId}/ips/{id}')
  Future<void> deleteIp(@Path('branchId') int branchId, @Path('id') int id);

  @PUT('Branch/{branchId}/ips/{id}/toggle-status')
  Future<BranchStatusResponse> toggleIp(
    @Path('branchId') int branchId,
    @Path('id') int id,
  );

  // Branch Wifi Management
  @GET('Branch/{branchId}/wifis')
  Future<List<BranchWifiDto>> getWifis(@Path('branchId') int branchId);

  @POST('Branch/{branchId}/wifis')
  Future<BranchWifiDto> addWifi(
    @Path('branchId') int branchId,
    @Body() BranchWifiRequest request,
  );

  @PUT('Branch/{branchId}/wifis/{id}')
  Future<BranchWifiDto> updateWifi(
    @Path('branchId') int branchId,
    @Path('id') int id,
    @Body() BranchWifiRequest request,
  );

  @DELETE('Branch/{branchId}/wifis/{id}')
  Future<void> deleteWifi(@Path('branchId') int branchId, @Path('id') int id);

  @PUT('Branch/{branchId}/wifis/{id}/toggle-status')
  Future<BranchWifiStatusResponse> toggleWifi(
    @Path('branchId') int branchId,
    @Path('id') int id,
  );
}
