import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/constants/app_color.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

// ignore: must_be_immutable
class CustomTextFormField extends StatelessWidget {
  CustomTextFormField({
    super.key,
    required this.hintText,
    this.controller,
    this.obscureText = false,
    required this.title,
  });
  final String hintText, title;
  final bool? obscureText;
  TextEditingController? controller;
  @override
  Widget build(BuildContext context) {
    return Column(
      spacing: 12,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
            fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 20),
          ),
        ),
        TextFormField(
          obscureText: obscureText!,
          validator: (value) {
            if (value!.isEmpty) {
              return 'This field is required';
            }
            return null;
          },
          controller: controller,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(18),
            filled: true,
            enabledBorder: buildOutlineInputBorder(),
            focusedBorder: buildOutlineInputBorder(),
            focusedErrorBorder: buildOutlineInputBorder().copyWith(
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            errorBorder: buildOutlineInputBorder().copyWith(
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            hintText: hintText,
            hintStyle: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 20),
              color: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
    );
  }

  OutlineInputBorder buildOutlineInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(13),
      borderSide: const BorderSide(style: BorderStyle.none),
    );
  }
}
