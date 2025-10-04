import 'package:flutter/material.dart';
import 'package:weekly_dash_board/core/theme/app_theme.dart';

class ModernAuthButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSecondary;
  final IconData? icon;

  const ModernAuthButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isSecondary = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary 
            ? colorScheme.surface 
            : colorScheme.primary,
          foregroundColor: isSecondary 
            ? colorScheme.primary 
            : colorScheme.onPrimary,
          elevation: isSecondary ? 0 : 2,
          shadowColor: colorScheme.shadow.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: isSecondary 
              ? BorderSide(
                  color: colorScheme.primary.withOpacity(0.3),
                  width: 1,
                )
              : BorderSide.none,
          ),
          disabledBackgroundColor: isSecondary 
            ? colorScheme.surface.withOpacity(0.6)
            : colorScheme.primary.withOpacity(0.6),
          disabledForegroundColor: isSecondary 
            ? colorScheme.onSurface.withOpacity(0.4)
            : colorScheme.onPrimary.withOpacity(0.4),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isSecondary 
                      ? colorScheme.primary 
                      : colorScheme.onPrimary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null) ...[
                    Icon(
                      icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: textTheme.titleMedium!.copyWith(
                      fontSize: AppTheme.getResponsiveFontSize(context, fontSize: 16),
                      fontWeight: FontWeight.w600,
                      color: isSecondary 
                        ? colorScheme.primary 
                        : colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
