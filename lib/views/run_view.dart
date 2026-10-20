import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import 'run_countdown_view.dart';
import 'run_idle_view.dart';
import 'run_live_view.dart';
import 'run_result_view.dart';

class RunView extends StatelessWidget {
  const RunView({super.key});

  @override
  Widget build(BuildContext context) {
    final stage = context.select<SessionController, int>(
      (s) => switch (s.phase) {
        RunPhase.idle => 0,
        RunPhase.countdown => 1,
        RunPhase.running || RunPhase.paused => 2,
        RunPhase.finished => 3,
      },
    );

    final page = switch (stage) {
      0 => const RunIdleView(),
      1 => const RunCountdownView(),
      2 => const RunLiveView(),
      _ => const RunResultView(),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 550),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        fit: StackFit.expand,
        children: [...previous, if (current != null) current],
      ),
      transitionBuilder: (child, anim) {
        final key = child.key;
        final fromBelow = key is ValueKey<int> && key.value == 3;
        return FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween(
              begin: fromBelow ? const Offset(0, 0.10) : const Offset(0.12, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey<int>(stage), child: page),
    );
  }
}
