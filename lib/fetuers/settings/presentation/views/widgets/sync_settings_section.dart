import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';

class SyncSettingsSection extends StatelessWidget {
  final SyncProvider syncProvider;
  final bool autoSync;
  final DateTime? lastBackup;
  final ValueChanged<SyncProvider> onSyncProviderChanged;
  final ValueChanged<bool> onAutoSyncChanged;

  const SyncSettingsSection({
    super.key,
    required this.syncProvider,
    required this.autoSync,
    required this.lastBackup,
    required this.onSyncProviderChanged,
    required this.onAutoSyncChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsSection(
      title: AppLocalizations.of(context).tr('settings.dataSync'),
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.syncProvider'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            _getSyncProviderText(context, syncProvider),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          leading: Icon(Icons.cloud_sync, color: colorScheme.primary),
          trailing: DropdownButton<SyncProvider>(
            value: syncProvider,
            onChanged: (SyncProvider? newValue) {
              if (newValue != null) {
                onSyncProviderChanged(newValue);
              }
            },
            items: SyncProvider.values.map((SyncProvider provider) {
              return DropdownMenuItem<SyncProvider>(
                value: provider,
                child: Text(
                  _getSyncProviderText(context, provider),
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        SwitchListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.autoSync'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            AppLocalizations.of(context).tr('settings.autoSyncSubtitle'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          value: autoSync,
          onChanged: onAutoSyncChanged,
          secondary: Icon(Icons.sync, color: colorScheme.primary),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.lastBackup'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            lastBackup != null
                ? _formatLastBackup(context, lastBackup!)
                : AppLocalizations.of(context).tr('settings.never'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          leading: Icon(Icons.backup, color: colorScheme.primary),
          trailing: TextButton(
            onPressed: () => _showBackupInfo(context),
            child: Text(
              AppLocalizations.of(context).tr('settings.info'),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  String _getSyncProviderText(BuildContext context, SyncProvider provider) {
    switch (provider) {
      case SyncProvider.none:
        return 'None';
      case SyncProvider.googleDrive:
        return 'Google Drive';
      case SyncProvider.iCloud:
        return 'iCloud';
    }
  }

  String _formatLastBackup(BuildContext context, DateTime lastBackup) {
    final now = DateTime.now();
    final difference = now.difference(lastBackup);

    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  void _showBackupInfo(BuildContext context) {
    if (lastBackup == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              AppLocalizations.of(context).tr('settings.backupInfoTitle'),
            ),
            content: Text(
              AppLocalizations.of(context).tr('settings.noBackupYet'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(AppLocalizations.of(context).tr('settings.close')),
              ),
            ],
          );
        },
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).tr('settings.backupInfoTitle'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).trWithParams(
                  'settings.lastBackupDate',
                  {'date': _formatLastBackup(context, lastBackup!)},
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).trWithParams(
                  'settings.backupDate',
                  {'date': lastBackup.toString().split(' ')[0]},
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).trWithParams(
                  'settings.backupTime',
                  {'time': lastBackup.toString().split(' ')[1].substring(0, 5)},
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).tr('settings.close')),
            ),
          ],
        );
      },
    );
  }
}
