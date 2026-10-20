class PatchDevice {
  final String id; // adresse MAC, ex. AA:BB:CC:DD:4F:A2
  final String name;
  final int rssi; // force du signal en dBm (-40 fort, -90 faible)
  final int? battery; // en %, null si inconnue
  final bool isPatch; // true = patch runSense, false = autre appareil

  const PatchDevice({
    required this.id,
    required this.name,
    required this.rssi,
    this.battery,
    this.isPatch = true,
  });

  String get shortId {
    final p = id.split(':');
    return p.length >= 2 ? '${p[p.length - 2]}:${p.last}' : id;
  }

  String get signalLabel {
    if (rssi >= -60) return 'Strong signal';
    if (rssi >= -75) return 'Medium signal';
    return 'Weak signal';
  }

  String get subtitle {
    final b = battery != null ? ' · Battery $battery%' : '';
    return 'ID $shortId · $signalLabel$b';
  }
}