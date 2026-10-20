import 'package:flutter/material.dart';
import '../../core/theme.dart';

class PulseRingsPainter extends CustomPainter {
  final Animation<double> t;

  PulseRingsPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const minR = 70.0;
    const maxR = 230.0;

    for (int i = 0; i < 3; i++) {
      final phase = (t.value + i / 3) % 1.0;
      final radius = minR + (maxR - minR) * Curves.easeOut.transform(phase);
      final paint = Paint()
        ..color = AppColors.volt.withValues(alpha: (1 - phase) * 0.22)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(PulseRingsPainter old) => false;
}