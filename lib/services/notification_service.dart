import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService() {
    androidPlatformChannelSpecifics = AndroidNotificationDetails(
      "1",
      "Scamizone",
      enableVibration: true,
      playSound: true,
    );
    notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);
  }

  final instance = FlutterLocalNotificationsPlugin();

  late final AndroidNotificationDetails androidPlatformChannelSpecifics;

  late final NotificationDetails notificationDetails;
  late final tz.Location location;

  Future<void> init() async {
    final AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings("middlefinger");

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    tz.initializeTimeZones();

    location = tz.getLocation("Asia/Kolkata");

    await instance.initialize(
      initializationSettings,
    );
  }

  Future<void> addNotification(String time, String className,
      [bool now = false]) async {
    if (!now) {
      final scheduledDate = tz.TZDateTime(
        location,
        tz.TZDateTime.now(location).year,
        tz.TZDateTime.now(location).month,
        tz.TZDateTime.now(location).day,
        int.parse(time.substring(0, 2)),
        int.parse(time.substring(3, 5)) - 5,
      );
      await instance.zonedSchedule(
        time.hashCode,
        className,
        time,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
      );
    } else {
      await instance.show(
        time.hashCode,
        className,
        time,
        notificationDetails,
      );
    }
  }
}
