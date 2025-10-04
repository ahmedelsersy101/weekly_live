// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_contaner_weekly_of.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_list_view_days.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/statistics_dashboard_widget.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/task_search_widget.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

class HomeViewBody extends StatefulWidget {
  const HomeViewBody({super.key});

  @override
  State<HomeViewBody> createState() => HomeViewBodyState();
}

class HomeViewBodyState extends State<HomeViewBody> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _dayKeys = {for (int i = 0; i < 6; i++) i: GlobalKey()};

  late TabController _tabController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: Theme.of(context).colorScheme.onPrimary,
            dividerColor: Theme.of(context).colorScheme.primary,
            labelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onPrimary,
              fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
            ),
            unselectedLabelStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
              fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
            ),
            indicatorColor: Theme.of(context).colorScheme.onPrimary,
            tabs: [
              Tab(text: AppLocalizations.of(context).tr('app.title')),
              Tab(text: AppLocalizations.of(context).tr('common.Search')),
              Tab(text: AppLocalizations.of(context).tr('app.stats')),
            ],
          ),
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildWeeklyView(),
              _buildLazyWidget(() => const TaskSearchWidget()),

              _buildLazyWidget(() => const StatisticsDashboardWidget()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLazyWidget(Widget Function() builder) {
    return FutureBuilder(
      future: Future.delayed(const Duration(milliseconds: 100)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return builder();
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildWeeklyView() {
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            controller: _scrollController,
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              CustomWeekInfo(context: context),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              CustomListViewDays(dayKeys: _dayKeys),
            ],
          ),
        ),
      ],
    );
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

class CustomWeekInfo extends StatelessWidget {
  const CustomWeekInfo({super.key, required this.context});

  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: ExpansionTileCard(
          baseColor: Theme.of(context).colorScheme.surface,
          expandedColor: Theme.of(context).colorScheme.surface,
          shadowColor: Theme.of(context).shadowColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
          elevation: 2,
          leading: Icon(Icons.dashboard, color: Theme.of(context).colorScheme.primary),
          animateTrailing: true,
          trailing: Icon(Icons.expand_more, color: Theme.of(context).colorScheme.onSurface),
          title: Text(
            AppLocalizations.of(context).tr('info.weekly'),
            style: Theme.of(context).textTheme.displaySmall!.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 22),
              fontWeight: FontWeight.bold,
            ),
          ),
          children: const [
            CustomContainerWeeklyOf(), // هتظهر وتختفي عند الفتح
          ],
        ),
      ),
    );
  }
}
