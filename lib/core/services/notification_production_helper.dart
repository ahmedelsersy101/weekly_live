import 'dart:developer';
import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Helper class for production-ready notification features
/// Ensures notifications work reliably in release mode on real devices
class NotificationProductionHelper {
  /// Check if the device supports reliable notifications in production
  static Future<Map<String, bool>> checkProductionCapabilities() async {
    final capabilities = <String, bool>{};

    try {
      final plugin = FlutterLocalNotificationsPlugin();

      if (Platform.isAndroid) {
        final androidImplementation = plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Check notification permission
          final notificationPermission =
              await androidImplementation.areNotificationsEnabled() ?? false;
          capabilities['android_notifications_enabled'] = notificationPermission;

          // Check exact alarm permission (Android 12+)
          final exactAlarmPermission =
              await androidImplementation.canScheduleExactNotifications() ?? false;
          capabilities['android_exact_alarms'] = exactAlarmPermission;

          log('NotificationProductionHelper: Android capabilities checked');
        }
      }

      if (Platform.isIOS) {
        final iosImplementation = plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

        if (iosImplementation != null) {
          // iOS permissions are handled during initialization
          capabilities['ios_notifications_enabled'] = true;
          log('NotificationProductionHelper: iOS capabilities checked');
        }
      }
    } catch (e) {
      log('NotificationProductionHelper: Error checking capabilities - $e');
    }

    return capabilities;
  }

  /// Request all necessary permissions for production notifications
  static Future<bool> requestProductionPermissions() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();
      bool allPermissionsGranted = true;

      if (Platform.isAndroid) {
        final androidImplementation = plugin
            .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

        if (androidImplementation != null) {
          // Request notification permission
          final notificationGranted =
              await androidImplementation.requestNotificationsPermission() ?? false;

          // Request exact alarm permission
          final exactAlarmGranted =
              await androidImplementation.requestExactAlarmsPermission() ?? false;

          allPermissionsGranted = notificationGranted && exactAlarmGranted;

          log(
            'NotificationProductionHelper: Android permissions - Notifications: $notificationGranted, ExactAlarms: $exactAlarmGranted',
          );
        }
      }

      if (Platform.isIOS) {
        final iosImplementation = plugin
            .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

        if (iosImplementation != null) {
          final granted =
              await iosImplementation.requestPermissions(
                alert: true,
                badge: true,
                sound: true,
                critical: true,
              ) ??
              false;

          allPermissionsGranted = allPermissionsGranted && granted;
          log('NotificationProductionHelper: iOS permissions granted: $granted');
        }
      }

      return allPermissionsGranted;
    } catch (e) {
      log('NotificationProductionHelper: Error requesting permissions - $e');
      return false;
    }
  }

  /// Show a test notification to verify production functionality
  static Future<bool> testProductionNotification() async {
    try {
      final plugin = FlutterLocalNotificationsPlugin();

      // Android notification details for production testing
      const androidDetails = AndroidNotificationDetails(
        'production_test',
        'Production Test',
        channelDescription: 'Testing notifications in production mode',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
        largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        autoCancel: true,
        ongoing: false,
        silent: false,
      );

      // iOS notification details for production testing
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
        badgeNumber: 1,
      );

      const notificationDetails = NotificationDetails(android: androidDetails, iOS: iosDetails);

      await plugin.show(
        999999, // Unique test ID
        'إشعار تجريبي - Production Test',
        'هذا إشعار تجريبي للتأكد من عمل الإشعارات في وضع الإنتاج',
        notificationDetails,
        payload: 'production_test',
      );

      log('NotificationProductionHelper: Production test notification sent');
      return true;
    } catch (e) {
      log('NotificationProductionHelper: Production test failed - $e');
      return false;
    }
  }

  /// Get detailed production status report
  static Future<Map<String, dynamic>> getProductionStatusReport() async {
    final report = <String, dynamic>{};

    try {
      // Check capabilities
      final capabilities = await checkProductionCapabilities();
      report['capabilities'] = capabilities;

      // Check pending notifications
      final plugin = FlutterLocalNotificationsPlugin();
      final pendingNotifications = await plugin.pendingNotificationRequests();
      report['pending_notifications_count'] = pendingNotifications.length;
      report['pending_notifications'] = pendingNotifications
          .map((n) => {'id': n.id, 'title': n.title, 'body': n.body})
          .toList();

      // Platform-specific checks
      if (Platform.isAndroid) {
        report['platform'] = 'Android';
        report['android_api_level'] = 'Unknown'; // Would need platform channel for exact API level
      } else if (Platform.isIOS) {
        report['platform'] = 'iOS';
      }

      // Overall status
      final hasBasicCapabilities = capabilities.values.any((v) => v == true);
      report['production_ready'] = hasBasicCapabilities;

      log('NotificationProductionHelper: Production status report generated');
    } catch (e) {
      log('NotificationProductionHelper: Error generating status report - $e');
      report['error'] = e.toString();
      report['production_ready'] = false;
    }

    return report;
  }

  /// Initialize production-ready notification settings
  static Future<bool> initializeProductionMode() async {
    try {
      log('NotificationProductionHelper: Initializing production mode...');

      // Request all permissions
      final permissionsGranted = await requestProductionPermissions();
      if (!permissionsGranted) {
        log('NotificationProductionHelper: Not all permissions granted');
      }

      // Check capabilities
      final capabilities = await checkProductionCapabilities();
      final hasCapabilities = capabilities.values.any((v) => v == true);

      if (!hasCapabilities) {
        log('NotificationProductionHelper: Device lacks notification capabilities');
        return false;
      }

      log('NotificationProductionHelper: Production mode initialized successfully');
      return true;
    } catch (e) {
      log('NotificationProductionHelper: Production initialization failed - $e');
      return false;
    }
  }
}
