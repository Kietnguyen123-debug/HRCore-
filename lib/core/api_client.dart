import 'package:appdiemdanh/ui/auth/login_screen.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:dio/io.dart';

class ApiClient {
  static const String baseUrl = 'https://quantrinhansu.runasp.net/api/';

  late Dio dio;

  ApiClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) {
          return status != null && status < 500;
        },
      ),
    );

    // Bỏ qua lỗi SSL Certificate trên Android
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
        return client;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('token');

          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          print('=== API ERROR DETAILS ===');
          print('Type: ${e.type}');
          print('Path: ${e.requestOptions.path}');
          print('Status: ${e.response?.statusCode}');
          print('Data: ${e.response?.data}');
          print('Message: ${e.message}');

          if (e.response?.statusCode == 401 &&
              !e.requestOptions.path.contains('Auth/login')) {
            print('401 Unauthorized detected. Redirecting to Login.');

            final prefs = await SharedPreferences.getInstance();
            await prefs.remove('token');
            await prefs.remove('role');
            await prefs.remove('userName');
            await prefs.remove('employeeCode');
            await prefs.remove('branchId');
            await prefs.remove('userId');
            await prefs.remove('session_last_active_time');
            await prefs.remove('remember_me');

            Get.offAll(() => LoginScreen());
          }

          return handler.next(e);
        },
      ),
    );
  }

  // ============================================================
  // AI CHATBOT (USER & ADMIN)
  // ============================================================

  Future<Response> chatWithAi(
      String message, {
        List<Map<String, dynamic>>? history,
      }) {
    return dio.post(
      'GeminiChat/chat',
      data: {
        'message': message,
        if (history != null) 'history': history,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 120), // Ép riêng timeout 120s cho AI
      ),
    );
  }

  Future<Response> chatWithAdminAi(
      String message, {
        List<Map<String, dynamic>>? history,
      }) {
    return dio.post(
      'AdminAi/chat',
      data: {
        'message': message,
        if (history != null) 'history': history,
      },
      options: Options(
        receiveTimeout: const Duration(seconds: 120),
      ),
    );
  }

  // ============================================================
  // AUTH
  // ============================================================

  Future<Response> login(
      String employeeCode,
      String password,
      String deviceId,
      ) {
    return dio.post(
      'Auth/login',
      data: {
        'employeeCode': employeeCode,
        'password': password,
        'deviceId': deviceId,
      },
    );
  }

  Future<Response> activateFirstTime(
      String employeeCode,
      String temporaryPassword,
      String newPassword,
      String deviceId,
      String faceImageBase64,
      ) {
    return dio.post(
      'Auth/activate-first-time',
      data: {
        'employeeCode': employeeCode,
        'temporaryPassword': temporaryPassword,
        'newPassword': newPassword,
        'deviceId': deviceId,
        'faceImageBase64': faceImageBase64,
      },
    );
  }

  Future<Response> createEmployee(
      String employeeCode,
      String fullName,
      int branchId,
      String role,
      String temporaryPassword, {
        String? email,
      }) {
    return dio.post(
      'Auth/create-employee',
      data: {
        'employeeCode': employeeCode,
        'fullName': fullName,
        'branchId': branchId,
        'role': role,
        'temporaryPassword': temporaryPassword,
        'email': email,
      },
    );
  }

  Future<Response> requestPasswordReset(String employeeCodeOrEmail) {
    return dio.post(
      'Auth/request-password-reset',
      data: {'employeeCodeOrEmail': employeeCodeOrEmail},
    );
  }

  Future<Response> verifyResetOtp(String employeeCodeOrEmail, String otp) {
    return dio.post(
      'Auth/verify-reset-otp',
      data: {'employeeCodeOrEmail': employeeCodeOrEmail, 'otp': otp},
    );
  }

  Future<Response> resetPasswordAfterOtp(
      String employeeCodeOrEmail,
      String otp,
      String newPassword,
      ) {
    return dio.post(
      'Auth/reset-password',
      data: {
        'employeeCodeOrEmail': employeeCodeOrEmail,
        'otp': otp,
        'newPassword': newPassword,
      },
    );
  }

  Future<Response> requestEmailVerify(String email) {
    return dio.post('Auth/request-email-verify', data: {'email': email});
  }

  Future<Response> verifyEmailOtp(String otp) {
    return dio.post('Auth/verify-email-otp', data: {'otp': otp});
  }

  // ============================================================
  // ADMIN DASHBOARD
  // ============================================================

  Future<Response> getAdminTodaySummary({int? branchId}) {
    return dio.get(
      'AdminDashboard/today-summary',
      queryParameters: branchId != null ? {'branchId': branchId} : null,
    );
  }

  Future<Response> getMonthlyReport(int month, int year, {int? branchId}) {
    return dio.get(
      'Report/monthly-summary',
      queryParameters: {
        'month': month,
        'year': year,
        if (branchId != null) 'branchId': branchId,
      },
    );
  }

  // ============================================================
  // EMPLOYEE
  // ============================================================

  Future<Response> getEmployees({
    int page = 1,
    int pageSize = 100,
    int? branchId,
  }) {
    return dio.get(
      'Employee',
      queryParameters: {
        'page': page,
        'pageSize': pageSize,
        if (branchId != null) 'branchId': branchId,
      },
    );
  }

  Future<Response> updateEmployee(
      int id,
      String fullName,
      int branchId,
      String role, {
        String? email,
      }) {
    return dio.put(
      'Employee/$id',
      data: {
        'fullName': fullName,
        'branchId': branchId,
        'role': role,
        'email': email,
      },
    );
  }

  Future<Response> unbindDevice(int id) {
    return dio.post('Employee/$id/unbind-device');
  }

  Future<Response> toggleStatus(int id) {
    return dio.put('Employee/$id/toggle-status');
  }

  Future<Response> resetPassword(int id, String newTemporaryPassword) {
    return dio.post(
      'Employee/$id/reset-password',
      data: {'newTemporaryPassword': newTemporaryPassword},
    );
  }

  // ============================================================
  // ATTENDANCE
  // ============================================================

  Future<Response> checkIn(
      String faceImageBase64,
      String bssid,
      String deviceId,
      ) {
    return dio.post(
      'Attendance/check-in',
      data: {
        'faceImageBase64': faceImageBase64,
        'bssid': bssid,
        'deviceId': deviceId,
      },
    );
  }

  Future<Response> checkOut(
      String faceImageBase64,
      String bssid,
      String deviceId,
      ) {
    return dio.post(
      'Attendance/check-out',
      data: {
        'faceImageBase64': faceImageBase64,
        'bssid': bssid,
        'deviceId': deviceId,
      },
    );
  }

  Future<Response> registerWifi(
      int branchId,
      String ssid,
      String bssid,
      bool isAutoCaptured,
      ) {
    return dio.post(
      'Attendance/register-wifi',
      data: {
        'branchId': branchId,
        'ssid': ssid,
        'bssid': bssid,
        'isAutoCaptured': isAutoCaptured,
      },
    );
  }

  Future<Response> addIpManual(
      int branchId, {
        String publicIp = "",
        String? description,
      }) {
    return dio.post(
      'Attendance/add-ip-manual',
      data: {
        'branchId': branchId,
        'publicIp': publicIp,
        'description': description ?? '',
      },
    );
  }

  Future<Response> registerFace(int employeeId, String faceImageBase64) {
    return dio.post(
      'Attendance/register-face',
      data: {
        'employeeId': employeeId,
        'faceImageBase64': faceImageBase64,
      },
    );
  }

  // ============================================================
  // ATTENDANCE EXPLANATION
  // ============================================================

  Future<Response> submitExplanation(
      String targetDate,
      String explanationReason, {
        String? missingCheckInTime,
        String? missingCheckOutTime,
      }) {
    return dio.post(
      'AttendanceExplanation',
      data: {
        'targetDate': targetDate,
        'explanationReason': explanationReason,
        'missingCheckInTime': missingCheckInTime,
        'missingCheckOutTime': missingCheckOutTime,
      },
    );
  }

  Future<Response> getPendingExplanations() {
    return dio.get('AttendanceExplanation/pending');
  }

  Future<Response> reviewExplanation(
      int id,
      String status,
      String reviewNote,
      ) {
    return dio.put(
      'AttendanceExplanation/$id/review',
      data: {'status': status, 'reviewNote': reviewNote},
    );
  }

  // ============================================================
  // SHIFT
  // ============================================================

  Future<Response> getShifts() {
    return dio.get('Shift');
  }

  Future<Response> getShift(int id) {
    return dio.get('Shift/$id');
  }

  Future<Response> createShift(
      String shiftCode,
      String shiftName,
      String startTime,
      String endTime,
      bool isActive,
      ) {
    return dio.post(
      'Shift',
      data: {
        'shiftCode': shiftCode,
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
        'isActive': isActive,
      },
    );
  }

  Future<Response> updateShift(
      int id,
      String shiftCode,
      String shiftName,
      String startTime,
      String endTime,
      bool isActive,
      ) {
    return dio.put(
      'Shift/$id',
      data: {
        'shiftCode': shiftCode,
        'shiftName': shiftName,
        'startTime': startTime,
        'endTime': endTime,
        'isActive': isActive,
      },
    );
  }

  Future<Response> deleteShift(int id) {
    return dio.delete('Shift/$id');
  }

  Future<Response> assignShift(
      int employeeId,
      int shiftId,
      String effectiveFromDate, {
        String? effectiveToDate,
      }) {
    return dio.post(
      'Shift/assignments',
      data: {
        'employeeId': employeeId,
        'shiftId': shiftId,
        'effectiveFromDate': effectiveFromDate,
        'effectiveToDate': effectiveToDate,
      },
    );
  }

  // ============================================================
  // OVERTIME
  // ============================================================

  Future<Response> logOvertime(
      String workDate,
      double hours,
      double multiplier,
      ) {
    return dio.post(
      'Overtime/log',
      data: {
        'workDate': workDate,
        'hours': hours,
        'multiplier': multiplier,
      },
    );
  }

  Future<Response> reviewOvertime(int id, bool isApproved) {
    return dio.put('Overtime/$id/approve', data: {'isApproved': isApproved});
  }

  // ============================================================
  // SALARY ADVANCE
  // ============================================================

  Future<Response> requestAdvance(double amount, String reason) {
    return dio.post(
      'SalaryAdvance/request',
      data: {'amount': amount, 'reason': reason},
    );
  }

  Future<Response> getMyAdvances() {
    return dio.get('SalaryAdvance/my-requests');
  }

  Future<Response> getPendingAdvances() {
    return dio.get('SalaryAdvance/pending');
  }

  Future<Response> reviewAdvance(int id, bool isApproved, String reviewNote) {
    return dio.put(
      'SalaryAdvance/$id/approve',
      data: {'isApproved': isApproved, 'reviewNote': reviewNote},
    );
  }

  // ============================================================
  // NOTIFICATION
  // ============================================================

  Future<Response> registerFcmToken(String fcmToken, String deviceId) {
    return dio.post(
      'Notification/register-token',
      data: {'fcmToken': fcmToken, 'deviceId': deviceId},
    );
  }

  Future<Response> getMyNotifications({int page = 1, int pageSize = 20}) {
    return dio.get(
      'Notification/my-notifications',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
  }

  Future<Response> markNotificationRead(int id) {
    return dio.put('Notification/$id/read');
  }

  // ============================================================
  // BRANCH
  // ============================================================

  Future<Response> getBranches() {
    return dio.get('Branch');
  }

  // ============================================================
  // LEAVE
  // ============================================================

  Future<Response> requestLeave(
      String reason,
      String startDate,
      String endDate,
      String leaveType,
      ) {
    return dio.post(
      'Leave/request',
      data: {
        'reason': reason,
        'startDate': startDate,
        'endDate': endDate,
        'leaveType': leaveType,
      },
    );
  }

  Future<Response> getLeaveBalance() {
    return dio.get('Leave/my-balance');
  }

  Future<Response> approveLeave(
      int id,
      bool isApproved, {
        String? rejectReason,
      }) {
    return dio.put(
      'Leave/approve/$id',
      queryParameters: {
        'isApproved': isApproved,
        if (rejectReason != null) 'rejectReason': rejectReason,
      },
    );
  }

  // ============================================================
  // PAYROLL
  // ============================================================

  Future<Response> getMyPayslip(
      int month,
      int year, {
        int standardWorkDays = 26,
      }) {
    return dio.get(
      'Payroll/my-payslip',
      queryParameters: {
        'month': month,
        'year': year,
        'standardWorkDays': standardWorkDays,
      },
    );
  }

  Future<Response> getMonthlyPayrollSummary(
      int month,
      int year, {
        int standardWorkDays = 26,
      }) {
    return dio.get(
      'Payroll/monthly-summary',
      queryParameters: {
        'month': month,
        'year': year,
        'standardWorkDays': standardWorkDays,
      },
    );
  }

  Future<Response> finalizePayroll(int month, int year, int standardWorkDays) {
    return dio.post(
      'Payroll/finalize',
      data: {
        'month': month,
        'year': year,
        'standardWorkDays': standardWorkDays,
      },
    );
  }

  Future<Response> configSalary(
      int employeeId,
      double baseSalary,
      double allowance,
      double penaltyPerLateMinute,
      int dependentCount,
      double? socialInsuranceBase,
      ) {
    return dio.put(
      'Payroll/config-salary/$employeeId',
      data: {
        'baseSalary': baseSalary,
        'allowance': allowance,
        'penaltyPerLateMinute': penaltyPerLateMinute,
        'dependentCount': dependentCount,
        'socialInsuranceBase': socialInsuranceBase,
      },
    );
  }
}