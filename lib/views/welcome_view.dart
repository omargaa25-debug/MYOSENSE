import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme.dart';
import 'bluetooth_view.dart';
import 'widgets/connect_illustration.dart';
import 'widgets/reveal.dart';
import 'widgets/shimmer_button.dart';
import 'widgets/step_tile.dart';

class WelcomeView extends StatefulWidget {
  const WelcomeView({super.key});

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..forward();

  late final AnimationController _ambient = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _ambient.dispose();
    super.dispose();
  }

  void _search() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 600),
        pageBuilder: (_, __, ___) => const BluetoothView(),
        transitionsBuilder: (_, anim, __, child) {
          final curved =
              CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 1.06, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }

  void _noPatch() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Mode démo : bientôt disponible')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wordmark = GoogleFonts.barlowCondensed(
      fontSize: 66,
      fontWeight: FontWeight.w800,
      fontStyle: FontStyle.italic,
      height: 1,
    );

    const steps = [
      'Switch on the ESP32 box',
      'Turn on Bluetooth on your phone',
      'Keep the patch close to the phone',
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- logo texte + slogan ----
                      Center(
                        child: Reveal(
                          parent: _intro,
                          begin: 0.0,
                          end: 0.3,
                          child: Column(
                            children: [
                              Text.rich(TextSpan(children: [
                                TextSpan(
                                  text: 'RUN',
                                  style: wordmark.copyWith(color: AppColors.volt),
                                ),
                                TextSpan(
                                  text: 'SENSE',
                                  style: wordmark.copyWith(
                                      color: AppColors.textPrimary),
                                ),
                              ])),
                              const SizedBox(height: 4),
                              Text(
                                'Écoute. Analyse. Protège.',
                                style: GoogleFonts.manrope(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ---- illustration ----
                      Reveal(
                        parent: _intro,
                        begin: 0.12,
                        end: 0.5,
                        from: const Offset(0, 0.15),
                        child: ConnectIllustration(ambient: _ambient),
                      ),
                      const SizedBox(height: 28),

                      // ---- titre + sous-titre ----
                      Reveal(
                        parent: _intro,
                        begin: 0.30,
                        end: 0.60,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CONNECT YOUR PATCH',
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 46,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                height: 1,
                                color: AppColors.volt,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Pair it once over Bluetooth. Next runs, it reconnects on its own.',
                              style: GoogleFonts.manrope(
                                fontSize: 17,
                                height: 1.4,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---- 3 étapes ----
                      for (int i = 0; i < steps.length; i++)
                        Reveal(
                          parent: _intro,
                          begin: 0.45 + i * 0.10,
                          end: 0.75 + i * 0.10,
                          from: const Offset(0.15, 0),
                          child: StepTile(number: i + 1, text: steps[i]),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- bouton ----
              Reveal(
                parent: _intro,
                begin: 0.75,
                end: 1.0,
                from: const Offset(0, 0.6),
                child: ShimmerButton(
                  label: 'SEARCH FOR MY PATCH',
                  icon: Icons.bluetooth_rounded,
                  onPressed: _search,
                ),
              ),
              Reveal(
                parent: _intro,
                begin: 0.85,
                end: 1.0,
                from: Offset.zero,
                child: TextButton(
                  onPressed: _noPatch,
                  child: Text(
                    "I don't have a patch yet",
                    style: GoogleFonts.manrope(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}