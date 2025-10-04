import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// Centralized permissions manager for notifications and exact alarms.
class PermissionService {
  static const MethodChannel _channel = MethodChannel('app.permissions');

  Future<bool> areNotificationsEnabled() async {
    if (!Platform.isAndroid) return true;
    try {
      final enabled = await _channel.invokeMethod<bool>('areNotificationsEnabled');
      return enabled ?? true;
    } catch (e) {
      debugPrint('areNotificationsEnabled error: $e');
      return true;
    }
  }

  Future<void> openNotificationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openNotificationSettings');
    } catch (e) {
      debugPrint('openNotificationSettings error: $e');
    }
  }

  Future<bool> canScheduleExactAlarms() async {
    if (!Platform.isAndroid) return true;
    try {
      final allowed = await _channel.invokeMethod<bool>('canScheduleExactAlarms');
      return allowed ?? true;
    } catch (e) {
      debugPrint('canScheduleExactAlarms error: $e');
      return true;
    }
  }

  Future<void> openExactAlarmSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openExactAlarmSettings');
    } catch (e) {
      debugPrint('openExactAlarmSettings error: $e');
    }
  }

  Future<bool> isIgnoringBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;
    try {
      final ignoring = await _channel.invokeMethod<bool>('isIgnoringBatteryOptimizations');
      return ignoring ?? true;
    } catch (e) {
      debugPrint('isIgnoringBatteryOptimizations error: $e');
      return true;
    }
  }

  Future<void> openBatteryOptimizationSettings() async {
    if (!Platform.isAndroid) return;
    try {
      await _channel.invokeMethod('openBatteryOptimizationSettings');
    } catch (e) {
      debugPrint('openBatteryOptimizationSettings error: $e');
    }
  }

  /// Request runtime POST_NOTIFICATIONS on Android 13+ and handle denial.
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final res = await Permission.notification.request();
    return res.isGranted;
  }

  /// Ensure notifications and exact alarms are permitted; guide to settings when needed.
  Future<PermissionCheckResult> ensureAllPermissions() async {
    final result = PermissionCheckResult();

    // Notifications
    final notifGranted = await requestNotificationPermission();
    result.notificationsGranted = notifGranted && await areNotificationsEnabled();

    // Exact alarm allowed (S+)
    result.exactAlarmsAllowed = await canScheduleExactAlarms();

    // Battery optimization ignored (best-effort for custom ROMs)
    result.ignoringBatteryOptimizations = await isIgnoringBatteryOptimizations();

    return result;
  }
}

class PermissionCheckResult {
  bool notificationsGranted = true;
  bool exactAlarmsAllowed = true;
  bool ignoringBatteryOptimizations = true;

  bool get isReadyForReminders =>
      notificationsGranted && exactAlarmsAllowed; // battery opt-out is advisory
}
