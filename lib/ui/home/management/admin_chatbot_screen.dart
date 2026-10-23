import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/chat_models.dart';
import '../../../repositories/admin_chatbot_repository.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/chat_message_bubble.dart';
import '../widgets/chat_quick_suggestions.dart';
import '../widgets/chat_typing_indicator.dart';

class AdminChatbotController extends GetxController {
  final AdminChatbotRepository _repo = AdminChatbotRepository();

  /// Danh sách các Phiên trò chuyện (Session) Admin của tài khoản hiện tại
  final RxList<ChatSession> sessions = <ChatSession>[].obs;

  /// Phiên trò chuyện đang chọn mở trên giao diện
  final Rxn<ChatSession> currentSession = Rxn<ChatSession>();

  /// Tin nhắn hiển thị trên UI của phiên trò chuyện hiện tại
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;

  final RxBool isTyping = false.obs;
  final TextEditingController textController = TextEditingController();
  final ScrollController scrollController = ScrollController();

  /// Gợi ý nhanh cho Quản trị viên
  final List<String> quickSuggestions = [
    "📊 Thống kê chấm công hôm nay",
    "⏰ Danh sách nhân viên đi trễ",
    "📋 Tình trạng đơn cần phê duyệt",
    "💰 Báo cáo tổng quan quỹ lương",
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

  /// Lấy Key lưu trữ danh sách phiên chat Admin theo Tài khoản hiện tại
  Future<String> _getStorageKey() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('employeeCode')?.trim();
    if (code != null && code.isNotEmpty) {
      return 'admin_chat_sessions_$code';
    }
    final name = prefs.getString('userName')?.trim();
    if (name != null && name.isNotEmpty) {
      return 'admin_chat_sessions_$name';
    }
    return 'admin_chat_sessions_default';
  }

