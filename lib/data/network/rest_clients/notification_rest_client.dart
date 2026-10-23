import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/notification_models.dart';
import '../models/common_models.dart';

part 'notification_rest_client.g.dart';

@RestApi()
abstract class NotificationRestClient {
  factory NotificationRestClient(Dio dio, {String baseUrl}) = _NotificationRestClient;

  @POST('Notification/register-token')
  Future<void> registerToken(@Body() RegisterFcmTokenRequest request);

  @DELETE('Notification/unregister-token')
  Future<void> unregisterToken(@Query('deviceId') String? deviceId);

  @GET('Notification/unread-count')
  Future<CountResponse> getUnreadCount();

  @GET('Notification/my-notifications')
  Future<PagedResponse<NotificationLogDto>> getMyNotifications({
    @Query('page') int page = 1,
    @Query('pageSize') int pageSize = 20,
  });

  @PUT('Notification/{id}/read')
  Future<void> markAsRead(@Path('id') int id);

  @PUT('Notification/read-all')
  Future<void> readAll();
}
