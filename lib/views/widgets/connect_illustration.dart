import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

double _pulse(double t, [double shift = 0]) =>
    (math.sin((t - shift) * 2 * math.pi) + 1) / 2;

class ConnectIllustration extends StatelessWidget {
  final Animation<double> ambient;

  const ConnectIllustration({super.key, required this.ambient});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Phone(ambient: ambient),
          _BluetoothLink(ambient: ambient),
          _Patch(ambient: ambient),
        ],
      ),
    );
  }
}

// ---------------- Téléphone ----------------
class _Phone extends StatelessWidget {
  final Animation<double> ambient;
  const _Phone({required this.ambient});

  @override
  Widget build(BuildContext context) {
    final logo = GoogleFonts.barlowCondensed(
      fontSize: 15,
      fontWeight: FontWeight.w800,
      fontStyle: FontStyle.italic,
    );
    return Container(
      width: 86,
      height: 150,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Column(
        children: [
          Container(
            width: 26,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 14),
          Text.rich(TextSpan(children: [
            TextSpan(text: 'RUN', style: logo.copyWith(color: AppColors.volt)),
            TextSpan(text: 'SENSE', style: logo.copyWith(color: Colors.white)),
          ])),
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _EcgPainter(ambient),
            ),
          ),
          Container(
            width: 62,
            height: 14,
            decoration: BoxDecoration(
              color: AppColors.volt,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _EcgPainter extends CustomPainter {
  final Animation<double> t;
  _EcgPainter(this.t) : super(repaint: t);

  @override
  void paint(Canvas canvas, Size s) {
    Offset p(double x, double y) => Offset(s.width * x, s.height * (0.15 + 0.7 * y));
    final path = Path()
      ..moveTo(p(0, 0.5).dx, p(0, 0.5).dy)
      ..lineTo(p(0.28, 0.5).dx, p(0.28, 0.5).dy)
      ..lineTo(p(0.42, 0.05).dx, p(0.42, 0.05).dy)
      ..lineTo(p(0.56, 1.0).dx, p(0.56, 1.0).dy)
      ..lineTo(p(0.68, 0.3).dx, p(0.68, 0.3).dy)
      ..lineTo(p(0.76, 0.5).dx, p(0.76, 0.5).dy)
      ..lineTo(p(1, 0.5).dx, p(1, 0.5).dy);

    final progress =
        Curves.easeInOut.transform((t.value * 1.6).clamp(0.0, 1.0));
    final trimmed = Path();
    for (final m in path.computeMetrics()) {
      trimmed.addPath(m.extractPath(0, m.length * progress), Offset.zero);
    }
    canvas.drawPath(
      trimmed,
      Paint()
        ..color = AppColors.volt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_EcgPainter old) => false;
}

// ---------------- Lien Bluetooth ----------------
class _BluetoothLink extends StatelessWidget {
  final Animation<double> ambient;
  const _BluetoothLink({required this.ambient});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 150,
      child: AnimatedBuilder(
        animation: ambient,
        builder: (_, __) {
          final t = ambient.value;
          return Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _ArcsPainter(t)),
              ),
              Positioned(
                top: 72,
                child: Transform.scale(
                  scale: 1 + 0.06 * _pulse(t),
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.volt,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.volt
                              .withValues(alpha: 0.15 + 0.3 * _pulse(t)),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.bluetooth_rounded,
                      color: AppColors.background,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ArcsPainter extends CustomPainter {
  final double t;
  _ArcsPainter(this.t);

  void _dashed(Canvas c, Path p, Paint paint) {
    for (final m in p.computeMetrics()) {
      double d = 0;
      while (d < m.length) {
        c.drawPath(m.extractPath(d, math.min(d + 6, m.length)), paint);
        d += 11;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size s) {
    final center = Offset(s.width / 2, 100);
    const start = -140 * math.pi / 180;
    const sweep = 100 * math.pi / 180;

    void arc(double radius, double alpha) {
      final paint = Paint()
        ..color = AppColors.volt.withValues(alpha: alpha)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round;
      _dashed(
        canvas,
        Path()..addArc(Rect.fromCircle(center: center, radius: radius), start, sweep),
        paint,
      );
    }

    arc(38, 0.35 + 0.65 * _pulse(t));
    arc(50, 0.25 + 0.75 * _pulse(t, 0.25));
  }

  @override
  bool shouldRepaint(_ArcsPainter old) => old.t != t;
}

// ---------------- Patch ----------------
class _Patch extends StatelessWidget {
  final Animation<double> ambient;
  const _Patch({required this.ambient});

  @override
  Widget build(BuildContext context) {
    Widget ring() => Container(
          width: 15,
          height: 15,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white54, width: 2.5),
          ),
        );

    return SizedBox(
      width: 96,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 92,
            height: 74,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ring(),
                const SizedBox(width: 5),
                Container(
                  width: 24,
                  height: 22,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: ambient,
                    builder: (_, __) => Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF2E9E4F)
                            .withValues(alpha: 0.35 + 0.65 * _pulse(ambient.value)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                ring(),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'EMG + IMU patch',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}