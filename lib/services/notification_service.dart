import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static const _keyStreakReminder = 'streak_reminder_enabled';
  static const _notifId = 1;

  static final _plugin = FlutterLocalNotificationsPlugin();

  // ── Init (panggil 1× di main.dart) ──────────────────────────────────────────

  static Future<void> initialize() async {
    tz.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    // Reschedule jika reminder masih aktif (misalnya setelah restart HP)
    final enabled = await isStreakReminderEnabled();
    if (enabled) await _schedule();
  }

  // ── Public API ────────────────────────────────────────────────────────────────

  static Future<bool> isStreakReminderEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyStreakReminder) ?? false;
  }

  static Future<void> setStreakReminderEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyStreakReminder, enabled);

    if (enabled) {
      await _requestPermission();
      await _schedule();
    } else {
      await _plugin.cancel(_notifId);
    }
  }

  // ── Internal ──────────────────────────────────────────────────────────────────

  static Future<void> _requestPermission() async {
    final android =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  static Future<void> _schedule() async {
    final now = tz.TZDateTime.now(tz.local);

    // Jadwalkan setiap hari pukul 20:00
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, 20, 0);

    // Jika jam 20:00 hari ini sudah lewat, jadwalkan besok
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    await _plugin.zonedSchedule(
      _notifId,
      'Jaga Streakmu! 🔥',
      'Kamu belum aktif hari ini. Buka Eco-Quest sekarang!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'streak_reminder_channel',
          'Pengingat Streak',
          channelDescription:
              'Notifikasi harian untuk menjaga streak aktivitas',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }
}
