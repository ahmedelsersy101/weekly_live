import 'package:equatable/equatable.dart';

enum RecurrenceType { none, daily, weekly, custom }

enum RecurrenceEndType { never, afterOccurrences, onDate }

class RecurrenceRule extends Equatable {
  final RecurrenceType type;
  final int interval; // Every X days/weeks
  final List<int> weekdays; // For weekly recurrence (0=Saturday, 1=Sunday, etc.)
  final RecurrenceEndType endType;
  final int? maxOccurrences;
  final DateTime? endDate;
  final DateTime startDate;

  const RecurrenceRule({
    required this.type,
    this.interval = 1,
    this.weekdays = const [],
    this.endType = RecurrenceEndType.never,
    this.maxOccurrences,
    this.endDate,
    required this.startDate,
  });

  RecurrenceRule copyWith({
    RecurrenceType? type,
    int? interval,
    List<int>? weekdays,
    RecurrenceEndType? endType,
    int? maxOccurrences,
    DateTime? endDate,
    DateTime? startDate,
  }) {
    return RecurrenceRule(
      type: type ?? this.type,
      interval: interval ?? this.interval,
      weekdays: weekdays ?? this.weekdays,
      endType: endType ?? this.endType,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      endDate: endDate ?? this.endDate,
      startDate: startDate ?? this.startDate,
    );
  }

  bool get isRecurring => type != RecurrenceType.none;

  /// Check if the recurrence should generate a task for the given date
  bool shouldOccurOn(DateTime date) {
    if (type == RecurrenceType.none) return false;
    
    // Check if date is before start date
    if (date.isBefore(startDate)) return false;
    
    // Check end conditions
    if (endType == RecurrenceEndType.onDate && endDate != null) {
      if (date.isAfter(endDate!)) return false;
    }
    
    switch (type) {
      case RecurrenceType.daily:
        final daysDiff = date.difference(startDate).inDays;
        return daysDiff >= 0 && daysDiff % interval == 0;
        
      case RecurrenceType.weekly:
        final daysDiff = date.difference(startDate).inDays;
        final weeksDiff = daysDiff ~/ 7;
        
        // Check if it's the right week interval
        if (weeksDiff % interval != 0) return false;
        
        // Check if it's the right day of week
        final dayOfWeek = _mapDateTimeToDayIndex(date);
        return weekdays.contains(dayOfWeek);
        
      case RecurrenceType.custom:
        // For now, treat custom same as weekly
        return shouldOccurOn(date);
        
      case RecurrenceType.none:
        return false;
    }
  }

  /// Map DateTime.weekday to app's day index (0=Saturday, 1=Sunday, etc.)
  int _mapDateTimeToDayIndex(DateTime date) {
    switch (date.weekday) {
      case DateTime.saturday: return 0;
      case DateTime.sunday: return 1;
      case DateTime.monday: return 2;
      case DateTime.tuesday: return 3;
      case DateTime.wednesday: return 4;
      case DateTime.thursday: return 5;
      case DateTime.friday: return 6; // Note: Friday might not be used in 6-day week
      default: return 0;
    }
  }

  /// Generate occurrence dates within a date range
  List<DateTime> generateOccurrences(DateTime rangeStart, DateTime rangeEnd) {
    final occurrences = <DateTime>[];
    
    if (type == RecurrenceType.none) return occurrences;
    
    DateTime current = startDate.isAfter(rangeStart) ? startDate : rangeStart;
    int occurrenceCount = 0;
    
    while (current.isBefore(rangeEnd) || current.isAtSameMomentAs(rangeEnd)) {
      if (shouldOccurOn(current)) {
        occurrences.add(current);
        occurrenceCount++;
        
        // Check max occurrences limit
        if (endType == RecurrenceEndType.afterOccurrences && 
            maxOccurrences != null && 
            occurrenceCount >= maxOccurrences!) {
          break;
        }
      }
      
      current = current.add(const Duration(days: 1));
    }
    
    return occurrences;
  }

  @override
  List<Object?> get props => [
    type,
    interval,
    weekdays,
    endType,
    maxOccurrences,
    endDate,
    startDate,
  ];

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'interval': interval,
      'weekdays': weekdays,
      'endType': endType.name,
      'maxOccurrences': maxOccurrences,
      'endDate': endDate?.toIso8601String(),
      'startDate': startDate.toIso8601String(),
    };
  }

  factory RecurrenceRule.fromJson(Map<String, dynamic> json) {
    return RecurrenceRule(
      type: RecurrenceType.values.firstWhere((e) => e.name == json['type']),
      interval: json['interval'] ?? 1,
      weekdays: List<int>.from(json['weekdays'] ?? []),
      endType: RecurrenceEndType.values.firstWhere((e) => e.name == json['endType']),
      maxOccurrences: json['maxOccurrences'],
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      startDate: DateTime.parse(json['startDate']),
    );
  }
}
