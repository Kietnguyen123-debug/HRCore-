import 'package:appdiemdanh/data/network/models/employee_admin_models.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../controllers/employee_controller.dart';
import '../../core/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DepartmentMembersScreen extends StatefulWidget {
  const DepartmentMembersScreen({super.key});

  @override
  State<DepartmentMembersScreen> createState() => _DepartmentMembersScreenState();
}

class _DepartmentMembersScreenState extends State<DepartmentMembersScreen> {
  final EmployeeController controller = Get.put(EmployeeController());
  int? branchId;
  String branchName = "Đang tải...";

  @override
  void initState() {
    super.initState();
    _loadBranchInfo();
  }

  Future<void> _loadBranchInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      branchId = prefs.getInt('branchId');
    });

    // Sau khi bạn đã sửa Backend thành [Authorize], 
    // chúng ta cho phép tất cả các Role đều được gọi API fetchEmployees
    if (branchId != null) {
      controller.fetchEmployees(branchId: branchId, refresh: true);
    } else {
      Get.snackbar(
        "Thông báo", 
        "Tài khoản của bạn chưa được gán vào chi nhánh/phòng ban nào.",
        backgroundColor: Colors.orangeAccent,
        colorText: Colors.white
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Thành viên phòng ban",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBranchHeader(),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.employees.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              // Filter only active employees from the same branch
              final members = controller.employees.where((e) => e.branchId == branchId && e.isActive).toList();

              if (members.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(LucideIcons.users, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 16),
                      Text(
                        branchId == null ? "Chưa được phân phòng ban" : "Chưa có đồng nghiệp nào trong danh sách",
                        style: GoogleFonts.poppins(color: Colors.grey, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.fetchEmployees(branchId: branchId, refresh: true),
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  itemCount: members.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return _buildMemberCard(member);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildBranchHeader() {
    return Obx(() {
      final membersCount = controller.employees.where((e) => e.branchId == branchId && e.isActive).length;
      final firstMember = controller.employees.isNotEmpty ? controller.employees.first : null;
      final displayBranchName = firstMember?.branchName ?? "Phòng ban của tôi";

      return Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayBranchName,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "$membersCount thành viên đang hoạt động",
              style: GoogleFonts.poppins(
                color: Colors.white.withOpacity(0.9),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildMemberCard(Employee member) {
    final name = member.fullName ?? "Ẩn danh";
    final code = member.employeeCode ?? "---";
    final initial = name.isNotEmpty ? name[0].toUpperCase() : "?";

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            initial,
            style: GoogleFonts.poppins(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
        title: Text(
          name,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          code,
          style: GoogleFonts.poppins(
            color: Colors.grey,
            fontSize: 13,
          ),
        ),
        trailing: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
