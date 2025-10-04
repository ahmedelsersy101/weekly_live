import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/widgets/settings_section.dart';

class WeekSettingsSection extends StatelessWidget {
  final WeekStart weekStart;
  final List<int> weekendDays;
  final ValueChanged<WeekStart> onWeekStartChanged;
  final ValueChanged<List<int>> onWeekendDaysChanged;

  const WeekSettingsSection({
    super.key,
    required this.weekStart,
    required this.weekendDays,
    required this.onWeekStartChanged,
    required this.onWeekendDaysChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SettingsSection(
      title: AppLocalizations.of(context).tr('settings.weekSettings'),
      children: [
        ListTile(
          title: Text(
            AppLocalizations.of(context).tr('settings.startOfWeek'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            _getWeekStartText(context, weekStart),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          leading: Icon(Icons.calendar_today, color: colorScheme.primary),
          trailing: DropdownButton<WeekStart>(
            value: weekStart,
            onChanged: (WeekStart? newValue) {
              if (newValue != null) {
                onWeekStartChanged(newValue);
              }
            },
            items: WeekStart.values.map((WeekStart start) {
              return DropdownMenuItem<WeekStart>(
                value: start,
                child: Text(
                  _getWeekStartText(context, start),
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
            AppLocalizations.of(context).tr('settings.weekendDays'),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          subtitle: Text(
            _getWeekendDaysText(context, weekendDays),
            style: TextStyle(color: colorScheme.onSurface),
          ),
          leading: Icon(Icons.weekend, color: colorScheme.primary),
          trailing: TextButton(
            onPressed: () => _showWeekendDaysDialog(context),
            child: Text(
              AppLocalizations.of(context).tr('settings.select'),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ),
      ],
    );
  }

  String _getWeekStartText(BuildContext context, WeekStart start) {
    switch (start) {
      case WeekStart.saturday:
        return AppLocalizations.of(context).tr('saturday');
      case WeekStart.sunday:
        return AppLocalizations.of(context).tr('sunday');
      case WeekStart.monday:
        return AppLocalizations.of(context).tr('monday');
      case WeekStart.thursday:
        return AppLocalizations.of(context).tr('thursday');
      case WeekStart.wednesday:
        return AppLocalizations.of(context).tr('wednesday');
      case WeekStart.tuesday:
        return AppLocalizations.of(context).tr('tuesday');
      case WeekStart.friday:
        return AppLocalizations.of(context).tr('friday');
    }
  }

  String _getWeekendDaysText(BuildContext context, List<int> days) {
    final dayNames = [
      '',
      AppLocalizations.of(context).tr('saturday'),
      AppLocalizations.of(context).tr('sunday'),
      AppLocalizations.of(context).tr('monday'),
      AppLocalizations.of(context).tr('tuesday'),
      AppLocalizations.of(context).tr('wednesday'),
      AppLocalizations.of(context).tr('thursday'),
      AppLocalizations.of(context).tr('friday'),
    ];
    final selectedDays = days.map((day) => dayNames[day]).toList();
    return selectedDays.join(', ');
  }

  void _showWeekendDaysDialog(BuildContext context) {
    final dayNames = [
      '',
      AppLocalizations.of(context).tr('saturday'),
      AppLocalizations.of(context).tr('sunday'),
      AppLocalizations.of(context).tr('monday'),
      AppLocalizations.of(context).tr('tuesday'),
      AppLocalizations.of(context).tr('wednesday'),
      AppLocalizations.of(context).tr('thursday'),
      AppLocalizations.of(context).tr('friday'),
    ];
    final List<bool> selectedDays = List.generate(
      8,
      (index) => weekendDays.contains(index),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                AppLocalizations.of(context).tr('settings.selectWeekendDays'),
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final dayIndex = index + 1;
                    return CheckboxListTile(
                      title: Text(dayNames[dayIndex]),
                      value: selectedDays[dayIndex],
                      onChanged: (bool? value) {
                        setState(() {
                          selectedDays[dayIndex] = value ?? false;
                        });
                      },
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context).tr('settings.cancel'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final selected = <int>[];
                    for (int i = 1; i < selectedDays.length; i++) {
                      if (selectedDays[i]) {
                        selected.add(i);
                      }
                    }
                    onWeekendDaysChanged(selected);
                    Navigator.of(context).pop();
                  },
                  child: Text(AppLocalizations.of(context).tr('settings.save')),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
