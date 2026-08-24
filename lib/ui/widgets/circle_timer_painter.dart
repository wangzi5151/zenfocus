import 'dart:math' as math;
import 'package:flutter/material.dart';

class DialPainter extends CustomPainter {
  DialPainter({
    required this.progress,
    required this.isFocus,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final bool isFocus;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.06;
    final inset = stroke * 0.75;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = trackColor;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);

    final clamped = progress.clamp(0.0, 1.0);
    if (clamped > 0) {
      final fgPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color;
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * clamped, false, fgPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DialPainter old) =>
      old.progress != progress ||
      old.isFocus != isFocus ||
      old.color != color ||
      old.trackColor != trackColor;
}
