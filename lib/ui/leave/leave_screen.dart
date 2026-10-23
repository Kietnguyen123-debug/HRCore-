import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appdiemdanh/core/api_client.dart';
import 'package:appdiemdanh/core/app_colors.dart';

class LeaveScreen extends StatelessWidget {
  LeaveScreen({super.key});
  final _reasonCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text("Xin Nghỉ Phép")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Lý do nghỉ phép",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _reasonCtrl,
              maxLines: 5,
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: "Nhập chi tiết lý do của bạn...",
                hintStyle: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Thời gian dự kiến",
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_outlined, color: AppColors.primary, size: 20),
                  const SizedBox(width: 12),
                  Text("Hôm nay (05/09/2026)", style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  var now = DateTime.now().toIso8601String();
                  var res = await ApiClient().requestLeave(_reasonCtrl.text, now, now, "Khác");
                  Get.back();
                  Get.snackbar(
                    "Thành công",
                    res.data['message'] ?? "Đã gửi đơn thành công",
                    backgroundColor: AppColors.secondary,
                    colorText: Colors.white,
                  );
                },
                child: const Text("Gửi Đơn Xin Nghỉ"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
