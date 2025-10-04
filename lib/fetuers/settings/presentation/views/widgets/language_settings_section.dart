import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';

class LanguageSettingsSection extends StatelessWidget {
  final Language language;
  final ValueChanged<Language> onLanguageChanged;

  const LanguageSettingsSection({
    super.key,
    required this.language,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsSection(
      title: AppLocalizations.of(context).tr('settings.language'),
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.appLanguage'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            _getLanguageText(context, language),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          leading: Icon(Icons.language, color: colorScheme.primary),
          trailing: DropdownButton<Language>(
            value: language,
            onChanged: (Language? newValue) {
              if (newValue != null) {
                onLanguageChanged(newValue);
              }
            },
            items: Language.values.map((Language lang) {
              return DropdownMenuItem<Language>(
                value: lang,
                child: Text(
                  _getLanguageText(context, lang),
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.languageInfo'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            AppLocalizations.of(context).tr('settings.languageInfoSubtitle'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          leading: Icon(Icons.info, color: colorScheme.primary),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageInfo(context),
        ),
      ],
    );
  }

  String _getLanguageText(BuildContext context, Language lang) {
    switch (lang) {
      case Language.english:
        return AppLocalizations.of(context).tr('settings.english');
      case Language.arabic:
        return AppLocalizations.of(context).tr('settings.arabic');
    }
  }

  void _showLanguageInfo(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            AppLocalizations.of(context).tr('settings.languageSupportTitle'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context).tr('settings.supportedLanguages'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '• ${AppLocalizations.of(context).tr('settings.english')}',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              Text(
                '• ${AppLocalizations.of(context).tr('settings.arabic')}',
                style: TextStyle(color: colorScheme.onSurface),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.of(context).tr('settings.languageNote'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).tr('settings.languageNoteMessage'),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).tr('settings.close'),
                style: TextStyle(color: colorScheme.onSurface),
              ),
            ),
          ],
        );
      },
    );
  }
}
