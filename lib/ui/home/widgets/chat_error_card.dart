import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

class ChatErrorCard extends StatelessWidget {
  final String text;
  final DateTime timestamp;
  final bool isDark;

  const ChatErrorCard({
    super.key,
    required this.text,
    required this.timestamp,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    // Loại bỏ kí tự ⚠️ thừa nếu có ở đầu chuỗi
    final cleanText = text.replaceFirst(RegExp(r'^⚠️\s*'), '');

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFCA5A5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.alertTriangle, size: 18, color: Colors.redAccent),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Cảnh báo hệ thống",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                      Text(
                        DateFormat('HH:mm').format(timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? Colors.red.shade300 : Colors.red.shade400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    cleanText,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: isDark ? Colors.red.shade100 : Colors.red.shade900,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
