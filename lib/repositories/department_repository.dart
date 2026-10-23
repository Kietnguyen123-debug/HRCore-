import '../data/network/dio_client.dart';
import '../data/network/models/department_models.dart';
import '../data/network/rest_clients/department_rest_client.dart';

class DepartmentRepository {
  final DepartmentRestClient _restClient;

  DepartmentRepository({DepartmentRestClient? restClient})
      : _restClient = restClient ?? DepartmentRestClient(DioClient().dio);

  Future<List<DepartmentListItemResponse>> getAll() async {
    final response = await _restClient.getAll();
    return response.data ?? [];
  }

  Future<DepartmentResponse> create(String name) {
    return _restClient.create(DepartmentRequest(name: name));
  }

  Future<DepartmentResponse> getById(int id) {
    return _restClient.getById(id);
  }

  Future<DepartmentResponse> update(int id, String name) {
    return _restClient.update(id, DepartmentRequest(name: name));
  }

  Future<void> delete(int id) {
    return _restClient.delete(id);
  }

  Future<DepartmentResponse> toggleStatus(int id) {
    return _restClient.toggleStatus(id);
  }
}
