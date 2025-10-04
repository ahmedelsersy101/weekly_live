import 'package:flutter/material.dart';
// import 'package:weekly_dash_board/fetuers/more/presentation/views/widgets/achievement_section.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/widgets/user_guide_section.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/widgets/contact_section.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/widgets/rate_share_section.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/widgets/about_section.dart';
import 'package:weekly_dash_board/fetuers/more/presentation/views/widgets/statistics_dashboard_widget.dart';

class MoreView extends StatelessWidget {
  const MoreView({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.surface,

      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StatisticsDashboardWidget(),
            SizedBox(height: 24),
            // AchievementSection(),
            // SizedBox(height: 24),
            UserGuideSection(),
            SizedBox(height: 24),

            ContactSection(),
            SizedBox(height: 24),

            RateShareSection(),
            SizedBox(height: 24),

            AboutSection(),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
