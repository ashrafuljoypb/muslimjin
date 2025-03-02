import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String notificationEnabledKey = 'prayer_notifications_enabled';

  Future<void> initNotification() async {
    // Initialize time zones
    tz.initializeTimeZones();

    // Android initialization settings
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    // Combined initialization settings for Android and iOS
    final InitializationSettings initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification tap if needed
      },
    );
  }

  Future<void> scheduleNotification(
      String title, String body, DateTime scheduledTime) async {
    // Check if notifications are enabled
    if (!await isNotificationsEnabled()) return;

    // Android notification details
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'prayer_times', // Channel ID
      'Prayer Times', // Channel name
      channelDescription: 'Prayer time notifications', // Channel description
      importance: Importance.max,
      priority: Priority.high,
    );

    // Notification details for both Android and iOS
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    try {
      // Schedule the notification
      await notificationsPlugin.zonedSchedule(
        scheduledTime.millisecondsSinceEpoch ~/ 1000, // Unique ID for the notification
        title,
        body,
        tz.TZDateTime.from(scheduledTime, tz.local), // Convert to local time zone
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Allow notification even in idle mode
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }

  Future<bool> isNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(notificationEnabledKey) ?? true; // Default to true if not set
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(notificationEnabledKey, enabled);
  }
}