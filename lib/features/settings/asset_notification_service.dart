import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/models/app_settings.dart';

class NotificationPermissionState {
  const NotificationPermissionState({
    required this.supported,
    required this.enabled,
  });

  final bool supported;
  final bool enabled;
}

abstract interface class AssetNotificationService {
  Future<void> initialize({void Function(String? payload)? onTap});
  Future<NotificationPermissionState> permissionState();
  Future<bool> requestPermission();
  Future<void> scheduleDailySummary({
    required AppSettings settings,
    required int reminderCount,
  });
  Future<void> cancelDailySummary();
}

class FlutterAssetNotificationService implements AssetNotificationService {
  FlutterAssetNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    DateTime Function()? clock,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _clock = clock ?? DateTime.now;

  final FlutterLocalNotificationsPlugin _plugin;
  final DateTime Function() _clock;
  var _initialized = false;

  static const _dailySummaryId = 1001;
  static const _channelId = 'asset_reminders';
  static const _channelName = '资产提醒';
  static const _payload = 'settings:reminders';

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {
    if (_initialized) return;
    tz.initializeTimeZones();
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings();
    await _plugin.initialize(
      settings: const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (response) {
        onTap?.call(response.payload);
      },
    );
    _initialized = true;
  }

  @override
  Future<NotificationPermissionState> permissionState() async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return const NotificationPermissionState(
        supported: false,
        enabled: false,
      );
    }
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      final enabled = await android?.areNotificationsEnabled() ?? false;
      return NotificationPermissionState(supported: true, enabled: enabled);
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    final enabled =
        await ios?.requestPermissions(
          alert: false,
          badge: false,
          sound: false,
        ) ??
        false;
    return NotificationPermissionState(supported: true, enabled: enabled);
  }

  @override
  Future<bool> requestPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return false;
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await ios?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        ) ??
        false;
  }

  @override
  Future<void> scheduleDailySummary({
    required AppSettings settings,
    required int reminderCount,
  }) async {
    if (!settings.remindersEnabled || reminderCount <= 0) {
      await cancelDailySummary();
      return;
    }
    final next = _nextOccurrence(
      settings.reminderHour,
      settings.reminderMinute,
    );
    await _plugin.zonedSchedule(
      id: _dailySummaryId,
      title: '资产提醒',
      body: '你有 $reminderCount 条资产提醒待处理',
      scheduledDate: next,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: '保修、闲置与保养通知',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: _payload,
    );
  }

  @override
  Future<void> cancelDailySummary() {
    return _plugin.cancel(id: _dailySummaryId);
  }

  tz.TZDateTime _nextOccurrence(int hour, int minute) {
    final now = _clock();
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (!scheduled.isAfter(tz.TZDateTime.from(now, tz.local))) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

class DisabledAssetNotificationService implements AssetNotificationService {
  const DisabledAssetNotificationService();

  @override
  Future<void> initialize({void Function(String? payload)? onTap}) async {}

  @override
  Future<NotificationPermissionState> permissionState() async {
    return const NotificationPermissionState(supported: false, enabled: false);
  }

  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<void> scheduleDailySummary({
    required AppSettings settings,
    required int reminderCount,
  }) async {
    debugPrint('Notifications unsupported; skip scheduling.');
  }

  @override
  Future<void> cancelDailySummary() async {}
}
