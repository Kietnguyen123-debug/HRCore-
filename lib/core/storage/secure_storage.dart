import 'package:shared_preferences/shared_preferences.dart';

/// An abstraction layer for secure key-value storage.
/// Currently implemented using SharedPreferences to maintain compatibility with existing dependencies.
/// Can be easily swapped with flutter_secure_storage by updating the implementation.
abstract class BaseSecureStorage {
  Future<void> write({required String key, required String value});
  Future<String?> read({required String key});
  Future<void> delete({required String key});
  Future<void> deleteAll();
}

class SecureStorageImpl implements BaseSecureStorage {
  @override
  Future<void> write({required String key, required String value}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Future<String?> read({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  @override
  Future<void> delete({required String key}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  @override
  Future<void> deleteAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Giữ lại Device ID, avatar local và cấu hình theme của người dùng khi đăng xuất
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key != 'app_persistent_device_id' &&
          !key.startsWith('user_avatar_base64') &&
          !key.startsWith('isDarkMode')) {
        await prefs.remove(key);
      }
    }
  }
}
