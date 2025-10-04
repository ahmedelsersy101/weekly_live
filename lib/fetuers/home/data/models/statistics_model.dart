import 'package:equatable/equatable.dart';

class StatisticsModel extends Equatable {
  final double overallCompletionRate;
  final int totalTasksCompleted;
  final int totalTasksCreated;
  final Map<int, DayProductivityStats> dayProductivity;
  final Map<String, CategoryStats> categoryStats;
  final List<WeeklyTrend> weeklyTrends;
  final DateTime mostProductiveDay;
  final DateTime leastProductiveDay;
  final double averageTasksPerDay;
  final int currentStreak;
  final int longestStreak;
  final Map<int, int> hourlyProductivity;

  const StatisticsModel({
    required this.overallCompletionRate,
    required this.totalTasksCompleted,
    required this.totalTasksCreated,
    required this.dayProductivity,
    required this.categoryStats,
    required this.weeklyTrends,
    required this.mostProductiveDay,
    required this.leastProductiveDay,
    required this.averageTasksPerDay,
    required this.currentStreak,
    required this.longestStreak,
    required this.hourlyProductivity,
  });

  StatisticsModel copyWith({
    double? overallCompletionRate,
    int? totalTasksCompleted,
    int? totalTasksCreated,
    Map<int, DayProductivityStats>? dayProductivity,
    Map<String, CategoryStats>? categoryStats,
    List<WeeklyTrend>? weeklyTrends,
    DateTime? mostProductiveDay,
    DateTime? leastProductiveDay,
    double? averageTasksPerDay,
    int? currentStreak,
    int? longestStreak,
    Map<int, int>? hourlyProductivity,
  }) {
    return StatisticsModel(
      overallCompletionRate:
          overallCompletionRate ?? this.overallCompletionRate,
      totalTasksCompleted: totalTasksCompleted ?? this.totalTasksCompleted,
      totalTasksCreated: totalTasksCreated ?? this.totalTasksCreated,
      dayProductivity: dayProductivity ?? this.dayProductivity,
      categoryStats: categoryStats ?? this.categoryStats,
      weeklyTrends: weeklyTrends ?? this.weeklyTrends,
      mostProductiveDay: mostProductiveDay ?? this.mostProductiveDay,
      leastProductiveDay: leastProductiveDay ?? this.leastProductiveDay,
      averageTasksPerDay: averageTasksPerDay ?? this.averageTasksPerDay,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      hourlyProductivity: hourlyProductivity ?? this.hourlyProductivity,
    );
  }

  @override
  List<Object?> get props => [
    overallCompletionRate,
    totalTasksCompleted,
    totalTasksCreated,
    dayProductivity,
    categoryStats,
    weeklyTrends,
    mostProductiveDay,
    leastProductiveDay,
    averageTasksPerDay,
    currentStreak,
    longestStreak,
    hourlyProductivity,
  ];
}

class DayProductivityStats extends Equatable {
  final int dayOfWeek;
  final String dayName;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final double averageCompletionTime; // in minutes
  final int mostProductiveHour;

  const DayProductivityStats({
    required this.dayOfWeek,
    required this.dayName,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.averageCompletionTime,
    required this.mostProductiveHour,
  });

  @override
  List<Object?> get props => [
    dayOfWeek,
    dayName,
    totalTasks,
    completedTasks,
    completionRate,
    averageCompletionTime,
    mostProductiveHour,
  ];
}

class CategoryStats extends Equatable {
  final String category;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final double averageCompletionTime;

  const CategoryStats({
    required this.category,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.averageCompletionTime,
  });

  @override
  List<Object?> get props => [
    category,
    totalTasks,
    completedTasks,
    completionRate,
    averageCompletionTime,
  ];
}

class WeeklyTrend extends Equatable {
  final DateTime weekStart;
  final int totalTasks;
  final int completedTasks;
  final double completionRate;
  final double productivityScore;

  const WeeklyTrend({
    required this.weekStart,
    required this.totalTasks,
    required this.completedTasks,
    required this.completionRate,
    required this.productivityScore,
  });

  @override
  List<Object?> get props => [
    weekStart,
    totalTasks,
    completedTasks,
    completionRate,
    productivityScore,
  ];
}
