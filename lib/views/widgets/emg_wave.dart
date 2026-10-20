import 'package:flutter/material.dart';

/// Signal EMG qui défile. Plus la fatigue monte, plus il est ample,
/// et plus la fréquence médiane baisse, plus il est "lent".
class EmgWave extends StatelessWidget {
  final Animation<double> t;
  final double fatigue;
  final double medianFreq;
  final double amp; // 0 à 1 (0 = signal plat, en pause)
  final Color color;

  const EmgWave({
    super.key,
    required this.t,
    required this.fatigue,
    required this.medianFreq,
    required this.amp,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => const LinearGradient(
        colors: [
          Colors.transparent,
          Colors.white,
          Colors.white,
          Colors.transparent,
        ],
        stops: [0, 0.06, 0.94, 1],
      ).createShader(rect),
      child: CustomPaint(
        size: Size.infinite,
        painter: _WavePainter(t, fatigue, medianFreq, amp, color),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final Animation<double> t;
  final double fatigue;
  final double medianFreq;
  final double amp;
  final Color color;

  _WavePainter(this.t, this.fatigue, this.medianFreq, this.amp, this.color)
    : super(repaint: t);

  static const _tpl = [
    Offset(0.00, 0.00),
    Offset(0.10, 0.00),
    Offset(0.16, 0.18),
    Offset(0.22, -0.12),
    Offset(0.28, 0.00),
    Offset(0.36, 0.00),
    Offset(0.42, 0.95),
    Offset(0.50, -0.85),
    Offset(0.58, 0.20),
    Offset(0.66, 0.00),
    Offset(1.00, 0.00),
  ];

  double _sample(double u) {
    final x = u - u.floorToDouble();
    for (int i = 0; i < _tpl.length - 1; i++) {
      final a = _tpl[i];
      final b = _tpl[i + 1];
      if (x >= a.dx && x <= b.dx) {
        final k = (x - a.dx) / (b.dx - a.dx);
        return a.dy + (b.dy - a.dy) * k;
      }
    }
    return 0;
  }

  @override
  void paint(Canvas canvas, Size s) {
    final mid = s.height / 2;
    final beats = (medianFreq / 13).clamp(3.5, 8.0);
    final a = (0.55 + fatigue / 100 * 0.45) * amp;

    final path = Path();
    for (double x = 0; x <= s.width; x += 2) {
      final u = x / s.width * beats + t.value * 2;
      final y = mid - _sample(u) * a * (s.height * 0.46);
      if (x == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
    );
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_WavePainter old) => true;
}
