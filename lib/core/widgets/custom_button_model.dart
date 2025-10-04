import 'package:flutter/material.dart';

class CustomButtonModel {
  final Color? buttonColor, textColor;
  final String? text;
  final void Function()? onPressed;

  const CustomButtonModel({
    this.buttonColor,
    this.textColor,
    this.text,
    this.onPressed,
  });
}
