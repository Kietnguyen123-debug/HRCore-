import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/role_models.dart';

part 'role_rest_client.g.dart';

@RestApi()
abstract class RoleRestClient {
  factory RoleRestClient(Dio dio, {String baseUrl}) = _RoleRestClient;

  @GET('role-management/roles')
  Future<List<RoleSummaryResponse>> getRoles();

  @POST('role-management/roles')
  Future<RoleSummaryResponse> createRole(@Body() CreateRoleRequest request);

  @GET('role-management/matrix/{roleId}')
  Future<PermissionMatrixResponse> getMatrix(@Path('roleId') int roleId);

  @PUT('role-management/roles/{roleId}')
  Future<RoleSummaryResponse> updateRole(
    @Path('roleId') int roleId,
    @Body() CreateRoleRequest request,
  );

  @DELETE('role-management/roles/{roleId}')
  Future<void> deleteRole(
    @Path('roleId') int roleId, {
    @Query('confirmation') String? confirmation,
  });

  @PUT('role-management/roles/{roleId}/permissions')
  Future<void> updateRolePermissions(
    @Path('roleId') int roleId,
    @Body() UpdateRolePermissionsRequest request,
  );

  @PUT('role-management/employees/{employeeId}/role')
  Future<void> assignRoleToEmployee(
    @Path('employeeId') int employeeId,
    @Body() AssignRoleRequest request,
  );
}
