import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme.dart';

/// Bouton stop à maintenir : un anneau se remplit, puis la course se termine.
class HoldToFinish extends StatefulWidget {
  final VoidCallback onComplete;
  final VoidCallback onTooShort;

  const HoldToFinish({
    super.key,
    required this.onComplete,
    required this.onTooShort,
  });

  @override
  State<HoldToFinish> createState() => _HoldToFinishState();
}

class _HoldToFinishState extends State<HoldToFinish>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 900),
      )..addStatusListener((st) {
        if (st == AnimationStatus.completed) {
          HapticFeedback.heavyImpact();
          widget.onComplete();
        }
      });

  bool _down = false;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _press() {
    setState(() => _down = true);
    HapticFeedback.selectionClick();
    _c.forward();
  }

  void _release() {
    if (!mounted) return;
    setState(() => _down = false);
    if (_c.status != AnimationStatus.completed) {
      if (_c.value < 0.9) widget.onTooShort();
      _c.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedScale(
        scale: _down ? 1.1 : 1,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SizedBox(
          width: 76,
          height: 76,
          child: AnimatedBuilder(
            animation: _c,
            builder: (_, __) => CustomPaint(
              painter: _HoldPainter(_c.value),
              child: Center(
                child: Transform.scale(
                  scale: 1 - 0.25 * _c.value,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color: Color.lerp(
                        Colors.white,
                        AppColors.danger,
                        _c.value,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HoldPainter extends CustomPainter {
  final double v;
  _HoldPainter(this.v);

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromLTWH(2, 2, s.width - 4, s.height - 4);
    canvas.drawOval(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Colors.white24,
    );
    if (v > 0) {
      canvas.drawArc(
        rect,
        -math.pi / 2,
        2 * math.pi * v,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5
          ..strokeCap = StrokeCap.round
          ..color = AppColors.danger,
      );
    }
  }

  @override
  bool shouldRepaint(_HoldPainter old) => old.v != v;
}
