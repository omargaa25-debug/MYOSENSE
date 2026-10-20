import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/ble_controller.dart';
import '../core/theme.dart';
import '../models/patch_device.dart';
import '../services/ble_service.dart';
import 'widgets/device_card.dart';
import 'widgets/radar.dart';
import 'widgets/reveal.dart';
import 'widgets/shimmer_button.dart';
import 'main_view.dart';

class BluetoothView extends StatelessWidget {
  const BluetoothView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      // plus tard : remplacer MockBleService par le vrai service BLE
      create: (_) => BleController(MockBleService())..startScan(),
      child: const _BluetoothBody(),
    );
  }
}

class _BluetoothBody extends StatefulWidget {
  const _BluetoothBody();

  @override
  State<_BluetoothBody> createState() => _BluetoothBodyState();
}

class _BluetoothBodyState extends State<_BluetoothBody>
    with TickerProviderStateMixin {
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();

  late final AnimationController _sweep = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _intro.dispose();
    _sweep.dispose();
    super.dispose();
  }

  Future<void> _connect(BleController ble, PatchDevice d) async {
    HapticFeedback.selectionClick();
    await ble.connect(d);
    if (!mounted) return;
    if (ble.error != null) {
      HapticFeedback.vibrate();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(ble.error!)));
    } else {
      HapticFeedback.heavyImpact();
    }
  }

  void _continue() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 700),
        pageBuilder: (_, __, ___) => const MainView(),
        transitionsBuilder: (_, anim, __, child) {
          final curved = CurvedAnimation(
            parent: anim,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(curved),
              child: child,
            ),
          );
        },
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ble = context.watch<BleController>();
    final patches = ble.patches;
    final others = ble.others;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- barre du haut ----
                      Reveal(
                        parent: _intro,
                        begin: 0,
                        end: 0.3,
                        from: const Offset(0, -0.3),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _BackButton(
                              onTap: () => Navigator.of(context).pop(),
                            ),
                            const _BluetoothChip(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),

                      // ---- titre ----
                      Reveal(
                        parent: _intro,
                        begin: 0.1,
                        end: 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Find your patch',
                              style: GoogleFonts.barlowCondensed(
                                fontSize: 54,
                                fontWeight: FontWeight.w800,
                                height: 1,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Hold the patch button 3 s until its LED blinks green.',
                              style: GoogleFonts.manrope(
                                fontSize: 16.5,
                                height: 1.4,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ---- radar ----
                      Center(
                        child: Reveal(
                          parent: _intro,
                          begin: 0.2,
                          end: 0.65,
                          from: const Offset(0, 0.1),
                          child: Radar(
                            sweep: _sweep,
                            devices: ble.allDevices,
                            scanning: ble.scanning,
                            connectingId: ble.connectingId,
                            connectedId: ble.connectedId,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ---- en-tête de liste ----
                      Reveal(
                        parent: _intro,
                        begin: 0.5,
                        end: 0.8,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'NEARBY PATCHES',
                              style: GoogleFonts.manrope(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: AppColors.textMuted,
                              ),
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: Text(
                                ble.scanning
                                    ? 'Scanning...'
                                    : '${patches.length} found',
                                key: ValueKey(ble.scanning),
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: ble.scanning
                                      ? AppColors.volt
                                      : AppColors.textMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // ---- liste des patchs ----
                      if (patches.isEmpty)
                        ble.scanning
                            ? _SearchingCard(sweep: _sweep)
                            : const _EmptyCard()
                      else
                        for (final d in patches)
                          DeviceCard(
                            key: ValueKey(d.id),
                            device: d,
                            highlighted: ble.highlightId == d.id,
                            connecting: ble.connectingId == d.id,
                            connected: ble.connectedId == d.id,
                            busy: ble.connectingId != null,
                            onConnect: () => _connect(ble, d),
                          ),

                      // ---- autres appareils cachés ----
                      if (others.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 6),
                              child: Text(
                                ble.showAll
                                    ? '${others.length} other Bluetooth devices'
                                    : '${others.length} other Bluetooth devices hidden',
                                style: GoogleFonts.manrope(
                                  fontSize: 15,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: ble.toggleShowAll,
                              child: Text(
                                ble.showAll ? 'Hide' : 'Show all',
                                style: GoogleFonts.manrope(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.volt,
                                ),
                              ),
                            ),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: Column(
                            children: [
                              if (ble.showAll)
                                for (final d in others) _OtherTile(device: d),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // ---- bouton du bas : Rescan -> Continue ----
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                transitionBuilder: (c, a) => FadeTransition(
                  opacity: a,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(a),
                    child: c,
                  ),
                ),
                child: ble.connectedId != null
                    ? ShimmerButton(
                        key: const ValueKey('continue'),
                        label: 'CONTINUE',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _continue,
                      )
                    : OutlinedButton(
                        key: const ValueKey('rescan'),
                        onPressed: ble.connectingId != null
                            ? null
                            : ble.startScan,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(60),
                          foregroundColor: AppColors.textPrimary,
                          side: const BorderSide(color: Colors.white24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _sweep,
                              builder: (_, child) => Transform.rotate(
                                angle: ble.scanning
                                    ? _sweep.value * 2 * math.pi
                                    : 0,
                                child: child,
                              ),
                              child: const Icon(
                                Icons.refresh_rounded,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Rescan',
                              style: GoogleFonts.manrope(
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
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

// ------------------------------------------------------------
class _BackButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: const BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.chevron_left_rounded,
          size: 32,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _BluetoothChip extends StatelessWidget {
  const _BluetoothChip();

  @override
  Widget build(BuildContext context) {
    // statut fixe pour l'instant : on le branchera sur l'état réel du Bluetooth
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.bluetooth_rounded,
            size: 22,
            color: Color(0xFF4FC3F7),
          ),
          const SizedBox(width: 10),
          Text(
            'Bluetooth on',
            style: GoogleFonts.manrope(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchingCard extends StatelessWidget {
  final Animation<double> sweep;
  const _SearchingCard({required this.sweep});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: sweep,
      builder: (_, __) {
        final wave = (math.sin(sweep.value * 2 * math.pi * 2) + 1) / 2;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: AppColors.volt.withValues(alpha: 0.12 + 0.3 * wave),
            ),
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.volt,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Looking for runSense patches…',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _EmptyCard extends StatelessWidget {
  const _EmptyCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Text(
        'No patch found. Check that the ESP32 box is on, then tap Rescan.',
        style: GoogleFonts.manrope(
          fontSize: 16,
          height: 1.4,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}

class _OtherTile extends StatelessWidget {
  final PatchDevice device;
  const _OtherTile({required this.device});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.card.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bluetooth_rounded,
            size: 22,
            color: AppColors.textMuted,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.name,
                  style: GoogleFonts.manrope(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                  ),
                ),
                Text(
                  'ID ${device.shortId} · Not a runSense patch',
                  style: GoogleFonts.manrope(
                    fontSize: 12.5,
                    color: AppColors.textMuted.withValues(alpha: 0.7),
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
