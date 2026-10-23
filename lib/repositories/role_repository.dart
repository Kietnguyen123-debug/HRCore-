import '../data/network/dio_client.dart';
import '../data/network/models/role_models.dart';
import '../data/network/rest_clients/role_rest_client.dart';

class RoleRepository {
  final RoleRestClient _restClient;

  RoleRepository({RoleRestClient? restClient})
      : _restClient = restClient ?? RoleRestClient(DioClient().dio);

  Future<List<RoleSummaryResponse>> getRoles() {
    return _restClient.getRoles();
  }

  Future<RoleSummaryResponse> createRole(String name, String? description) {
    return _restClient.createRole(CreateRoleRequest(name: name, description: description));
  }

  Future<PermissionMatrixResponse> getMatrix(int roleId) {
    return _restClient.getMatrix(roleId);
  }

  Future<RoleSummaryResponse> updateRole(int roleId, String name, String? description) {
    return _restClient.updateRole(roleId, CreateRoleRequest(name: name, description: description));
  }

  Future<void> deleteRole(int roleId, {String? confirmation}) {
    return _restClient.deleteRole(roleId, confirmation: confirmation);
  }

  Future<void> updateRolePermissions(int roleId, List<int> permissionIds) {
    return _restClient.updateRolePermissions(roleId, UpdateRolePermissionsRequest(permissionIds: permissionIds));
  }

  Future<void> assignRoleToEmployee(int employeeId, int roleId) {
    return _restClient.assignRoleToEmployee(employeeId, AssignRoleRequest(roleId: roleId));
  }
}
