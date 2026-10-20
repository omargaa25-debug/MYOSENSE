import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import '../core/format.dart';
import '../core/theme.dart';
import 'widgets/emg_wave.dart';
import 'widgets/fatigue_ring.dart';
import 'widgets/hold_to_finish.dart';
import 'widgets/patch_chip.dart';
import 'widgets/pressable.dart';
import 'widgets/reveal.dart';

class RunLiveView extends StatefulWidget {
  const RunLiveView({super.key});

  @override
  State<RunLiveView> createState() => _RunLiveViewState();
}

class _RunLiveViewState extends State<RunLiveView>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat();

  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  bool _hint = false;
  Timer? _hintTimer;

  @override
  void dispose() {
    _hintTimer?.cancel();
    _intro.dispose();
    _loop.dispose();
    _wave.dispose();
    super.dispose();
  }

  void _lap(SessionController s) {
    final msg = s.lap();
    HapticFeedback.mediumImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(msg),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _showHint() {
    setState(() => _hint = true);
    _hintTimer?.cancel();
    _hintTimer = Timer(const Duration(milliseconds: 1800), () {
      if (mounted) setState(() => _hint = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SessionController>();
    final paused = s.phase == RunPhase.paused;
    final fColor = fatigueColor(s.fatigue);

    final (riskText, riskColor, tileBg, coachBg) = switch (s.tearRisk) {
      TearRisk.low => (
        'Low',
        AppColors.volt,
        AppColors.card,
        const Color(0xFF1C2410),
      ),
      TearRisk.medium => (
        'Medium',
        AppColors.warning,
        const Color(0xFF2A2012),
        const Color(0xFF2A2010),
      ),
      TearRisk.high => (
        'High',
        AppColors.danger,
        const Color(0xFF2E1513),
        const Color(0xFF2E1513),
      ),
    };

    final w = MediaQuery.of(context).size.width;
    final ringSize = math.min(w * 0.64, 270.0);

    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              child: Column(
                children: [
                  // ---- en-tête ----
                  Reveal(
                    parent: _intro,
                    begin: 0,
                    end: 0.2,
                    from: const Offset(0, -0.4),
                    curve: Curves.easeOutBack,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _LiveBadge(paused: paused, loop: _loop),
                        const PatchChip(label: 'Right quad · 86%'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ---- chrono ----
                  Reveal(
                    parent: _intro,
                    begin: 0.05,
                    end: 0.35,
                    scaleFrom: 0.8,
                    curve: Curves.easeOutBack,
                    child: AnimatedBuilder(
                      animation: _loop,
                      builder: (_, __) {
                        final blink =
                            (math.sin(_loop.value * 2 * math.pi) + 1) / 2;
                        return Opacity(
                          opacity: paused ? 0.35 + 0.65 * blink : 1,
                          child: Text(
                            formatDuration(s.elapsed),
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 92,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 6),

                  // ---- anneau de fatigue ----
                  Reveal(
                    parent: _intro,
                    begin: 0.12,
                    end: 0.5,
                    scaleFrom: 0.7,
                    curve: Curves.easeOutBack,
                    child: AnimatedBuilder(
                      animation: _loop,
                      builder: (_, __) => FatigueRing(
                        value: s.fatigue,
                        size: ringSize,
                        color: fColor,
                        level: s.fatigueLabel,
                        pulse: (math.sin(_loop.value * 2 * math.pi) + 1) / 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ---- EMG ----
                  Reveal(
                    parent: _intro,
                    begin: 0.25,
                    end: 0.6,
                    from: const Offset(-0.15, 0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'EMG signal',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                'Median freq. ${s.medianFreq.round()} Hz ↓',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 64,
                            width: double.infinity,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(end: paused ? 0.06 : 1.0),
                              duration: const Duration(milliseconds: 600),
                              builder: (_, a, __) => EmgWave(
                                t: _wave,
                                fatigue: s.fatigue,
                                medianFreq: s.medianFreq,
                                amp: a,
                                color: fColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ---- 3 stats ----
                  Reveal(
                    parent: _intro,
                    begin: 0.35,
                    end: 0.7,
                    from: const Offset(0, 0.4),
                    curve: Curves.easeOutBack,
                    child: Row(
                      children: [
                        Expanded(
                          child: _StatTile(
                            label: 'Pace /km',
                            value: formatPace(s.paceSecPerKm),
                            valueColor: AppColors.textPrimary,
                            bg: AppColors.card,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            label: 'Distance',
                            value: s.km.toStringAsFixed(2),
                            unit: 'km',
                            valueColor: AppColors.textPrimary,
                            bg: AppColors.card,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatTile(
                            label: 'Tear risk',
                            value: riskText,
                            valueColor: riskColor,
                            bg: tileBg,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // ---- coach IA ----
                  Reveal(
                    parent: _intro,
                    begin: 0.45,
                    end: 0.8,
                    from: const Offset(0, 0.4),
                    curve: Curves.easeOutBack,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: coachBg,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.auto_awesome_rounded,
                            color: riskColor,
                            size: 28,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 450),
                              layoutBuilder: (current, previous) => Stack(
                                alignment: Alignment.topLeft,
                                children: [
                                  ...previous,
                                  if (current != null) current,
                                ],
                              ),
                              transitionBuilder: (c, a) => FadeTransition(
                                opacity: a,
                                child: SlideTransition(
                                  position: Tween(
                                    begin: const Offset(0, 0.25),
                                    end: Offset.zero,
                                  ).animate(a),
                                  child: c,
                                ),
                              ),
                              child: KeyedSubtree(
                                key: ValueKey(s.coachMessage),
                                child: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'AI coach · ',
                                        style: GoogleFonts.manrope(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w800,
                                          color: riskColor,
                                        ),
                                      ),
                                      TextSpan(
                                        text: s.coachMessage,
                                        style: GoogleFonts.manrope(
                                          fontSize: 17,
                                          height: 1.35,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ---- commandes ----
          Reveal(
            parent: _intro,
            begin: 0.5,
            end: 0.95,
            from: const Offset(0, 0.8),
            curve: Curves.easeOutBack,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14, top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedOpacity(
                    opacity: _hint ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      'Hold the stop button to finish',
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Pressable(
                        scale: 0.9,
                        onTap: () => _lap(s),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white24, width: 2),
                          ),
                          child: const Icon(
                            Icons.flag_outlined,
                            size: 30,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _mainButton(s, paused),
                      HoldToFinish(onComplete: s.finish, onTooShort: _showHint),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mainButton(SessionController s, bool paused) {
    return Pressable(
      scale: 0.92,
      onTap: () {
        HapticFeedback.mediumImpact();
        s.togglePause();
      },
      child: AnimatedBuilder(
        animation: _loop,
        builder: (_, __) {
          final breath = paused
              ? 0.0
              : (math.sin(_loop.value * 2 * math.pi) + 1) / 2;
          return Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: AppColors.volt,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.volt.withValues(alpha: 0.2 + 0.25 * breath),
                  blurRadius: 24 + 16 * breath,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(
                scale: a,
                child: RotationTransition(
                  turns: Tween(begin: 0.85, end: 1.0).animate(a),
                  child: c,
                ),
              ),
              child: Icon(
                paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                key: ValueKey(paused),
                size: 52,
                color: AppColors.background,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  final bool paused;
  final Animation<double> loop;
  const _LiveBadge({required this.paused, required this.loop});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AnimatedBuilder(
          animation: loop,
          builder: (_, __) {
            final w = (math.sin(loop.value * 2 * math.pi) + 1) / 2;
            final c = paused ? AppColors.warning : const Color(0xFFFF5A4D);
            return Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: c.withValues(alpha: paused ? 1 : 0.45 + 0.55 * w),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c.withValues(alpha: paused ? 0 : 0.5 * w),
                    blurRadius: 8,
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(width: 10),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(
            paused ? 'PAUSED' : 'LIVE RUN',
            key: ValueKey(paused),
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final Color valueColor;
  final Color bg;

  const _StatTile({
    required this.label,
    required this.value,
    this.unit,
    required this.valueColor,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 38,
                    fontWeight: FontWeight.w800,
                    height: 1.05,
                    color: valueColor,
                  ),
                ),
                if (unit != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 3),
                    child: Text(
                      unit!,
                      style: GoogleFonts.barlowCondensed(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: valueColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
