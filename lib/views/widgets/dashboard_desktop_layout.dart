import 'package:flutter/material.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/statistics_dashboard_widget.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/task_search_widget.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/more_view.dart';
import 'package:weekly_dash_board/fetuers/settings/presentation/views/settings_view.dart';
import 'package:weekly_dash_board/core/widgets/drawer_page.dart';
import 'package:weekly_dash_board/views/widgets/custom_background_container.dart';

import 'package:weekly_dash_board/views/widgets/dashbord_tablet_layout.dart';

class DashboardDesktopLayout extends StatefulWidget {
  final DrawerPage currentPage;
  final Function(int index, DrawerPage page) onItemSelected;

  const DashboardDesktopLayout({
    super.key,
    required this.currentPage,
    required this.onItemSelected,
  });

  @override
  State<DashboardDesktopLayout> createState() => _DashboardDesktopLayoutState();
}

class _DashboardDesktopLayoutState extends State<DashboardDesktopLayout> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: DashboardTabletLayout(
            currentPage: widget.currentPage,
            onItemSelected: widget.onItemSelected,
          ),
        ),

        if (widget.currentPage == DrawerPage.weekly)
          const Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: 0),
              child: CustomBackgroundContainer(
                child: StatisticsDashboardWidget(),
              ),
            ),
          ),
        if (widget.currentPage != DrawerPage.weekly)
          const Expanded(
            flex: 0,
            child: Padding(padding: EdgeInsets.only(right: 16), child: null),
          ),
      ],
    );
  }

  Widget _buildNonWeeklyContent() {
    switch (widget.currentPage) {
      case DrawerPage.search:
        return const TaskSearchWidget();
      case DrawerPage.stats:
        return const Center(child: Text('Stats not available in desktop view'));
      case DrawerPage.more:
        return const MoreView();
      case DrawerPage.settings:
        return const SettingsView();
      case DrawerPage.weekly:
        return const SizedBox(); // لن يصل هنا
    }
  }
}
