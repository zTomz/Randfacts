import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class LocalNotifications {
  static final LocalNotifications instance = LocalNotifications._internal();
  factory LocalNotifications() => instance;

  LocalNotifications._internal() {
    // Init
    _init();

    _configureLocalTimeZone();
  }

  void _init() async {
    // Get permission for android devices
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()!
        .requestPermission();

    notificationsEnabled = await flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.areNotificationsEnabled() ??
        false;

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) {
      return;
    }
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  tz.TZDateTime _nextInstanceOfTenAM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      10,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> zonedScheduleNotificationForNext7Days(List<String> facts) async {
    for (int i = 1; i <= 7; i++) {
      final now = tz.TZDateTime.now(tz.local);
      var newTime = now.add(Duration(days: i));
      if (newTime.hour > 10) {
        newTime = newTime.subtract(Duration(hours: newTime.hour - 10));
      } else {
        newTime = newTime.add(Duration(hours: 10 - newTime.hour));
      }
      newTime = newTime.subtract(Duration(minutes: newTime.minute));
      newTime = newTime.subtract(Duration(seconds: newTime.second));

      await flutterLocalNotificationsPlugin.zonedSchedule(
        i,
        'New random fact',
        facts[Random().nextInt(facts.length)],
        newTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'your channel id',
            'your channel name',
            channelDescription: 'your channel description',
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  void alarmIn5Seconds() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'New random fact',
      "Test",
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  bool notificationsEnabled = false;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  int _id = 0;

  Future<void> showNotification(List<String> randomFacts) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    await flutterLocalNotificationsPlugin.show(
      _id++,
      'New random fact',
      randomFacts[Random().nextInt(randomFacts.length)],
      notificationDetails,
      payload: 'single message',
    );
  }

  Future<void> scheduleDailyTenAMNotification(List<String> randomFacts) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'New random fact',
      randomFacts[Random().nextInt(randomFacts.length)],
      _nextInstanceOfTenAM(),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily notification channel id',
          'daily notification channel name',
          channelDescription: 'daily notification description',
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void cancelAllAlarms() {
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void getActiveAlarms() async {
    List<ActiveNotification> currentAlarms =
        await flutterLocalNotificationsPlugin.getActiveNotifications();
    List<PendingNotificationRequest> pendingAlarms =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();

    debugPrint("Active alarms:");
    for (var alarm in currentAlarms) {
      debugPrint(alarm.id.toString());
      debugPrint(alarm.body);
    }

    debugPrint("Pending alarms:");
    for (var alarm in pendingAlarms) {
      debugPrint(alarm.id.toString());
      debugPrint(alarm.body);
    }
  }
}

class ReceivedNotification {
  ReceivedNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.payload,
  });

  final int id;
  final String? title;
  final String? body;
  final String? payload;
}
