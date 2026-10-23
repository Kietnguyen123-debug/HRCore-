import 'package:dio/dio.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/salary_advance_models.dart';
import '../data/network/models/common_models.dart';
import '../data/network/rest_clients/salary_advance_rest_client.dart';

class SalaryAdvanceRepository {
  final SalaryAdvanceRestClient _restClient;
  final Dio _dio;

  SalaryAdvanceRepository({SalaryAdvanceRestClient? restClient, Dio? dio})
      : _dio = dio ?? DioClient().dio,
        _restClient = restClient ?? SalaryAdvanceRestClient(dio ?? DioClient().dio);

  Future<SalaryAdvanceResponse> requestAdvance({
    required double amount,
    required String reason,
  }) {
    return _restClient.requestAdvance(SalaryAdvanceRequest(
      amount: amount,
      reason: reason,
    ));
  }

  Future<List<SalaryAdvanceResponse>> getMyRequests() async {
    try {
      final response = await _dio.get('SalaryAdvance/my-requests');
      final list = _extractList(response.data);
      return list
          .whereType<Map>()
          .map((json) => SalaryAdvanceResponse.fromJson(Map<String, dynamic>.from(json)))
          .toList();
    } catch (_) {
      return await _restClient.getMyRequests();
    }
  }

  Future<CancelRequestResponse> cancelRequest(int id) {
    return _restClient.cancelRequest(id);
  }

  List<dynamic> _extractList(dynamic rawData) {
    if (rawData == null) return [];
    if (rawData is List) return rawData;
    if (rawData is Map) {
      final map = Map<String, dynamic>.from(rawData);
      for (final key in ['data', 'items', 'result', '\$values', 'list']) {
        if (map.containsKey(key) && map[key] is List) {
          return map[key] as List;
        }
      }
      if (map.containsKey('data') && map['data'] is Map) {
        final inner = Map<String, dynamic>.from(map['data'] as Map);
        for (final key in ['items', '\$values', 'data', 'list']) {
          if (inner.containsKey(key) && inner[key] is List) {
            return inner[key] as List;
          }
        }
      }
    }
    return [];
  }
}
