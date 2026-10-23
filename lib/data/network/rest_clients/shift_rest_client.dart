import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/shift_models.dart';

part 'shift_rest_client.g.dart';

@RestApi()
abstract class ShiftRestClient {
  factory ShiftRestClient(Dio dio, {String baseUrl}) = _ShiftRestClient;

  @GET('Shift')
  Future<List<ShiftDto>> getAll();

  @GET('Shift/my-today')
  Future<EmployeeShiftScheduleDto?> getMyToday();

  @GET('Shift/my-schedule')
  Future<List<EmployeeShiftScheduleDto>> getMySchedule({
    @Query('from') String? from,
    @Query('to') String? to,
  });
}
