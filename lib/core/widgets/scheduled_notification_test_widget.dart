import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/services/scheduled_notification_service.dart';

/// Test widget for scheduled notifications
/// This widget provides buttons to test and manage scheduled notifications
/// Should only be used in development/debug mode
class ScheduledNotificationTestWidget extends StatefulWidget {
  const ScheduledNotificationTestWidget({super.key});

  @override
  State<ScheduledNotificationTestWidget> createState() => _ScheduledNotificationTestWidgetState();
}

class _ScheduledNotificationTestWidgetState extends State<ScheduledNotificationTestWidget> {
  Map<String, bool> _notificationStatus = {'daily': false, 'weekly': false};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationStatus();
  }

  Future<void> _loadNotificationStatus() async {
    setState(() => _isLoading = true);
    try {
      final status = await ScheduledNotificationService.getScheduledNotificationsStatus();
      setState(() {
        _notificationStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Failed to load notification status: $e');
    }
  }

  Future<void> _testDailyNotification() async {
    setState(() => _isLoading = true);
    try {
      final success = await ScheduledNotificationService.testDailyNotification();
      setState(() => _isLoading = false);
      if (success) {
        _showSuccessSnackBar('Daily notification test sent!');
      } else {
        _showErrorSnackBar('Failed to send daily notification test');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error testing daily notification: $e');
    }
  }

  Future<void> _testWeeklyNotification() async {
    setState(() => _isLoading = true);
    try {
      final success = await ScheduledNotificationService.testWeeklyNotification();
      setState(() => _isLoading = false);
      if (success) {
        _showSuccessSnackBar('Weekly notification test sent!');
      } else {
        _showErrorSnackBar('Failed to send weekly notification test');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error testing weekly notification: $e');
    }
  }

  Future<void> _refreshAllNotifications() async {
    setState(() => _isLoading = true);
    try {
      final success = await ScheduledNotificationService.refreshAllScheduledNotifications();
      setState(() => _isLoading = false);
      if (success) {
        _showSuccessSnackBar('All notifications refreshed successfully!');
        await _loadNotificationStatus();
      } else {
        _showErrorSnackBar('Failed to refresh some notifications');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error refreshing notifications: $e');
    }
  }

  Future<void> _cancelAllNotifications() async {
    setState(() => _isLoading = true);
    try {
      final success = await ScheduledNotificationService.cancelAllScheduledNotifications();
      setState(() => _isLoading = false);
      if (success) {
        _showSuccessSnackBar('All notifications cancelled successfully!');
        await _loadNotificationStatus();
      } else {
        _showErrorSnackBar('Failed to cancel some notifications');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorSnackBar('Error cancelling notifications: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.notifications_active, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Scheduled Notifications Test',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Status Section
            const Text('Current Status:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildStatusCard(
                    'Daily (9:00 AM)',
                    _notificationStatus['daily'] ?? false,
                    Colors.orange,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatusCard(
                    'Weekly (Saturday 9:00 AM)',
                    _notificationStatus['weekly'] ?? false,
                    Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Test Buttons
            const Text('Test Notifications:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testDailyNotification,
                    icon: const Icon(Icons.today, size: 18),
                    label: const Text('Test Daily'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _testWeeklyNotification,
                    icon: const Icon(Icons.calendar_view_week, size: 18),
                    label: const Text('Test Weekly'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Management Buttons
            const Text('Manage Notifications:', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _refreshAllNotifications,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: const Text('Refresh All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _cancelAllNotifications,
                    icon: const Icon(Icons.cancel, size: 18),
                    label: const Text('Cancel All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Refresh Status Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _loadNotificationStatus,
                icon: const Icon(Icons.info_outline, size: 18),
                label: const Text('Refresh Status'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, bool isActive, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isActive ? color.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isActive ? color : Colors.grey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? color : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isActive ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: isActive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  fontSize: 11,
                  color: isActive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
