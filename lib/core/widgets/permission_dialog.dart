import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/services/permission_service.dart';

class PermissionDialog extends StatelessWidget {
  final PermissionService permissionService;
  final VoidCallback? onClose;

  const PermissionDialog({super.key, required this.permissionService, this.onClose});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Enable Reminders & Notifications'),
      content: const Text(
        'To deliver scheduled reminders reliably, the app needs:\n\n'
        '• Notifications permission (Android 13+)\n'
        '• Exact alarms permission (Android 12+)\n\n'
        'On some devices (Xiaomi/Oppo/Realme), you may also need to disable battery optimizations.',
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Not now')),
        if (Platform.isAndroid) ...[
          TextButton(
            onPressed: () async {
              await permissionService.openNotificationSettings();
            },
            child: const Text('Notification Settings'),
          ),
          TextButton(
            onPressed: () async {
              await permissionService.openExactAlarmSettings();
            },
            child: const Text('Allow Exact Alarms'),
          ),
          TextButton(
            onPressed: () async {
              await permissionService.openBatteryOptimizationSettings();
            },
            child: const Text('Battery Optimization'),
          ),
        ],
        FilledButton(
          onPressed: () async {
            // Re-check after user visits settings
            final status = await permissionService.ensureAllPermissions();
            if (context.mounted) Navigator.of(context).pop(status);
            onClose?.call();
          },
          child: const Text('I Enabled Them'),
        ),
      ],
    );
  }
}
