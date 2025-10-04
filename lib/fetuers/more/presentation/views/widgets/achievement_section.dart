import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/utils/app_style.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/core/services/statistics_service.dart';
import 'package:weekly_dash_board/fetuers/home/data/models/statistics_model.dart';

class AchievementSection extends StatelessWidget {
  const AchievementSection({super.key});

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
                  color: colorScheme.shadow.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tr('more.achievementStats'),
                  style: AppStyles.styleSemiBold18(
                    context,
                  ).copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 16),

                _buildChartSection(
                  context,
                  AppLocalizations.of(context).tr('more.weeklyProgress'),
                  _buildWeeklyChart(context, stats),
                ),
                const SizedBox(height: 16),

                _buildChartSection(
                  context,
                  AppLocalizations.of(context).tr('more.monthlyOverview'),
                  _buildMonthlyChart(context, stats),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        AppLocalizations.of(context).tr('more.completionRate'),
                        '${stats.overallCompletionRate.toInt()}%',
                        Icons.trending_up,
                        colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        AppLocalizations.of(context).tr('more.currentStreak'),
                        '${cubit.getCurrentStreak()} days',
                        Icons.local_fire_department,
                        colorScheme.error,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        AppLocalizations.of(context).tr('more.totalTasks'),
                        '${stats.totalTasksCreated}',
                        Icons.list,
                        colorScheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        AppLocalizations.of(
                          context,
                        ).tr('statistics.tasksCompleted'),
                        '${stats.totalTasksCompleted}',
                        Icons.check_circle,
                        colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildChartSection(BuildContext context, String title, Widget chart) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppStyles.styleMedium16(
            context,
          ).copyWith(color: colorScheme.onSurface),
        ),
        const SizedBox(height: 8),
        SizedBox(height: 120, child: chart),
      ],
    );
  }

  Widget _buildWeeklyChart(BuildContext context, StatisticsModel stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final dayProductivity = stats.dayProductivity;

    final spots = <FlSpot>[];
    for (int i = 0; i < 6; i++) {
      final dayStats = dayProductivity[i];
      if (dayStats != null) {
        spots.add(FlSpot(i.toDouble(), dayStats.completionRate));
      } else {
        spots.add(FlSpot(i.toDouble(), 0));
      }
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const days = ['Sat', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu'];
                if (value.toInt() >= 0 && value.toInt() < days.length) {
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: colorScheme.primary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyChart(BuildContext context, StatisticsModel stats) {
    final colorScheme = Theme.of(context).colorScheme;
    final weeklyTrends = stats.weeklyTrends;

    final barGroups = <BarChartGroupData>[];
    final months = ['Jan', 'Feb', 'Mar', 'Apr'];

    for (int i = 0; i < 4; i++) {
      double productivityScore = 0;
      if (i < weeklyTrends.length) {
        productivityScore = weeklyTrends[i].productivityScore;
      }

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: productivityScore, color: colorScheme.primary),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < months.length) {
                  return Text(
                    months[value.toInt()],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 10,
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: barGroups,
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppStyles.styleSemiBold20(context).copyWith(color: color),
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
}
