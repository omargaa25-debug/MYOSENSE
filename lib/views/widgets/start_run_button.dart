import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class StartRunButton extends StatefulWidget {
  final bool patchConnected;
  final int battery;
  final VoidCallback onPressed;

  const StartRunButton({
    super.key,
    required this.patchConnected,
    required this.battery,
    required this.onPressed,
  });

  @override
  State<StartRunButton> createState() => _StartRunButtonState();
}

class _StartRunButtonState extends State<StartRunButton>
    with TickerProviderStateMixin {
  // animation ambiante en boucle
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  // animation de lancement (glissement du cercle)
  late final AnimationController _go = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 800),
  );

  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    _go.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    if (_go.isAnimating || _go.value > 0) return;
    HapticFeedback.heavyImpact();
    await _go.forward();
    if (!mounted) return;
    HapticFeedback.lightImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.patchConnected
        ? 'Patch connected · ${widget.battery}%'
        : 'Connect your patch first';

    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) {
        setState(() => _down = false);
        _start();
      },
      child: AnimatedScale(
        scale: _down ? 0.96 : 1,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        child: AnimatedBuilder(
          animation: Listenable.merge([_c, _go]),
          builder: (_, __) {
            final t = _c.value;
            final breath = (math.sin(t * 2 * math.pi) + 1) / 2;
            final e = Curves.easeInOutCubic.transform(_go.value);

            return Container(
              height: 128,
              decoration: BoxDecoration(
                color: AppColors.volt,
                borderRadius: BorderRadius.circular(64),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.volt.withValues(
                      alpha: 0.18 + 0.22 * breath + 0.2 * e,
                    ),
                    blurRadius: 24 + 18 * breath + 16 * e,
                    spreadRadius: -6 + 4 * breath,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(64),
                child: LayoutBuilder(
                  builder: (context, box) {
                    const size = 104.0;
                    final startLeft = box.maxWidth - size - 12;
                    const endLeft = 12.0;
                    final left = startLeft + (endLeft - startLeft) * e;

                    // reflet qui balaie (s'éteint au lancement)
                    final s = Curves.easeInOut.transform(
                      math.min(1.0, t / 0.45),
                    );

                    final goT = ((e - 0.35) / 0.65).clamp(0.0, 1.0);

                    return Stack(
                      children: [
                        // reflet
                        Positioned(
                          left: -140 + (box.maxWidth + 140) * s,
                          top: 0,
                          bottom: 0,
                          width: 110,
                          child: Opacity(
                            opacity: 1 - e,
                            child: Transform(
                              transform: Matrix4.skewX(-0.35),
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white.withValues(alpha: 0),
                                      Colors.white.withValues(alpha: 0.38),
                                      Colors.white.withValues(alpha: 0),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // traînée derrière le cercle
                        Positioned(
                          left: left + size / 2,
                          top: 22,
                          bottom: 22,
                          width: math.max(0.0, startLeft - left) + 40,
                          child: Opacity(
                            opacity: e > 0 ? 1 : 0,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(40),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.background.withValues(
                                      alpha: 0.22,
                                    ),
                                    AppColors.background.withValues(alpha: 0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        // texte START RUN : s'efface vers la droite
                        Positioned(
                          left: 30,
                          right: 130,
                          top: 0,
                          bottom: 0,
                          child: Opacity(
                            opacity: 1 - (e * 3).clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(40 * e, 0),
                              child: _texts(status, breath),
                            ),
                          ),
                        ),

                        // LET'S GO : arrive par la droite
                        Positioned(
                          right: 40,
                          top: 0,
                          bottom: 0,
                          child: Center(
                            child: Opacity(
                              opacity: goT,
                              child: Transform.translate(
                                offset: Offset(30 * (1 - goT), 0),
                                child: Text(
                                  "LET'S GO",
                                  style: GoogleFonts.barlowCondensed(
                                    fontSize: 46,
                                    fontWeight: FontWeight.w800,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.background,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // cercle play : glisse vers la gauche
                        Positioned(
                          left: left,
                          top: (128 - size) / 2,
                          width: size,
                          height: size,
                          child: _playButton(t, breath, e),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _texts(String status, double breath) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'START RUN',
          style: GoogleFonts.barlowCondensed(
            fontSize: 42,
            fontWeight: FontWeight.w800,
            height: 1,
            color: AppColors.background,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background.withValues(
                  alpha: 0.35 + 0.65 * breath,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                status,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _playButton(double t, double breath, double e) {
    Widget ring(double phase) {
      final p = (t + phase) % 1.0;
      return Transform.scale(
        scale: 0.78 + 0.22 * Curves.easeOut.transform(p),
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.background.withValues(
                alpha: (1 - p) * 0.5 * (1 - e),
              ),
              width: 3,
            ),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        ring(0),
        ring(0.5),
        Transform.scale(
          // léger étirement pendant le glissement
          scale: 1 + 0.03 * breath + 0.08 * math.sin(e * math.pi),
          child: Container(
            width: 84,
            height: 84,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Transform.translate(
              offset: Offset(2 * breath * (1 - e), 0),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (c, a) =>
                    ScaleTransition(scale: a, child: c),
                child: Icon(
                  e > 0.5 ? Icons.bolt_rounded : Icons.play_arrow_rounded,
                  key: ValueKey(e > 0.5),
                  color: AppColors.volt,
                  size: 44,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
