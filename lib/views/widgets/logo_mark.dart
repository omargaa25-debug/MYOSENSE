import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';

class LogoMark extends StatelessWidget {
  final Animation<double> intro;
  final Animation<double> ambient;
  final double size;

  const LogoMark({
    super.key,
    required this.intro,
    required this.ambient,
    this.size = 120,
  });

  @override
  Widget build(BuildContext context) {
    final box = CurvedAnimation(
      parent: intro,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );
    final line = CurvedAnimation(
      parent: intro,
      curve: const Interval(0.25, 0.55, curve: Curves.easeInOut),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([box, line, ambient]),
      builder: (_, __) {
        final glow = (math.sin(ambient.value * 2 * math.pi) + 1) / 2;
        return CustomPaint(
          size: Size.square(size),
          painter: _LogoPainter(box.value, line.value, glow),
        );
      },
    );
  }
}

class _LogoPainter extends CustomPainter {
  final double boxT;
  final double lineT;
  final double glow;

  _LogoPainter(this.boxT, this.lineT, this.glow);

  Path _trim(Path p, double t) {
    final out = Path();
    for (final m in p.computeMetrics()) {
      out.addPath(m.extractPath(0, m.length * t), Offset.zero);
    }
    return out;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final w = s.width;
    final stroke = w * 0.065;

    final boxPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(stroke / 2, stroke / 2, w - stroke, w - stroke),
        Radius.circular(w * 0.29),
      ));

    Offset p(double x, double y) => Offset(w * x, w * y);
    final ecg = Path()
      ..moveTo(p(0.14, 0.52).dx, p(0.14, 0.52).dy)
      ..lineTo(p(0.34, 0.52).dx, p(0.34, 0.52).dy)
      ..lineTo(p(0.43, 0.28).dx, p(0.43, 0.28).dy)
      ..lineTo(p(0.52, 0.74).dx, p(0.52, 0.74).dy)
      ..lineTo(p(0.60, 0.40).dx, p(0.60, 0.40).dy)
      ..lineTo(p(0.66, 0.52).dx, p(0.66, 0.52).dy)
      ..lineTo(p(0.86, 0.52).dx, p(0.86, 0.52).dy);

    final glowPaint = Paint()
      ..color = AppColors.volt.withValues(alpha: 0.2 + 0.35 * glow)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 1.6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final paint = Paint()
      ..color = AppColors.volt
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final boxTrim = _trim(boxPath, boxT);
    final ecgTrim = _trim(ecg, lineT);

    canvas.drawPath(boxTrim, glowPaint);
    canvas.drawPath(ecgTrim, glowPaint);
    canvas.drawPath(boxTrim, paint);
    canvas.drawPath(ecgTrim, paint);
  }

  @override
  bool shouldRepaint(_LogoPainter old) =>
      old.boxT != boxT || old.lineT != lineT || old.glow != glow;
}