import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/widgets/custom_button_model.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    this.customButtonModel,
    this.height,
    this.width,
    required String title,
  });

  final CustomButtonModel? customButtonModel;
  final double? height, width;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height ?? 45,
      width: width ?? 207,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: customButtonModel?.buttonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: customButtonModel?.onPressed,
        child: Text(
          customButtonModel?.text ?? '',
          style: Theme.of(context).textTheme.displaySmall!.copyWith(
            color: customButtonModel?.textColor,
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 24),
          ),
        ),
      ),
    );
  }
}
