import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/chat_models.dart';
import 'chat_error_card.dart';

class ChatMessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isDark;

  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isError) {
      return ChatErrorCard(
        text: message.text,
        timestamp: message.timestamp,
        isDark: isDark,
      );
    }

    final isUser = message.isUser;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.bot, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primary
                        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 4),
                      bottomRight: Radius.circular(isUser ? 4 : 18),
                    ),
                    border: Border.all(
                      color: isUser
                          ? Colors.transparent
                          : (isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : const Color(0xFFE2E8F0)),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isUser ? 0.08 : 0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Text(
                          message.text,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        )
                      : (message.isPending
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  message.text,
                                  style: GoogleFonts.poppins(
                                    fontSize: 13,
                                    color: AppColors.primary,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          : MarkdownBody(
                              data: message.text,
                              selectable: true,
                              styleSheet: _buildMarkdownStyleSheet(context, isDark),
                            )),
                ),
                if (!isUser &&
                    message.executedAction != null &&
                    message.executedAction!.trim().isNotEmpty) ...[
                  _buildExecutedActionBadge(message.executedAction!, isDark),
                ],
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: Text(
                    DateFormat('HH:mm').format(message.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.user, color: AppColors.primary, size: 16),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExecutedActionBadge(String rawAction, bool isDark) {
    final formattedAction = _formatActionText(rawAction);

    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2000) : const Color(0xFFFFF7ED),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFFB45309) : const Color(0xFFFDBA74),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.zap, size: 13, color: Color(0xFFD97706)),
          const SizedBox(width: 5),
          Text(
            "Hành động: $formattedAction",
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }

  String _formatActionText(String action) {
    final trimmed = action.trim();
    if (trimmed.contains(';')) {
      final parts = trimmed
          .split(';')
          .map((p) => _formatSingleAction(p.trim()))
          .where((p) => p.isNotEmpty);
      return parts.join(', ');
    }
    return _formatSingleAction(trimmed);
  }

  String _formatSingleAction(String action) {
    var clean = action.trim();
    if (clean.startsWith('Hành động:')) {
      clean = clean.replaceFirst('Hành động:', '').trim();
    }
    switch (clean) {
      case 'GetMyAttendanceSummary':
      case 'CheckAttendance':
        return 'Tra cứu tổng quan ngày công';
      case 'GetMyLeaveBalance':
      case 'CheckLeaveBalance':
        return 'Kiểm tra số dư phép năm';
      case 'GetMyShiftSchedule':
        return 'Xem ca làm việc';
      case 'GetMyPayslip':
      case 'CheckPayroll':
        return 'Tra cứu phiếu lương';
      case 'GetAdminDashboardOverview':
        return 'Xem tổng quan quản trị';
      case 'CreateLeaveRequest':
        return 'Tạo đơn xin nghỉ phép';
      case 'RequestSalaryAdvance':
        return 'Yêu cầu tạm ứng lương';
      case 'SubmitAttendanceExplanation':
      case 'CreateAttendanceExplanation':
        return 'Gửi đơn giải trình chấm công';
      case 'SubmitOvertimeRequest':
      case 'CreateOvertimeRequest':
        return 'Đăng ký làm tăng ca';
      default:
        return clean;
    }
  }

  MarkdownStyleSheet _buildMarkdownStyleSheet(BuildContext context, bool isDark) {
    final textColor = isDark ? Colors.grey.shade100 : const Color(0xFF1E293B);
    final codeBg = isDark ? Colors.black45 : const Color(0xFFE2E8F0);

    return MarkdownStyleSheet(
      p: GoogleFonts.poppins(
        fontSize: 14,
        height: 1.5,
        color: textColor,
      ),
      strong: GoogleFonts.poppins(
        fontWeight: FontWeight.w700,
        color: isDark ? const Color(0xFF818CF8) : AppColors.primary,
      ),
      em: GoogleFonts.poppins(
        fontStyle: FontStyle.italic,
        color: textColor,
      ),
      h1: GoogleFonts.poppins(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.primary,
        height: 1.4,
      ),
      h2: GoogleFonts.poppins(
        fontSize: 15.5,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppColors.primary,
        height: 1.4,
      ),
      h3: GoogleFonts.poppins(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : AppColors.primary,
        height: 1.4,
      ),
      code: TextStyle(
        backgroundColor: codeBg,
        fontFamily: 'monospace',
        fontSize: 12.5,
        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
      ),
      codeblockDecoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      tableHead: GoogleFonts.poppins(
        fontWeight: FontWeight.bold,
        fontSize: 12.5,
        color: isDark ? Colors.white : AppColors.primary,
      ),
      tableBody: GoogleFonts.poppins(
        fontSize: 12.5,
        color: textColor,
      ),
      tableBorder: TableBorder.all(
        color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
        width: 1,
        borderRadius: BorderRadius.circular(6),
      ),
      tablePadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      tableCellsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      listBullet: GoogleFonts.poppins(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
      ),
      blockquoteDecoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(4),
        border: const Border(
          left: BorderSide(color: AppColors.primary, width: 3.5),
        ),
      ),
      blockquotePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }
}
