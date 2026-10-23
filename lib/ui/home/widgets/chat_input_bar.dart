import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/app_colors.dart';

class ChatInputBar extends StatelessWidget {
  final TextEditingController textController;
  final bool isBusy;
  final ValueChanged<String> onSubmitted;

  const ChatInputBar({
    super.key,
    required this.textController,
    required this.isBusy,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Icon(
            LucideIcons.sparkles,
            size: 18,
            color: isBusy
                ? Colors.grey
                : (isDark ? const Color(0xFF818CF8) : AppColors.primary),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: textController,
              enabled: !isBusy,
              style: GoogleFonts.poppins(
                fontSize: 13.5,
                color: isDark ? Colors.white : Colors.black87,
              ),
              textInputAction: TextInputAction.send,
              decoration: InputDecoration(
                hintText: isBusy
                    ? "SmartHR AI đang phản hồi..."
                    : "Nhập câu hỏi cho Trợ lý AI SmartHR...",
                hintStyle: GoogleFonts.poppins(
                  fontSize: 13,
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                ),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: InputBorder.none,
              ),
              onSubmitted: isBusy ? null : (val) => onSubmitted(val),
            ),
          ),
          const SizedBox(width: 8),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: textController,
            builder: (context, value, child) {
              final hasText = value.text.trim().isNotEmpty;
              final canSend = hasText && !isBusy;

              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: canSend
                      ? AppColors.primary
                      : (isDark ? Colors.grey.shade800 : Colors.grey.shade200),
                  shape: BoxShape.circle,
                  boxShadow: canSend
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: IconButton(
                  iconSize: 18,
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    LucideIcons.send,
                    color: canSend
                        ? Colors.white
                        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400),
                  ),
                  onPressed: canSend ? () => onSubmitted(textController.text) : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
