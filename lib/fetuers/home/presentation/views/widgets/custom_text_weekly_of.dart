import 'package:flutter/material.dart';

class CustomTextWeeklyOf extends StatelessWidget {
  const CustomTextWeeklyOf({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