  /// Tải toàn bộ Phiên trò chuyện Admin từ SharedPreferences
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
          loadedSessions.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          sessions.assignAll(loadedSessions);
          switchSession(loadedSessions.first);
          return;
        }
      }
    } catch (e) {
      debugPrint("Lỗi tải lịch sử phiên chat admin: $e");
    }

    createNewSession();
  }

  /// Lưu danh sách Phiên trò chuyện Admin vào SharedPreferences
  Future<void> saveSessions() async {
    try {
      final key = await _getStorageKey();
      final prefs = await SharedPreferences.getInstance();
      final String encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(key, encoded);
    } catch (e) {
      debugPrint("Lỗi lưu danh sách phiên chat admin: $e");
    }
  }

  /// Tạo một Cuộc Trò Chuyện Mới (+ New Chat)
  Future<void> createNewSession() async {
    final now = DateTime.now();
    final newId = "admin_session_${now.millisecondsSinceEpoch}";

    String greeting = "Xin chào Quản trị viên! Tôi là Trợ lý AI quản trị Nhân sự. Tôi có thể giúp gì cho bạn về dữ liệu chấm công, nhân sự, bảng lương hôm nay?";
    try {
      await _repo.checkAccess();
    } catch (_) {
      greeting = "Bạn không có quyền truy cập vào Admin Chatbot (Yêu cầu quyền Admin/HR/HRManager).";
    }

    final initialGreeting = ChatMessage(
      id: "greeting_${now.millisecondsSinceEpoch}",
      text: greeting,
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
      await createNewSession();
    }

    final activeSession = currentSession.value!;
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
    final response = await _repo.sendMessage(
      message: cleanText,
      currentMessages: historySnapshot,
    );

    // 3. Cập nhật phản hồi từ AI
    final replyText = response.reply ?? "Tôi chưa nhận được phản hồi từ máy chủ AI.";
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

class AdminChatbotScreen extends StatefulWidget {
  const AdminChatbotScreen({super.key});

  @override
  State<AdminChatbotScreen> createState() => _AdminChatbotScreenState();
}

class _AdminChatbotScreenState extends State<AdminChatbotScreen> with WidgetsBindingObserver {
  late final AdminChatbotController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.isRegistered<AdminChatbotController>()
        ? Get.find<AdminChatbotController>()
        : Get.put(AdminChatbotController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    if (View.of(context).viewInsets.bottom > 0) {
      controller.scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F172A)
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context, isDark),
      drawer: _buildHistoryDrawer(context, isDark),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _buildMessageList(context, isDark),
            ),
            Obx(
              () => controller.isTyping.value
                  ? ChatTypingIndicator(isDark: isDark)
                  : const SizedBox.shrink(),
            ),
            Obx(
              () => ChatQuickSuggestions(
                suggestions: controller.quickSuggestions,
                isDisabled: controller.isTyping.value,
                onSelected: (suggestion) => controller.selectSuggestion(suggestion),
              ),
            ),
            Obx(
              () => ChatInputBar(
                textController: controller.textController,
                isBusy: controller.isTyping.value,
                onSubmitted: (val) => controller.sendMessage(val),
              ),
            ),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDark) {
    return AppBar(
      elevation: 0.5,
      titleSpacing: 0,
      backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, size: 22, color: AppColors.primary),
        tooltip: "Quay lại",
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.bot, color: AppColors.primary, size: 20),
              ),
              Positioned(
                bottom: 1,
                right: 1,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Obx(() {
                  final activeSession = controller.currentSession.value;
                  final sessionTitle = activeSession?.title ?? "Admin AI Assistant";
                  return Text(
                    sessionTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.bold,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : const Color(0xFF1E293B),
                    ),
                  );
                }),
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 10, color: Colors.amber),
                    const SizedBox(width: 3),
                    Text(
                      "AI Trợ lý Quản trị • Trực tuyến",
                      style: GoogleFonts.poppins(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(LucideIcons.history, size: 20, color: AppColors.primary),
            tooltip: "Lịch sử trò chuyện",
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        IconButton(
          icon: const Icon(LucideIcons.plusCircle, size: 21, color: AppColors.primary),
          tooltip: "Cuộc trò chuyện mới",
          onPressed: () => controller.createNewSession(),
        ),
        IconButton(
          icon: const Icon(LucideIcons.refreshCw, size: 18),
          tooltip: "Làm mới cuộc trò chuyện này",
          onPressed: () => _confirmClearChat(context),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  /// Drawer hiển thị Sidebar Lịch sử các Cuộc trò chuyện Admin theo Chuẩn ChatGPT/Gemini
  Widget _buildHistoryDrawer(BuildContext context, bool isDark) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            // Drawer Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? Colors.white10 : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.bot, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "SmartHR Admin AI",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              "Lịch sử trò chuyện quản trị",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(LucideIcons.plus, size: 18),
                      label: Text(
                        "Cuộc trò chuyện mới",
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 13.5,
                        ),
                      ),
                      onPressed: () {
                        controller.createNewSession();
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách các Phiên trò chuyện Admin trong Lịch sử
            Expanded(
              child: Obx(() {
                if (controller.sessions.isEmpty) {
                  return Center(
                    child: Text(
                      "Chưa có lịch sử trò chuyện",
                      style: GoogleFonts.poppins(
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                  itemCount: controller.sessions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 4),
                  itemBuilder: (context, index) {
                    final session = controller.sessions[index];
                    final isSelected = session.id == controller.currentSession.value?.id;

                    return _buildSessionTile(context, session, isSelected, isDark);
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(
    BuildContext context,
    ChatSession session,
    bool isSelected,
    bool isDark,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? (isDark ? AppColors.primary.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.10))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : Colors.transparent,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        dense: true,
        leading: Icon(
          LucideIcons.messageSquare,
          size: 18,
          color: isSelected ? AppColors.primary : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
        ),
        title: Text(
          session.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.white : AppColors.primary)
                : (isDark ? Colors.grey.shade200 : const Color(0xFF334155)),
          ),
        ),
        subtitle: Text(
          DateFormat('HH:mm • dd/MM/yyyy').format(session.updatedAt),
          style: GoogleFonts.poppins(
            fontSize: 10.5,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.redAccent),
          tooltip: "Xóa cuộc trò chuyện này",
          onPressed: () => _confirmDeleteSession(context, session),
        ),
        onTap: () {
          controller.switchSession(session);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _confirmDeleteSession(BuildContext context, ChatSession session) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
            const SizedBox(width: 10),
            Text(
              "Xóa cuộc trò chuyện",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          "Bạn có chắc chắn muốn xóa cuộc trò chuyện \"${session.title}\" không?",
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            height: 1.4,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "HỦY",
              style: GoogleFonts.poppins(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              controller.deleteSession(session.id);
            },
            child: Text(
              "XÓA",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(BuildContext context, bool isDark) {
    return Obx(
      () => ListView.builder(
        controller: controller.scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: controller.messages.length,
        itemBuilder: (context, index) {
          final msg = controller.messages[index];
          return ChatMessageBubble(
            message: msg,
            isDark: isDark,
          );
        },
      ),
    );
  }

  void _confirmClearChat(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Get.dialog(
      AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(LucideIcons.refreshCw, color: AppColors.primary, size: 20),
            const SizedBox(width: 10),
            Text(
              "Làm mới cuộc trò chuyện",
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
          ],
        ),
        content: Text(
          "Bạn có chắc chắn muốn xóa phiên trò chuyện hiện tại không?",
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            height: 1.4,
            color: isDark ? Colors.grey.shade300 : const Color(0xFF475569),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              "HỦY",
              style: GoogleFonts.poppins(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () {
              Get.back();
              controller.clearCurrentSession();
            },
            child: Text(
              "XÓA",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
