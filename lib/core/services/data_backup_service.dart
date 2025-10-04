import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide ThemeMode;
import 'package:path_provider/path_provider.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';
import 'package:weekly_dash_board/core/services/settings_service.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart';
import 'package:weekly_dash_board/fetuers/home/data/services/hive_service.dart';

class DataBackupService {
  static const String _backupDirName = 'backups';

  static Future<Directory> _ensureBackupDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    final backupDir = Directory('${dir.path}/$_backupDirName');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  static Future<File> backup() async {
    final backupDir = await _ensureBackupDirectory();
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '-')
        .replaceAll('.', '-')
        .replaceAll('T', '_');
    final file = File('${backupDir.path}/weekly_backup_$timestamp.json');

    final tasks = HiveService.loadTasks();
    var settings = await SettingsService.loadSettings();

    final data = {
      'version': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'settings': _serializeSettings(settings),
      'tasks': tasks.map(_serializeTask).toList(),
    };

    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data));

    settings = settings.copyWith(lastBackup: DateTime.now());
    await SettingsService.saveSettings(settings);
    return file;
  }

  static Future<bool> restoreLatest() async {
    final backupDir = await _ensureBackupDirectory();
    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();

    if (files.isEmpty) {
      return false;
    }

    files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
    final latest = files.first;
    final raw = await latest.readAsString();
    final decoded = json.decode(raw) as Map<String, dynamic>;

    final settingsMap = decoded['settings'] as Map<String, dynamic>;
    final restoredSettings = _deserializeSettings(settingsMap);
    await SettingsService.saveSettings(restoredSettings);

    final tasksList = (decoded['tasks'] as List).cast<Map<String, dynamic>>();
    final tasks = tasksList.map(_deserializeTask).toList();
    await HiveService.saveTasks(tasks);


    return true;
  }

  static Map<String, dynamic> _serializeSettings(SettingsModel s) {
    return {
      'themeMode': s.themeMode.index,
      'primaryColor': s.primaryColor.value,
      'notificationsEnabled': s.notificationsEnabled,
      'reminderTimes': s.reminderTimes.map(
        (k, v) => MapEntry(k.toString(), '${v.hour}:${v.minute}'),
      ),
      'weekStart': s.weekStart.index,
      'weekendDays': s.weekendDays,
      'syncProvider': s.syncProvider.index,
      'autoSync': s.autoSync,
      'language': s.language.index,
      'lastBackup': s.lastBackup.millisecondsSinceEpoch,
    };
  }

  static SettingsModel _deserializeSettings(Map<String, dynamic> m) {
    final reminderTimesRaw = (m['reminderTimes'] as Map<String, dynamic>).map(
      (k, v) => MapEntry(int.parse(k), _parseTime(v as String)),
    );

    return SettingsModel(
      themeMode: ThemeMode.values[m['themeMode'] as int],
      primaryColor: Color(m['primaryColor'] as int),
      notificationsEnabled: m['notificationsEnabled'] as bool,
      reminderTimes: reminderTimesRaw,
      weekStart: WeekStart.values[m['weekStart'] as int],
      weekendDays: (m['weekendDays'] as List).cast<int>(),
      syncProvider: SyncProvider.values[m['syncProvider'] as int],
      autoSync: m['autoSync'] as bool,
      language: Language.values[m['language'] as int],
      lastBackup: DateTime.fromMillisecondsSinceEpoch(m['lastBackup'] as int),
    );
  }

  static Map<String, dynamic> _serializeTask(TaskModel t) {
    return {
      'id': t.id,
      'userId': t.userId,
      'title': t.title,
      'description': t.description,
      'isCompleted': t.isCompleted,
      'dayOfWeek': t.dayOfWeek,
      'isImportant': t.isImportant,
      'categoryId': t.categoryId,
      'priority': t.priority.index,
      'dueDate': t.dueDate?.toIso8601String(),
      'createdAt': t.createdAt.toIso8601String(),
      'completedAt': t.completedAt?.toIso8601String(),
      'estimatedMinutes': t.estimatedMinutes,
      'tags': t.tags,
      'notes': t.notes,
    };
  }

  static TaskModel _deserializeTask(Map<String, dynamic> m) {
    return TaskModel(
      id: m['id'] as String,
      userId: m['userId'] as String? ?? '', // Handle legacy backups without userId
      title: m['title'] as String,
      description: m['description'] as String?,
      isCompleted: m['isCompleted'] as bool? ?? false,
      dayOfWeek: m['dayOfWeek'] as int,
      isImportant: m['isImportant'] as bool? ?? false,
      categoryId: m['categoryId'] as String? ?? 'other',
      priority: m['priority'] != null
          ? TaskPriority.values[m['priority'] as int]
          : TaskPriority.medium,
      dueDate: _parseDate(m['dueDate'] as String?),
      createdAt: _parseDate(m['createdAt'] as String?) ?? DateTime.now(),
      completedAt: _parseDate(m['completedAt'] as String?),
      estimatedMinutes: m['estimatedMinutes'] as int? ?? 0,
      tags: (m['tags'] as List?)?.cast<String>() ?? const [],
      notes: m['notes'] as String?,
    );
  }

  static TimeOfDay _parseTime(String v) {
    final parts = v.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return TimeOfDay(hour: hour, minute: minute);
  }

  static DateTime? _parseDate(String? v) {
    if (v == null) return null;
    return DateTime.tryParse(v);
  }
}
