import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';
import 'package:timezone/timezone.dart' as tz;

import '../../shared/domain/entities/pair.dart';

@Singleton()
class LocalNotification {
  final _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    void onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse,
    ) async {
      final String? payload = notificationResponse.payload;
      if (notificationResponse.payload != null) {
        log('notification payload: $payload');
      }
    }

    const initSettingsAndroid = AndroidInitializationSettings(
      'ic_notification',
    );
    final initSettingsDarwin = DarwinInitializationSettings();

    final initializationSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsDarwin,
      macOS: initSettingsDarwin,
    );
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );
  }

  Future<void> show({
    required String title,
    required String body,
    String? payload,
    Pair<String, String>? channel,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel?.first ?? 'high_importance_channel',
      channel?.second ?? 'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      payload: payload,
      platformChannelSpecifics,
    );
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    Pair<String, String>? channel,
  }) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      channel?.first ?? 'high_importance_channel',
      channel?.second ?? 'High Importance Notifications',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const iosPlatformChannelSpecifics = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iosPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(
        scheduledDate,
        tz.local,
      ),
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancel(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}
