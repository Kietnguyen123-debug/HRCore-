import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/app_colors.dart';
import '../../../data/network/models/role_models.dart';
import '../../../repositories/role_repository.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({super.key});

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  final RoleRepository _repository = RoleRepository();
  var roles = <RoleSummaryResponse>[].obs;
  var isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    fetchRoles();
  }

  Future<void> fetchRoles() async {
    isLoading.value = true;
    try {
      final list = await _repository.getRoles();
      roles.assignAll(list);
    } catch (e) {
      Get.snackbar("Lỗi", "Không thể tải danh sách vai trò");
    } finally {
      isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Quản lý Vai trò & Phân quyền"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: fetchRoles,
          )
        ],
      ),
      body: Obx(() {
        if (isLoading.value && roles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (roles.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.shieldAlert, size: 64, color: Theme.of(context).disabledColor),
                const SizedBox(height: 16),
                const Text("Chưa có vai trò nào"),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: fetchRoles,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: roles.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final r = roles[index];
              return _buildRoleCard(r);
            },
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showRoleModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildRoleCard(RoleSummaryResponse role) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: role.isSystemDefault
                      ? Colors.orange.withValues(alpha: 0.1)
                      : AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  role.isSystemDefault ? LucideIcons.shieldCheck : LucideIcons.shield,
                  color: role.isSystemDefault ? Colors.orange : AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          role.name ?? "N/A",
                          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (role.isSystemDefault) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text("Hệ thống", style: TextStyle(fontSize: 10, color: Colors.orange, fontWeight: FontWeight.bold)),
                          ),
                        ]
                      ],
                    ),
                    if (role.description != null && role.description!.isNotEmpty)
                      Text(role.description!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'matrix') _openPermissionMatrix(role);
                  if (val == 'edit') _showRoleModal(role: role);
                  if (val == 'delete') _confirmDelete(role);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'matrix', child: Row(children: [Icon(LucideIcons.key, size: 16), SizedBox(width: 8), Text("Ma trận quyền")])),
                  if (!role.isSystemDefault) ...[
                    const PopupMenuItem(value: 'edit', child: Row(children: [Icon(LucideIcons.edit3, size: 16), SizedBox(width: 8), Text("Chỉnh sửa")])),
                    const PopupMenuItem(value: 'delete', child: Row(children: [Icon(LucideIcons.trash2, size: 16, color: Colors.red), SizedBox(width: 8), Text("Xóa vai trò", style: TextStyle(color: Colors.red))])),
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _openPermissionMatrix(role),
              icon: const Icon(LucideIcons.sliders, size: 16),
              label: const Text("Cấu hình Ma trận Quyền hạn"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _openPermissionMatrix(RoleSummaryResponse role) async {
    Get.dialog(const Center(child: CircularProgressIndicator()));
    try {
      final matrix = await _repository.getMatrix(role.id);
      Get.back();

      List<PermissionMatrixItem> items = matrix.permissions ?? [];
      Set<int> selectedPermissionIds = items.where((p) => p.enabled).map((p) => p.id).toSet();

      Get.bottomSheet(
        StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Ma trận Quyền: ${role.name}", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text("Tích chọn các quyền được phép thực thi cho vai trò này", style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 12)),
                  const Divider(height: 24),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text("Không có danh mục quyền"))
                        : ListView.separated(
                            itemCount: items.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final p = items[index];
                              bool isChecked = selectedPermissionIds.contains(p.id);
                              return CheckboxListTile(
                                value: isChecked,
                                title: Text("${p.module ?? ''} • ${p.action ?? ''}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                subtitle: Text(p.description ?? 'Không có mô tả', style: const TextStyle(fontSize: 12)),
                                onChanged: (v) {
                                  setModalState(() {
                                    if (v == true) {
                                      selectedPermissionIds.add(p.id);
                                    } else {
                                      selectedPermissionIds.remove(p.id);
                                    }
                                  });
                                },
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        try {
                          await _repository.updateRolePermissions(role.id, selectedPermissionIds.toList());
                          Get.snackbar("Thành công", "Đã cập nhật ma trận quyền hạn cho ${role.name}");
                          fetchRoles();
                        } catch (e) {
                          Get.snackbar("Lỗi", "Không thể cập nhật ma trận quyền");
                        }
                      },
                      child: const Text("LƯU MA TRẬN QUYỀN"),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        isScrollControlled: true,
      );
    } catch (e) {
      Get.back();
      Get.snackbar("Lỗi", "Không thể tải ma trận quyền");
    }
  }

  void _confirmDelete(RoleSummaryResponse role) {
    Get.defaultDialog(
      title: "Xác nhận xóa",
      middleText: "Bạn có chắc chắn muốn xóa vai trò '${role.name}'?",
      textConfirm: "Xóa",
      textCancel: "Hủy",
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        try {
          await _repository.deleteRole(role.id, confirmation: "DELETE");
          Get.snackbar("Thành công", "Đã xóa vai trò");
          fetchRoles();
        } catch (e) {
          Get.snackbar("Lỗi", "Không thể xóa vai trò này");
        }
      },
    );
  }

  void _showRoleModal({RoleSummaryResponse? role}) {
    final isEdit = role != null;
    final nameCtrl = TextEditingController(text: role?.name);
    final descCtrl = TextEditingController(text: role?.description);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isEdit ? "Chỉnh sửa vai trò" : "Tạo vai trò mới", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Tên vai trò (VD: TruongPhong, KeToan)")),
            const SizedBox(height: 12),
            TextField(controller: descCtrl, decoration: const InputDecoration(labelText: "Mô tả vai trò")),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.trim().isEmpty) {
                    Get.snackbar("Lỗi", "Vui lòng nhập tên vai trò");
                    return;
                  }
                  Get.back();
                  try {
                    if (isEdit) {
                      await _repository.updateRole(role.id, nameCtrl.text.trim(), descCtrl.text.trim());
                    } else {
                      await _repository.createRole(nameCtrl.text.trim(), descCtrl.text.trim());
                    }
                    Get.snackbar("Thành công", isEdit ? "Đã cập nhật vai trò" : "Đã tạo vai trò mới");
                    fetchRoles();
                  } catch (e) {
                    Get.snackbar("Lỗi", "Thao tác thất bại");
                  }
                },
                child: Text(isEdit ? "CẬP NHẬT" : "TẠO MỚI"),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
