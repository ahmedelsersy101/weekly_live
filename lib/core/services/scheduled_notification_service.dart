import 'dart:developer';
import 'notification_service.dart';

/// Service class for managing scheduled push notifications
/// Handles daily and weekly recurring notifications
class ScheduledNotificationService {
  static final ScheduledNotificationService _instance = ScheduledNotificationService._internal();
  factory ScheduledNotificationService() => _instance;
  ScheduledNotificationService._internal();

  // Notification IDs for different types
  static const int _dailyNotificationId = 1001;
  static const int _weeklyNotificationId = 1002;

  // Notification messages in Arabic
  static const String _dailyMessage = 'قم بتفقد مهام اليوم';
  static const String _weeklyMessage = 'قم بإضافة مهام الأسبوع';
  static const String _appTitle = ' المهام اليومية';

  /// Initialize and schedule all recurring notifications
  /// This should be called when the app starts or when user enables notifications
  static Future<void> initializeScheduledNotifications() async {
    try {
      log('ScheduledNotificationService: Initializing scheduled notifications...');

      // Schedule daily notification
      await _scheduleDailyNotification();

      // Schedule weekly notification
      await _scheduleWeeklyNotification();

      log('ScheduledNotificationService: All scheduled notifications initialized successfully');
    } catch (e) {
      log('ScheduledNotificationService: Failed to initialize scheduled notifications - $e');
      rethrow;
    }
  }

  /// Schedule daily notification at 9:00 AM every day
  static Future<bool> _scheduleDailyNotification() async {
    try {
      // Cancel existing daily notification to prevent duplicates
      await NotificationService().cancelNotification(_dailyNotificationId);

      // Calculate next 9:00 AM
      final DateTime now = DateTime.now();
      DateTime nextNotification = DateTime(now.year, now.month, now.day, 9, 0);

      // If it's already past 9:00 AM today, schedule for tomorrow
      if (now.hour >= 9) {
        nextNotification = nextNotification.add(const Duration(days: 1));
      }

      // Schedule the notification
      final bool success = await NotificationService().scheduleNotification(
        id: _dailyNotificationId,
        title: _appTitle,
        body: _dailyMessage,
        scheduledTime: nextNotification,
        payload: 'daily_reminder',
      );

      if (success) {
        log('ScheduledNotificationService: Daily notification scheduled for $nextNotification');
      } else {
        log('ScheduledNotificationService: Failed to schedule daily notification');
      }

      return success;
    } catch (e) {
      log('ScheduledNotificationService: Error scheduling daily notification - $e');
      return false;
    }
  }

  /// Schedule weekly notification at 9:00 AM every Saturday
  static Future<bool> _scheduleWeeklyNotification() async {
    try {
      // Cancel existing weekly notification to prevent duplicates
      await NotificationService().cancelNotification(_weeklyNotificationId);

      // Calculate next Saturday at 9:00 AM
      final DateTime now = DateTime.now();
      DateTime nextSaturday = _getNextSaturday(now);
      nextSaturday = DateTime(nextSaturday.year, nextSaturday.month, nextSaturday.day, 9, 0);

      // Schedule the notification
      final bool success = await NotificationService().scheduleNotification(
        id: _weeklyNotificationId,
        title: _appTitle,
        body: _weeklyMessage,
        scheduledTime: nextSaturday,
        payload: 'weekly_reminder',
      );

      if (success) {
        log('ScheduledNotificationService: Weekly notification scheduled for $nextSaturday');
      } else {
        log('ScheduledNotificationService: Failed to schedule weekly notification');
      }

      return success;
    } catch (e) {
      log('ScheduledNotificationService: Error scheduling weekly notification - $e');
      return false;
    }
  }

  /// Get the next Saturday from the given date
  static DateTime _getNextSaturday(DateTime from) {
    // Saturday is day 6 (Monday = 1, Sunday = 7)
    int daysUntilSaturday = (6 - from.weekday) % 7;

    // If today is Saturday and it's before 9:00 AM, use today
    if (from.weekday == 6 && from.hour < 9) {
      return from;
    }

    // If today is Saturday and it's after 9:00 AM, or if daysUntilSaturday is 0, get next Saturday
    if (daysUntilSaturday == 0) {
      daysUntilSaturday = 7;
    }

    return from.add(Duration(days: daysUntilSaturday));
  }

  /// Reschedule daily notification (useful when user changes notification time)
  static Future<bool> rescheduleDailyNotification() async {
    try {
      log('ScheduledNotificationService: Rescheduling daily notification...');
      return await _scheduleDailyNotification();
    } catch (e) {
      log('ScheduledNotificationService: Error rescheduling daily notification - $e');
      return false;
    }
  }

