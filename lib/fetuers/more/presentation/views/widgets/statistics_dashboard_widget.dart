import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/utils/app_style.dart';
import 'package:weekly_dash_board/core/constants/app_color.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/core/services/statistics_service.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';

class StatisticsDashboardWidget extends StatelessWidget {
  const StatisticsDashboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        if (state is WeeklySuccess) {
          final cubit = context.read<WeeklyCubit>();
          final tasks = cubit.getAllTasks();
          final statisticsService = StatisticsService();
          final stats = statisticsService.calculateStatistics(tasks);

          final colorScheme = Theme.of(context).colorScheme;
          return Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(
                    context,
                  ).tr('statistics.productivityDashboard'),

                  style: AppStyles.styleSemiBold18(
                    context,
                  ).copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        AppLocalizations.of(context).tr('more.completionRate'),
                        '${stats.overallCompletionRate.toInt()}%',
                        Icons.trending_up,
                        AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        AppLocalizations.of(context).tr('more.currentStreak'),
                        '${cubit.getCurrentStreak()} days',
                        Icons.local_fire_department,
                        AppColors.warning,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        AppLocalizations.of(context).tr('more.totalTasks'),
                        '${stats.totalTasksCreated}',
                        Icons.list,
                        AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildMetricCard(
                        context,
                        AppLocalizations.of(
                          context,
                        ).tr('statistics.tasksCompleted'),
                        '${stats.totalTasksCompleted}',
                        Icons.check_circle,
                        AppColors.success,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(
                          context,
                        ).tr('more.productivityInsights'),
                        style: AppStyles.styleSemiBold16(
                          context,
                        ).copyWith(color: colorScheme.primary),
                      ),
                      const SizedBox(height: 12),
                      _buildInsightRow(
                        context,
                        AppLocalizations.of(
                          context,
                        ).tr('more.averageTasksPerDay'),

                        stats.averageTasksPerDay.toStringAsFixed(1),
                        Icons.calendar_today,
                      ),
                      _buildInsightRow(
                        context,
                        AppLocalizations.of(
                          context,
                        ).tr('more.mostProductiveDay'),
                        _getDayName(stats.mostProductiveDay.weekday),
                        Icons.star,
                      ),
                      _buildInsightRow(
                        context,
                        AppLocalizations.of(context).tr('more.overdueTasks'),
                        '${cubit.getOverdueTasksCount()}',
                        Icons.warning,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.styleSemiBold24(context).copyWith(color: color),
          ),
          Text(
            title,
            style: AppStyles.styleRegular12(
              context,
            ).copyWith(color: colorScheme.onSurface),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInsightRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppStyles.styleRegular14(
                context,
              ).copyWith(color: colorScheme.onSurface),
            ),
          ),
          Text(
            value,
            style: AppStyles.styleSemiBold16(
              context,
            ).copyWith(color: colorScheme.primary),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday];
  }
}
