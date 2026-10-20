import '../models/patch_device.dart';

abstract class BleService {
  /// Émet les appareils au fur et à mesure qu'ils sont trouvés.
  Stream<PatchDevice> scan();

  Future<void> connect(PatchDevice device);
}

/// Simulation pour développer l'interface sans le patch.
class MockBleService implements BleService {
  @override
  Stream<PatchDevice> scan() async* {
    const found = [
      (1300, PatchDevice(id: 'A4:CF:12:8B:4F:A2', name: 'runSense Patch RS-01', rssi: -52, battery: 86)),
      (900, PatchDevice(id: '5C:1B:77:20:AA:10', name: 'Unknown device', rssi: -70, isPatch: false)),
      (1100, PatchDevice(id: 'A4:CF:12:3D:9C:17', name: 'runSense Patch RS-01', rssi: -83, battery: 41)),
      (800, PatchDevice(id: '88:D2:0F:61:3E:B9', name: 'JBL Flip 5', rssi: -64, isPatch: false)),
    ];
    for (final (delayMs, device) in found) {
      await Future.delayed(Duration(milliseconds: delayMs));
      yield device;
    }
    await Future.delayed(const Duration(milliseconds: 1500));
  }

  @override
  Future<void> connect(PatchDevice device) async {
    await Future.delayed(const Duration(milliseconds: 2200));
  }
}