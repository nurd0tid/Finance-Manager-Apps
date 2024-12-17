import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _firstLaunchKey = 'first_launch';

  // Mengecek apakah aplikasi pertama kali dibuka
  static Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_firstLaunchKey) ?? true;
  }

  // Menyimpan status aplikasi pernah dibuka
  static Future<void> setFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_firstLaunchKey, false);
  }
}
