import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

class CustomTextOnTap extends StatelessWidget {
  const CustomTextOnTap({super.key, this.title, this.onTap});
  final String? title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        title ?? 'Forget Password',
        style: Theme.of(context).textTheme.titleMedium!.copyWith(
          fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
        ),
      ),
    );
  }
}
