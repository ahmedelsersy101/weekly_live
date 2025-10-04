import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/category_model.dart' hide TaskPriority;
import 'package:weekly_dash_board/core/models/settings_model.dart' as settings;
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:flutter/material.dart' hide ThemeMode;

class SupabaseDataService {
  static final _supabase = Supabase.instance.client;

  /// Get current user ID or throw exception if not authenticated
  static Future<String> _getCurrentUserId() async {
    final userId = await SupabaseAuthService.getUserId();
    if (userId == null) {
      throw Exception('User not authenticated. Please sign in first.');
    }
    return userId;
  }

  // ==================== TASKS ====================

  /// Save or update a task for the current user
  static Future<void> saveTask(TaskModel task) async {
    try {
      final userId = await _getCurrentUserId();
      final taskWithUserId = task.copyWith(userId: userId);

      final taskData = {
        'id': taskWithUserId.id,
        'user_id': taskWithUserId.userId,
        'title': taskWithUserId.title,
        'description': taskWithUserId.description,
        'is_completed': taskWithUserId.isCompleted,
        'day_of_week': taskWithUserId.dayOfWeek,
        'is_important': taskWithUserId.isImportant,
        'category_id': taskWithUserId.categoryId,
        'priority': taskWithUserId.priority.index,
        'due_date': taskWithUserId.dueDate?.toIso8601String(),
        'created_at': taskWithUserId.createdAt.toIso8601String(),
        'completed_at': taskWithUserId.completedAt?.toIso8601String(),
        'estimated_minutes': taskWithUserId.estimatedMinutes,
        'tags': taskWithUserId.tags,
        'notes': taskWithUserId.notes,
        'reminder_time': taskWithUserId.reminderTime != null
            ? '${taskWithUserId.reminderTime!.hour}:${taskWithUserId.reminderTime!.minute}'
            : null,
        'parent_recurrence_id': taskWithUserId.parentRecurrenceId,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('tasks').upsert(taskData, onConflict: 'id');
    } catch (e) {
      throw Exception('Failed to save task: ${e.toString()}');
    }
  }

  /// Get all tasks for the current user
  static Future<List<TaskModel>> getUserTasks() async {
    try {
      final userId = await _getCurrentUserId();

      final response = await _supabase
          .from('tasks')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return response.map<TaskModel>((data) => _taskFromJson(data)).toList();
    } catch (e) {
      throw Exception('Failed to load tasks: ${e.toString()}');
    }
  }

  /// Delete a task for the current user
  static Future<void> deleteTask(String taskId) async {
    try {
      final userId = await _getCurrentUserId();

      await _supabase.from('tasks').delete().eq('id', taskId).eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to delete task: ${e.toString()}');
    }
  }

  /// Bulk save tasks for the current user
  static Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      final userId = await _getCurrentUserId();

      final tasksData = tasks.map((task) {
        final taskWithUserId = task.copyWith(userId: userId);
        return {
          'id': taskWithUserId.id,
          'user_id': taskWithUserId.userId,
          'title': taskWithUserId.title,
          'description': taskWithUserId.description,
          'is_completed': taskWithUserId.isCompleted,
          'day_of_week': taskWithUserId.dayOfWeek,
          'is_important': taskWithUserId.isImportant,
          'category_id': taskWithUserId.categoryId,
          'priority': taskWithUserId.priority.index,
          'due_date': taskWithUserId.dueDate?.toIso8601String(),
          'created_at': taskWithUserId.createdAt.toIso8601String(),
          'completed_at': taskWithUserId.completedAt?.toIso8601String(),
          'estimated_minutes': taskWithUserId.estimatedMinutes,
          'tags': taskWithUserId.tags,
          'notes': taskWithUserId.notes,
          'reminder_time': taskWithUserId.reminderTime != null
              ? '${taskWithUserId.reminderTime!.hour}:${taskWithUserId.reminderTime!.minute}'
              : null,
          'parent_recurrence_id': taskWithUserId.parentRecurrenceId,
          'updated_at': DateTime.now().toIso8601String(),
        };
      }).toList();

      await _supabase.from('tasks').upsert(tasksData, onConflict: 'id');
    } catch (e) {
      throw Exception('Failed to save tasks: ${e.toString()}');
    }
  }

  // ==================== CATEGORIES ====================

  /// Save or update a category for the current user
  static Future<void> saveCategory(TaskCategoryModel category) async {
    try {
      final userId = await _getCurrentUserId();
      final categoryWithUserId = category.copyWith(userId: userId);

      final categoryData = {
        'id': categoryWithUserId.id,
        'user_id': categoryWithUserId.userId,
        'name': categoryWithUserId.name,
        'name_ar': categoryWithUserId.nameAr,
        'icon_code_point': categoryWithUserId.iconCodePoint,
        'icon_font_family': categoryWithUserId.iconFontFamily,
        'color_value': categoryWithUserId.color.value,
        'is_default': categoryWithUserId.isDefault,
        'created_at': categoryWithUserId.createdAt.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('categories').upsert(categoryData, onConflict: 'id');
    } catch (e) {
      throw Exception('Failed to save category: ${e.toString()}');
    }
  }

  /// Get all categories for the current user (including default categories)
  static Future<List<TaskCategoryModel>> getUserCategories() async {
    try {
      final userId = await _getCurrentUserId();

      // Get user-specific categories and default categories
      final response = await _supabase
          .from('categories')
          .select()
          .or('user_id.eq.$userId,is_default.eq.true')
          .order('created_at', ascending: true);

      return response.map<TaskCategoryModel>((data) => _categoryFromJson(data)).toList();
    } catch (e) {
      // Return default categories if there's an error
      return TaskCategoryModel.getDefaultCategories();
    }
  }

  /// Delete a custom category for the current user
  static Future<void> deleteCategory(String categoryId) async {
    try {
      final userId = await _getCurrentUserId();

      await _supabase
          .from('categories')
          .delete()
          .eq('id', categoryId)
          .eq('user_id', userId)
          .eq('is_default', false); // Only allow deletion of custom categories
    } catch (e) {
      throw Exception('Failed to delete category: ${e.toString()}');
    }
  }

  // ==================== SETTINGS ====================

  /// Save user settings
  static Future<void> saveSettings(settings.SettingsModel settingsModel) async {
    try {
      final userId = await _getCurrentUserId();
      final settingsWithUserId = settingsModel.copyWith(userId: userId);

      final settingsData = {
        'user_id': settingsWithUserId.userId,
        'theme_mode': settingsWithUserId.themeMode.index,
        'primary_color': settingsWithUserId.primaryColor.value,
        'notifications_enabled': settingsWithUserId.notificationsEnabled,
        'reminder_times': _encodeReminderTimes(settingsWithUserId.reminderTimes),
        'week_start': settingsWithUserId.weekStart.index,
        'weekend_days': settingsWithUserId.weekendDays,
        'sync_provider': settingsWithUserId.syncProvider.index,
        'auto_sync': settingsWithUserId.autoSync,
        'language': settingsWithUserId.language.index,
        'last_backup': settingsWithUserId.lastBackup.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabase.from('user_settings').upsert(settingsData, onConflict: 'user_id');
    } catch (e) {
      throw Exception('Failed to save settings: ${e.toString()}');
    }
  }

  /// Get user settings
  static Future<settings.SettingsModel?> getUserSettings() async {
    try {
      final userId = await _getCurrentUserId();

      final response = await _supabase
          .from('user_settings')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _settingsFromJson(response);
    } catch (e) {
      return null; // Return null to use default settings
    }
  }

  // ==================== SYNC OPERATIONS ====================

  /// Sync local data to Supabase
  static Future<void> syncLocalDataToSupabase({
    required List<TaskModel> localTasks,
    required List<TaskCategoryModel> localCategories,
    required settings.SettingsModel localSettings,
  }) async {
    try {
      // Sync tasks
      if (localTasks.isNotEmpty) {
        await saveTasks(localTasks);
      }

      // Sync custom categories (exclude defaults)
      final customCategories = localCategories.where((cat) => !cat.isDefault).toList();

      for (final category in customCategories) {
        await saveCategory(category);
      }

      // Sync settings
      await saveSettings(localSettings);
    } catch (e) {
      throw Exception('Failed to sync data to Supabase: ${e.toString()}');
    }
  }

  /// Get all user data from Supabase
  static Future<Map<String, dynamic>> getAllUserData() async {
    try {
      final tasks = await getUserTasks();
      final categories = await getUserCategories();
      final settings = await getUserSettings();

      return {'tasks': tasks, 'categories': categories, 'settings': settings};
    } catch (e) {
      throw Exception('Failed to get user data: ${e.toString()}');
    }
  }

  /// Clear all user data (for account deletion)
  static Future<void> clearAllUserData() async {
    try {
      final userId = await _getCurrentUserId();

      // Delete in order to respect foreign key constraints
      await _supabase.from('tasks').delete().eq('user_id', userId);
      await _supabase.from('categories').delete().eq('user_id', userId);
      await _supabase.from('user_settings').delete().eq('user_id', userId);
    } catch (e) {
      throw Exception('Failed to clear user data: ${e.toString()}');
    }
  }

  // ==================== HELPER METHODS ====================

  /// Convert Supabase JSON to TaskModel
  static TaskModel _taskFromJson(Map<String, dynamic> data) {
    TimeOfDay? reminderTime;
    if (data['reminder_time'] != null) {
      final timeParts = (data['reminder_time'] as String).split(':');
      reminderTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
    }

    return TaskModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      title: data['title'] as String,
      description: data['description'] as String?,
      isCompleted: data['is_completed'] as bool,
      dayOfWeek: data['day_of_week'] as int,
      isImportant: data['is_important'] as bool? ?? false,
      categoryId: data['category_id'] as String? ?? 'other',
      priority: TaskPriority.values[data['priority'] as int? ?? 1],
      dueDate: data['due_date'] != null ? DateTime.parse(data['due_date'] as String) : null,
      createdAt: DateTime.parse(data['created_at'] as String),
      completedAt: data['completed_at'] != null
          ? DateTime.parse(data['completed_at'] as String)
          : null,
      estimatedMinutes: data['estimated_minutes'] as int? ?? 0,
      tags: (data['tags'] as List?)?.cast<String>() ?? [],
      notes: data['notes'] as String?,
      reminderTime: reminderTime,
      parentRecurrenceId: data['parent_recurrence_id'] as String?,
    );
  }

  /// Convert Supabase JSON to TaskCategoryModel
  static TaskCategoryModel _categoryFromJson(Map<String, dynamic> data) {
    return TaskCategoryModel(
      id: data['id'] as String,
      userId: data['user_id'] as String?,
      name: data['name'] as String,
      nameAr: data['name_ar'] as String,
      iconCodePoint: data['icon_code_point'] as int,
      iconFontFamily: data['icon_font_family'] as String?,
      color: Color(data['color_value'] as int),
      isDefault: data['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(data['created_at'] as String),
    );
  }

  /// Convert Supabase JSON to SettingsModel
  static settings.SettingsModel _settingsFromJson(Map<String, dynamic> data) {
    return settings.SettingsModel(
      userId: data['user_id'] as String,
      themeMode: settings.ThemeMode.values[data['theme_mode'] as int? ?? 0],
      primaryColor: Color(data['primary_color'] as int),
      notificationsEnabled: data['notifications_enabled'] as bool? ?? true,
      reminderTimes: _decodeReminderTimes(data['reminder_times']),
      weekStart: settings.WeekStart.values[data['week_start'] as int? ?? 0],
      weekendDays: (data['weekend_days'] as List?)?.cast<int>() ?? [6, 7],
      syncProvider: settings.SyncProvider.values[data['sync_provider'] as int? ?? 2],
      autoSync: data['auto_sync'] as bool? ?? false,
      language: settings.Language.values[data['language'] as int? ?? 0],
      lastBackup: DateTime.parse(data['last_backup'] as String),
    );
  }

  /// Encode reminder times for database storage
  static Map<String, String> _encodeReminderTimes(Map<int, TimeOfDay> reminderTimes) {
    return reminderTimes.map(
      (day, time) => MapEntry(day.toString(), '${time.hour}:${time.minute}'),
    );
  }

  /// Decode reminder times from database
  static Map<int, TimeOfDay> _decodeReminderTimes(dynamic data) {
    if (data == null) return {};

    final Map<String, dynamic> reminderData = Map<String, dynamic>.from(data);
    return reminderData.map((dayStr, timeStr) {
      final day = int.parse(dayStr);
      final timeParts = timeStr.toString().split(':');
      final time = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      return MapEntry(day, time);
    });
  }
}
