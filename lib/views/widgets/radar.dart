import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../models/patch_device.dart';

class Radar extends StatelessWidget {
  final Animation<double> sweep;
  final List<PatchDevice> devices;
  final bool scanning;
  final String? connectingId;
  final String? connectedId;

  const Radar({
    super.key,
    required this.sweep,
    required this.devices,
    required this.scanning,
    this.connectingId,
    this.connectedId,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: scanning ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 600),
      builder: (_, activity, __) {
        return SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _RadarPainter(
                    sweep: sweep,
                    devices: devices,
                    activity: activity,
                    connectingId: connectingId,
                    connectedId: connectedId,
                  ),
                ),
              ),
              _Core(sweep: sweep, connected: connectedId != null),
            ],
          ),
        );
      },
    );
  }
}

class _Core extends StatelessWidget {
  final Animation<double> sweep;
  final bool connected;
  const _Core({required this.sweep, required this.connected});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sweep,
      builder: (_, child) {
        final wave = (math.sin(sweep.value * 2 * math.pi) + 1) / 2;
        return Transform.scale(
          scale: 1 + 0.05 * wave,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.volt,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.volt.withValues(alpha: 0.18 + 0.25 * wave),
                  blurRadius: 24,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
        child: Icon(
          connected ? Icons.check_rounded : Icons.monitor_heart_rounded,
          key: ValueKey(connected),
          color: AppColors.background,
          size: 30,
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final Animation<double> sweep;
  final List<PatchDevice> devices;
  final double activity;
  final String? connectingId;
  final String? connectedId;

  _RadarPainter({
    required this.sweep,
    required this.devices,
    required this.activity,
    this.connectingId,
    this.connectedId,
  }) : super(repaint: sweep);

  static const _wedge = math.pi / 3;
  static const _twoPi = 2 * math.pi;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final r = size.width / 2 - 2;
    final rot = sweep.value * _twoPi;

    // ---- anneaux ----
    const ringAlpha = [0.50, 0.30, 0.18];
    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(
        center,
        r * i / 3,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.6
          ..color = AppColors.volt.withValues(alpha: ringAlpha[i - 1] * 0.7),
      );
    }

    // ---- faisceau qui tourne ----
    if (activity > 0.01) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rot);
      final rect = Rect.fromCircle(center: Offset.zero, radius: r);
      final wedge = Path()
        ..moveTo(0, 0)
        ..arcTo(rect, 0, _wedge, false)
        ..close();
      canvas.drawPath(
        wedge,
        Paint()
          ..shader = SweepGradient(
            startAngle: 0,
            endAngle: _wedge,
            colors: [
              AppColors.volt.withValues(alpha: 0),
              AppColors.volt.withValues(alpha: 0.30 * activity),
            ],
          ).createShader(rect),
      );
      // bord avant du faisceau
      canvas.drawLine(
        Offset.zero,
        Offset(math.cos(_wedge) * r, math.sin(_wedge) * r),
        Paint()
          ..strokeWidth = 1.5
          ..color = AppColors.volt.withValues(alpha: 0.5 * activity),
      );
      canvas.restore();
    }

    // ---- appareils ----
    final leading = (rot + _wedge) % _twoPi;
    for (final d in devices) {
      final angle = (d.id.hashCode % 360) * math.pi / 180;
      final fraction = ((-d.rssi - 40) / 55).clamp(0.0, 1.0);
      final dist = r * (0.32 + 0.58 * fraction);
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      final delta = (leading - angle) % _twoPi;
      final fade = 0.3 + 0.7 * math.pow(1 - delta / _twoPi, 2).toDouble();
      final alpha = 1 - activity * (1 - fade);

      final isConnected = d.id == connectedId;
      final isConnecting = d.id == connectingId;
      final color = d.isPatch ? AppColors.volt : AppColors.textMuted;
      final radius = isConnected ? 11.0 : (d.isPatch ? 8.0 : 6.0);

      // écho quand le faisceau passe
      if (activity > 0.01 && delta < 0.7) {
        final p = delta / 0.7;
        canvas.drawCircle(
          pos,
          radius + 4 + 14 * p,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
            ..color = color.withValues(alpha: (1 - p) * 0.5 * activity),
        );
      }

      // halo du patch en connexion / connecté
      if (isConnecting || isConnected) {
        final wave = (math.sin(sweep.value * _twoPi * 3) + 1) / 2;
        canvas.drawCircle(
          pos,
          radius + 6 + 6 * wave,
          Paint()..color = AppColors.volt.withValues(alpha: 0.15 + 0.2 * wave),
        );
      }

      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = color.withValues(alpha: alpha.clamp(0.0, 1.0)),
      );
    }
  }

  @override
  bool shouldRepaint(_RadarPainter old) => true;
}