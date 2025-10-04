import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/services/motivational_service.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/core/widgets/enhanced_progress_indicator.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';

class ProgressOverviewWidget extends StatelessWidget {
  const ProgressOverviewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        if (state is WeeklySuccess) {
          final cubit = context.read<WeeklyCubit>();
          final todayIndex = _getTodayIndex();
          final todayTasks = cubit.getTasksForDay(todayIndex);
          final completedTasks = todayTasks.where((task) => task.isCompleted).length;
          final totalTasks = todayTasks.length;
          final progressPercentage = totalTasks > 0 ? (completedTasks / totalTasks) * 100 : 0.0;

          final motivationalQuote = MotivationalService.getPersonalizedQuote(
            context,
            progressPercentage: progressPercentage,
            currentStreak: cubit.getCurrentStreak(),
            overdueCount: cubit.getOverdueTasksCount(),
          );

          final colorScheme = Theme.of(context).colorScheme;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).tr('more.progress'),
                          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 22),
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          _getTodayDateString(),
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onPrimary.withOpacity(0.8),
                            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.today, color: colorScheme.onPrimary, size: 24),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Row(
                  children: [
                    EnhancedProgressIndicator(
                      progress: progressPercentage / 100,
                      label: AppLocalizations.of(context).tr('common.done'),
                      progressColor: colorScheme.onPrimary,
                      backgroundColor: colorScheme.onPrimary,
                      size: 80,
                      showPercentage: true,
                    ),

                    const SizedBox(width: 20),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildStatRow(
                            context,
                            AppLocalizations.of(context).tr('more.totalTasks'),
                            totalTasks,
                            Icons.list,
                          ),
                          const SizedBox(height: 8),
                          _buildStatRow(
                            context,
                            AppLocalizations.of(context).tr('more.completed'),
                            completedTasks,
                            Icons.check_circle,
                          ),
                          const SizedBox(height: 8),
                          _buildStatRow(
                            context,
                            AppLocalizations.of(context).tr('more.remaining'),
                            totalTasks - completedTasks,
                            Icons.pending,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colorScheme.onPrimary.withOpacity(0.2), width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_emotions, color: colorScheme.onPrimary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          motivationalQuote,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: colorScheme.onPrimary,
                            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatRow(BuildContext context, String label, int value, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, color: colorScheme.onPrimary.withOpacity(0.8), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: colorScheme.onPrimary.withOpacity(0.8),
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 12),
          ),
        ),
        Text(
          '$value',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: colorScheme.onPrimary,
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  int _getTodayIndex() {
    final today = DateTime.now();
    final weekday = today.weekday;

    switch (weekday) {
      case DateTime.saturday: // 6
        return 0;
      case DateTime.sunday: // 7
        return 1;
      case DateTime.monday: // 1
        return 2;
      case DateTime.tuesday: // 2
        return 3;
      case DateTime.wednesday: // 3
        return 4;
      case DateTime.thursday: // 4
        return 5;
      case DateTime.friday: // 5
        return 2; // Default to Monday for Friday
      default:
        return 2;
    }
  }

  String _getTodayDateString() {
    final today = DateTime.now();
    final days = ['Saturday', 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'];
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${days[today.weekday - 1]}, ${months[today.month - 1]} ${today.day}';
  }
}
