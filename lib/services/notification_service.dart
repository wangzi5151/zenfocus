import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const settings =
        InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
    try {
      await _plugin.initialize(settings);
      final android =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
    } catch (_) {}
  }

  Future<void> show(String title, String body) async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'zenfocus_timer',
        'ZenFocus',
        channelDescription: 'Timer reminders',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
    try {
      await _plugin.show(0, title, body, details);
    } catch (_) {}
  }
}
