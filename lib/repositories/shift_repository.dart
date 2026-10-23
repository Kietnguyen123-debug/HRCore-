import 'package:dio/dio.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/shift_models.dart';
import '../data/network/rest_clients/shift_rest_client.dart';

class ShiftRepository {
  final ShiftRestClient _restClient;

  ShiftRepository({ShiftRestClient? restClient})
      : _restClient = restClient ?? ShiftRestClient(DioClient().dio);

  Future<List<ShiftDto>> getAllShifts() {
    return _restClient.getAll();
  }

  /// Lấy ca hôm nay an toàn (Không bị quăng lỗi nếu không có ca)
  Future<EmployeeShiftScheduleDto?> getMyToday() async {
    try {
      return await _restClient.getMyToday();
    } on DioException catch (e) {
      // 204 No Content hoặc 404 Not Found là trường hợp bình thường (Không có ca)
      if (e.response?.statusCode == 204 ||
          e.response?.statusCode == 404 ||
          e.response?.data == null) {
        return null;
      }
      rethrow;
    } catch (_) {
      // Lỗi parse body rỗng do Retrofit
      return null;
    }
  }

  Future<List<EmployeeShiftScheduleDto>> getMySchedule({DateTime? from, DateTime? to}) {
    return _restClient.getMySchedule(
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
    );
  }
}