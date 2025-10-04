import 'dart:math';
import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';

class MotivationalService {
  static List<String> highProgressQuotes(BuildContext context) => [
    AppLocalizations.of(context).tr('more.high_progress_quotes[0]'),
    AppLocalizations.of(context).tr('more.high_progress_quotes[1]'),
    AppLocalizations.of(context).tr('more.high_progress_quotes[2]'),
    AppLocalizations.of(context).tr('more.high_progress_quotes[3]'),
    AppLocalizations.of(context).tr('more.high_progress_quotes[4]'),
  ];

  static List<String> mediumProgressQuotes(BuildContext context) => [
    AppLocalizations.of(context).tr('more.medium_progress_quotes[0]'),
    AppLocalizations.of(context).tr('more.medium_progress_quotes[1]'),
    AppLocalizations.of(context).tr('more.medium_progress_quotes[2]'),
    AppLocalizations.of(context).tr('more.medium_progress_quotes[3]'),
    AppLocalizations.of(context).tr('more.medium_progress_quotes[4]'),
  ];

  static List<String> lowProgressQuotes(BuildContext context) => [
    AppLocalizations.of(context).tr('more.low_progress_quotes[0]'),
    AppLocalizations.of(context).tr('more.low_progress_quotes[1]'),
    AppLocalizations.of(context).tr('more.low_progress_quotes[2]'),
    AppLocalizations.of(context).tr('more.low_progress_quotes[3]'),
    AppLocalizations.of(context).tr('more.low_progress_quotes[4]'),
  ];

  static List<String> noProgressQuotes(BuildContext context) => [
    AppLocalizations.of(context).tr('more.no_progress_quotes[0]'),
    AppLocalizations.of(context).tr('more.no_progress_quotes[1]'),
    AppLocalizations.of(context).tr('more.no_progress_quotes[2]'),
    AppLocalizations.of(context).tr('more.no_progress_quotes[3]'),
    AppLocalizations.of(context).tr('more.no_progress_quotes[4]'),
  ];

  static List<String> overdueQuotes(BuildContext context) => [
    AppLocalizations.of(context).tr('more.overdue_quotes[0]'),
    AppLocalizations.of(context).tr('more.overdue_quotes[1]'),
    AppLocalizations.of(context).tr('more.overdue_quotes[2]'),
    AppLocalizations.of(context).tr('more.overdue_quotes[3]'),
    AppLocalizations.of(context).tr('more.overdue_quotes[4]'),
  ];

  static List<String> streakQuotes(BuildContext context) => [
    AppLocalizations.of(context).tr('more.streak_quotes[0]'),
    AppLocalizations.of(context).tr('more.streak_quotes[1]'),
    AppLocalizations.of(context).tr('more.streak_quotes[2]'),
    AppLocalizations.of(context).tr('more.streak_quotes[3]'),
    AppLocalizations.of(context).tr('more.streak_quotes[4]'),
  ];

  static String getQuoteByProgress(
    BuildContext context,
    double progressPercentage,
  ) {
    if (progressPercentage == 100) {
      return AppLocalizations.of(context).tr('more.progress_complete');
    } else if (progressPercentage >= 75) {
      return AppLocalizations.of(context).tr('more.progress_almost_done');
    } else if (progressPercentage >= 50) {
      return AppLocalizations.of(context).tr('more.progress_halfway');
    } else if (progressPercentage > 0) {
      return AppLocalizations.of(context).tr('more.progress_starting');
    } else {
      return AppLocalizations.of(context).tr('more.progress_empty');
    }
  }

  static String getQuoteByStreak(BuildContext context, int currentStreak) {
    if (currentStreak >= 7) {
      return AppLocalizations.of(context).tr('more.streak_strong');
    } else if (currentStreak >= 3) {
      return AppLocalizations.of(context).tr('more.streak_consistency');
    } else {
      return AppLocalizations.of(context).tr('more.streak_start');
    }
  }

  static String getQuoteByOverdueTasks(BuildContext context, int overdueCount) {
    if (overdueCount > 0) {
      return AppLocalizations.of(context).tr('more.overdue_tasks');
    }
    return getQuoteByProgress(context, 100); // No overdue tasks
  }

  static String getQuoteByTimeOfDay(BuildContext context) {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return AppLocalizations.of(context).tr('more.quote_morning');
    } else if (hour >= 12 && hour < 17) {
      return AppLocalizations.of(context).tr('more.quote_afternoon');
    } else if (hour >= 17 && hour < 21) {
      return AppLocalizations.of(context).tr('more.quote_evening');
    } else {
      return AppLocalizations.of(context).tr('more.quote_night');
    }
  }

  static String getQuoteByCategory(BuildContext context, String category) {
    switch (category.toLowerCase()) {
      case 'work':
        return AppLocalizations.of(context).tr('more.category_work');
      case 'study':
        return AppLocalizations.of(context).tr('more.category_study');
      case 'health':
        return AppLocalizations.of(context).tr('more.category_health');
      case 'personal':
        return AppLocalizations.of(context).tr('more.category_personal');
      case 'finance':
        return AppLocalizations.of(context).tr('more.category_finance');
      case 'home':
        return AppLocalizations.of(context).tr('more.category_home');
      default:
        return AppLocalizations.of(context).tr('more.category_default');
    }
  }

  static String getRandomQuote(List<String> quotes) {
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }

  static String getPersonalizedQuote(
    BuildContext context, {
    double? progressPercentage,
    int? currentStreak,
    int? overdueCount,
    String? category,
  }) {
    final quotes = <String>[];

    if (progressPercentage != null) {
      quotes.add(getQuoteByProgress(context, progressPercentage));
    }

    if (currentStreak != null && currentStreak > 0) {
      quotes.add(getQuoteByStreak(context, currentStreak));
    }

    if (overdueCount != null && overdueCount > 0) {
      quotes.add(getQuoteByOverdueTasks(context, overdueCount));
    }

    if (category != null) {
      quotes.add(getQuoteByCategory(context, category));
    }

    if (quotes.isEmpty) {
      quotes.add(getQuoteByTimeOfDay(context));
    }

    return getRandomQuote(quotes);
  }
}
