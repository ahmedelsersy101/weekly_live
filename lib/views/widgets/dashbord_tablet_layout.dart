import 'package:flutter/material.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_contaner_weekly_of.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_list_view_days.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/statistics_dashboard_widget.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/task_search_widget.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/more_view.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/settings_view.dart';
import 'package:weekly_dash_board/core/widgets/drawer_page.dart';
import 'package:weekly_dash_board/core/utils/size_config.dart';

import 'package:weekly_dash_board/views/widgets/custom_drawer.dart';

class DashboardTabletLayout extends StatefulWidget {
  final DrawerPage currentPage;
  final Function(int index, DrawerPage page) onItemSelected;

  const DashboardTabletLayout({
    super.key,
    required this.currentPage,
    required this.onItemSelected,
  });

  @override
  State<DashboardTabletLayout> createState() => _DashboardTabletLayoutState();
}

class _DashboardTabletLayoutState extends State<DashboardTabletLayout> {
  final Map<int, GlobalKey> _dayKeys = {
    for (int i = 0; i < 6; i++) i: GlobalKey(),
  };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: CustomDrawer(onItemSelected: widget.onItemSelected)),
        const SizedBox(width: 16),
        Expanded(flex: 3, child: _buildMainContent()),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildMainContent() {
    switch (widget.currentPage) {
      case DrawerPage.weekly:
        return _buildWeeklyView();
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

  Widget _buildWeeklyView() {
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: CustomContainerWeeklyOf(),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: CustomScrollView(
            slivers: [
              MediaQuery.of(context).size.width < SizeConfig.desktop
                  ? CustomListViewDays(dayKeys: _dayKeys)
                  : const CustomGridViewDays(),
            ],
          ),
        ),
      ],
    );
  }
}
