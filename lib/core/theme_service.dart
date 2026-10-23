import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  static const String _globalKey = 'isDarkMode';

  /// Lấy cấu hình Theme (Ưu tiên theo tài khoản, sau đó đến cấu hình chung)
  Future<bool> loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('employeeCode');
    
    if (code != null && prefs.containsKey('${_globalKey}_$code')) {
      return prefs.getBool('${_globalKey}_$code') ?? false;
    }
    return prefs.getBool(_globalKey) ?? false;
  }

  /// Lưu cấu hình Theme (Lưu cả vào tài khoản và cấu hình chung để đồng bộ)
  Future<void> saveThemeToPrefs(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('employeeCode');
    
    await prefs.setBool(_globalKey, isDarkMode);
    if (code != null) {
      await prefs.setBool('${_globalKey}_$code', isDarkMode);
    }
  }

  void switchTheme() async {
    // Không dùng Get.isDarkMode vì nó có thể trả về giá trị hệ thống
    // Chúng ta lấy giá trị thực tế đang được lưu
    bool currentMode = await loadThemeFromPrefs();
    bool newMode = !currentMode;

    Get.changeThemeMode(newMode ? ThemeMode.dark : ThemeMode.light);
    await saveThemeToPrefs(newMode);
  }

  /// Cập nhật Theme ngay lập tức khi đăng nhập
  Future<void> updateThemeOnLogin() async {
    bool isDarkMode = await loadThemeFromPrefs();
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }
}
