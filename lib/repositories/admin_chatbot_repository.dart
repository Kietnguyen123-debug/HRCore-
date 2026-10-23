import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/chat_models.dart';
import '../data/network/rest_clients/admin_chatbot_rest_client.dart';

class AdminChatbotRepository {
  final AdminChatbotRestClient _restClient;

  AdminChatbotRepository({AdminChatbotRestClient? restClient})
      : _restClient = restClient ?? AdminChatbotRestClient(DioClient().dio);

  Future<void> checkAccess() {
    return _restClient.checkAccess();
  }

  Future<ChatResponseDto> chat(ChatRequestDto request) {
    return _restClient.chat(request);
  }

  /// Sends a chat message with up to 6 recent messages as history to the Admin AI backend.
  Future<ChatResponseDto> sendMessage({
    required String message,
    List<ChatMessage>? currentMessages,
  }) async {
    try {
      List<ChatMessageHistoryDto> history = [];

      if (currentMessages != null && currentMessages.isNotEmpty) {
        final validMessages = currentMessages.where((m) {
          if (m.isPending) return false;
          final text = m.text.trim();
          if (text.isEmpty) return false;
          if (text.contains('⚠️')) return false;
          if (text.toLowerCase().contains('timeout')) return false;
          return true;
        }).toList();

        const maxHistory = 6;
        final recentMessages = validMessages.length > maxHistory
            ? validMessages.sublist(validMessages.length - maxHistory)
            : validMessages;

        history = recentMessages.map((m) {
          return ChatMessageHistoryDto(
            role: m.isUser ? "user" : "model",
            text: m.text.trim(),
          );
        }).toList();
      }

      final requestDto = ChatRequestDto(
        message: message.trim(),
        history: history.isNotEmpty ? history : null,
      );

      final response = await _restClient.chat(requestDto);
      if (response.reply == null || response.reply!.trim().isEmpty) {
        return const ChatResponseDto(
          success: false,
          reply: "⚠️ Máy chủ AI chưa có câu trả lời cho nội dung này. Vui lòng thử lại.",
          executedAction: null,
        );
      }
      return response;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final data = e.response?.data;

      debugPrint("❌ [Admin Chatbot API Error] Status Code: $statusCode");
      debugPrint("❌ [Admin Chatbot API Error] Response Body: $data");

      String errorMsg = "";
      if (e.response != null) {
        if (data is Map) {
          errorMsg = data['reply'] ??
              data['Reply'] ??
              data['message'] ??
              data['Message'] ??
              data['error'] ??
              "";
        }
        if (errorMsg.isEmpty) {
          if (statusCode == 400) {
            errorMsg = "Yêu cầu không hợp lệ (Lỗi 400). Vui lòng kiểm tra lại dữ liệu.";
          } else if (statusCode == 401) {
            errorMsg = "Phiên đăng nhập đã hết hạn hoặc không có quyền Admin/HR.";
          } else if (statusCode == 403) {
            errorMsg = "Bạn không có quyền truy cập vào Admin Chatbot.";
          } else if (statusCode == 500) {
            errorMsg = "Lỗi máy chủ nội bộ (Lỗi 500). Chi tiết: ${data.toString()}";
          } else {
            errorMsg = "Máy chủ trả về lỗi HTTP $statusCode.";
          }
        }
      } else {
        errorMsg = "Không thể kết nối đến máy chủ AI quản trị. Vui lòng kiểm tra lại mạng.";
      }

      return ChatResponseDto(
        success: false,
        reply: "⚠️ $errorMsg",
        executedAction: null,
      );
    } catch (e) {
      return ChatResponseDto(
        success: false,
        reply: "⚠️ Đã xảy ra lỗi không xác định: $e",
        executedAction: null,
      );
    }
  }
}
