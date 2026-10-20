import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme.dart';
import '../../models/patch_device.dart';

class DeviceCard extends StatelessWidget {
  final PatchDevice device;
  final bool highlighted;
  final bool connecting;
  final bool connected;
  final bool busy; // un autre appareil est en cours de connexion
  final VoidCallback onConnect;

  const DeviceCard({
    super.key,
    required this.device,
    required this.highlighted,
    required this.connecting,
    required this.connected,
    required this.busy,
    required this.onConnect,
  });

  @override
  Widget build(BuildContext context) {
    // entrée : fondu + glissement vers le haut
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 550),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 28 * (1 - v)), child: child),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(
            color: highlighted
                ? AppColors.volt
                : Colors.white.withValues(alpha: 0.05),
            width: highlighted ? 1.6 : 1,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: AppColors.volt.withValues(alpha: 0.12),
                    blurRadius: 22,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFF222A28),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.monitor_heart_outlined,
                  color: AppColors.volt, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.name,
                    style: GoogleFonts.manrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device.subtitle,
                    style: GoogleFonts.manrope(
                      fontSize: 13.5,
                      height: 1.35,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            _ActionPill(
              highlighted: highlighted,
              connecting: connecting,
              connected: connected,
              disabled: busy && !connecting,
              onTap: onConnect,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionPill extends StatelessWidget {
  final bool highlighted;
  final bool connecting;
  final bool connected;
  final bool disabled;
  final VoidCallback onTap;

  const _ActionPill({
    required this.highlighted,
    required this.connecting,
    required this.connected,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final filled = highlighted || connected;
    final textStyle = GoogleFonts.manrope(
      fontSize: 16,
      fontWeight: FontWeight.w800,
      color: filled ? AppColors.background : AppColors.textPrimary,
    );

    Widget child;
    if (connecting) {
      child = const SizedBox(
        key: ValueKey('loading'),
        width: 22,
        height: 22,
        child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.volt),
      );
    } else if (connected) {
      child = Row(
        key: const ValueKey('connected'),
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_rounded, size: 20, color: AppColors.background),
          const SizedBox(width: 4),
          Text('Linked', style: textStyle),
        ],
      );
    } else {
      child = Text('Connect', key: const ValueKey('idle'), style: textStyle);
    }

    return GestureDetector(
      onTap: (disabled || connecting || connected) ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: disabled ? 0.4 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 112,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: filled ? AppColors.volt : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: filled
                  ? AppColors.volt
                  : (connecting ? AppColors.volt : Colors.white30),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: child,
          ),
        ),
      ),
    );
  }
}