import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'recurrence_model.dart';

enum TaskPriority { low, medium, high, urgent }

class TaskModel extends Equatable {
  final String id;
  final String userId; // Supabase User ID for multi-device sync
  final String title;
  final String? description;
  final bool isCompleted;
  final int dayOfWeek; // 0 = Saturday, 1 = Sunday, ..., 5 = Thursday
  final bool isImportant;
  final String categoryId; // Reference to TaskCategoryModel.id
  final TaskPriority priority;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int estimatedMinutes;
  final List<String> tags;
  final String? notes;
  final TimeOfDay? reminderTime;
  final RecurrenceRule? recurrenceRule;
  final String? parentRecurrenceId; // For linking recurring task instances

  TaskModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.dayOfWeek,
    this.isImportant = false,
    this.categoryId = 'other',
    this.priority = TaskPriority.medium,
    this.dueDate,
    DateTime? createdAt,
    this.completedAt,
    this.estimatedMinutes = 0,
    this.tags = const [],
    this.notes,
    this.reminderTime,
    this.recurrenceRule,
    this.parentRecurrenceId,
  }) : createdAt = createdAt ?? DateTime.now();

  TaskModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    bool? isCompleted,
    int? dayOfWeek,
    bool? isImportant,
    String? categoryId,
    TaskPriority? priority,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? completedAt,
    int? estimatedMinutes,
    List<String>? tags,
    String? notes,
    TimeOfDay? reminderTime,
    RecurrenceRule? recurrenceRule,
    String? parentRecurrenceId,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isImportant: isImportant ?? this.isImportant,
      categoryId: categoryId ?? this.categoryId,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      reminderTime: reminderTime ?? this.reminderTime,
      recurrenceRule: recurrenceRule ?? this.recurrenceRule,
      parentRecurrenceId: parentRecurrenceId ?? this.parentRecurrenceId,
    );
  }

  bool get isOverdue {
    if (dueDate == null || isCompleted) return false;
    return DateTime.now().isAfter(dueDate!);
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueSoon {
    if (dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final difference = dueDate!.difference(now).inDays;
    return difference <= 2 && difference >= 0;
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    isCompleted,
    dayOfWeek,
    isImportant,
    categoryId,
    priority,
    dueDate,
    createdAt,
    completedAt,
    estimatedMinutes,
    tags,
    notes,
    reminderTime,
    recurrenceRule,
    parentRecurrenceId,
  ];

  bool get isRecurring => recurrenceRule != null && recurrenceRule!.isRecurring;

  bool get isRecurrenceParent => isRecurring && parentRecurrenceId == null;

  bool get isRecurrenceInstance => parentRecurrenceId != null;
}
