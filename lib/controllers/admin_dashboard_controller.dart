import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../repositories/admin_repository.dart';
import '../repositories/branch_repository.dart';
import '../repositories/role_repository.dart';
import '../data/network/models/admin_models.dart';
import '../data/network/models/branch_models.dart';
import '../data/network/models/role_models.dart';
import 'auth_controller.dart';
import 'notification_controller.dart';

class AdminDashboardController extends GetxController {
  final AdminRepository _adminRepo = AdminRepository();
  final BranchRepository _branchRepo = BranchRepository();
  final RoleRepository _roleRepo = RoleRepository();

  final summaryDataMap = <String, dynamic>{
    'totalEmployees': 0,
    'checkedInCount': 0,
    'notCheckedInCount': 0,
    'lateCount': 0,
    'pendingLeaveRequests': 0,
  }.obs;

  var pendingCounts = Rxn<DashboardPendingCountsResponse>();
  var recentAttendance = <AdminAttendanceDto>[].obs;
  var branches = <BranchListItemResponse>[].obs;
  var selectedBranchId = RxnInt();
  var isLoading = false.obs;

  var userRole = ''.obs;
  var permissionMatrix = <PermissionMatrixItem>[].obs;
  var isPermissionsLoaded = false.obs;

  RxMap<String, dynamic> get summaryData => summaryDataMap;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<NotificationController>()) {
        Get.find<NotificationController>().refreshAll();
      }
      await Future.wait([
        fetchTodaySummary(),
        fetchPendingCounts(),
        fetchBranches(),
        fetchRecentAttendance(),
        fetchUserPermissions(),
      ]);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTodaySummary() async {
    try {
      final res = await _adminRepo.getTodaySummary(branchId: selectedBranchId.value);
      summaryDataMap.assignAll(res.toJson());
    } catch (_) {}
  }

  var pendingLeavesCount = 0.obs;
  var pendingOvertimeCount = 0.obs;
  var pendingAdvanceCount = 0.obs;
  var pendingExplanationCount = 0.obs;

  int get totalPendingCount =>
      pendingLeavesCount.value +
      pendingOvertimeCount.value +
      pendingAdvanceCount.value +
      pendingExplanationCount.value;

  Future<void> fetchPendingCounts() async {
    try {
      final res = await _adminRepo.getPendingCounts(branchId: selectedBranchId.value);
      pendingCounts.value = res;
      pendingLeavesCount.value = res.pendingLeave;
      pendingOvertimeCount.value = res.pendingOvertime;
      pendingAdvanceCount.value = res.pendingSalaryAdvance;
      pendingExplanationCount.value = res.pendingAttendanceExplanation;
    } catch (_) {}

    try {
      final leavesRes = await _adminRepo.getPendingLeaves(branchId: selectedBranchId.value);
      pendingLeavesCount.value = leavesRes.list.length;
    } catch (_) {}

    try {
      final overtimesRes = await _adminRepo.getPendingOvertimes(branchId: selectedBranchId.value);
      pendingOvertimeCount.value = overtimesRes.list.length;
    } catch (_) {}

    try {
      final advancesRes = await _adminRepo.getPendingAdvances();
      pendingAdvanceCount.value = advancesRes.length;
    } catch (_) {}

    try {
      final explanationsRes = await _adminRepo.getPendingExplanations();
      pendingExplanationCount.value = explanationsRes.length;
    } catch (_) {}
  }

  Future<void> fetchRecentAttendance() async {
    try {
      final paged = await _adminRepo.getAttendanceList(
        branchId: selectedBranchId.value,
        page: 1,
        pageSize: 10,
      );
      recentAttendance.assignAll(paged.list);
    } catch (_) {}
  }

  Future<void> fetchBranches() async {
    try {
      final list = await _branchRepo.getAll();
      branches.assignAll(list);
    } catch (_) {}
  }

  Future<void> fetchUserPermissions() async {
    try {
      final authCtrl = Get.isRegistered<AuthController>()
          ? Get.find<AuthController>()
          : Get.put(AuthController());
      final user = authCtrl.currentUser.value ?? await authCtrl.getMe();
      userRole.value = user.role ?? '';

      if (userRole.value.isNotEmpty) {
        final roles = await _roleRepo.getRoles();
        final matchedRole = roles.firstWhereOrNull(
          (r) => r.name?.trim().toLowerCase() == userRole.value.trim().toLowerCase(),
        );
        if (matchedRole != null) {
          final matrixResp = await _roleRepo.getMatrix(matchedRole.id);
          if (matrixResp.permissions != null) {
            permissionMatrix.assignAll(matrixResp.permissions!);
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi nạp phân quyền người dùng từ server: $e");
    } finally {
      isPermissionsLoaded.value = true;
    }
  }

  bool hasPermission(String moduleKey) {
    final role = userRole.value.trim().toLowerCase();

    // 1. Admin hoặc SystemAdmin có toàn quyền
    if (role.contains('admin') || role == 'quản trị viên' || role == 'administrator' || role == 'systemadmin') {
      return true;
    }

    // 2. Tuyệt đối dựa 100% vào Ma trận quyền (Permission Matrix) lấy trực tiếp từ Server
    if (permissionMatrix.isNotEmpty) {
      final keyLower = moduleKey.toLowerCase();
      final item = permissionMatrix.firstWhereOrNull((p) {
        final mod = (p.module ?? '').toLowerCase();
        final act = (p.action ?? '').toLowerCase();
        final desc = (p.description ?? '').toLowerCase();
        return mod.contains(keyLower) || act.contains(keyLower) || desc.contains(keyLower);
      });
      if (item != null) {
        return item.enabled;
      }
    }

    // 3. Nếu chưa có ma trận hoặc không tìm thấy trên Server, trả về false (không hardcode)
    return false;
  }

  void setBranch(int? branchId) {
    selectedBranchId.value = branchId;
    refreshData();
  }

  void onBranchChanged(int? branchId) => setBranch(branchId);
}
