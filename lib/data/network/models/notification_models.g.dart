// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterFcmTokenRequest _$RegisterFcmTokenRequestFromJson(
  Map<String, dynamic> json,
) => RegisterFcmTokenRequest(
  fcmToken: json['fcmToken'] as String,
  deviceId: json['deviceId'] as String?,
);

Map<String, dynamic> _$RegisterFcmTokenRequestToJson(
  RegisterFcmTokenRequest instance,
) => <String, dynamic>{
  'fcmToken': instance.fcmToken,
  'deviceId': instance.deviceId,
};

NotificationLogDto _$NotificationLogDtoFromJson(Map<String, dynamic> json) =>
    NotificationLogDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String?,
      body: json['body'] as String?,
      type: json['type'] as String?,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

CountResponse _$CountResponseFromJson(Map<String, dynamic> json) =>
    CountResponse(count: (json['count'] as num?)?.toInt() ?? 0);
