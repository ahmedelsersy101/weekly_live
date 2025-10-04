import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart' as settings;
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/constants/app_icons.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';

class ThemeSettingsSection extends StatelessWidget {
  final settings.ThemeMode themeMode;
  final ValueChanged<settings.ThemeMode> onThemeModeChanged;

  const ThemeSettingsSection({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SettingsSection(
      title: AppLocalizations.of(context).tr('settings.themeMode'),
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.themeMode'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            _getThemeModeDescription(context, themeMode),
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          leading: Icon(
            _getThemeModeIcon(themeMode, isDarkMode),
            color: colorScheme.primary,
          ),
          trailing: DropdownButton<settings.ThemeMode>(
            value: themeMode,
            underline: const SizedBox(),
            dropdownColor: colorScheme.surface,
            style: TextStyle(color: colorScheme.onSurface),
            items: [
              DropdownMenuItem(
                value: settings.ThemeMode.system,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.settings,
                      size: AppIcons.sizeSmall,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).tr('settings.systemTheme'),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: settings.ThemeMode.light,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.lightMode,
                      size: AppIcons.sizeSmall,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.of(context).tr('settings.lightTheme'),
                    ),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: settings.ThemeMode.dark,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      AppIcons.darkMode,
                      size: AppIcons.sizeSmall,
                      color: colorScheme.onSurface,
                    ),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context).tr('settings.darkTheme')),
                  ],
                ),
              ),
            ],
            onChanged: (settings.ThemeMode? newThemeMode) {
              if (newThemeMode != null) {
                onThemeModeChanged(newThemeMode);
              }
            },
          ),
        ),
        const Divider(),
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.currentTheme'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            isDarkMode
                ? AppLocalizations.of(context).tr('settings.darkModeActive')
                : AppLocalizations.of(context).tr('settings.lightModeActive'),
            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
          ),
          leading: Icon(
            isDarkMode ? AppIcons.darkMode : AppIcons.lightMode,
            color: colorScheme.primary,
          ),
          trailing: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isDarkMode ? colorScheme.surface : colorScheme.primary,
              border: Border.all(color: colorScheme.outline, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              size: 16,
              color: isDarkMode ? colorScheme.primary : colorScheme.onPrimary,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getThemeModeIcon(settings.ThemeMode themeMode, bool isDarkMode) {
    switch (themeMode) {
      case settings.ThemeMode.light:
        return AppIcons.lightMode;
      case settings.ThemeMode.dark:
        return AppIcons.darkMode;
      case settings.ThemeMode.system:
        return isDarkMode ? AppIcons.darkMode : AppIcons.lightMode;
    }
  }

  String _getThemeModeDescription(
    BuildContext context,
    settings.ThemeMode themeMode,
  ) {
    switch (themeMode) {
      case settings.ThemeMode.light:
        return AppLocalizations.of(context).tr('settings.lightThemeDesc');
      case settings.ThemeMode.dark:
        return AppLocalizations.of(context).tr('settings.darkThemeDesc');
      case settings.ThemeMode.system:
        return AppLocalizations.of(context).tr('settings.systemThemeDesc');
    }
  }
}
