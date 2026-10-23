import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../controllers/admin_dashboard_controller.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/branch_models.dart';
import '../../../repositories/branch_repository.dart';

class BranchListScreen extends StatefulWidget {
  const BranchListScreen({super.key});

  @override
  State<BranchListScreen> createState() => _BranchListScreenState();
}

class _BranchListScreenState extends State<BranchListScreen> {
  final BranchRepository _repository = BranchRepository();
  final AdminDashboardController dashController = Get.find<AdminDashboardController>();

  var branchList = <BranchListItemResponse>[].obs;
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    fetchBranches();
  }

  Future<void> fetchBranches() async {
    isLoading.value = true;
    try {
      final list = await _repository.getAll();
      branchList.assignAll(list);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải danh sách chi nhánh");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Quản lý Chi nhánh"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: fetchBranches,
          )
        ],
      ),
      body: Obx(() {
        if (isLoading.value && branchList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (branchList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.building, size: 64, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                const Text("Chưa có chi nhánh nào"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: fetchBranches,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: branchList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final b = branchList[index];
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(LucideIcons.building2, color: AppColors.primary),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            b.name ?? "N/A",
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text("ID: ${b.id}", style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.edit3, color: Colors.blue, size: 20),
                      onPressed: () => _showBranchModal(branch: b),
                    ),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, color: Colors.red, size: 20),
                      onPressed: () => _confirmDelete(b),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBranchModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BranchListItemResponse branch) {
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
                Text("Xác nhận xóa chi nhánh", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),
            Text("Bạn có chắc chắn muốn xóa chi nhánh '${branch.name}'? Hành động này không thể hoàn tác.", style: const TextStyle(fontSize: 14)),
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
                    onPressed: () async {
                      Get.back();
                      try {
                        await _repository.delete(branch.id);
                        Get.snackbar("Thành công", "Đã xóa chi nhánh", backgroundColor: Colors.green, colorText: Colors.white);
                        fetchBranches();
                        dashController.fetchBranches();
                      } catch (e) {
                        Get.snackbar("Lỗi", "Không thể xóa chi nhánh này", backgroundColor: Colors.redAccent, colorText: Colors.white);
                      }
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

  void _showBranchModal({BranchListItemResponse? branch}) {
    final isEdit = branch != null;
    final nameCtrl = TextEditingController(text: branch?.name);

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
                isEdit ? "Cập nhật chi nhánh" : "Tạo chi nhánh mới",
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: "Tên chi nhánh",
                  hintText: "Ví dụ: Chi nhánh Hà Nội, Chi nhánh HCM...",
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
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    if (name.isEmpty) {
                      Get.snackbar("Lỗi", "Vui lòng nhập tên chi nhánh");
                      return;
                    }
                    Get.back();
                    try {
                      if (isEdit) {
                        await _repository.update(branch.id, name);
                        Get.snackbar("Thành công", "Đã cập nhật chi nhánh", backgroundColor: Colors.green, colorText: Colors.white);
                      } else {
                        await _repository.create(name);
                        Get.snackbar("Thành công", "Đã tạo chi nhánh mới", backgroundColor: Colors.green, colorText: Colors.white);
                      }
                      fetchBranches();
                      dashController.fetchBranches();
                    } catch (e) {
                      Get.snackbar("Lỗi", "Thao tác thất bại", backgroundColor: Colors.redAccent, colorText: Colors.white);
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
