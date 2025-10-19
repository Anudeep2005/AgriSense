import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class Notifications {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

   
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'farm_channel',
      'Farm Alerts',
      channelDescription: 'Notifications about farm activities',
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      0,
      title,
      body,
      details,
    );
  }
}
