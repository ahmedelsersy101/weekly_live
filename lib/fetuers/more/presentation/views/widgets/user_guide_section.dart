import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/utils/app_style.dart';

class UserGuideSection extends StatelessWidget {
  const UserGuideSection({super.key});

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Icon(Icons.help_outline, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).tr('more.user_guide'),
                style: AppStyles.styleSemiBold18(
                  context,
                ).copyWith(color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),

          _buildGuideItem(
            context,
            AppLocalizations.of(context).tr('more.create_tasks'),
            AppLocalizations.of(context).tr('more.create_tasks_desc'),
            Icons.add_task,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            context,
            AppLocalizations.of(context).tr('more.set_priorities'),
            AppLocalizations.of(context).tr('more.set_priorities_desc'),
            Icons.priority_high,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            context,
            AppLocalizations.of(context).tr('more.track_progress'),
            AppLocalizations.of(context).tr('more.track_progress_desc'),
            Icons.check_circle_outline,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            context,
            AppLocalizations.of(context).tr('more.weekly_view'),
            AppLocalizations.of(context).tr('more.weekly_view_desc'),
            Icons.calendar_today,
          ),
          const SizedBox(height: 12),

          _buildGuideItem(
            context,
            AppLocalizations.of(context).tr('more.settings'),
            AppLocalizations.of(context).tr('more.settings_desc'),
            Icons.settings,
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).tr('more.pro_tip_desc'),
                    style: AppStyles.styleRegular14(context).copyWith(
                      color: colorScheme.primary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    String title,
    String description,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppStyles.styleSemiBold16(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.onSurface),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: AppStyles.styleRegular14(
                  context,
                ).copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
