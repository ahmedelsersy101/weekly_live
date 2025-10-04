import 'package:flutter/material.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/root_view.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/statistics_dashboard_widget.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/task_search_widget.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/more_view.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/settings_view.dart';
import 'package:weekly_dash_board/core/widgets/drawer_page.dart';

class DashboardMobileLayout extends StatefulWidget {
  final DrawerPage currentPage;
  final Function(int index, DrawerPage page) onItemSelected;

  const DashboardMobileLayout({
    super.key,
    required this.currentPage,
    required this.onItemSelected,
  });

  @override
  State<DashboardMobileLayout> createState() => _DashboardMobileLayoutState();
}

class _DashboardMobileLayoutState extends State<DashboardMobileLayout> {
  final Map<int, GlobalKey> _dayKeys = {
    for (int i = 0; i < 6; i++) i: GlobalKey(),
  };

  @override
  Widget build(BuildContext context) {
    return _buildMainContent();
  }

  Widget _buildMainContent() {
    switch (widget.currentPage) {
      case DrawerPage.weekly:
        return const RootView();
      case DrawerPage.search:
        return const TaskSearchWidget();
      case DrawerPage.stats:
        return const StatisticsDashboardWidget();
      case DrawerPage.more:
        return const MoreView();
      case DrawerPage.settings:
        return const SettingsView();
    }
  }

  void scrollToDay(int dayIndex) {
    final key = _dayKeys[dayIndex];
    if (key == null) return;
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.1,
    );
  }
}
