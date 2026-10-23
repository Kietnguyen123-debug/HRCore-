import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../data/network/dio_client.dart';
import '../data/network/models/chat_models.dart';
import '../data/network/rest_clients/chatbot_rest_client.dart';

/// Repository responsible for Chatbot AI interactions supporting multi-turn chat history.
class ChatbotRepository {
  final ChatbotRestClient _restClient;

  ChatbotRepository({ChatbotRestClient? restClient})
      : _restClient = restClient ?? ChatbotRestClient(DioClient().dio);

  /// Sends a chat message with up to 6 recent messages as history to the SmartHR AI backend.
  Future<ChatResponseDto> sendMessage({
    required String message,
    List<ChatMessage>? currentMessages,
  }) async {
    try {
      // Logic xử lý Lịch sử (History) 6 tin nhắn gần nhất
      List<ChatMessageHistoryDto> history = [];

      if (currentMessages != null && currentMessages.isNotEmpty) {
        // 1. Lọc bỏ tin nhắn rác, tin báo lỗi, warning và tin đang pending
        final validMessages = currentMessages.where((m) {
          if (m.isPending) return false;
          final text = m.text.trim();
          if (text.isEmpty) return false;
          if (text.contains('⚠️')) return false;
          if (text.toLowerCase().contains('timeout')) return false;
          if (text.toLowerCase().contains('rất tiếc')) return false;
          return true;
        }).toList();

        // 2. Cắt tỉa History: lấy tối đa 6 tin nhắn gần nhất
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

      // Log chi tiết lỗi ra Console để Debug khi phát triển
      debugPrint("❌ [Chatbot API Error] Status Code: $statusCode");
      debugPrint("❌ [Chatbot API Error] Response Body: $data");
      debugPrint("❌ [Chatbot API Error] Exception Type: ${e.type}");

      String errorMsg = "";

      if (e.response != null) {
        // 1. Lấy thông báo lỗi từ JSON Server trả về (Thử tìm cả 'reply', 'message', 'error')
        if (data is Map) {
          errorMsg = data['reply'] ??
              data['Reply'] ??
              data['message'] ??
              data['Message'] ??
              data['error'] ??
              "";
        }

        // 2. Nếu Server không trả về chuỗi lỗi cụ thể, phân loại theo Status Code
        if (errorMsg.isEmpty) {
          if (statusCode == 400) {
            errorMsg = "Yêu cầu không hợp lệ (Lỗi 400). Vui lòng kiểm tra lại dữ liệu.";
          } else if (statusCode == 401) {
            errorMsg = "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
          } else if (statusCode == 404) {
            errorMsg = "Không tìm thấy API Chatbot (Lỗi 404).";
          } else if (statusCode == 500) {
            errorMsg = "Lỗi máy chủ nội bộ (Lỗi 500). Chi tiết: ${data.toString()}";
          } else {
            errorMsg = "Máy chủ trả về lỗi HTTP $statusCode.";
          }
        }
      } else {
        // Trường hợp thực sự không có kết nối mạng / Server offline hoàn toàn
        if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMsg = "Yêu cầu báo cáo mất nhiều thời gian hơn dự kiến. Vui lòng thử lại sau ít phút!";
        } else {
          errorMsg = "Không thể kết nối đến máy chủ AI. Vui lòng kiểm tra lại mạng hoặc IP Server.";
        }
      }

      return ChatResponseDto(
        success: false,
        reply: "⚠️ $errorMsg",
        executedAction: null,
      );
    } catch (e) {
      debugPrint("❌ Lỗi không xác định khi gọi Chatbot: $e");
      return ChatResponseDto(
        success: false,
        reply: "⚠️ Đã xảy ra lỗi không xác định: $e",
        executedAction: null,
      );
    }
  }
}