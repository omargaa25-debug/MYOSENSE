import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/patch_device.dart';
import '../services/ble_service.dart';

class BleController extends ChangeNotifier {
  final BleService _service;
  BleController(this._service);

  final Map<String, PatchDevice> _found = {};
  StreamSubscription<PatchDevice>? _sub;

  bool scanning = false;
  bool showAll = false;
  String? connectingId;
  String? connectedId;
  String? error;

  /// Patchs runSense, du signal le plus fort au plus faible.
  List<PatchDevice> get patches => _found.values.where((d) => d.isPatch).toList()
    ..sort((a, b) => b.rssi.compareTo(a.rssi));

  List<PatchDevice> get others =>
      _found.values.where((d) => !d.isPatch).toList();

  List<PatchDevice> get allDevices => _found.values.toList();

  String? get highlightId =>
      connectedId ?? connectingId ?? (patches.isEmpty ? null : patches.first.id);

  void startScan() {
    _sub?.cancel();
    _found.clear();
    connectedId = null;
    connectingId = null;
    error = null;
    scanning = true;
    notifyListeners();

    _sub = _service.scan().listen(
      (d) {
        _found[d.id] = d;
        notifyListeners();
      },
      onDone: _stopScan,
      onError: (_) {
        error = 'Scan impossible';
        _stopScan();
      },
    );
  }

  void _stopScan() {
    scanning = false;
    notifyListeners();
  }

  void toggleShowAll() {
    showAll = !showAll;
    notifyListeners();
  }

  Future<void> connect(PatchDevice device) async {
    if (connectingId != null) return;
    _sub?.cancel();
    scanning = false;
    connectingId = device.id;
    error = null;
    notifyListeners();
    try {
      await _service.connect(device);
      connectedId = device.id;
    } catch (_) {
      error = 'Connexion échouée, réessaie';
    }
    connectingId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}