import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../repositories/chatbot_repository.dart';
import '../data/network/models/chat_models.dart';

class ChatbotController extends GetxController {
  final ChatbotRepository _repository = ChatbotRepository();

  /// Danh sách các Phiên trò chuyện (Session) của tài khoản hiện tại
  final RxList<ChatSession> sessions = <ChatSession>[].obs;

  /// Phiên trò chuyện đang chọn mở trên giao diện
  final Rxn<ChatSession> currentSession = Rxn<ChatSession>();

  /// Tin nhắn hiển thị trên UI của phiên trò chuyện hiện tại
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  final RxBool isTyping = false.obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  /// Gợi ý nhanh cho người dùng
  final List<String> quickSuggestions = [
    "Xin nghỉ phép ngày mai",
    "Xem công tháng này",
    "Phiếu lương tháng mới nhất",
    "Số ngày phép còn lại",
    "Quy định tăng ca",
  ];

  @override
  void onInit() {
    super.onInit();
    loadSessionsForCurrentAccount();
  }

  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }

  /// Lấy Key lưu trữ danh sách phiên chat theo Tài khoản hiện tại
  Future<String> _getStorageKey() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('employeeCode')?.trim();
    if (code != null && code.isNotEmpty) {
      return 'chat_sessions_$code';
    }
    final name = prefs.getString('userName')?.trim();
    if (name != null && name.isNotEmpty) {
      return 'chat_sessions_$name';
    }
    return 'chat_sessions_default';
  }

  /// Tải toàn bộ Phiên trò chuyện của Tài khoản hiện tại từ SharedPreferences
  Future<void> loadSessionsForCurrentAccount() async {
    try {
      final key = await _getStorageKey();
      final prefs = await SharedPreferences.getInstance();
      final String? jsonString = prefs.getString(key);

      if (jsonString != null && jsonString.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(jsonString);
        final loadedSessions = decoded
            .map((item) => ChatSession.fromJson(Map<String, dynamic>.from(item)))
            .toList();

        if (loadedSessions.isNotEmpty) {
          // Sắp xếp theo thời gian mới nhất lên đầu
          loadedSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          sessions.assignAll(loadedSessions);

          // Chọn phiên trò chuyện gần đây nhất
          switchSession(loadedSessions.first);
          return;
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch sử phiên chat tài khoản: $e");
    }

    // Nếu tài khoản chưa có lịch sử phiên nào, tạo cuộc trò chuyện mới ban đầu
    createNewSession();
  }

  /// Lưu danh sách Phiên trò chuyện của Tài khoản hiện tại vào SharedPreferences
  Future<void> saveSessions() async {
    try {
      final key = await _getStorageKey();
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint("Lỗi lưu danh sách phiên chat: $e");
    }
  }

  /// Tạo một Cuộc Trò Chuyện Mới (+ New Chat)
  void createNewSession() {
    final now = DateTime.now();
    final newId = "session_${now.millisecondsSinceEpoch}";

    final initialGreeting = ChatMessage(
      id: "greeting_${now.millisecondsSinceEpoch}",
      text: "Xin chào! Tôi là **Trợ lý AI SmartHR** 🤖✨\n\nTôi có thể giúp bạn kiểm tra **ngày công**, **số dư phép**, **bảng lương** hoặc hướng dẫn các **quy trình xin nghỉ/tăng ca**.\n\nBạn cần trợ giúp gì hôm nay?",
      isUser: false,
      timestamp: now,
    );

    final newSession = ChatSession(
      id: newId,
      title: "Cuộc trò chuyện mới",
      createdAt: now,
      updatedAt: now,
      messages: [initialGreeting],
    );

    sessions.insert(0, newSession);
    currentSession.value = newSession;
    messages.assignAll(newSession.messages);

    saveSessions();
    _scrollToBottom();
  }

  /// Chuyển đổi sang phiên trò chuyện cũ từ Sidebar
  void switchSession(ChatSession session) {
    currentSession.value = session;
    messages.assignAll(session.messages);
    _scrollToBottom();
  }

  /// Xóa một phiên trò chuyện khỏi lịch sử
  Future<void> deleteSession(String sessionId) async {
    sessions.removeWhere((s) => s.id == sessionId);

    if (currentSession.value?.id == sessionId) {
      if (sessions.isNotEmpty) {
        switchSession(sessions.first);
      } else {
        createNewSession();
      }
    } else {
      saveSessions();
    }
  }

  /// Gửi tin nhắn và tiếp tục trao đổi trên Phiên hiện tại
  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty || isTyping.value) return;

    if (currentSession.value == null) {
      createNewSession();
    }

    final activeSession = currentSession.value!;

    // Snapshot các tin nhắn cũ trong phiên hiện tại trước khi gửi
    final List<ChatMessage> historySnapshot = List<ChatMessage>.from(messages);

    // 1. Thêm tin nhắn của User vào danh sách UI và Session
    final userMsgId = "user_${DateTime.now().millisecondsSinceEpoch}";
    final userMessage = ChatMessage(
      id: userMsgId,
      text: cleanText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    messages.add(userMessage);
    activeSession.messages.add(userMessage);

    // Tự động cập nhật Tiêu đề phiên chat theo câu hỏi đầu tiên của người dùng
    if (activeSession.title == "Cuộc trò chuyện mới") {
      activeSession.title = cleanText.length > 32
          ? "${cleanText.substring(0, 32)}..."
          : cleanText;
    }

    textController.clear();
    isTyping.value = true;
    _scrollToBottom();

    // 2. Gọi API kèm Lịch sử hội thoại của đúng phiên hiện tại
    final response = await _repository.sendMessage(
      message: cleanText,
      currentMessages: historySnapshot,
    );

    // 3. Cập nhật phản hồi thực tế từ AI Bot vào Session hiện tại
    final replyText = response.reply ?? "Tôi chưa hiểu rõ câu hỏi của bạn. Vui lòng thử lại.";
    final isErrorMsg = !response.success || replyText.startsWith('⚠️') || replyText.toLowerCase().contains('timeout');

    final botMsgId = "bot_${DateTime.now().millisecondsSinceEpoch}";
    final botMessage = ChatMessage(
      id: botMsgId,
      text: replyText,
      isUser: false,
      timestamp: DateTime.now(),
      executedAction: response.executedAction,
      isPending: false,
      isError: isErrorMsg,
    );

    messages.add(botMessage);
    activeSession.messages.add(botMessage);
    activeSession.updatedAt = DateTime.now();

    // Đẩy phiên vừa chát lên đầu danh sách
    sessions.remove(activeSession);
    sessions.insert(0, activeSession);

    isTyping.value = false;
    _scrollToBottom();

    // 4. Lưu lại toàn bộ danh sách phiên chat theo tài khoản
    saveSessions();
  }

  void selectSuggestion(String suggestion) {
    if (isTyping.value) return;
    textController.text = suggestion;
    textController.selection = TextSelection.fromPosition(
      TextPosition(offset: suggestion.length),
    );
    sendMessage(suggestion);
  }

  /// Xóa toàn bộ tin nhắn trong phiên hiện tại
  Future<void> clearCurrentSession() async {
    if (currentSession.value != null) {
      deleteSession(currentSession.value!.id);
    }
  }

  void scrollToBottom() {
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}
