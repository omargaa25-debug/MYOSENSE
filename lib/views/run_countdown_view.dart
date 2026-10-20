import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import '../core/theme.dart';

class RunCountdownView extends StatelessWidget {
  const RunCountdownView({super.key});

  @override
  Widget build(BuildContext context) {
    final n = context.select<SessionController, int>((s) => s.countdown);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'GET READY',
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 28),
                  TweenAnimationBuilder<double>(
                    key: ValueKey(n),
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 950),
                    builder: (_, v, __) {
                      final appear = Curves.easeOutBack.transform(
                        (v / 0.35).clamp(0.0, 1.0),
                      );
                      final scale = 0.5 + 0.5 * appear;
                      final isGo = n <= 0;
                      final fade = (isGo || v < 0.8)
                          ? 1.0
                          : 1 - (v - 0.8) / 0.2;

                      return SizedBox(
                        width: 280,
                        height: 280,
                        child: CustomPaint(
                          painter: _CountPainter(
                            sweep: isGo ? 1 : v,
                            ripple: v,
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: fade.clamp(0.0, 1.0),
                              child: Transform.scale(
                                scale: scale,
                                child: Text(
                                  isGo ? 'GO!' : '$n',
                                  style: GoogleFonts.barlowCondensed(
                                    fontSize: isGo ? 120 : 160,
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.italic,
                                    height: 1,
                                    color: isGo
                                        ? AppColors.volt
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Keep your patch close to the muscle.',
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: TextButton(
              onPressed: context.read<SessionController>().cancelCountdown,
              child: Text(
                'Cancel',
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountPainter extends CustomPainter {
  final double sweep;
  final double ripple;
  _CountPainter({required this.sweep, required this.ripple});

  @override
  void paint(Canvas canvas, Size s) {
    final c = s.center(Offset.zero);
    final r = s.width / 2 - 14;

    canvas.drawCircle(
      c,
      r * (0.9 + 0.45 * ripple),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.volt.withValues(alpha: (1 - ripple) * 0.35),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..color = const Color(0xFF222A28),
    );
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r),
      -math.pi / 2,
      2 * math.pi * sweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round
        ..color = AppColors.volt,
    );
  }

  @override
  bool shouldRepaint(_CountPainter old) =>
      old.sweep != sweep || old.ripple != ripple;
}
