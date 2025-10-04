import 'dart:developer';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

/// Service class for managing local notifications
/// Handles scheduling, updating, and canceling notifications for tasks
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// Initialize the notification service
  /// Must be called before using any notification features
  static Future<void> initialize() async {
    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Set local timezone
      final String timeZoneName = await _getTimeZoneName();
      tz.setLocalLocation(tz.getLocation(timeZoneName));

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/app_icon');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      // Request permissions for Android 13+
      if (Platform.isAndroid) {
        await _requestAndroidPermissions();
      }

      // Request permissions for iOS
      if (Platform.isIOS) {
        await _requestIOSPermissions();
      }

      log('NotificationService: Initialized successfully');
    } catch (e) {
      log('NotificationService: Initialization failed - $e');
      rethrow;
    }
  }

  /// Get the current timezone name
  static Future<String> _getTimeZoneName() async {
    try {
      final timeZoneName = DateTime.now().timeZoneName;

      // Map common timezone abbreviations to valid timezone names
      final timezoneMap = {
        // فلسطين
        'IDT': 'Asia/Gaza', // Israel Daylight Time → فلسطين (غزة)
        'IST': 'Asia/Hebron', // Israel Standard Time → فلسطين (القدس/الضفة)
        // أمريكا
        'PST': 'America/Los_Angeles',
        'PDT': 'America/Los_Angeles',
        'EST': 'America/New_York',
        'EDT': 'America/New_York',
        'CST': 'America/Chicago',
        'CDT': 'America/Chicago',
        'MST': 'America/Denver',
        'MDT': 'America/Denver',

        // أوروبا
        'GMT': 'UTC',
        'BST': 'Europe/London',
        'CET': 'Europe/Paris',
        'CEST': 'Europe/Paris',

        // الدول العربية
        'AST': 'Asia/Riyadh', // السعودية، قطر، الكويت، البحرين
        'EET': 'Africa/Cairo', // مصر
        'EEST': 'Africa/Cairo', // مصر (التوقيت الصيفي)
        'MSK': 'Europe/Moscow', // بتستخدمها سوريا/لبنان أحياناً
        'CAT': 'Africa/Khartoum', // السودان
        'E. Africa Standard Time': 'Africa/Nairobi', // شرق إفريقيا
        'GMT+3': 'Asia/Baghdad', // العراق
        'GMT+2': 'Africa/Tripoli', // ليبيا
        'GMT+1': 'Africa/Algiers', // الجزائر/تونس
        'WET': 'Africa/Casablanca', // المغرب
        'WEST': 'Africa/Casablanca', // المغرب (DST)
        // الخليج
        'Asia/Dubai': 'Asia/Dubai', // الإمارات
        'Asia/Muscat': 'Asia/Muscat', // عمان
        'Asia/Doha': 'Asia/Qatar', // قطر
        'Asia/Kuwait': 'Asia/Kuwait', // الكويت
        'Asia/Bahrain': 'Asia/Bahrain', // البحرين
        'Asia/Aden': 'Asia/Aden', // اليمن
        // الشام
        'Asia/Amman': 'Asia/Amman', // الأردن
        'Asia/Beirut': 'Asia/Beirut', // لبنان
        'Asia/Damascus': 'Asia/Damascus', // سوريا
      };

      // Check if we have a mapping for this timezone
      if (timezoneMap.containsKey(timeZoneName)) {
        return timezoneMap[timeZoneName]!;
      }

      // If no mapping found, try to use the timezone name directly
      // but fallback to UTC if it doesn't exist
      try {
        tz.getLocation(timeZoneName);
        return timeZoneName;
      } catch (e) {
        log('NotificationService: Timezone $timeZoneName not found, using UTC');
        return 'UTC';
      }
    } catch (e) {
      log('NotificationService: Could not get timezone, using UTC - $e');
      return 'UTC';
    }
  }

  /// Request notification permissions for Android 13+
  static Future<void> _requestAndroidPermissions() async {
    try {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        final bool? granted = await androidImplementation.requestNotificationsPermission();
        log('NotificationService: Android permissions granted: $granted');
      }
    } catch (e) {
      log('NotificationService: Android permission request failed - $e');
    }
  }

  /// Request notification permissions for iOS
  static Future<void> _requestIOSPermissions() async {
    try {
      final IOSFlutterLocalNotificationsPlugin? iosImplementation = _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();

      if (iosImplementation != null) {
        final bool? granted = await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        log('NotificationService: iOS permissions granted: $granted');
      }
    } catch (e) {
      log('NotificationService: iOS permission request failed - $e');
    }
  }

  /// Handle notification tap/interaction
  static void _onDidReceiveNotificationResponse(NotificationResponse response) {
    log(
      'NotificationService: Notification tapped - ID: ${response.id}, Payload: ${response.payload}',
    );
  }

  /// Schedule a notification for a specific date and time
  ///
  /// [id] - Unique identifier for the notification
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [scheduledTime] - When to show the notification
  /// [payload] - Optional data to pass with the notification
  Future<bool> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    try {
      // Validate input parameters
      if (title.trim().isEmpty) {
        throw ArgumentError('Notification title cannot be empty');
      }

      if (scheduledTime.isBefore(DateTime.now())) {
        log('NotificationService: Cannot schedule notification in the past');
        return false;
      }

      // Convert to timezone-aware datetime
      final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

      // Android notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'task_reminders', // Channel ID
        'Task Reminders', // Channel name
        channelDescription: 'Notifications for scheduled tasks',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@drawable/app_icon',
        largeIcon: DrawableResourceAndroidBitmap('@drawable/app_icon'),
      );

      // iOS notification details
      const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'default',
      );

      // Combined notification details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Schedule the notification
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzScheduledTime,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );

      log('NotificationService: Scheduled notification - ID: $id, Time: $scheduledTime');
      return true;
    } catch (e) {
      log('NotificationService: Failed to schedule notification - $e');
      return false;
    }
  }

  /// Cancel a specific notification by ID
  ///
  /// [id] - The ID of the notification to cancel
  Future<bool> cancelNotification(int id) async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id);
      log('NotificationService: Cancelled notification - ID: $id');
      return true;
    } catch (e) {
      log('NotificationService: Failed to cancel notification - $e');
      return false;
    }
  }

  /// Update an existing notification by canceling the old one and scheduling a new one
  ///
  /// [id] - The ID of the notification to update
  /// [title] - New notification title
  /// [body] - New notification body text
  /// [newTime] - New scheduled time
  /// [payload] - Optional new payload data
  Future<bool> updateNotification({
    required int id,
    required String title,
    required String body,
    required DateTime newTime,
    String? payload,
  }) async {
    try {
      // Cancel the existing notification
      final bool cancelled = await cancelNotification(id);
      if (!cancelled) {
        log('NotificationService: Failed to cancel existing notification for update');
        return false;
      }

      // Schedule the new notification with the same ID
      final bool scheduled = await scheduleNotification(
        id: id,
        title: title,
        body: body,
        scheduledTime: newTime,
        payload: payload,
      );

      if (scheduled) {
        log('NotificationService: Updated notification - ID: $id, New time: $newTime');
      }

      return scheduled;
    } catch (e) {
      log('NotificationService: Failed to update notification - $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications
  Future<bool> cancelAllNotifications() async {
    try {
      await _flutterLocalNotificationsPlugin.cancelAll();
      log('NotificationService: Cancelled all notifications');
      return true;
    } catch (e) {
      log('NotificationService: Failed to cancel all notifications - $e');
      return false;
    }
  }

  /// Get list of all pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      final List<PendingNotificationRequest> pendingNotifications =
          await _flutterLocalNotificationsPlugin.pendingNotificationRequests();

      log('NotificationService: Found ${pendingNotifications.length} pending notifications');
      return pendingNotifications;
    } catch (e) {
      log('NotificationService: Failed to get pending notifications - $e');
      return [];
    }
  }

  /// Check if a specific notification is scheduled
  ///
  /// [id] - The ID of the notification to check
  Future<bool> isNotificationScheduled(int id) async {
    try {
      final List<PendingNotificationRequest> pendingNotifications = await getPendingNotifications();

      return pendingNotifications.any((notification) => notification.id == id);
    } catch (e) {
      log('NotificationService: Failed to check notification status - $e');
      return false;
    }
  }

  /// Show an immediate notification (for testing purposes)
  ///
  /// [id] - Unique identifier for the notification
  /// [title] - Notification title
  /// [body] - Notification body text
  /// [payload] - Optional data to pass with the notification
  Future<bool> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      // Android notification details
      const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'immediate_notifications',
        'Immediate Notifications',
        channelDescription: 'Immediate notifications for testing',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@drawable/app_icon',
      );

      // iOS notification details
      const DarwinNotificationDetails iOSPlatformChannelSpecifics = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      // Combined notification details
      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Show the notification immediately
      await _flutterLocalNotificationsPlugin.show(
        id,
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      log('NotificationService: Showed immediate notification - ID: $id');
      return true;
    } catch (e) {
      log('NotificationService: Failed to show immediate notification - $e');
      return false;
    }
  }
}
