import 'dart:math';

/// 16-byte cryptographically-random lowercase hex id (UUID4-equivalent entropy).
String secureHexId() {
  final r = Random.secure();
  return List.generate(16, (_) => r.nextInt(256).toRadixString(16).padLeft(2, '0')).join();
}
