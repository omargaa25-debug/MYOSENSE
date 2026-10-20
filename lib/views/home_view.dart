import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/home_controller.dart';
import '../core/theme.dart';
import 'widgets/challenge_card.dart';
import 'widgets/pressable.dart';
import 'widgets/reveal.dart';
import 'widgets/run_card.dart';
import 'widgets/start_run_button.dart';
import 'widgets/week_card.dart';

class HomeView extends StatelessWidget {
  final VoidCallback onStartRun;
  const HomeView({super.key, required this.onStartRun});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeController(),
      child: _HomeBody(onStartRun: onStartRun),
    );
  }
}

class _HomeBody extends StatefulWidget {
  final VoidCallback onStartRun;
  const _HomeBody({required this.onStartRun});

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _loop.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.read<HomeController>();

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- en-tête ----
            Reveal(
              parent: _intro,
              begin: 0.0,
              end: 0.22,
              from: const Offset(0, -0.4),
              curve: Curves.easeOutBack,
              child: _Header(
                loop: _loop,
                hasNotifications: c.hasNotifications,
                onBell: () => _toast('Notifications : bientôt'),
              ),
            ),
            const SizedBox(height: 18),

            // ---- semaine ----
            Reveal(
              parent: _intro,
              begin: 0.05,
              end: 0.35,
              from: const Offset(0, 0.25),
              scaleFrom: 0.94,
              curve: Curves.easeOutBack,
              child: WeekCard(stats: c.week, intro: _intro),
            ),
            const SizedBox(height: 18),

            // ---- start run ----
            Reveal(
              parent: _intro,
              begin: 0.18,
              end: 0.48,
              from: const Offset(0, 0.4),
              scaleFrom: 0.9,
              curve: Curves.easeOutBack,
              child: StartRunButton(
                patchConnected: c.patchConnected,
                battery: c.patchBattery,
                onPressed: widget.onStartRun,
              ),
            ),
            const SizedBox(height: 26),

            // ---- recent runs ----
            Reveal(
              parent: _intro,
              begin: 0.30,
              end: 0.52,
              from: const Offset(-0.1, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recent runs',
                    style: GoogleFonts.barlowCondensed(
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _toast('Historique : bientôt'),
                    child: Text(
                      'See all',
                      style: GoogleFonts.manrope(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: AppColors.volt,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            for (int i = 0; i < c.recentRuns.length; i++)
              Reveal(
                parent: _intro,
                begin: 0.42 + i * 0.10,
                end: 0.72 + i * 0.10,
                from: const Offset(0, 0.3),
                scaleFrom: 0.95,
                curve: Curves.easeOutBack,
                child: Pressable(
                  onTap: () => _toast('Détail de la course : bientôt'),
                  child: RunCard(
                    run: c.recentRuns[i],
                    routeProgress: CurvedAnimation(
                      parent: _intro,
                      curve: Interval(
                        0.55 + i * 0.1,
                        1.0,
                        curve: Curves.easeInOut,
                      ),
                    ),
                  ),
                ),
              ),

            // ---- défi ----
            Reveal(
              parent: _intro,
              begin: 0.65,
              end: 0.95,
              from: const Offset(0, 0.3),
              scaleFrom: 0.95,
              curve: Curves.easeOutBack,
              child: Pressable(
                onTap: () => _toast('Défi : bientôt'),
                child: ChallengeCard(challenge: c.challenge),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final Animation<double> loop;
  final bool hasNotifications;
  final VoidCallback onBell;

  const _Header({
    required this.loop,
    required this.hasNotifications,
    required this.onBell,
  });

  @override
  Widget build(BuildContext context) {
    final logo = GoogleFonts.barlowCondensed(
      fontSize: 46,
      fontWeight: FontWeight.w800,
      height: 1,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: 'run',
                style: logo.copyWith(color: AppColors.textPrimary),
              ),
              TextSpan(
                text: 'Sense',
                style: logo.copyWith(color: AppColors.volt),
              ),
            ],
          ),
        ),
        Pressable(
          onTap: onBell,
          scale: 0.9,
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: AppColors.card,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.notifications_none_rounded,
                  size: 28,
                  color: AppColors.textPrimary,
                ),
                if (hasNotifications)
                  Positioned(
                    top: 13,
                    right: 14,
                    child: AnimatedBuilder(
                      animation: loop,
                      builder: (_, __) {
                        final w = (math.sin(loop.value * 2 * math.pi) + 1) / 2;
                        return Transform.scale(
                          scale: 1 + 0.25 * w,
                          child: Container(
                            width: 11,
                            height: 11,
                            decoration: BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.5 * w,
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
