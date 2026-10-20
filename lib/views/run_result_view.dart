import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import '../core/format.dart';
import '../core/theme.dart';
import 'widgets/reveal.dart';
import 'widgets/shimmer_button.dart';

class RunResultView extends StatefulWidget {
  const RunResultView({super.key});

  @override
  State<RunResultView> createState() => _RunResultViewState();
}

class _RunResultViewState extends State<RunResultView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..forward();

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  void _close(bool save) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(save ? 'Run saved' : 'Run discarded')),
    );
    context.read<SessionController>().reset();
  }

  @override
  Widget build(BuildContext context) {
    final r = context.read<SessionController>().result;
    if (r == null) return const SizedBox.shrink();
    final peakColor = fatigueColor(r.peakFatigue.toDouble());

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Reveal(
                      parent: _intro,
                      begin: 0,
                      end: 0.2,
                      from: const Offset(0, -0.3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.laps > 0
                                ? 'RUN COMPLETE · ${r.laps} LAPS'
                                : 'RUN COMPLETE',
                            style: GoogleFonts.manrope(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 2,
                              color: AppColors.textMuted,
                            ),
                          ),
                          Text(
                            'Run summary',
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 54,
                              fontWeight: FontWeight.w800,
                              height: 1.05,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ---- distance + stats ----
                    Reveal(
                      parent: _intro,
                      begin: 0.08,
                      end: 0.38,
                      from: const Offset(0, 0.25),
                      scaleFrom: 0.94,
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 22),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(34),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'DISTANCE',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                                color: AppColors.textMuted,
                              ),
                            ),
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0, end: r.km),
                              duration: const Duration(milliseconds: 1500),
                              curve: Curves.easeOutCubic,
                              builder: (_, v, __) => FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: [
                                    Text(
                                      v.toStringAsFixed(2),
                                      style: GoogleFonts.barlowCondensed(
                                        fontSize: 88,
                                        fontWeight: FontWeight.w800,
                                        height: 1,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'km',
                                      style: GoogleFonts.barlowCondensed(
                                        fontSize: 36,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                _MiniStat('Time', formatDuration(r.time)),
                                _MiniStat('Avg pace', r.avgPace),
                                _MiniStat('Energy', '${r.kcal} kcal'),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ---- fatigue max + récupération ----
                    Reveal(
                      parent: _intro,
                      begin: 0.2,
                      end: 0.5,
                      from: const Offset(0, 0.3),
                      curve: Curves.easeOutBack,
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: _BigCard(
                                label: 'Peak fatigue',
                                value: r.peakFatigue,
                                unit: '%',
                                color: peakColor,
                                bg: AppColors.card,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _BigCard(
                                label: 'Right quad recovers in',
                                value: r.recoveryHours,
                                unit: 'h',
                                color: AppColors.warning,
                                bg: const Color(0xFF2D1B0F),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ---- courbe de fatigue ----
                    Reveal(
                      parent: _intro,
                      begin: 0.32,
                      end: 0.62,
                      from: const Offset(0, 0.3),
                      scaleFrom: 0.95,
                      curve: Curves.easeOutBack,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Fatigue curve',
                                  style: GoogleFonts.manrope(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'Avg ${r.avgFatigue}%',
                                  style: GoogleFonts.manrope(
                                    fontSize: 15,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              height: 130,
                              width: double.infinity,
                              child: CustomPaint(
                                painter: _CurvePainter(
                                  r.fatigueCurve,
                                  CurvedAnimation(
                                    parent: _intro,
                                    curve: const Interval(
                                      0.35,
                                      1.0,
                                      curve: Curves.easeInOut,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('0:00', style: _small),
                                Text(formatDuration(r.time), style: _small),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // ---- boutons ----
            Reveal(
              parent: _intro,
              begin: 0.6,
              end: 1.0,
              from: const Offset(0, 0.8),
              curve: Curves.easeOutBack,
              child: Column(
                children: [
                  ShimmerButton(
                    label: 'SAVE RUN',
                    icon: Icons.check_rounded,
                    onPressed: () => _close(true),
                  ),
                  TextButton(
                    onPressed: () => _close(false),
                    child: Text(
                      'Discard run',
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static final _small = GoogleFonts.manrope(
    fontSize: 13,
    color: AppColors.textMuted,
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.barlowCondensed(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            height: 1.05,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.manrope(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _BigCard extends StatelessWidget {
  final String label;
  final int value;
  final String unit;
  final Color color;
  final Color bg;

  const _BigCard({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 16,
              color: AppColors.textPrimary.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 6),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value.toDouble()),
            duration: const Duration(milliseconds: 1400),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '${v.round()}',
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 58,
                    fontWeight: FontWeight.w800,
                    height: 1,
                    color: color,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: GoogleFonts.barlowCondensed(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: color,
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

class _CurvePainter extends CustomPainter {
  final List<double> data;
  final Animation<double> progress;

  _CurvePainter(this.data, this.progress) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size s) {
    double y(double v) => s.height * (1 - v / 100);

    // zones de risque
    canvas.drawRect(
      Rect.fromLTRB(0, y(100), s.width, y(85)),
      Paint()..color = AppColors.danger.withValues(alpha: 0.10),
    );
    canvas.drawRect(
      Rect.fromLTRB(0, y(85), s.width, y(70)),
      Paint()..color = AppColors.warning.withValues(alpha: 0.10),
    );
    final line = Paint()
      ..strokeWidth = 1
      ..color = Colors.white.withValues(alpha: 0.08);
    canvas.drawLine(Offset(0, y(85)), Offset(s.width, y(85)), line);
    canvas.drawLine(Offset(0, y(70)), Offset(s.width, y(70)), line);

    final pts = data.length < 2 ? <double>[8, 8] : data;
    final path = Path();
    for (int i = 0; i < pts.length; i++) {
      final x = s.width * i / (pts.length - 1);
      if (i == 0) {
        path.moveTo(x, y(pts[i]));
      } else {
        path.lineTo(x, y(pts[i]));
      }
    }

    final metric = path.computeMetrics().first;
    final len = metric.length * progress.value;
    final trimmed = metric.extractPath(0, len);
    final tip =
        metric.getTangentForOffset(len)?.position ?? Offset(0, y(pts.first));

    // remplissage sous la courbe
    final fill = Path.from(trimmed)
      ..lineTo(tip.dx, s.height)
      ..lineTo(0, s.height)
      ..close();
    canvas.drawPath(
      fill,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.volt.withValues(alpha: 0.28),
            AppColors.volt.withValues(alpha: 0),
          ],
        ).createShader(Offset.zero & s),
    );

    canvas.drawPath(
      trimmed,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = AppColors.volt,
    );

    if (progress.value > 0) {
      canvas.drawCircle(
        tip,
        9,
        Paint()
          ..color = AppColors.volt.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(tip, 4.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_CurvePainter old) => false;
}
