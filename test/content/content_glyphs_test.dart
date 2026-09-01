// test/content/content_glyphs_test.dart
//
// Every character the bundled content puts on screen or on the printed
// Charter must be one the bundled fonts can draw; otherwise it is a box on
// a real phone. C7 sweeps lib/ only, so it never saw "Nō" in a deck title
// or 間 in the canon. This scans the content files themselves: the JSON
// string values in assets/data, the deck manifest, and the <text> in the
// SVG plates.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

Iterable<String> _strings(Object? o) sync* {
  if (o is String) {
    yield o;
  } else if (o is List) {
    for (final x in o) {
      yield* _strings(x);
    }
  } else if (o is Map) {
    for (final v in o.values) {
      yield* _strings(v);
    }
  }
}

void main() {
  test('bundled content uses only characters the bundled fonts can draw', () {
    final covered = bundledFontCoverage(root: Directory.current);
    expect(covered, isNotEmpty,
        reason: 'no font coverage read: the check would pass by finding '
            'nothing');

    final sources = <String, Iterable<String>>{};
    for (final f in [
      ...Directory('assets/data').listSync().whereType<File>(),
      File('assets/images/deck/manifest.json'),
    ].where((f) => f.path.endsWith('.json'))) {
      sources[f.path] = _strings(jsonDecode(f.readAsStringSync()));
    }
    final svgText = RegExp(r'<text[^>]*>([^<]*)</text>');
    for (final f in Directory('assets/plates')
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.svg'))) {
      sources[f.path] = [
        for (final m in svgText.allMatches(f.readAsStringSync())) m.group(1)!,
      ];
    }
    expect(sources.values.expand((s) => s), isNotEmpty);

    final missing = <String>{};
    for (final e in sources.entries) {
      for (final s in e.value) {
        for (final r in s.runes) {
          if (r <= 0x20 || covered.contains(r)) continue;
          missing.add('${e.key}: ${String.fromCharCode(r)} '
              '(U+${r.toRadixString(16).toUpperCase().padLeft(4, '0')})');
        }
      }
    }
    expect(missing, isEmpty);
  });
}
