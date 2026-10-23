import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:intl/intl.dart';
import '../../controllers/notification_controller.dart';
import '../../core/app_colors.dart';
import '../../data/network/models/notification_models.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  final NotificationController controller = Get.put(NotificationController());

  @override
  void initState() {
    super.initState();
    controller.refreshAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Thông báo", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.checkCheck),
            tooltip: "Đánh dấu tất cả đã đọc",
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bellOff, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "Bạn chưa có thông báo nào",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshAll,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.notifications.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = controller.notifications[index];
              return _buildNotificationItem(n);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationLogDto n) {
    bool isRead = n.isRead;
    
    return InkWell(
      onTap: () {
        if (!isRead) controller.markAsRead(n.id);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isRead ? Theme.of(context).cardColor : AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRead ? Theme.of(context).dividerColor.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isRead ? Colors.grey.withValues(alpha: 0.1) : AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRead ? LucideIcons.bell : LucideIcons.bellRing,
                color: isRead ? Colors.grey : AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    n.title ?? "Thông báo hệ thống",
                    style: GoogleFonts.poppins(
                      fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                      fontSize: 15,
                      color: isRead ? Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.7) : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.body ?? "",
                    style: TextStyle(
                      fontSize: 13,
                      color: isRead ? Theme.of(context).textTheme.bodySmall?.color : Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    DateFormat('HH:mm - dd/MM/yyyy').format(n.createdAt.toLocal()),
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            if (!isRead)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
