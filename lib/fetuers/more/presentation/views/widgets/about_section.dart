import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:weekly_dash_board/core/utils/app_localizations.dart';
import 'package:weekly_dash_board/core/utils/app_style.dart';

class AboutSection extends StatefulWidget {
  const AboutSection({super.key});

  @override
  State<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends State<AboutSection> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
      // ignore: empty_catches
    } catch (e) {}
  }

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
              Icon(Icons.info, color: colorScheme.primary, size: 24),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).tr('more.aboutTheApp'),
                style: AppStyles.styleSemiBold18(context).copyWith(color: colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Center(
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(Icons.calendar_today, color: colorScheme.onPrimary, size: 40),
                ),
                const SizedBox(height: 16),
                Text(
                  AppLocalizations.of(context).tr('more.title'),
                  style: AppStyles.styleSemiBold24(context).copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).tr('more.subtitle'),
                  style: AppStyles.styleRegular16(
                    context,
                  ).copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tr('more.description_title'),
                  style: AppStyles.styleSemiBold16(context).copyWith(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).tr('more.description_text'),
                  style: AppStyles.styleRegular14(
                    context,
                  ).copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.primary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tr('more.version_info'),
                  style: AppStyles.styleSemiBold16(context).copyWith(color: colorScheme.primary),
                ),
                const SizedBox(height: 12),
                _buildVersionRow(AppLocalizations.of(context).tr('more.version'), _appVersion),
                const SizedBox(height: 8),
                _buildVersionRow(AppLocalizations.of(context).tr('more.build'), _buildNumber),
                const SizedBox(height: 8),
                _buildVersionRow(AppLocalizations.of(context).tr('more.platform'), 'Flutter'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: colorScheme.tertiary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colorScheme.tertiary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).tr('more.key_features'),
                  style: AppStyles.styleSemiBold16(context).copyWith(color: colorScheme.tertiary),
                ),
                const SizedBox(height: 12),
                _buildFeatureItem(AppLocalizations.of(context).tr('more.feature_weekly_planning')),
                _buildFeatureItem(
                  AppLocalizations.of(context).tr('more.feature_priority_management'),
                ),
                _buildFeatureItem(
                  AppLocalizations.of(context).tr('more.feature_progress_tracking'),
                ),
                _buildFeatureItem(AppLocalizations.of(context).tr('more.feature_notifications')),
                _buildFeatureItem(AppLocalizations.of(context).tr('more.feature_uiux')),
                _buildFeatureItem(AppLocalizations.of(context).tr('more.feature_cross_platform')),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              AppLocalizations.of(context).tr('©.2025.Weekly.App.All.rights.reserved.'),
              style: AppStyles.styleRegular12(
                context,
              ).copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionRow(String label, String value) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppStyles.styleRegular14(
            context,
          ).copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
        ),
        Text(
          value,
          style: AppStyles.styleSemiBold16(
            context,
          ).copyWith(color: colorScheme.onSurface, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildFeatureItem(String feature) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        feature,
        style: AppStyles.styleRegular14(
          context,
        ).copyWith(color: colorScheme.onSurface.withOpacity(0.8)),
      ),
    );
  }
}
