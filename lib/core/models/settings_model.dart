import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:weekly_dash_board/core/constants/app_color.dart';

enum ThemeMode { light, dark, system }

enum Language { english, arabic }

enum WeekStart { saturday, sunday, monday, thursday, wednesday, tuesday, friday }

enum SyncProvider { googleDrive, iCloud, none }

class SettingsModel extends Equatable {
  final String? userId; // Supabase User ID for syncing settings across devices
  final ThemeMode themeMode;
  final Color primaryColor;
  final bool notificationsEnabled;
  final Map<int, TimeOfDay> reminderTimes; // day of week -> time
  final WeekStart weekStart;
  final List<int> weekendDays; // 1 = Monday, 7 = Sunday
  final SyncProvider syncProvider;
  final bool autoSync;
  final Language language;
  final DateTime lastBackup;

  SettingsModel({
    this.userId,
    this.themeMode = ThemeMode.system,
    this.primaryColor = AppColors.primary, // default primary color
    this.notificationsEnabled = true,
    Map<int, TimeOfDay>? reminderTimes,
    this.weekStart = WeekStart.saturday,
    List<int>? weekendDays,
    this.syncProvider = SyncProvider.none,
    this.autoSync = false,
    this.language = Language.english,
    DateTime? lastBackup,
  }) : reminderTimes = reminderTimes ?? _defaultReminderTimes,
       weekendDays = weekendDays ?? [6, 7], // Saturday and Sunday
       lastBackup = lastBackup ?? DateTime.now();

  static const Map<int, TimeOfDay> _defaultReminderTimes = {
    1: TimeOfDay(hour: 9, minute: 0), // Monday
    2: TimeOfDay(hour: 9, minute: 0), // Tuesday
    3: TimeOfDay(hour: 9, minute: 0), // Wednesday
    4: TimeOfDay(hour: 9, minute: 0), // Thursday
    5: TimeOfDay(hour: 9, minute: 0), // Friday
    6: TimeOfDay(hour: 10, minute: 0), // Saturday
    7: TimeOfDay(hour: 10, minute: 0), // Sunday
  };

  static SettingsModel get defaultSettings => SettingsModel._(
    userId: null,
    themeMode: ThemeMode.system,
    primaryColor: AppColors.primary,
    notificationsEnabled: true,
    reminderTimes: _defaultReminderTimes,
    weekStart: WeekStart.saturday,
    weekendDays: const [6, 7],
    syncProvider: SyncProvider.none,
    autoSync: false,
    language: Language.english,
    lastBackup: DateTime(2024, 1, 1),
  );

  const SettingsModel._({
    required this.userId,
    required this.themeMode,
    required this.primaryColor,
    required this.notificationsEnabled,
    required this.reminderTimes,
    required this.weekStart,
    required this.weekendDays,
    required this.syncProvider,
    required this.autoSync,
    required this.language,
    required this.lastBackup,
  });

  SettingsModel copyWith({
    String? userId,
    ThemeMode? themeMode,
    Color? primaryColor,
    bool? notificationsEnabled,
    Map<int, TimeOfDay>? reminderTimes,
    WeekStart? weekStart,
    List<int>? weekendDays,
    SyncProvider? syncProvider,
    bool? autoSync,
    Language? language,
    DateTime? lastBackup,
  }) {
    return SettingsModel(
      userId: userId ?? this.userId,
      themeMode: themeMode ?? this.themeMode,
      primaryColor: primaryColor ?? this.primaryColor,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      reminderTimes: reminderTimes ?? this.reminderTimes,
      weekStart: weekStart ?? this.weekStart,
      weekendDays: weekendDays ?? this.weekendDays,
      syncProvider: syncProvider ?? this.syncProvider,
      autoSync: autoSync ?? this.autoSync,
      language: language ?? this.language,
      lastBackup: lastBackup ?? this.lastBackup,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    themeMode,
    primaryColor,
    notificationsEnabled,
    reminderTimes,
    weekStart,
    weekendDays,
    syncProvider,
    autoSync,
    language,
    lastBackup,
  ];
}
