import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/department_controller.dart';
import '../../../data/network/models/department_models.dart';
import '../../../core/app_colors.dart';

class DepartmentListScreen extends StatefulWidget {
  const DepartmentListScreen({super.key});

  @override
  State<DepartmentListScreen> createState() => _DepartmentListScreenState();
}

class _DepartmentListScreenState extends State<DepartmentListScreen> {
  final DepartmentController controller = Get.put(DepartmentController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Quản lý phòng ban"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => controller.fetchDepartments(),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.departments.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.departments.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.building, size: 64, color: Colors.grey.shade300),
                const SizedBox(height: 16),
                Text(
                  "Chưa có phòng ban nào",
                  style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchDepartments,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.departments.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final dept = controller.departments[index];
              return _buildDepartmentCard(dept);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDepartmentModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDepartmentCard(DepartmentListItemResponse dept) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(LucideIcons.building, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dept.name ?? "N/A",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  "ID: ${dept.id}",
                  style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.edit3, color: Colors.blue, size: 20),
                onPressed: () => _showDepartmentModal(dept: dept),
              ),
              IconButton(
                icon: const Icon(LucideIcons.trash2, color: Colors.redAccent, size: 20),
                onPressed: () => _confirmDelete(dept),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmDelete(DepartmentListItemResponse dept) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.trash2, color: Colors.red, size: 22),
                const SizedBox(width: 8),
                Text("Xác nhận xóa phòng ban", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text("Bạn có chắc chắn muốn xóa phòng ban '${dept.name}'? Hành động này không thể hoàn tác.", style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.back(),
                    child: const Text("HỦY"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Get.back();
                      controller.deleteDepartment(dept.id);
                    },
                    child: const Text("XÁC NHẬN XÓA", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDepartmentModal({DepartmentListItemResponse? dept}) {
    final isEdit = dept != null;
    final nameCtrl = TextEditingController(text: dept?.name);

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isEdit ? "Cập nhật phòng ban" : "Tạo phòng ban mới",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Tên phòng ban",
                  hintText: "Ví dụ: Phòng Kỹ thuật, Phòng Nhân sự...",
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      Get.snackbar("Lỗi", "Vui lòng nhập tên phòng ban");
                      return;
                    }
                    Get.back();
                    if (isEdit) {
                      controller.updateDepartment(dept.id, name);
                    } else {
                      controller.createDepartment(name);
                    }
                  },
                  child: Text(isEdit ? "CẬP NHẬT" : "TẠO MỚI", style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}
