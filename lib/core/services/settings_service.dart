import 'dart:convert';
import 'package:flutter/material.dart' hide ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _primaryColorKey = 'primary_color';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _reminderTimesKey = 'reminder_times';
  static const String _weekStartKey = 'week_start';
  static const String _weekendDaysKey = 'weekend_days';
  static const String _syncProviderKey = 'sync_provider';
  static const String _autoSyncKey = 'auto_sync';
  static const String _languageKey = 'language';
  static const String _lastBackupKey = 'last_backup';

  static Future<SettingsModel> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final themeMode = ThemeMode.values[prefs.getInt(_themeModeKey) ?? 2]; // default to system
    final primaryColorValue = prefs.getInt(_primaryColorKey) ?? 0xFF3F51B5; // default to indigo
    final primaryColor = Color(primaryColorValue);
    final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;

    final reminderTimesJson = prefs.getString(_reminderTimesKey);
    Map<int, TimeOfDay> reminderTimes = {};
    if (reminderTimesJson != null) {
      final Map<String, dynamic> timesMap = json.decode(reminderTimesJson);
      timesMap.forEach((key, value) {
        final timeParts = value.split(':');
        reminderTimes[int.parse(key)] = TimeOfDay(
          hour: int.parse(timeParts[0]),
          minute: int.parse(timeParts[1]),
        );
      });
    }

    final weekStart = WeekStart.values[prefs.getInt(_weekStartKey) ?? 0]; // default to monday
    final weekendDaysJson = prefs.getString(_weekendDaysKey);
    final weekendDays = weekendDaysJson != null
        ? List<int>.from(json.decode(weekendDaysJson))
        : [6, 7]; // default to Saturday and Sunday

    final syncProvider =
        SyncProvider.values[prefs.getInt(_syncProviderKey) ?? 2]; // default to none
    final autoSync = prefs.getBool(_autoSyncKey) ?? false;
    final language = Language.values[prefs.getInt(_languageKey) ?? 0]; // default to english

    final lastBackupMillis = prefs.getInt(_lastBackupKey);
    final lastBackup = lastBackupMillis != null
        ? DateTime.fromMillisecondsSinceEpoch(lastBackupMillis)
        : DateTime.now();

    return SettingsModel(
      themeMode: themeMode,
      primaryColor: primaryColor,
      notificationsEnabled: notificationsEnabled,
      reminderTimes: reminderTimes.isNotEmpty ? reminderTimes : null,
      weekStart: weekStart,
      weekendDays: weekendDays,
      syncProvider: syncProvider,
      autoSync: autoSync,
      language: language,
      lastBackup: lastBackup,
    );
  }

  static Future<void> saveSettings(SettingsModel settings) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_themeModeKey, settings.themeMode.index);
    await prefs.setInt(_primaryColorKey, settings.primaryColor.value);
    await prefs.setBool(_notificationsEnabledKey, settings.notificationsEnabled);

    final Map<String, String> timesMap = {};
    settings.reminderTimes.forEach((key, value) {
      timesMap[key.toString()] = '${value.hour}:${value.minute}';
    });
    await prefs.setString(_reminderTimesKey, json.encode(timesMap));

    await prefs.setInt(_weekStartKey, settings.weekStart.index);
    await prefs.setString(_weekendDaysKey, json.encode(settings.weekendDays));
    await prefs.setInt(_syncProviderKey, settings.syncProvider.index);
    await prefs.setBool(_autoSyncKey, settings.autoSync);
    await prefs.setInt(_languageKey, settings.language.index);
    await prefs.setInt(_lastBackupKey, settings.lastBackup.millisecondsSinceEpoch);
  }

  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
