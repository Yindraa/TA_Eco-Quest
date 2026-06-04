import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola preferensi notifikasi in-app.
/// Notifikasi OS (flutter_local_notifications) tidak digunakan karena
/// inkompatibel dengan AGP 8.11.x.
///
/// Streak reminder diimplementasikan sebagai in-app banner:
/// saat app dibuka dan pohon belum disiram hari ini,
/// MainScaffold menampilkan SnackBar pengingat.
class NotificationService {
  static const _keyStreakReminder = 'streak_reminder_enabled';

  static Future<void> initialize() async {
    // No-op
  }

  static Future<bool> isStreakReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakReminder) ?? false;
  }

  static Future<void> setStreakReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakReminder, enabled);
  }
}
