import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static const _keyStreakReminder = 'streak_reminder_enabled';

  static Future<bool> isStreakReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakReminder) ?? false;
  }

  static Future<void> setStreakReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakReminder, enabled);
    // TODO: integrate flutter_local_notifications to schedule/cancel
    // a daily reminder notification when this is toggled.
  }
}
