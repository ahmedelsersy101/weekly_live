import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

class AppTextStyles {
  // Display styles for large headlines
  static TextStyle displayLarge(BuildContext context) {
    return Theme.of(context).textTheme.displayLarge!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 32),
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    return Theme.of(context).textTheme.displayMedium!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 28),
    );
  }

  static TextStyle displaySmall(BuildContext context) {
    return Theme.of(context).textTheme.displaySmall!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 24),
    );
  }

  // Headline styles for section headers
  static TextStyle headlineLarge(BuildContext context) {
    return Theme.of(context).textTheme.headlineLarge!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 22),
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 20),
    );
  }

  static TextStyle headlineSmall(BuildContext context) {
    return Theme.of(context).textTheme.headlineSmall!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 18),
    );
  }

  // Title styles for card titles and important text
  static TextStyle titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
    );
  }

  static TextStyle titleSmall(BuildContext context) {
    return Theme.of(context).textTheme.titleSmall!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
    );
  }

  // Body styles for regular content
  static TextStyle bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return Theme.of(context).textTheme.bodySmall!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 12),
    );
  }

  // Label styles for buttons and labels
  static TextStyle labelLarge(BuildContext context) {
    return Theme.of(context).textTheme.labelLarge!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 14),
    );
  }

  static TextStyle labelMedium(BuildContext context) {
    return Theme.of(context).textTheme.labelMedium!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 12),
    );
  }

  static TextStyle labelSmall(BuildContext context) {
    return Theme.of(context).textTheme.labelSmall!.copyWith(
      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 10),
    );
  }

  // Legacy compatibility methods - these will be gradually replaced
  static TextStyle styleRegular16(BuildContext context) {
    return bodyLarge(context);
  }

  static TextStyle styleBold16(BuildContext context) {
    return bodyLarge(context).copyWith(fontWeight: FontWeight.w700);
  }

  static TextStyle styleMedium16(BuildContext context) {
    return titleMedium(context);
  }

  static TextStyle styleMedium20(BuildContext context) {
    return headlineMedium(context);
  }

  static TextStyle styleSemiBold16(BuildContext context) {
    return titleLarge(context);
  }

  static TextStyle styleSemiBold20(BuildContext context) {
    return headlineMedium(context);
  }

  static TextStyle styleRegular12(BuildContext context) {
    return bodySmall(context);
  }

  static TextStyle styleSemiBold24(BuildContext context) {
    return displaySmall(context);
  }

  static TextStyle styleRegular14(BuildContext context) {
    return bodyMedium(context);
  }

  static TextStyle styleSemiBold18(BuildContext context) {
    return headlineSmall(context);
  }
}
