import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/week_stats.dart';

class WeekCard extends StatelessWidget {
  final WeekStats stats;
  final Animation<double> intro;

  const WeekCard({super.key, required this.stats, required this.intro});

  static const _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final maxKm = stats.dailyKm.reduce((a, b) => a > b ? a : b);
    const maxBar = 112.0;

    final small = GoogleFonts.manrope(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 24, 26, 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(34),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THIS WEEK',
                      style: GoogleFonts.manrope(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.6,
                        color: AppColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: stats.km),
                      duration: const Duration(milliseconds: 1400),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, __) => Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            v.toStringAsFixed(1),
                            style: GoogleFonts.barlowCondensed(
                              fontSize: 84,
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
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${stats.runs} runs', style: small),
                    const SizedBox(height: 8),
                    Text('${stats.totalTime} total', style: small),
                    const SizedBox(height: 8),
                    Text('${stats.avgPace} avg pace', style: small),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AnimatedBuilder(
            animation: intro,
            builder: (_, __) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (int i = 0; i < 7; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(
                      child: _bar(
                        i: i,
                        km: stats.dailyKm[i],
                        maxKm: maxKm,
                        maxBar: maxBar,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _bar({
    required int i,
    required double km,
    required double maxKm,
    required double maxBar,
  }) {
    final t = Interval(
      (0.25 + i * 0.05).clamp(0.0, 1.0),
      (0.70 + i * 0.05).clamp(0.0, 1.0),
      curve: Curves.easeOutBack,
    ).transform(intro.value);

    final has = km > 0;
    final target = has ? (22 + (maxBar - 22) * (km / maxKm)) : 7.0;
    final today = i == stats.todayIndex;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxBar,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: (7 + (target - 7) * t).clamp(4.0, maxBar),
              decoration: BoxDecoration(
                color: has ? AppColors.volt : const Color(0xFF2A3130),
                borderRadius: BorderRadius.circular(has ? 14 : 4),
                boxShadow: (today && has)
                    ? [
                        BoxShadow(
                          color: AppColors.volt.withValues(
                            alpha: 0.45 * t.clamp(0.0, 1.0),
                          ),
                          blurRadius: 18,
                          spreadRadius: -2,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _days[i],
          style: GoogleFonts.manrope(
            fontSize: 18,
            fontWeight: today ? FontWeight.w800 : FontWeight.w600,
            color: today ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}
