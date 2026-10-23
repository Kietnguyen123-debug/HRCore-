// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessageHistoryDto _$ChatMessageHistoryDtoFromJson(
  Map<String, dynamic> json,
) => ChatMessageHistoryDto(
  role: json['role'] as String,
  text: json['text'] as String,
);

Map<String, dynamic> _$ChatMessageHistoryDtoToJson(
  ChatMessageHistoryDto instance,
) => <String, dynamic>{'role': instance.role, 'text': instance.text};

ChatRequestDto _$ChatRequestDtoFromJson(Map<String, dynamic> json) =>
    ChatRequestDto(
      message: json['message'] as String,
      history: (json['history'] as List<dynamic>?)
          ?.map(
            (e) => ChatMessageHistoryDto.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
    );

Map<String, dynamic> _$ChatRequestDtoToJson(ChatRequestDto instance) =>
    <String, dynamic>{'message': instance.message, 'history': instance.history};

ChatResponseDto _$ChatResponseDtoFromJson(Map<String, dynamic> json) =>
    ChatResponseDto(
      success: json['success'] as bool,
      reply: json['reply'] as String?,
      executedAction: json['executedAction'] as String?,
    );
