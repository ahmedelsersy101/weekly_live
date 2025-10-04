import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';

class HiveService {
  static const String _tasksBoxName = 'tasks_box';
  static const String _tasksKey = 'tasks';

  static Box? _tasksBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    _tasksBox = await Hive.openBox(_tasksBoxName);
  }

  static Future<void> saveTasks(List<TaskModel> tasks) async {
    try {
      if (_tasksBox == null) {
        await init(); // Re-initialize if box is null
      }
      
      final serializedTasks = tasks
          .map(
            (task) => {
              'id': task.id,
              'userId': task.userId,
              'title': task.title,
              'description': task.description,
              'isCompleted': task.isCompleted,
              'dayOfWeek': task.dayOfWeek,
              'isImportant': task.isImportant,
              'categoryId': task.categoryId,
              'priority': task.priority.index,
              'dueDate': task.dueDate?.millisecondsSinceEpoch,
              'createdAt': task.createdAt.millisecondsSinceEpoch,
              'completedAt': task.completedAt?.millisecondsSinceEpoch,
              'estimatedMinutes': task.estimatedMinutes,
              'tags': task.tags,
              'notes': task.notes,
              'reminderTime': task.reminderTime != null
                  ? '${task.reminderTime!.hour}:${task.reminderTime!.minute}'
                  : null,
              'parentRecurrenceId': task.parentRecurrenceId,
            },
          )
          .toList();
      await _tasksBox!.put(_tasksKey, serializedTasks);
      print('HiveService: Saved ${tasks.length} tasks successfully');
    } catch (e) {
      print('HiveService: Error saving tasks - $e');
    }
  }

  static List<TaskModel> loadTasks() {
    try {
      if (_tasksBox == null) {
        print('HiveService: Box is null, returning empty list');
        return [];
      }
      
      final serializedTasks = _tasksBox!.get(_tasksKey);
      if (serializedTasks is List) {
        final tasks = serializedTasks.whereType<Map>().map((raw) {
          final data = Map<String, dynamic>.from(raw);

          TimeOfDay? reminderTime;
          if (data['reminderTime'] != null) {
            final timeParts = (data['reminderTime'] as String).split(':');
            reminderTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }

          return TaskModel(
            id: data['id'] as String,
            userId: (data['userId'] as String?) ?? '', // Handle legacy data without userId
            title: data['title'] as String,
            description: data['description'] as String?,
            isCompleted: data['isCompleted'] as bool,
            dayOfWeek: data['dayOfWeek'] as int,
            isImportant: (data['isImportant'] as bool?) ?? false,
            categoryId: (data['categoryId'] as String?) ?? 'other',
            priority: TaskPriority.values[(data['priority'] as int?) ?? 1],
            dueDate: data['dueDate'] != null 
                ? DateTime.fromMillisecondsSinceEpoch(data['dueDate'] as int)
                : null,
            createdAt: data['createdAt'] != null
                ? DateTime.fromMillisecondsSinceEpoch(data['createdAt'] as int)
                : DateTime.now(),
            completedAt: data['completedAt'] != null
                ? DateTime.fromMillisecondsSinceEpoch(data['completedAt'] as int)
                : null,
            estimatedMinutes: (data['estimatedMinutes'] as int?) ?? 0,
            tags: (data['tags'] as List?)?.cast<String>() ?? [],
            notes: data['notes'] as String?,
            reminderTime: reminderTime,
            parentRecurrenceId: data['parentRecurrenceId'] as String?,
          );
        }).toList();
        
        print('HiveService: Loaded ${tasks.length} tasks successfully');
        return tasks;
      }
    } catch (e) {
      print('HiveService: Error loading tasks - $e');
    }
    return [];
  }

  static Future<void> close() async {
    await _tasksBox?.close();
  }
}
