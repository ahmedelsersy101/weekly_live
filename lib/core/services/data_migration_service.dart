import 'package:shared_preferences/shared_preferences.dart';
import 'package:weekly_dash_board/core/services/supabase_auth_service.dart';
import 'package:weekly_dash_board/core/services/supabase_data_service.dart';
import 'package:weekly_dash_board/fetuers/home/data/services/hive_service.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/task_model.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/category_model.dart';
import 'package:weekly_dash_board/core/models/settings_model.dart';
import 'package:weekly_dash_board/core/services/settings_service.dart';

class DataMigrationService {
  static const String _migrationCompleteKey = 'data_migration_complete';
  static const String _lastMigrationUserKey = 'last_migration_user';

  /// Check if data migration is needed for the current user
  static Future<bool> isMigrationNeeded() async {
    try {
      final userId = await SupabaseAuthService.getUserId();
      if (userId == null) return false;

      final prefs = await SharedPreferences.getInstance();
      final migrationComplete = prefs.getBool(_migrationCompleteKey) ?? false;
      final lastMigrationUser = prefs.getString(_lastMigrationUserKey);

      // Migration needed if:
      // 1. Never migrated before, OR
      // 2. Different user than last migration
      return !migrationComplete || lastMigrationUser != userId;
    } catch (e) {
      return false;
    }
  }

