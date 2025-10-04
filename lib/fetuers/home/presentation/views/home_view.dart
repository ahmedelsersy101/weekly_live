import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/home_view_body.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final GlobalKey<HomeViewBodyState> _bodyKey = GlobalKey<HomeViewBodyState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).tr('app.title'),
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w700,
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 24),
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            onPressed: _openCalendar,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
          IconButton(
            onPressed: _showClearAllTasksDialog,
            icon: const Icon(Icons.clear_all),
            tooltip: AppLocalizations.of(context).tr('settings.clearAllTasks'),
          ),
        ],
      ),

      backgroundColor: Theme.of(context).colorScheme.background,
      body: HomeViewBody(key: _bodyKey),
    );
  }

  void _openCalendar() {
    showDialog(
      context: context,
      builder: (context) {
        DateTime focusedDay = DateTime.now();
        DateTime? selectedDay = focusedDay;
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                height: 400, // ارتفاع مناسب للكاليندر
                child: TableCalendar(
                  firstDay: DateTime.utc(2015, 1, 1),
                  lastDay: DateTime.utc(2100, 12, 31),
                  focusedDay: focusedDay,
                  calendarStyle: CalendarStyle(
                    defaultTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ), // لون الأرقام
                    weekNumberTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    todayTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    titleTextStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ), // لون الشهر
                    leftChevronIcon: Icon(
                      Icons.chevron_left,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // لون السهم الأيسر
                    ),
                    rightChevronIcon: Icon(
                      Icons.chevron_right,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface, // لون السهم الأيمن
                    ),
                  ),
                  selectedDayPredicate: (day) => isSameDay(day, selectedDay),
                  onDaySelected: (sel, foc) {
                    setState(() {
                      selectedDay = sel;
                      focusedDay = foc;
                    });
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).tr('settings.cancel'),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedDay != null) {
                  final dayIndex = _mapDateToAppDayIndex(selectedDay!);
                  if (dayIndex != null) {
                    _bodyKey.currentState?.scrollToDay(dayIndex);
                  }
                }
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(AppLocalizations.of(context).tr('common.go')),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllTasksDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            AppLocalizations.of(context).tr('settings.clearAllTasksTitle'),
          ),
          content: Text(
            AppLocalizations.of(context).tr('settings.clearAllTasksConfirm'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context).tr('settings.cancel'),
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<WeeklyCubit>().clearAllTasks();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: Text(AppLocalizations.of(context).tr('common.confirm')),
            ),
          ],
        );
      },
    );
  }

  int? _mapDateToAppDayIndex(DateTime date) {
    final weekday = date.weekday; // 1..7
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
        return null; // day off
    }
    return null;
  }
}
