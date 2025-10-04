import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/utils/size_config.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/view_model/settings_cubit.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/week_settings_section.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/language_settings_section.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/theme_settings_section.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/account_settings_section.dart';
import 'package:weekly_dash_board/core/services/data_backup_service.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  void initState() {
    super.initState();
    context.read<SettingsCubit>().loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: colorScheme.error,
              ),
            );
            context.read<SettingsCubit>().clearError();
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: colorScheme.primary),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (state.settings != null) ...[
                  MediaQuery.of(context).size.width < SizeConfig.desktop &&
                          MediaQuery.of(context).size.width < SizeConfig.tablet
                      ? const AccountSettingsSection()
                      : const SizedBox(),
                  const SizedBox(height: 24),
                  ThemeSettingsSection(
                    themeMode: state.settings!.themeMode,
                    onThemeModeChanged: (themeMode) {
                      context.read<SettingsCubit>().updateThemeMode(themeMode);
                    },
                  ),
                  const SizedBox(height: 24),
                  WeekSettingsSection(
                    weekStart: state.settings!.weekStart,
                    weekendDays: state.settings!.weekendDays,
                    onWeekStartChanged: (weekStart) {
                      context.read<SettingsCubit>().updateWeekStart(weekStart);
                      context.read<WeeklyCubit>().updateWeekStart(weekStart);
                    },
                    onWeekendDaysChanged: (weekendDays) {
                      context.read<SettingsCubit>().updateWeekendDays(
                        weekendDays,
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  // SyncSettingsSection(
                  //   syncProvider: state.settings!.syncProvider,
                  //   autoSync: state.settings!.autoSync,
                  //   lastBackup: state.settings!.lastBackup,
                  //   onSyncProviderChanged: (provider) {
                  //     context.read<SettingsCubit>().updateSyncProvider(
                  //       provider,
                  //     );
                  //   },
                  //   onAutoSyncChanged: (autoSync) {
                  //     context.read<SettingsCubit>().updateAutoSync(autoSync);
                  //   },
                  // ),
                  // const SizedBox(height: 24),
                  LanguageSettingsSection(
                    language: state.settings!.language,
                    onLanguageChanged: (language) {
                      context.read<SettingsCubit>().updateLanguage(language);
                    },
                  ),
                  const SizedBox(height: 24),
                ],
                SettingsSection(
                  title: AppLocalizations.of(
                    context,
                  ).tr('settings.dataManagement'),
                  children: [
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context).tr('settings.backupData'),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        ).tr('settings.backupSubtitle'),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      leading: Icon(Icons.backup, color: colorScheme.primary),
                      onTap: () async {
                        await _backupData(context);
                        context.read<SettingsCubit>().loadSettings();
                      },
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context).tr('settings.restoreData'),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        ).tr('settings.restoreSubtitle'),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      leading: Icon(Icons.restore, color: colorScheme.primary),
                      onTap: () async {
                        await _restoreData(context);
                        if (context.mounted) {
                          context.read<WeeklyCubit>().reloadTasksFromStorage();
                          context.read<SettingsCubit>().loadSettings();
                        }
                      },
                    ),
                    ListTile(
                      title: Text(
                        AppLocalizations.of(context).tr('settings.resetApp'),
                        style: TextStyle(color: colorScheme.onSurface),
                      ),
                      subtitle: Text(
                        AppLocalizations.of(
                          context,
                        ).tr('settings.resetSubtitle'),
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      leading: Icon(Icons.refresh, color: colorScheme.primary),
                      onTap: () {
                        _showResetConfirmationDialog(context);
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).tr('settings.resetConfirmationTitle'),
          ),
          content: Text(
            AppLocalizations.of(
              context,
            ).tr('settings.resetConfirmationMessage'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(AppLocalizations.of(context).tr('settings.cancel')),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<SettingsCubit>().resetToDefaults();
              },
              style: TextButton.styleFrom(foregroundColor: colorScheme.error),
              child: Text(AppLocalizations.of(context).tr('settings.reset')),
            ),
          ],
        );
      },
    );
  }

  Future<void> _backupData(BuildContext context) async {
    try {
      final file = await DataBackupService.backup();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).trWithParams(
                'settings.backupSuccess',
                {'filename': file.path.split('/').last},
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).trWithParams('settings.backupFailed', {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }

  Future<void> _restoreData(BuildContext context) async {
    try {
      final success = await DataBackupService.restoreLatest();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success ? 'Data restored successfully' : 'No backups found',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                context,
              ).trWithParams('settings.restoreFailed', {'error': e.toString()}),
            ),
          ),
        );
      }
    }
  }
}
