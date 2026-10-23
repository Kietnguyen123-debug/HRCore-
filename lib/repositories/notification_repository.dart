import '../data/network/dio_client.dart';
import '../data/network/models/notification_models.dart';
import '../data/network/models/common_models.dart';
import '../data/network/rest_clients/notification_rest_client.dart';

/// Repository responsible for notification management, including
/// FCM token registration and fetching personal notification logs.
class NotificationRepository {
  final NotificationRestClient _restClient;

  NotificationRepository({NotificationRestClient? restClient})
      : _restClient = restClient ?? NotificationRestClient(DioClient().dio);

  /// Registers a Firebase Cloud Messaging token for the current device.
  Future<void> registerToken({required String fcmToken, String? deviceId}) {
    return _restClient.registerToken(RegisterFcmTokenRequest(
      fcmToken: fcmToken,
      deviceId: deviceId,
    ));
  }

  /// Unregisters the FCM token for the current device.
  Future<void> unregisterToken({String? deviceId}) {
    return _restClient.unregisterToken(deviceId);
  }

  /// Fetches the count of unread notifications.
  Future<int> getUnreadCount() async {
    final response = await _restClient.getUnreadCount();
    return response.count;
  }

  /// Fetches a paginated list of notification logs for the authenticated user.
  Future<PagedResponse<NotificationLogDto>> getMyNotifications({
    int page = 1,
    int pageSize = 20,
  }) {
    return _restClient.getMyNotifications(page: page, pageSize: pageSize);
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(int id) {
    return _restClient.markAsRead(id);
  }

  /// Marks all notifications for the current user as read.
  Future<void> readAll() {
    return _restClient.readAll();
  }
}
