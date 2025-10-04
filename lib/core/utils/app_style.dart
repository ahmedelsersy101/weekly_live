import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/utils/app_text_styles.dart';

abstract class AppStyles {
  static TextStyle styleRegular16(BuildContext context) {
    return AppTextStyles.styleRegular16(context);
  }

  static TextStyle styleBold16(BuildContext context) {
    return AppTextStyles.styleBold16(context);
  }

  static TextStyle styleMedium16(BuildContext context) {
    return AppTextStyles.styleMedium16(context);
  }

  static TextStyle styleMedium20(BuildContext context) {
    return AppTextStyles.styleMedium20(context);
  }

  static TextStyle styleSemiBold16(BuildContext context) {
    return AppTextStyles.styleSemiBold16(context);
  }

  static TextStyle styleSemiBold20(BuildContext context) {
    return AppTextStyles.styleSemiBold20(context);
  }

  static TextStyle styleRegular12(BuildContext context) {
    return AppTextStyles.styleRegular12(context);
  }

  static TextStyle styleSemiBold24(BuildContext context) {
    return AppTextStyles.styleSemiBold24(context);
  }

  static TextStyle styleRegular14(BuildContext context) {
    return AppTextStyles.styleRegular14(context);
  }

  static TextStyle styleSemiBold18(BuildContext context) {
    return AppTextStyles.styleSemiBold18(context);
  }
}

double getResponsiveFontSize(context, {required double fontSize}) {
  double scaleFactor = getScaleFactor(context);
  double responsiveFontSize = fontSize * scaleFactor;

  double lowerLimit = fontSize * .8;
  double upperLimit = fontSize * 1.2;

  return responsiveFontSize.clamp(lowerLimit, upperLimit);
}

double getScaleFactor(context) {
  double width = MediaQuery.sizeOf(context).width;
  if (width < 700) {
    return width / 650;
  } else if (width < 1000) {
    return width / 1100;
  } else {
    return width / 1920;
  }
}
