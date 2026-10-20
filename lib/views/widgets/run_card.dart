import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/run_summary.dart';

class RunCard extends StatelessWidget {
  final RunSummary run;
  final Animation<double> routeProgress;

  const RunCard({super.key, required this.run, required this.routeProgress});

  @override
  Widget build(BuildContext context) {
    final statusColor = run.isHigh ? AppColors.warning : AppColors.volt;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              color: const Color(0xFF1E2423),
              borderRadius: BorderRadius.circular(22),
            ),
            child: CustomPaint(
              painter: _RoutePainter(run.route, routeProgress),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      run.title,
                      style: GoogleFonts.manrope(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      run.when,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _stat(run.km.toStringAsFixed(1), 'km'),
                    const SizedBox(width: 22),
                    _stat(run.pace, '/km'),
                    const SizedBox(width: 22),
                    _stat(run.time, 'time'),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        run.statusText,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String value, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.barlowCondensed(
            fontSize: 34,
            fontWeight: FontWeight.w700,
            height: 1.05,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          unit,
          style: GoogleFonts.manrope(fontSize: 14, color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  final List<Offset> points;
  final Animation<double> progress;

  _RoutePainter(this.points, this.progress) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size s) {
    final grid = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 5;
    for (final f in [0.3, 0.7]) {
      canvas.drawLine(
        Offset(s.width * f, 0),
        Offset(s.width * f, s.height),
        grid,
      );
      canvas.drawLine(
        Offset(0, s.height * f),
        Offset(s.width, s.height * f),
        grid,
      );
    }

    const pad = 12.0;
    Offset map(Offset o) => Offset(
      pad + o.dx * (s.width - 2 * pad),
      pad + o.dy * (s.height - 2 * pad),
    );

    final path = Path()..moveTo(map(points.first).dx, map(points.first).dy);
    for (final p in points.skip(1)) {
      final m = map(p);
      path.lineTo(m.dx, m.dy);
    }

    final metric = path.computeMetrics().first;
    final len = metric.length * progress.value;

    canvas.drawPath(
      metric.extractPath(0, len),
      Paint()
        ..color = AppColors.volt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    // point lumineux au bout du tracé
    final tip = metric.getTangentForOffset(len);
    if (tip != null && progress.value > 0) {
      canvas.drawCircle(
        tip.position,
        9,
        Paint()
          ..color = AppColors.volt.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(tip.position, 4.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(_RoutePainter old) => false;
}
