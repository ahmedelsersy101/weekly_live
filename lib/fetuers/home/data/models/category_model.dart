import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TaskCategoryModel extends Equatable {
  final String id;
  final String? userId; // Null for default categories, user ID for custom categories
  final String name;
  final String nameAr;
  final int iconCodePoint;
  final String? iconFontFamily;
  final Color color;
  final bool isDefault;
  final DateTime createdAt;

  const TaskCategoryModel({
    required this.id,
    this.userId,
    required this.name,
    required this.nameAr,
    required this.iconCodePoint,
    this.iconFontFamily,
    required this.color,
    this.isDefault = false,
    required this.createdAt,
  });

  TaskCategoryModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? nameAr,
    int? iconCodePoint,
    String? iconFontFamily,
    Color? color,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return TaskCategoryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      iconFontFamily: iconFontFamily ?? this.iconFontFamily,
      color: color ?? this.color,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    nameAr,
    iconCodePoint,
    iconFontFamily,
    color,
    isDefault,
    createdAt,
  ];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'nameAr': nameAr,
      'iconCodePoint': iconCodePoint,
      'iconFontFamily': iconFontFamily,
      'colorValue': color.value,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TaskCategoryModel.fromJson(Map<String, dynamic> json) {
    return TaskCategoryModel(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      nameAr: json['nameAr'],
      iconCodePoint: json['iconCodePoint'] as int,
      iconFontFamily: json['iconFontFamily'] as String?,
      color: Color(json['colorValue']),
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Predefined default categories
  static List<TaskCategoryModel> getDefaultCategories() {
    final now = DateTime.now();
    return [
      TaskCategoryModel(
        id: 'work',
        name: 'Work',
        nameAr: 'عمل',
        iconCodePoint: Icons.work.codePoint,
        iconFontFamily: Icons.work.fontFamily,
        color: const Color(0xFF1976D2), // Blue
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'study',
        name: 'Study',
        nameAr: 'دراسة',
        iconCodePoint: Icons.school.codePoint,
        iconFontFamily: Icons.school.fontFamily,
        color: const Color(0xFF388E3C), // Green
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'health',
        name: 'Health',
        nameAr: 'صحة',
        iconCodePoint: Icons.favorite.codePoint,
        iconFontFamily: Icons.favorite.fontFamily,
        color: const Color(0xFFE53935), // Red
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'personal',
        name: 'Personal',
        nameAr: 'شخصي',
        iconCodePoint: Icons.person.codePoint,
        iconFontFamily: Icons.person.fontFamily,
        color: const Color(0xFF7B1FA2), // Purple
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'finance',
        name: 'Finance',
        nameAr: 'مالي',
        iconCodePoint: Icons.attach_money.codePoint,
        iconFontFamily: Icons.attach_money.fontFamily,
        color: const Color(0xFFFF8F00), // Orange
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'home',
        name: 'Home',
        nameAr: 'منزل',
        iconCodePoint: Icons.home.codePoint,
        iconFontFamily: Icons.home.fontFamily,
        color: const Color(0xFF5D4037), // Brown
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'shopping',
        name: 'Shopping',
        nameAr: 'تسوق',
        iconCodePoint: Icons.shopping_cart.codePoint,
        iconFontFamily: Icons.shopping_cart.fontFamily,
        color: const Color(0xFFE91E63), // Pink
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'entertainment',
        name: 'Entertainment',
        nameAr: 'ترفيه',
        iconCodePoint: Icons.movie.codePoint,
        iconFontFamily: Icons.movie.fontFamily,
        color: const Color(0xFF00ACC1), // Cyan
        isDefault: true,
        createdAt: now,
      ),
      TaskCategoryModel(
        id: 'other',
        name: 'Other',
        nameAr: 'أخرى',
        iconCodePoint: Icons.category.codePoint,
        iconFontFamily: Icons.category.fontFamily,
        color: const Color(0xFF757575), // Grey
        isDefault: true,
        createdAt: now,
      ),
    ];
  }

  // Predefined colors for new categories
  static List<Color> getAvailableColors() {
    return [
      const Color(0xFF1976D2), // Blue
      const Color(0xFF388E3C), // Green
      const Color(0xFFE53935), // Red
      const Color(0xFF7B1FA2), // Purple
      const Color(0xFFFF8F00), // Orange
      const Color(0xFF5D4037), // Brown
      const Color(0xFFE91E63), // Pink
      const Color(0xFF00ACC1), // Cyan
      const Color(0xFF8BC34A), // Light Green
      const Color(0xFFFF5722), // Deep Orange
      const Color(0xFF9C27B0), // Purple
      const Color(0xFF607D8B), // Blue Grey
      const Color(0xFFFFC107), // Amber
      const Color(0xFF795548), // Brown
      const Color(0xFF009688), // Teal
    ];
  }

  // Predefined icons for new categories
  static List<int> getAvailableIcons() {
    return [
      Icons.work.codePoint,
      Icons.school.codePoint,
      Icons.favorite.codePoint,
      Icons.person.codePoint,
      Icons.attach_money.codePoint,
      Icons.home.codePoint,
      Icons.shopping_cart.codePoint,
      Icons.movie.codePoint,
      Icons.category.codePoint,
      Icons.fitness_center.codePoint,
      Icons.restaurant.codePoint,
      Icons.directions_car.codePoint,
      Icons.flight.codePoint,
      Icons.music_note.codePoint,
      Icons.camera_alt.codePoint,
      Icons.book.codePoint,
      Icons.computer.codePoint,
      Icons.phone.codePoint,
      Icons.email.codePoint,
      Icons.event.codePoint,
      Icons.location_on.codePoint,
      Icons.star.codePoint,
      Icons.lightbulb.codePoint,
      Icons.palette.codePoint,
      Icons.sports_soccer.codePoint,
    ];
  }
}

enum TaskPriority { one, two, three, four, five, six, seven, eight }

extension TaskPriorityX on TaskPriority {
  static TaskPriority fromInt(int value) {
    switch (value) {
      case 1:
        return TaskPriority.one;
      case 2:
        return TaskPriority.two;
      case 3:
        return TaskPriority.three;
      case 4:
        return TaskPriority.four;
      case 5:
        return TaskPriority.five;
      case 6:
        return TaskPriority.six;
      case 7:
        return TaskPriority.seven;
      case 8:
        return TaskPriority.eight;
      default:
        return TaskPriority.one; // fallback
    }
  }
}

TaskPriority getCategoryPriority(String categoryId) {
  switch (categoryId) {
    case 'work':
      return TaskPriorityX.fromInt(1);
    case 'study':
      return TaskPriorityX.fromInt(2);
    case 'health':
      return TaskPriorityX.fromInt(3);
    case 'personal':
      return TaskPriorityX.fromInt(4);
    case 'finance':
      return TaskPriorityX.fromInt(5);
    case 'home':
      return TaskPriorityX.fromInt(6);
    case 'shopping':
      return TaskPriorityX.fromInt(7);
    case 'entertainment':
      return TaskPriorityX.fromInt(8);
    default:
      return TaskPriority.one; // default priority
  }
}
