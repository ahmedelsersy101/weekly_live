import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_list_tasks.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/task_dialog.dart';

class CustomCardHomeView extends StatelessWidget {
  final int dayIndex;

  const CustomCardHomeView({super.key, required this.dayIndex});

  bool _isCurrentDay(String date) {
    final now = DateTime.now();
    final currentDate =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
    return date == currentDate;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        if (state is WeeklySuccess) {
          final dayStats = state.weeklyState.dayStats[dayIndex];
          return ExpandableDayCard(dayIndex: dayIndex, dayStats: dayStats);
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ExpandableDayCard extends StatelessWidget {
  final int dayIndex;
  final dynamic dayStats;

  const ExpandableDayCard({super.key, required this.dayIndex, required this.dayStats});

  bool _isCurrentDay(String date) {
    final today = DateTime.now();

    try {
      final parts = date.split('/'); // ["27", "9"]
      if (parts.length == 2) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);

        return today.day == day && today.month == month;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: ExpansionTileCard(
        baseColor: Theme.of(context).colorScheme.surface,
        expandedColor: Theme.of(context).colorScheme.surface,
        shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        elevation: 2,

        leading: Icon(Icons.calendar_today, color: Theme.of(context).colorScheme.primary),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _isCurrentDay(dayStats.date)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Text(
            dayStats.date,
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: _isCurrentDay(dayStats.date)
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
              fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
            ),
          ),
        ),
        title: Text(
          AppLocalizations.of(context).tr(dayStats.dayName),
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 22),
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${AppLocalizations.of(context).tr('common.done')} : ${dayStats.completedTasks} / ${dayStats.totalTasks}',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
        children: <Widget>[
          const Divider(thickness: 1.0, height: 1.0),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _DayContent(dayIndex: dayIndex),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButtonAddTasks(dayIndex: dayIndex),
                    const SizedBox(width: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        onPressed: () => _confirmClearDay(context, dayIndex),
                        icon: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onPrimary,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

void _confirmClearDay(BuildContext context, int dayIndex) {
  showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          AppLocalizations.of(ctx).tr('settings.clearDayTasksTitle'),
          style: Theme.of(ctx).textTheme.displaySmall!.copyWith(
            color: Theme.of(ctx).colorScheme.onSurface,
            fontSize: AppTheme.getResponsiveFontSize(ctx, fontSize: 24),
          ),
        ),
        content: Text(
          AppLocalizations.of(ctx).tr('settings.clearDayTasksMessage'),
          style: TextStyle(color: Theme.of(ctx).colorScheme.onSurface),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              AppLocalizations.of(ctx).tr('settings.cancel'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ctx.read<WeeklyCubit>().clearTasksForDay(dayIndex);
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            child: Text(AppLocalizations.of(ctx).tr('settings.clear')),
          ),
        ],
      );
    },
  );
}

class CustomButtonAddTasks extends StatelessWidget {
  final int dayIndex;

  const CustomButtonAddTasks({super.key, required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        onPressed: () => _showAddTaskDialog(context, dayIndex),
        icon: Icon(Icons.add, color: Theme.of(context).colorScheme.onPrimary, size: 24),
      ),
    );
  }
void _showAddTaskDialog(BuildContext context, int dayIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return TaskDialogWidget(
          dayIndex: dayIndex,
          onConfirm:
              ({
                required title,
                required days,
                required isImportant,
                required reminderTime,
                required categoryId,
              }) {
                context.read<WeeklyCubit>().addTaskToDays(
                  title,
                  days,
                  isImportant: isImportant,
                  reminderTime: reminderTime,
                  categoryId: categoryId,
                );
              },
        );
      },
    );
  }

  String _getDayLabel(int dayIndex) {
    switch (dayIndex) {
      case 0:
        return 'سبت';
      case 1:
        return 'أحد';
      case 2:
        return 'اثنين';
      case 3:
        return 'ثلاثاء';
      case 4:
        return 'أربعاء';
      case 5:
        return 'خميس';
      default:
        return 'جمعه';
    }
  }

  OutlineInputBorder customOutlineInputBorder(BuildContext context) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: Theme.of(context).colorScheme.outline),
      borderRadius: const BorderRadius.all(Radius.circular(8)),
    );
  }
}

List<int> _orderedOtherDays(int currentDay) {
  // ترتيب الأيام المتبقية ابتداءً من اليوم التالي وحتى قبل اليوم الحالي
  return List<int>.generate(6, (i) => (currentDay + 1 + i) % 7);
}

String _localizedDayLabel(BuildContext context, int dayIndex) {
  const keys = ['saturday', 'sunday', 'monday', 'tuesday', 'wednesday', 'thursday', 'friday'];
  if (dayIndex < 0 || dayIndex >= keys.length) return '';
  return AppLocalizations.of(context).tr(keys[dayIndex]);
}

class _DayContent extends StatelessWidget {
  final int dayIndex;
  const _DayContent({required this.dayIndex});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        if (state is! WeeklySuccess) return const SizedBox.shrink();
        final isCollapsed = state.weeklyState.collapsedDays.contains(dayIndex);
        if (isCollapsed) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context).tr('settings.allTasksDone'),
                  style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
              ],
            ),
          );
        }
        return CustomListTasks(dayIndex: dayIndex);
      },
    );
  }
}