  /// Reschedule weekly notification (useful when user changes notification time)
  static Future<bool> rescheduleWeeklyNotification() async {
    try {
      log('ScheduledNotificationService: Rescheduling weekly notification...');
      return await _scheduleWeeklyNotification();
    } catch (e) {
      log('ScheduledNotificationService: Error rescheduling weekly notification - $e');
      return false;
    }
  }

  /// Cancel daily notification
  static Future<bool> cancelDailyNotification() async {
    try {
      final bool success = await NotificationService().cancelNotification(_dailyNotificationId);
      if (success) {
        log('ScheduledNotificationService: Daily notification cancelled');
      }
      return success;
    } catch (e) {
      log('ScheduledNotificationService: Error cancelling daily notification - $e');
      return false;
    }
  }

  /// Cancel weekly notification
  static Future<bool> cancelWeeklyNotification() async {
    try {
      final bool success = await NotificationService().cancelNotification(_weeklyNotificationId);
      if (success) {
        log('ScheduledNotificationService: Weekly notification cancelled');
      }
      return success;
    } catch (e) {
      log('ScheduledNotificationService: Error cancelling weekly notification - $e');
      return false;
    }
  }

  /// Cancel all scheduled notifications (daily and weekly)
  static Future<bool> cancelAllScheduledNotifications() async {
    try {
      log('ScheduledNotificationService: Cancelling all scheduled notifications...');

      final bool dailyCancelled = await cancelDailyNotification();
      final bool weeklyCancelled = await cancelWeeklyNotification();

      final bool allCancelled = dailyCancelled && weeklyCancelled;

      if (allCancelled) {
        log('ScheduledNotificationService: All scheduled notifications cancelled successfully');
      } else {
        log('ScheduledNotificationService: Some notifications may not have been cancelled');
      }

      return allCancelled;
    } catch (e) {
      log('ScheduledNotificationService: Error cancelling all scheduled notifications - $e');
      return false;
    }
  }

  /// Check if daily notification is scheduled
  static Future<bool> isDailyNotificationScheduled() async {
    try {
      return await NotificationService().isNotificationScheduled(_dailyNotificationId);
    } catch (e) {
      log('ScheduledNotificationService: Error checking daily notification status - $e');
      return false;
    }
  }

  /// Check if weekly notification is scheduled
  static Future<bool> isWeeklyNotificationScheduled() async {
    try {
      return await NotificationService().isNotificationScheduled(_weeklyNotificationId);
    } catch (e) {
      log('ScheduledNotificationService: Error checking weekly notification status - $e');
      return false;
    }
  }

  /// Get status of all scheduled notifications
  static Future<Map<String, bool>> getScheduledNotificationsStatus() async {
    try {
      final bool dailyScheduled = await isDailyNotificationScheduled();
      final bool weeklyScheduled = await isWeeklyNotificationScheduled();

      return {'daily': dailyScheduled, 'weekly': weeklyScheduled};
    } catch (e) {
      log('ScheduledNotificationService: Error getting scheduled notifications status - $e');
      return {'daily': false, 'weekly': false};
    }
  }

  /// Refresh all scheduled notifications (useful for app startup or settings changes)
  static Future<bool> refreshAllScheduledNotifications() async {
    try {
      log('ScheduledNotificationService: Refreshing all scheduled notifications...');

      final bool dailyScheduled = await _scheduleDailyNotification();
      final bool weeklyScheduled = await _scheduleWeeklyNotification();

      final bool allScheduled = dailyScheduled && weeklyScheduled;

      if (allScheduled) {
        log('ScheduledNotificationService: All scheduled notifications refreshed successfully');
      } else {
        log('ScheduledNotificationService: Some notifications may not have been scheduled');
      }

      return allScheduled;
    } catch (e) {
      log('ScheduledNotificationService: Error refreshing scheduled notifications - $e');
      return false;
    }
  }

  /// Test daily notification (show immediately for testing)
  static Future<bool> testDailyNotification() async {
    try {
      return await NotificationService().showImmediateNotification(
        id: _dailyNotificationId + 1000, // Use different ID to avoid conflicts
        title: _appTitle,
        body: _dailyMessage,
        payload: 'test_daily_reminder',
      );
    } catch (e) {
      log('ScheduledNotificationService: Error testing daily notification - $e');
      return false;
    }
  }

  /// Test weekly notification (show immediately for testing)
  static Future<bool> testWeeklyNotification() async {
    try {
      return await NotificationService().showImmediateNotification(
        id: _weeklyNotificationId + 1000, // Use different ID to avoid conflicts
        title: _appTitle,
        body: _weeklyMessage,
        payload: 'test_weekly_reminder',
      );
    } catch (e) {
      log('ScheduledNotificationService: Error testing weekly notification - $e');
      return false;
    }
  }
}
