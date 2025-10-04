import 'package:flutter/material.dart';

/// Centralized icon system for the weekly dashboard app
class AppIcons {
  // Private constructor to prevent instantiation
  AppIcons._();

  // Icon sizes
  static const double small = 16.0;
  static const double medium = 20.0;
  static const double large = 24.0;
  static const double extraLarge = 32.0;

  // Priority Icons - distinct shapes for better readability
  static const IconData priorityLow = Icons.keyboard_arrow_down;
  static const IconData priorityMedium = Icons.remove;
  static const IconData priorityHigh = Icons.priority_high;
  static const IconData priorityUrgent = Icons.warning;

  // Navigation Icons
  static const IconData dashboard = Icons.dashboard;
  static const IconData home = Icons.home;
  static const IconData settings = Icons.settings;
  static const IconData more = Icons.more_horiz;

  // Task Icons
  static const IconData task = Icons.task_alt;
  static const IconData addTask = Icons.add;
  static const IconData deleteTask = Icons.delete;
  static const IconData editTask = Icons.edit;
  static const IconData completeTask = Icons.check_circle;
  static const IconData incompleteTask = Icons.radio_button_unchecked;

  // Calendar Icons
  static const IconData calendar = Icons.calendar_today;
  static const IconData date = Icons.date_range;
  static const IconData time = Icons.access_time;
  static const IconData reminder = Icons.notifications;

  // Category Icons
  static const IconData work = Icons.work;
  static const IconData study = Icons.school;
  static const IconData health = Icons.favorite;
  static const IconData personal = Icons.person;
  static const IconData finance = Icons.attach_money;
  static const IconData homeCategory = Icons.home;
  static const IconData other = Icons.category;

  // Action Icons
  static const IconData save = Icons.save;
  static const IconData cancel = Icons.cancel;
  static const IconData clear = Icons.clear;
  static const IconData expand = Icons.expand_more;
  static const IconData collapse = Icons.expand_less;

  // Theme Icons
  static const IconData lightMode = Icons.light_mode;
  static const IconData darkMode = Icons.dark_mode;
  static const IconData autoMode = Icons.brightness_auto;

  // Size constants for consistency
  static const double sizeSmall = small;
  static const double sizeMedium = medium;
  static const double sizeLarge = large;
  static const double sizeExtraLarge = extraLarge;

  // Helper methods for creating consistent icons
  static Icon createIcon(IconData iconData, {double? size, Color? color}) {
    return Icon(
      iconData,
      size: size ?? medium,
      color: color,
    );
  }

  static Icon createPriorityIcon(String priority, {double? size, Color? color}) {
    IconData iconData;
    switch (priority.toLowerCase()) {
      case 'low':
        iconData = priorityLow;
        break;
      case 'medium':
        iconData = priorityMedium;
        break;
      case 'high':
        iconData = priorityHigh;
        break;
      case 'urgent':
        iconData = priorityUrgent;
        break;
      default:
        iconData = priorityMedium;
    }
    return Icon(iconData, size: size ?? medium, color: color);
  }

  static Icon createCategoryIcon(String category, {double? size, Color? color}) {
    IconData iconData;
    switch (category.toLowerCase()) {
      case 'work':
        iconData = work;
        break;
      case 'study':
        iconData = study;
        break;
      case 'health':
        iconData = health;
        break;
      case 'personal':
        iconData = personal;
        break;
      case 'finance':
        iconData = finance;
        break;
      case 'home':
        iconData = homeCategory;
        break;
      default:
        iconData = other;
    }
    return Icon(iconData, size: size ?? medium, color: color);
  }
}