  /// Perform complete data migration from local storage to Supabase
  static Future<MigrationResult> migrateUserData() async {
    try {
      final userId = await SupabaseAuthService.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('DataMigration: Starting migration for user: $userId');

      // Step 1: Load local data
      final localTasks = await _loadLocalTasks(userId);
      final localCategories = await _loadLocalCategories();
      final localSettings = await _loadLocalSettings(userId);

      print('DataMigration: Loaded ${localTasks.length} tasks, ${localCategories.length} categories');

      // Step 2: Check if user has existing data in Supabase
      final existingData = await SupabaseDataService.getAllUserData();
      final existingTasks = existingData['tasks'] as List<TaskModel>;
      final existingCategories = existingData['categories'] as List<TaskCategoryModel>;
      final existingSettings = existingData['settings'] as SettingsModel?;

      print('DataMigration: Found ${existingTasks.length} existing tasks in Supabase');

      // Step 3: Merge data intelligently
      final mergedTasks = _mergeTasks(localTasks, existingTasks);
      final mergedCategories = _mergeCategories(localCategories, existingCategories);
      final mergedSettings = _mergeSettings(localSettings, existingSettings);

      print('DataMigration: Merged to ${mergedTasks.length} tasks, ${mergedCategories.length} categories');

      // Step 4: Save merged data to Supabase
      await SupabaseDataService.syncLocalDataToSupabase(
        localTasks: mergedTasks,
        localCategories: mergedCategories,
        localSettings: mergedSettings,
      );

      // Step 5: Mark migration as complete
      await _markMigrationComplete(userId);

      print('DataMigration: Migration completed successfully');

      return MigrationResult(
        success: true,
        tasksCount: mergedTasks.length,
        categoriesCount: mergedCategories.length,
        settingsMigrated: true,
      );

    } catch (e) {
      print('DataMigration: Migration failed: $e');
      return MigrationResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Load user data from Supabase on login
  static Future<UserDataResult> loadUserDataFromSupabase() async {
    try {
      final userId = await SupabaseAuthService.getUserId();
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      print('DataMigration: Loading user data from Supabase for user: $userId');

      final userData = await SupabaseDataService.getAllUserData();
      final tasks = userData['tasks'] as List<TaskModel>;
      final categories = userData['categories'] as List<TaskCategoryModel>;
      final settings = userData['settings'] as SettingsModel?;

      print('DataMigration: Loaded ${tasks.length} tasks, ${categories.length} categories from Supabase');

      return UserDataResult(
        success: true,
        tasks: tasks,
        categories: categories,
        settings: settings,
      );

    } catch (e) {
      print('DataMigration: Failed to load user data: $e');
      return UserDataResult(
        success: false,
        error: e.toString(),
        tasks: [],
        categories: TaskCategoryModel.getDefaultCategories(),
        settings: null,
      );
    }
  }

  /// Clear local data after successful migration
  static Future<void> clearLocalDataAfterMigration() async {
    try {
      // Clear Hive data
      await HiveService.saveTasks([]);
      
      // Clear settings (but keep migration flags)
      final prefs = await SharedPreferences.getInstance();
      final migrationComplete = prefs.getBool(_migrationCompleteKey);
      final lastMigrationUser = prefs.getString(_lastMigrationUserKey);
      
      // Clear all settings data (implement basic clearing)
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (!key.startsWith('data_migration_')) {
          await prefs.remove(key);
        }
      }
      
      // Restore migration flags
      if (migrationComplete != null) {
        await prefs.setBool(_migrationCompleteKey, migrationComplete);
      }
      if (lastMigrationUser != null) {
        await prefs.setString(_lastMigrationUserKey, lastMigrationUser);
      }

      print('DataMigration: Local data cleared after migration');
    } catch (e) {
      print('DataMigration: Failed to clear local data: $e');
    }
  }

  /// Reset migration status (for testing or troubleshooting)
  static Future<void> resetMigrationStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_migrationCompleteKey);
      await prefs.remove(_lastMigrationUserKey);
      print('DataMigration: Migration status reset');
    } catch (e) {
      print('DataMigration: Failed to reset migration status: $e');
    }
  }

  // ==================== PRIVATE METHODS ====================

  /// Load local tasks and assign current user ID
  static Future<List<TaskModel>> _loadLocalTasks(String userId) async {
    try {
      final localTasks = HiveService.loadTasks();
      
      // Update tasks with current user ID
      return localTasks.map((task) => task.copyWith(userId: userId)).toList();
    } catch (e) {
      print('DataMigration: Failed to load local tasks: $e');
      return [];
    }
  }

  /// Load local categories
  static Future<List<TaskCategoryModel>> _loadLocalCategories() async {
    try {
      // For now, return default categories
      // In the future, you might load custom categories from local storage
      return TaskCategoryModel.getDefaultCategories();
    } catch (e) {
      print('DataMigration: Failed to load local categories: $e');
      return TaskCategoryModel.getDefaultCategories();
    }
  }

  /// Load local settings and assign current user ID
  static Future<SettingsModel> _loadLocalSettings(String userId) async {
    try {
      final localSettings = await SettingsService.loadSettings();
      return localSettings.copyWith(userId: userId);
    } catch (e) {
      print('DataMigration: Failed to load local settings: $e');
      return SettingsModel.defaultSettings.copyWith(userId: userId);
    }
  }

  /// Merge local and remote tasks (prefer newer data)
  static List<TaskModel> _mergeTasks(List<TaskModel> localTasks, List<TaskModel> remoteTasks) {
    final Map<String, TaskModel> mergedMap = {};

    // Add all remote tasks first
    for (final task in remoteTasks) {
      mergedMap[task.id] = task;
    }

    // Add local tasks, but only if they're newer or don't exist remotely
    for (final localTask in localTasks) {
      final existingTask = mergedMap[localTask.id];
      if (existingTask == null || localTask.createdAt.isAfter(existingTask.createdAt)) {
        mergedMap[localTask.id] = localTask;
      }
    }

    return mergedMap.values.toList();
  }

  /// Merge local and remote categories
  static List<TaskCategoryModel> _mergeCategories(
    List<TaskCategoryModel> localCategories, 
    List<TaskCategoryModel> remoteCategories
  ) {
    final Map<String, TaskCategoryModel> mergedMap = {};

    // Add all remote categories first
    for (final category in remoteCategories) {
      mergedMap[category.id] = category;
    }

    // Add local categories if they don't exist remotely
    for (final localCategory in localCategories) {
      if (!mergedMap.containsKey(localCategory.id)) {
        mergedMap[localCategory.id] = localCategory;
      }
    }

    return mergedMap.values.toList();
  }

  /// Merge local and remote settings (prefer remote if exists)
  static SettingsModel _mergeSettings(SettingsModel localSettings, SettingsModel? remoteSettings) {
    // If remote settings exist, use them (they're the source of truth)
    // Otherwise, use local settings
    return remoteSettings ?? localSettings;
  }

  /// Mark migration as complete for current user
  static Future<void> _markMigrationComplete(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_migrationCompleteKey, true);
      await prefs.setString(_lastMigrationUserKey, userId);
    } catch (e) {
      print('DataMigration: Failed to mark migration complete: $e');
    }
  }
}

/// Result of data migration operation
class MigrationResult {
  final bool success;
  final int tasksCount;
  final int categoriesCount;
  final bool settingsMigrated;
  final String? error;

  MigrationResult({
    required this.success,
    this.tasksCount = 0,
    this.categoriesCount = 0,
    this.settingsMigrated = false,
    this.error,
  });
}

/// Result of loading user data from Supabase
class UserDataResult {
  final bool success;
  final List<TaskModel> tasks;
  final List<TaskCategoryModel> categories;
  final SettingsModel? settings;
  final String? error;

  UserDataResult({
    required this.success,
    required this.tasks,
    required this.categories,
    this.settings,
    this.error,
  });
}
