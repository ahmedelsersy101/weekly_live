import 'package:flutter/material.dart';

class EnhancedProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;
  final bool showPercentage;
  final String? subtitle;

  const EnhancedProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    this.progressColor,
    this.backgroundColor,
    this.size = 100,
    this.showPercentage = true,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle with gradient
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  effectiveBackgroundColor.withOpacity(0.1),
                  effectiveBackgroundColor.withOpacity(0.3),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),

          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              strokeWidth: 8,
              backgroundColor: effectiveBackgroundColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              strokeCap: StrokeCap.round,
            ),
          ),

          // Inner content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPercentage)
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: size * 0.2,
                    fontWeight: FontWeight.bold,
                    color: effectiveProgressColor,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w600,
                  color: effectiveProgressColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: effectiveProgressColor.withOpacity(0.6),
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class SegmentedProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final int segments;
  final Color? activeColor;
  final Color? inactiveColor;
  final double height;
  final double spacing;

  const SegmentedProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    this.segments = 10,
    this.activeColor,
    this.inactiveColor,
    this.height = 20,
    this.spacing = 4,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveActiveColor = activeColor ?? Theme.of(context).colorScheme.primary;
    final effectiveInactiveColor = inactiveColor ?? Theme.of(context).colorScheme.surface;

    final activeSegments = (progress * segments).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(segments, (index) {
            final isActive = index < activeSegments;
            return Expanded(
              child: Container(
                height: height,
                margin: EdgeInsets.only(right: index < segments - 1 ? spacing : 0),
                decoration: BoxDecoration(
                  color: isActive ? effectiveActiveColor : effectiveInactiveColor,
                  borderRadius: BorderRadius.circular(height / 2),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: effectiveActiveColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class RadialProgressIndicator extends StatelessWidget {
  final double progress;
  final String label;
  final String? value;
  final Color? progressColor;
  final Color? backgroundColor;
  final double size;
  final double strokeWidth;

  const RadialProgressIndicator({
    super.key,
    required this.progress,
    required this.label,
    this.value,
    this.progressColor,
    this.backgroundColor,
    this.size = 120,
    this.strokeWidth = 12,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveProgressColor = progressColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? Theme.of(context).colorScheme.surface;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: effectiveBackgroundColor.withOpacity(0.1),
            ),
          ),

          // Progress arc
          SizedBox(
            width: size,
            height: size,
            child: CustomPaint(
              painter: RadialProgressPainter(
                progress: progress.clamp(0.0, 1.0),
                progressColor: effectiveProgressColor,
                backgroundColor: effectiveBackgroundColor.withOpacity(0.2),
                strokeWidth: strokeWidth,
              ),
            ),
          ),

          // Center content
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontSize: size * 0.25,
                    fontWeight: FontWeight.bold,
                    color: effectiveProgressColor,
                  ),
                ),
              Text(
                label,
                style: TextStyle(
                  fontSize: size * 0.12,
                  fontWeight: FontWeight.w600,
                  color: effectiveProgressColor.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RadialProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  RadialProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * 3.14159 * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is RadialProgressPainter && oldDelegate.progress != progress;
  }
}
