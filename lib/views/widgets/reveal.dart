import 'package:flutter/material.dart';

class Reveal extends StatelessWidget {
  final Animation<double> parent;
  final double begin;
  final double end;
  final Offset from;
  final double scaleFrom;
  final Curve curve;
  final Widget child;

  const Reveal({
    super.key,
    required this.parent,
    required this.begin,
    required this.end,
    this.from = const Offset(0, 0.3),
    this.scaleFrom = 1.0,
    this.curve = Curves.easeOutCubic,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(
      parent: parent,
      curve: Interval(begin, end, curve: Curves.easeOut),
    );
    final move = CurvedAnimation(
      parent: parent,
      curve: Interval(begin, end, curve: curve),
    );
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween(begin: from, end: Offset.zero).animate(move),
        child: ScaleTransition(
          scale: Tween(begin: scaleFrom, end: 1.0).animate(move),
          child: child,
        ),
      ),
    );
  }
}
