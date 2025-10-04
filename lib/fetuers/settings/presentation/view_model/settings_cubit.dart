import 'package:flutter/material.dart' hide ThemeMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';
import 'package:weekly_dash_board/core/services/settings_service.dart';
import 'package:weekly_dash_board/core/services/scheduled_notification_service.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(const SettingsState());

  Future<void> loadSettings() async {
    try {
      emit(state.copyWith(isLoading: true));
      final settings = await SettingsService.loadSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> updateThemeMode(ThemeMode themeMode) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(themeMode: themeMode);
      await SettingsService.saveSettings(newSettings);
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updatePrimaryColor(Color color) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(primaryColor: color);
      await SettingsService.saveSettings(newSettings);
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateNotificationsEnabled(bool enabled) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(notificationsEnabled: enabled);
      await SettingsService.saveSettings(newSettings);

      // Update scheduled notifications based on the new setting
      if (enabled) {
        await ScheduledNotificationService.refreshAllScheduledNotifications();
      } else {
        await ScheduledNotificationService.cancelAllScheduledNotifications();
      }

      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateReminderTime(int dayOfWeek, TimeOfDay time) async {
    try {
      if (state.settings == null) return;
      final newReminderTimes = Map<int, TimeOfDay>.from(state.settings!.reminderTimes);
      newReminderTimes[dayOfWeek] = time;

      final newSettings = state.settings!.copyWith(reminderTimes: newReminderTimes);
      await SettingsService.saveSettings(newSettings);

      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateWeekStart(WeekStart weekStart) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(weekStart: weekStart);
      await SettingsService.saveSettings(newSettings);
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateWeekendDays(List<int> weekendDays) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(weekendDays: weekendDays);
      await SettingsService.saveSettings(newSettings);
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateSyncProvider(SyncProvider provider) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(syncProvider: provider);
      await SettingsService.saveSettings(newSettings);
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateAutoSync(bool autoSync) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(autoSync: autoSync);
      await SettingsService.saveSettings(newSettings);
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateLanguage(Language language) async {
    try {
      if (state.settings == null) return;
      final newSettings = state.settings!.copyWith(language: language);
      await SettingsService.saveSettings(newSettings);

      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> resetToDefaults() async {
    try {
      emit(state.copyWith(isLoading: true));
      await SettingsService.resetToDefaults();

      final defaultSettings = SettingsModel.defaultSettings;
      await SettingsService.saveSettings(defaultSettings);

      emit(state.copyWith(settings: defaultSettings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void clearError() {
    emit(state.copyWith(error: null));
  }

  /// Refresh scheduled notifications based on current settings
  Future<void> refreshScheduledNotifications() async {
    try {
      if (state.settings == null) return;

      if (state.settings!.notificationsEnabled) {
        await ScheduledNotificationService.refreshAllScheduledNotifications();
      } else {
        await ScheduledNotificationService.cancelAllScheduledNotifications();
      }
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  /// Get the status of scheduled notifications
  Future<Map<String, bool>> getScheduledNotificationsStatus() async {
    try {
      return await ScheduledNotificationService.getScheduledNotificationsStatus();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
      return {'daily': false, 'weekly': false};
    }
  }
}
