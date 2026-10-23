import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/chatbot_controller.dart';
import '../../core/app_colors.dart';
import '../../data/network/models/chat_models.dart';
import 'widgets/chat_input_bar.dart';
import 'widgets/chat_message_bubble.dart';
import 'widgets/chat_quick_suggestions.dart';
import 'widgets/chat_typing_indicator.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> with WidgetsBindingObserver {
  late final ChatbotController controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    controller = Get.put(ChatbotController());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // Cuộn xuống khi bàn phím xuất hiện
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
      leading: Builder(
        builder: (ctx) => IconButton(
          icon: const Icon(LucideIcons.history, size: 22, color: AppColors.primary),
          tooltip: "Lịch sử trò chuyện",
          onPressed: () => Scaffold.of(ctx).openDrawer(),
        ),
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
                  final sessionTitle = activeSession?.title ?? "SmartHR Assistant";
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
                      "AI Trợ lý Nhân sự • Trực tuyến",
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

  /// Drawer hiển thị Sidebar Lịch sử các Cuộc trò chuyện theo Chuẩn ChatGPT/Gemini
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
                              "SmartHR AI Chat",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : const Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              "Lịch sử trò chuyện theo tài khoản",
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

            // Danh sách các Phiên trò chuyện trong Lịch sử
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
