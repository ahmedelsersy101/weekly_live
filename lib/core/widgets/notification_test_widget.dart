import 'package:flutter/material.dart';
import '../services/notification_service.dart';

/// Test widget for notification functionality
/// This widget provides buttons to test immediate notifications
class NotificationTestWidget extends StatelessWidget {
  const NotificationTestWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Notification Test',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'Test the notification system with immediate notifications:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testImmediateNotification(context),
                    icon: const Icon(Icons.notifications),
                    label: const Text('Test Notification'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _testScheduledNotification(context),
                    icon: const Icon(Icons.schedule),
                    label: const Text('Test in 5 seconds'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showPendingNotifications(context),
                icon: const Icon(Icons.list),
                label: const Text('Show Pending Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testImmediateNotification(BuildContext context) async {
    try {
      final notificationService = NotificationService();
      final success = await notificationService.showImmediateNotification(
        id: 999,
        title: 'Test Notification',
        body: 'This is a test notification from your Weekly Dashboard app!',
        payload: 'test_notification',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Test notification sent successfully!' : 'Failed to send test notification',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _testScheduledNotification(BuildContext context) async {
    try {
      final notificationService = NotificationService();
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));

      final success = await notificationService.scheduleNotification(
        id: 998,
        title: 'Scheduled Test',
        body: 'This notification was scheduled 5 seconds ago!',
        scheduledTime: scheduledTime,
        payload: 'scheduled_test',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Notification scheduled for 5 seconds from now!'
                  : 'Failed to schedule notification',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _showPendingNotifications(BuildContext context) async {
    try {
      final notificationService = NotificationService();
      final pendingNotifications = await notificationService.getPendingNotifications();

      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Pending Notifications'),
            content: SizedBox(
              width: double.maxFinite,
              child: pendingNotifications.isEmpty
                  ? const Text('No pending notifications')
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: pendingNotifications.length,
                      itemBuilder: (context, index) {
                        final notification = pendingNotifications[index];
                        return ListTile(
                          leading: const Icon(Icons.notifications_outlined),
                          title: Text(notification.title ?? 'No Title'),
                          subtitle: Text(notification.body ?? 'No Body'),
                          trailing: Text('ID: ${notification.id}'),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
            ],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    }
  }
}
