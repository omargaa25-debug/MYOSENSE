import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/session_controller.dart';
import 'home_view.dart';
import 'run_view.dart';
import 'widgets/nav_bar.dart';
import 'widgets/tab_placeholder.dart';

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _index = 0;
  int _prev = 0;

  static const _items = [
    NavItemData(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItemData(
      Icons.play_circle_outline_rounded,
      Icons.play_circle_rounded,
      'Run',
    ),
    NavItemData(Icons.bar_chart_rounded, Icons.bar_chart_rounded, 'Insights'),
  ];

  void _select(int i) {
    if (i == _index) return;
    setState(() {
      _prev = _index;
      _index = i;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeView(onStartRun: () => _select(1)),
      const RunView(),
      const TabPlaceholder(
        icon: Icons.bar_chart_rounded,
        title: 'Insights',
        subtitle: 'Page Insights\nContenu à définir',
      ),
    ];

    final dir = _index > _prev ? 1.0 : -1.0;
    return ChangeNotifierProvider(
      create: (_) => SessionController(),
      child: Scaffold(
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, anim) => FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween(
                begin: Offset(0.12 * dir, 0),
                end: Offset.zero,
              ).animate(anim),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(_index), child: pages[_index]),
        ),
        bottomNavigationBar: RunSenseNavBar(
          index: _index,
          items: _items,
          onChanged: _select,
        ),
      ),
    );
  }
}
