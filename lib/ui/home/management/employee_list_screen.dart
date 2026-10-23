import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:appdiemdanh/controllers/employee_controller.dart';
import 'package:appdiemdanh/controllers/admin_dashboard_controller.dart';
import 'package:appdiemdanh/controllers/department_controller.dart';
import 'package:appdiemdanh/core/app_colors.dart';
import '../../../models/employee_model.dart';
import '../../../repositories/role_repository.dart';
import '../../../data/network/models/role_models.dart';
import '../../auth/face_auth_screen.dart';
import 'salary_config_screen.dart';
import 'assign_shift_screen.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  late final EmployeeController controller;
  late final AdminDashboardController dashController;
  final TextEditingController searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final RoleRepository _roleRepo = RoleRepository();
  List<RoleSummaryResponse> _serverRoles = [];

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<EmployeeController>() ? Get.find<EmployeeController>() : Get.put(EmployeeController());
    dashController = Get.isRegistered<AdminDashboardController>() ? Get.find<AdminDashboardController>() : Get.put(AdminDashboardController());
    _scrollController.addListener(_onScroll);
    controller.fetchEmployees();
    _loadRoles();
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  Future<void> _loadRoles() async {
    try {
      final list = await _roleRepo.getRoles();
      if (mounted) {
        setState(() {
          _serverRoles = list;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Quản lý nhân sự"),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            onPressed: () => controller.fetchEmployees(),
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.employees.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                  if (controller.employees.isEmpty)
                    const Center(child: Text("Không có nhân viên nào"))
                  else
                    RefreshIndicator(
                      onRefresh: () => controller.fetchEmployees(refresh: true),
                      child: ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: controller.employees.length + (controller.isMoreLoading.value ? 1 : 0),
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          if (index == controller.employees.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final emp = controller.employees[index];
                          return _buildEmployeeCard(emp);
                        },
                      ),
                    ),

                  if (controller.isLoading.value && controller.employees.isNotEmpty)
                    const Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LinearProgressIndicator(minHeight: 2),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEmployeeModal(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          TextField(
            controller: searchCtrl,
            onChanged: (val) {
              controller.searchQuery.value = val;
              controller.fetchEmployees();
            },
            decoration: const InputDecoration(
              hintText: "Tìm theo tên hoặc mã NV",
              prefixIcon: Icon(LucideIcons.search, size: 20),
              contentPadding: EdgeInsets.symmetric(vertical: 0),
            ),
          ),
          const SizedBox(height: 12),
          Obx(() {
            final branches = dashController.branches;
            int? validBranch = branches.any((b) => b.id == controller.selectedBranchId.value)
                ? controller.selectedBranchId.value
                : null;

            return DropdownButtonFormField<int>(
              value: validBranch,
              decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12)),
              hint: const Text("Tất cả chi nhánh"),
              items: [
                const DropdownMenuItem<int>(value: null, child: Text("Tất cả chi nhánh")),
                ...branches.map((b) => DropdownMenuItem<int>(value: b.id, child: Text(b.name ?? ""))),
              ],
              onChanged: (val) {
                controller.selectedBranchId.value = val;
                controller.fetchEmployees();
              },
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmployeeCard(Employee emp) {
    bool isActive = emp.isActive;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      emp.fullName?.isNotEmpty == true ? emp.fullName![0].toUpperCase() : "NV",
                      style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (emp.isEmailVerified)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(color: Theme.of(context).cardColor, shape: BoxShape.circle),
                        child: const Icon(Icons.verified, color: Colors.blue, size: 14),
                      ),
                    )
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emp.fullName ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Mã NV: ${emp.employeeCode} • ${emp.role}", style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    if (emp.email != null && emp.email!.isNotEmpty)
                      Text(emp.email!, style: const TextStyle(fontSize: 11, color: Colors.blueGrey)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isActive ? "Hoạt động" : "Khóa",
                  style: TextStyle(color: isActive ? Colors.green : Colors.red, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionIcon(LucideIcons.edit3, "Sửa", Colors.blue, () => _showEmployeeModal(emp: emp)),
              _actionIcon(LucideIcons.scanFace, "Face", Colors.purple, () => _handleFaceRegistration(emp.id)),
              _actionIcon(LucideIcons.calendarClock, "Gán ca", Colors.teal, () => Get.to(() => AssignShiftScreen(employeeId: emp.id, employeeName: emp.fullName ?? ""))),
              _actionIcon(LucideIcons.banknote, "Lương", Colors.green, () => Get.to(() => SalaryConfigScreen(employeeId: emp.id))),
              _actionIcon(LucideIcons.unlock, "Gỡ máy", Colors.orange, () => _confirmUnbind(emp.id)),
              _actionIcon(isActive ? LucideIcons.userX : LucideIcons.userCheck, isActive ? "Khóa" : "Mở", isActive ? Colors.red : Colors.green, () => _confirmToggleStatus(emp)),
              _actionIcon(LucideIcons.key, "Reset", Colors.grey, () => _showResetPassDialog(emp.id)),
            ],
          )
        ],
      ),
    );
  }

  Widget _actionIcon(IconData icon, String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmToggleStatus(Employee emp) {
    String action = emp.isActive ? "Khóa" : "Mở khóa";
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
            Text("Xác nhận $action tài khoản", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("Bạn có chắc chắn muốn $action tài khoản của nhân viên '${emp.fullName}' không?"),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text("HỦY"))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: emp.isActive ? Colors.red : Colors.green),
                    onPressed: () {
                      Get.back();
                      controller.toggleStatus(emp.id);
                    },
                    child: Text("XÁC NHẬN $action", style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _confirmUnbind(int id) {
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
            Text("Xác nhận Gỡ liên kết thiết bị", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text("Gỡ liên kết thiết bị cũ cho phép nhân viên đăng nhập trên thiết bị mới. Xác nhận?"),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text("HỦY"))),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                      controller.unbindDevice(id);
                    },
                    child: const Text("GỠ THIẾT BỊ", style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showResetPassDialog(int id) {
    final passCtrl = TextEditingController(text: "123456");
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
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Cấp lại mật khẩu tạm", style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(controller: passCtrl, decoration: const InputDecoration(labelText: "Mật khẩu tạm mới")),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(child: TextButton(onPressed: () => Get.back(), child: const Text("HỦY"))),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final newPass = passCtrl.text.trim();
                        if (newPass.length < 6) {
                          Get.snackbar("Lỗi", "Mật khẩu tạm phải có tối thiểu 6 ký tự");
                          return;
                        }
                        Get.back();
                        controller.resetPassword(id, newPass);
                      },
                      child: const Text("ĐẶT LẠI MẬT KHẨU", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> _handleFaceRegistration(int employeeId) async {
    final String? base64 = await Get.to(() => const FaceAuthScreen());
    if (base64 != null && base64.isNotEmpty) {
      await controller.registerFace(employeeId, base64);
    }
  }

  void _showEmployeeModal({Employee? emp}) {
    final isEdit = emp != null;
    final nameCtrl = TextEditingController(text: emp?.fullName);
    final codeCtrl = TextEditingController(text: emp?.employeeCode);
    final emailCtrl = TextEditingController(text: emp?.email);
    final passCtrl = TextEditingController(text: "123456");
    int? selectedBId = emp?.branchId ?? (dashController.branches.isNotEmpty ? dashController.branches.first.id : null);
    int? selectedDId = emp?.departmentId;
    String role = emp?.role ?? "Employee";

    final DepartmentController deptController = Get.isRegistered<DepartmentController>()
        ? Get.find<DepartmentController>()
        : Get.put(DepartmentController());

    Get.bottomSheet(
      Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isEdit ? "Cập nhật nhân viên" : "Tạo nhân viên mới", style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    if (!isEdit) TextField(controller: codeCtrl, decoration: const InputDecoration(labelText: "Mã nhân viên (Bắt buộc)")),
                    const SizedBox(height: 12),
                    TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Họ và tên (Bắt buộc)")),
                    const SizedBox(height: 12),
                    TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: "Email công ty (Tùy chọn)", hintText: "example@company.com")),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: dashController.branches.any((b) => b.id == selectedBId) ? selectedBId : null,
                      decoration: const InputDecoration(labelText: "Chi nhánh"),
                      items: dashController.branches.map((b) => DropdownMenuItem<int>(value: b.id, child: Text(b.name ?? ""))).toList(),
                      onChanged: (val) {
                        setModalState(() {
                          selectedBId = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    Obx(() {
                      final depts = deptController.departments;
                      int? validDept = depts.any((d) => d.id == selectedDId) ? selectedDId : null;
                      return DropdownButtonFormField<int>(
                        value: validDept,
                        decoration: const InputDecoration(labelText: "Phòng ban"),
                        items: [
                          const DropdownMenuItem<int>(value: null, child: Text("Chưa phân phòng")),
                          ...depts.map((d) => DropdownMenuItem<int>(value: d.id, child: Text(d.name ?? ""))),
                        ],
                        onChanged: (val) {
                          setModalState(() {
                            selectedDId = val;
                          });
                        },
                      );
                    }),
                    const SizedBox(height: 12),
                    Builder(
                      builder: (context) {
                        final roleOptions = <Map<String, String>>[
                          {'value': 'Employee', 'label': 'Nhân viên (Employee)'},
                          {'value': 'Manager', 'label': 'Quản lý (Manager)'},
                          {'value': 'HR', 'label': 'Nhân sự (HR)'},
                          {'value': 'Admin', 'label': 'Quản trị viên (Admin)'},
                        ];

                        for (var r in _serverRoles) {
                          if (r.name != null && r.name!.isNotEmpty && !roleOptions.any((o) => o['value'] == r.name)) {
                            roleOptions.add({'value': r.name!, 'label': r.description ?? r.name!});
                          }
                        }

                        if (!roleOptions.any((o) => o['value'] == role)) {
                          roleOptions.add({'value': role, 'label': role});
                        }

                        return DropdownButtonFormField<String>(
                          value: role,
                          decoration: const InputDecoration(labelText: "Vai trò"),
                          items: roleOptions.map((o) => DropdownMenuItem<String>(
                            value: o['value'],
                            child: Text(o['label']!),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                role = val;
                              });
                            }
                          },
                        );
                      },
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: 12),
                      TextField(
                        controller: passCtrl,
                        decoration: const InputDecoration(
                          labelText: "Mật khẩu tạm (Bắt buộc)",
                          helperText: "Tối thiểu 6 ký tự",
                        ),
                      ),
                    ],
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
                          final code = codeCtrl.text.trim();
                          final email = emailCtrl.text.trim();
                          final pass = passCtrl.text.trim();

                          if (name.isEmpty) {
                            Get.snackbar("Lỗi", "Vui lòng nhập họ tên nhân viên");
                            return;
                          }
                          if (!isEdit && code.isEmpty) {
                            Get.snackbar("Lỗi", "Vui lòng nhập mã nhân viên");
                            return;
                          }
                          if (!isEdit && pass.length < 6) {
                            Get.snackbar("Lỗi", "Mật khẩu tạm phải có ít nhất 6 ký tự");
                            return;
                          }

                          Get.back(); // Đóng modal trước
                          if (isEdit) {
                            controller.updateEmployee(
                              emp.id,
                              name,
                              selectedBId ?? 1,
                              role,
                              departmentId: selectedDId,
                              email: email.isNotEmpty ? email : null,
                            );
                          } else {
                            controller.createEmployee(
                              code,
                              name,
                              selectedBId ?? 1,
                              role,
                              pass,
                              departmentId: selectedDId,
                              email: email.isNotEmpty ? email : null,
                            );
                          }
                        },
                        child: Text(isEdit ? "CẬP NHẬT" : "TẠO MỚI", style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      isScrollControlled: true,
    );
  }
}
