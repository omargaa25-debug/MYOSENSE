import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import '../core/theme.dart';
import 'widgets/patch_chip.dart';
import 'widgets/reveal.dart';

class RunIdleView extends StatefulWidget {
  const RunIdleView({super.key});

  @override
  State<RunIdleView> createState() => _RunIdleViewState();
}

class _RunIdleViewState extends State<RunIdleView>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1700),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2800),
  )..repeat();

  bool _down = false;

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Column(
          children: [
            Reveal(
              parent: _intro,
              begin: 0,
              end: 0.25,
              from: const Offset(0, -0.4),
              curve: Curves.easeOutBack,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 11,
                        height: 11,
                        decoration: const BoxDecoration(
                          color: AppColors.textMuted,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'READY',
                        style: GoogleFonts.manrope(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const PatchChip(label: 'Right quad · 86%'),
                ],
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Reveal(
                        parent: _intro,
                        begin: 0.10,
                        end: 0.40,
                        child: Text(
                          'Ready to run?',
                          style: GoogleFonts.barlowCondensed(
                            fontSize: 58,
                            fontWeight: FontWeight.w800,
                            fontStyle: FontStyle.italic,
                            height: 1,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Reveal(
                        parent: _intro,
                        begin: 0.18,
                        end: 0.48,
                        child: Text(
                          'Tap start. The timer, distance and\nmuscle tracking begin together.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(
                            fontSize: 16,
                            height: 1.4,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Reveal(
                        parent: _intro,
                        begin: 0.25,
                        end: 0.85,
                        from: const Offset(0, 0.2),
                        scaleFrom: 0.5,
                        curve: Curves.elasticOut,
                        child: _orb(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              children: [
                for (int i = 0; i < 3; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(
                    child: Reveal(
                      parent: _intro,
                      begin: 0.55 + i * 0.1,
                      end: 0.85 + i * 0.1,
                      from: const Offset(0, 0.6),
                      curve: Curves.easeOutBack,
                      child: _Tip(
                        icon: const [
                          Icons.sensors_rounded,
                          Icons.tune_rounded,
                          Icons.route_rounded,
                        ][i],
                        text: const [
                          'Patch linked',
                          'Calibrated',
                          'Distance on',
                        ][i],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _orb() {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        HapticFeedback.heavyImpact();
        context.read<SessionController>().startCountdown();
      },
      child: AnimatedScale(
        scale: _down ? 0.92 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 300,
          height: 300,
          child: AnimatedBuilder(
            animation: _loop,
            builder: (_, __) {
              final t = _loop.value;
              final breath = (math.sin(t * 2 * math.pi) + 1) / 2;
              return Stack(
                alignment: Alignment.center,
                children: [
                  for (final phase in [0.0, 1 / 3, 2 / 3])
                    Builder(
                      builder: (_) {
                        final p = (t + phase) % 1.0;
                        return Transform.scale(
                          scale: 0.62 + 0.38 * Curves.easeOut.transform(p),
                          child: Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.volt.withValues(
                                  alpha: (1 - p) * 0.35,
                                ),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  Transform.scale(
                    scale: 1 + 0.025 * breath,
                    child: Container(
                      width: 190,
                      height: 190,
                      decoration: BoxDecoration(
                        color: AppColors.volt,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.volt.withValues(
                              alpha: 0.25 + 0.2 * breath,
                            ),
                            blurRadius: 40 + 20 * breath,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.play_arrow_rounded,
                            size: 70,
                            color: AppColors.background,
                          ),
                          Text(
                            'START',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              height: 0.9,
                              color: AppColors.background,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.volt, size: 24),
          const SizedBox(height: 6),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
