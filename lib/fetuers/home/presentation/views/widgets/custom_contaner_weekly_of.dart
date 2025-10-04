import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/view_model/weekly_cubit.dart';
import 'package:weekly_dash_board/fetuers/home/presentation/views/widgets/custom_text_weekly_of.dart';

class CustomContainerWeeklyOf extends StatelessWidget {
  const CustomContainerWeeklyOf({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WeeklyCubit, WeeklyState>(
      builder: (context, state) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20.0),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: _buildContainerDecoration(context),
          child: state is WeeklySuccess
              ? _buildSuccessContent(context, state.weeklyState)
              : _buildZeroStateContent(context),
        );
      },
    );
  }

  BoxDecoration _buildContainerDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).shadowColor.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
          spreadRadius: 0,
        ),
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          blurRadius: 6,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildSuccessContent(BuildContext context, dynamic weeklyState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildFirstRow(context, weeklyState),
        const SizedBox(height: 16),
        _buildSecondRow(context, weeklyState),
      ],
    );
  }

  Widget _buildFirstRow(BuildContext context, dynamic weeklyState) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            AppLocalizations.of(context).trWithParams('settings.weekOf', {
              'weekNumber': weeklyState.weekNumber.toString(),
            }),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            context,
            '${AppLocalizations.of(context).tr('common.done')} : ${weeklyState.completedTasks} / ${weeklyState.totalTasks}',
          ),
        ),
      ],
    );
  }

  Widget _buildSecondRow(BuildContext context, dynamic weeklyState) {
    final percentage = weeklyState.completionPercentage;
    final percentageLabel = _getPerformanceLabel(context, percentage);

    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            AppLocalizations.of(context).trWithParams(
              'settings.completionPercentage',
              {'percentage': percentage.toStringAsFixed(0)},
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(child: _buildInfoCard(context, percentageLabel)),
      ],
    );
  }

  Widget _buildInfoCard(
    BuildContext context,
    String title, {
    EdgeInsets? padding,
  }) {
    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: _buildCardDecoration(context),
      child: Center(child: CustomTextWeeklyOf(title: title)),
    );
  }

  BoxDecoration _buildCardDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
          spreadRadius: 0,
        ),
      ],
    );
  }

  Widget _buildZeroStateContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CustomTextWeeklyOf(
          title: AppLocalizations.of(context).trWithParams(
            'settings.weeklyOf',
            {
              'weekNumber': AppLocalizations.of(
                context,
              ).tr('settings.zeroWeek'),
            },
          ),
        ),
        const SizedBox(height: 16),
        CustomTextWeeklyOf(
          title: AppLocalizations.of(context).tr('settings.zeroProgress'),
        ),
        const SizedBox(height: 16),
        CustomTextWeeklyOf(
          title: AppLocalizations.of(context).tr('settings.zeroPercentage'),
        ),
      ],
    );
  }

  String _getPerformanceLabel(BuildContext context, double percentage) {
    if (percentage >= 90) {
      return AppLocalizations.of(context).tr('settings.excellent');
    } else if (percentage >= 70) {
      return AppLocalizations.of(context).tr('settings.good');
    } else if (percentage >= 50) {
      return AppLocalizations.of(context).tr('settings.average');
    } else {
      return AppLocalizations.of(context).tr('settings.improve');
    }
  }
}
