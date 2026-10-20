import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';

class NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const NavItemData(this.icon, this.activeIcon, this.label);
}

class RunSenseNavBar extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  final List<NavItemData> items;

  const RunSenseNavBar({
    super.key,
    required this.index,
    required this.onChanged,
    required this.items,
  });

  static const double _height = 74;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: _height,
          child: LayoutBuilder(
            builder: (context, box) {
              final itemW = box.maxWidth / items.length;
              return Stack(
                children: [
                  // lueur + barre qui glissent sous l'onglet actif
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 450),
                    curve: Curves.easeOutBack,
                    left: index * itemW,
                    top: 0,
                    width: itemW,
                    height: _height,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.volt.withValues(alpha: 0.14),
                            Colors.transparent,
                          ],
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          width: 38,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.volt,
                            borderRadius: const BorderRadius.vertical(
                              bottom: Radius.circular(4),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.volt.withValues(alpha: 0.7),
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (int i = 0; i < items.length; i++)
                        Expanded(
                          child: _NavItem(
                            data: items[i],
                            active: i == index,
                            onTap: () {
                              if (i != index) {
                                HapticFeedback.selectionClick();
                                onChanged(i);
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final NavItemData data;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.volt : AppColors.textPrimary;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedScale(
            scale: active ? 1.15 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: Icon(
                active ? data.activeIcon : data.icon,
                key: ValueKey(active),
                color: color,
                size: 28,
              ),
            ),
          ),
          const SizedBox(height: 5),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              color: color,
            ),
            child: Text(data.label),
          ),
        ],
      ),
    );
  }
}
