import 'package:shared_preferences/shared_preferences.dart';

/// Mengelola preferensi notifikasi.
/// Notifikasi OS (flutter_local_notifications) dihapus karena inkompatibel
/// dengan AGP 8.11.x — notifikasi status laporan ditampilkan sebagai
/// in-app SnackBar melalui MainScaffold + Supabase Realtime.
class NotificationService {
  static const _keyStreakReminder = 'streak_reminder_enabled';

  static Future<void> initialize() async {
    // No-op — tidak perlu inisialisasi plugin eksternal
  }

  static Future<bool> isStreakReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakReminder) ?? false;
  }

  static Future<void> setStreakReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakReminder, enabled);
    // TODO (future): integrate flutter_local_notifications setelah
    // kompatibilitas AGP diselesaikan untuk scheduled streak reminder.
  }
}
