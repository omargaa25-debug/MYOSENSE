import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class FatigueRing extends StatelessWidget {
  final double value; // 0 à 100
  final double size;
  final Color color;
  final String level;
  final double pulse; // 0 à 1, lueur

  const FatigueRing({
    super.key,
    required this.value,
    required this.size,
    required this.color,
    required this.level,
    required this.pulse,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          value / 100,
          color,
          value >= 70 ? pulse : pulse * 0.3,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Muscle fatigue',
                style: GoogleFonts.manrope(
                  fontSize: size * 0.062,
                  color: AppColors.textMuted,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value.round().toString(),
                    style: GoogleFonts.barlowCondensed(
                      fontSize: size * 0.36,
                      fontWeight: FontWeight.w800,
                      height: 1.05,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '%',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: size * 0.15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                level,
                style: GoogleFonts.manrope(
                  fontSize: size * 0.075,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double v;
  final Color color;
  final double glow;

  _RingPainter(this.v, this.color, this.glow);

  @override
  void paint(Canvas canvas, Size s) {
    final stroke = s.width * 0.09;
    final rect = Rect.fromLTWH(
      stroke / 2,
      stroke / 2,
      s.width - stroke,
      s.height - stroke,
    );

    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = const Color(0xFF222A28),
    );

    if (v <= 0) return;
    final sweep = 2 * math.pi * v.clamp(0.0, 1.0);

    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color.withValues(alpha: 0.18 + 0.30 * glow)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.v != v || old.color != color || old.glow != glow;
}
