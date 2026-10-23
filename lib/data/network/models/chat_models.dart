import 'package:json_annotation/json_annotation.dart';

part 'chat_models.g.dart';

@JsonSerializable(createToJson: true)
class ChatMessageHistoryDto {
  final String role; // "user" hoặc "model"
  final String text;

  const ChatMessageHistoryDto({
    required this.role,
    required this.text,
  });

  factory ChatMessageHistoryDto.fromJson(Map<String, dynamic> json) => _$ChatMessageHistoryDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatMessageHistoryDtoToJson(this);
}

@JsonSerializable(createToJson: true)
class ChatRequestDto {
  final String message;
  final List<ChatMessageHistoryDto>? history;

  const ChatRequestDto({
    required this.message,
    this.history,
  });

  factory ChatRequestDto.fromJson(Map<String, dynamic> json) => _$ChatRequestDtoFromJson(json);
  Map<String, dynamic> toJson() => _$ChatRequestDtoToJson(this);
}

class ChatResponseDto {
  final bool success;
  final String? reply;
  final String? executedAction;

  const ChatResponseDto({
    required this.success,
    this.reply,
    this.executedAction,
  });

  factory ChatResponseDto.fromJson(Map<String, dynamic> rawJson) {
    Map<String, dynamic> json = rawJson;
    if (rawJson.containsKey('data') && rawJson['data'] is Map) {
      json = Map<String, dynamic>.from(rawJson['data'] as Map);
    } else if (rawJson.containsKey('result') && rawJson['result'] is Map) {
      json = Map<String, dynamic>.from(rawJson['result'] as Map);
    }

    dynamic findKey(List<String> keys) {
      for (final k in keys) {
        if (json.containsKey(k) && json[k] != null) return json[k];
      }
      return null;
    }

    final successVal = findKey(['success', 'Success', 'isSuccess', 'IsSuccess']);
    final replyVal = findKey([
      'reply', 'Reply',
      'message', 'Message',
      'answer', 'Answer',
      'text', 'Text',
      'detail', 'Detail',
      'title', 'Title',
      'error', 'Error'
    ]);
    final actionVal = findKey(['executedAction', 'ExecutedAction', 'action', 'Action']);

    bool isSuccess = false;
    if (successVal is bool) {
      isSuccess = successVal;
    } else if (successVal != null) {
      isSuccess = successVal.toString().toLowerCase() == 'true';
    } else {
      isSuccess = replyVal != null &&
          replyVal.toString().trim().isNotEmpty &&
          !json.containsKey('status') &&
          !json.containsKey('Status');
    }

    String? replyText = replyVal?.toString();
    if (!isSuccess && (replyText == null || replyText.isEmpty)) {
      if (json.containsKey('title')) replyText = json['title'].toString();
      if (json.containsKey('detail')) replyText = json['detail'].toString();
      if (json.containsKey('error')) replyText = json['error'].toString();
    }

    return ChatResponseDto(
      success: isSuccess,
      reply: replyText,
      executedAction: actionVal?.toString(),
    );
  }
}

/// Model dùng riêng cho giao diện UI
class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? executedAction;
  final bool isPending;
  final bool isError;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.executedAction,
    this.isPending = false,
    this.isError = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      text: json['text'] as String? ?? '',
      isUser: json['isUser'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? (DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now())
          : DateTime.now(),
      executedAction: json['executedAction'] as String?,
      isPending: json['isPending'] as bool? ?? false,
      isError: json['isError'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'isUser': isUser,
        'timestamp': timestamp.toIso8601String(),
        'executedAction': executedAction,
        'isPending': isPending,
        'isError': isError,
      };

  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    String? executedAction,
    bool? isPending,
    bool? isError,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      executedAction: executedAction ?? this.executedAction,
      isPending: isPending ?? this.isPending,
      isError: isError ?? this.isError,
    );
  }
}

/// Model đại diện cho một Phiên Trò Chuyện (Chat Session) riêng biệt như ChatGPT/Gemini
class ChatSession {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<ChatMessage> messages;

  ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory ChatSession.fromJson(Map<String, dynamic> json) {
    return ChatSession(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: json['title'] as String? ?? 'Cuộc trò chuyện mới',
      createdAt: json['createdAt'] != null
          ? (DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? (DateTime.tryParse(json['updatedAt'].toString()) ?? DateTime.now())
          : DateTime.now(),
      messages: (json['messages'] as List<dynamic>?)
              ?.map((m) => ChatMessage.fromJson(Map<String, dynamic>.from(m)))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
      };
}
