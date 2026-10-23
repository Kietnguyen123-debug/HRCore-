import 'package:json_annotation/json_annotation.dart';

part 'notification_models.g.dart';

@JsonSerializable(createToJson: true)
class RegisterFcmTokenRequest {
  final String fcmToken;
  final String? deviceId;

  const RegisterFcmTokenRequest({
    required this.fcmToken,
    this.deviceId,
  });

  factory RegisterFcmTokenRequest.fromJson(Map<String, dynamic> json) => _$RegisterFcmTokenRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterFcmTokenRequestToJson(this);
}

class NotificationLogDto {
  final int id;
  final String? title;
  final String? body;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  const NotificationLogDto({
    required this.id,
    this.title,
    this.body,
    this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory NotificationLogDto.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic val) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String && val.isNotEmpty) {
        try {
          return DateTime.parse(val);
        } catch (_) {}
      }
      return DateTime.now();
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    final id = parseInt(findKey(['id', 'Id']));
    final title = findKey(['title', 'Title']) as String?;
    final body = findKey(['body', 'Body', 'message', 'Message']) as String?;
    final type = findKey(['type', 'Type']) as String?;
    final isRead = (findKey(['isRead', 'IsRead']) as bool?) ?? false;
    final createdAt = parseDate(findKey(['createdAt', 'CreatedAt']));

    return NotificationLogDto(
      id: id,
      title: title,
      body: body,
      type: type,
      isRead: isRead,
      createdAt: createdAt,
    );
  }
}

class CountResponse {
  final int count;

  const CountResponse({this.count = 0});

  factory CountResponse.fromJson(Map<String, dynamic> json) {
    final val = json['count'] ?? json['Count'];
    if (val is num) return CountResponse(count: val.toInt());
    if (val is String) return CountResponse(count: int.tryParse(val) ?? 0);
    return const CountResponse(count: 0);
  }
}
