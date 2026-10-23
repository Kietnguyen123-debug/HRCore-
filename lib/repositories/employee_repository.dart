import '../core/api_client.dart';
import '../models/employee_model.dart';

class EmployeeRepository {
  final ApiClient _apiClient = ApiClient();

  Future<List<Employee>> getEmployees({
    int page = 1,
    int pageSize = 100,
    int? branchId,
  }) async {
    try {
      final response = await _apiClient.getEmployees(
        page: page,
        pageSize: pageSize,
        branchId: branchId,
      );

      final data = response.data;

      if (data is List) {
        return data
            .map((e) => Employee.fromJson(e))
            .toList();
      }

      if (data is Map && data['items'] is List) {
        return (data['items'] as List)
            .map((e) => Employee.fromJson(e))
            .toList();
      }

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateEmployee(
      int id,
      String fullName,
      int branchId,
      String role, {
        String? email,
      }) async {
    await _apiClient.updateEmployee(
      id,
      fullName,
      branchId,
      role,
      email: email,
    );
  }

  Future<void> toggleStatus(
      int id,
      ) async {
    await _apiClient.toggleStatus(id);
  }

  Future<void> unbindDevice(
      int id,
      ) async {
    await _apiClient.unbindDevice(id);
  }

  Future<void> resetPassword(
      int id,
      String newTemporaryPassword,
      ) async {
    await _apiClient.resetPassword(
      id,
      newTemporaryPassword,
    );
  }

  Future<void> createEmployee(
      String employeeCode,
      String fullName,
      int branchId,
      String role,
      String temporaryPassword, {
        String? email,
      }) async {
    await _apiClient.createEmployee(
      employeeCode,
      fullName,
      branchId,
      role,
      temporaryPassword,
      email: email,
    );
  }

  Future<void> registerFace(
      int employeeId,
      String faceImageBase64,
      ) async {
    await _apiClient.registerFace(
      employeeId,
      faceImageBase64,
    );
  }
}