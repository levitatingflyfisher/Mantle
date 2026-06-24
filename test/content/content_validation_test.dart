// test/content/content_validation_test.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> canon;
  late Map<String, dynamic> tl;
  late Map<String, dynamic> spot;
  late Map<String, dynamic> deck;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Map<String, dynamic> load(String p) =>
        jsonDecode(File('assets/data/$p').readAsStringSync())
            as Map<String, dynamic>;
    canon = load('canon.json');
    tl = load('throughlines.json');
    spot = load('spot.json');
    deck = jsonDecode(
        File('assets/images/deck/manifest.json').readAsStringSync())
        as Map<String, dynamic>;
  });

  test('canon has 20 items with unique ids', () {
    final ids = (canon['canon'] as List).map((e) => e['id']).toList();
    expect(ids.length, 20);
    expect(ids.toSet().length, 20);
  });

  test('every echo.toId resolves to a canon id', () {
    final ids = {for (final e in canon['canon'] as List) e['id'] as String};
    for (final e in canon['canon'] as List) {
      expect(ids, contains(e['echo']['toId']),
          reason: '${e['id']} echo.toId="${e['echo']['toId']}" not found');
    }
  });

  test('every throughlines[] entry exists in throughlines.json (canon + deck)', () {
    final keys = {
      for (final t in tl['throughlines'] as List) t['key'] as String
    };
    for (final e in canon['canon'] as List) {
      for (final k in (e['throughlines'] as List)) {
        expect(keys, contains(k),
            reason: 'canon item ${e['id']} has unknown throughline "$k"');
      }
    }
    for (final img in deck['images'] as List) {
      for (final k in (img['throughlines'] as List)) {
        expect(keys, contains(k),
            reason: 'deck image ${img['id']} has unknown throughline "$k"');
      }
    }
  });

  test('every deck features[] and spot featureId resolves to a canon id', () {
    final ids = {for (final e in canon['canon'] as List) e['id'] as String};
    for (final img in deck['images'] as List) {
      for (final f in (img['features'] as List)) {
        expect(ids, contains(f),
            reason: 'deck image ${img['id']} has unknown feature "$f"');
      }
    }
    for (final q in spot['questions'] as List) {
      expect(ids, contains(q['featureId']),
          reason:
              'spot question ${q['id']} featureId="${q['featureId']}" not found');
    }
  });

  // ── Plate SVG coverage ──────────────────────────────────────────────────────

  test('every canon plate field resolves to an SVG in assets/plates/', () {
    for (final e in canon['canon'] as List) {
      final plateKey = e['plate'] as String;
      final file = File('assets/plates/$plateKey.svg');
      expect(file.existsSync(), isTrue,
          reason:
              'canon item ${e['id']} has plate="$plateKey" but assets/plates/$plateKey.svg not found');
    }
  });

  test('every spot plateA and plateB resolves to an SVG in assets/plates/', () {
    for (final q in spot['questions'] as List) {
      final qId = q['id'] as String;
      for (final side in ['plateA', 'plateB']) {
        expect(q[side], isNotNull,
            reason: 'spot question $qId missing $side');
        final plateKey = q[side] as String;
        final file = File('assets/plates/$plateKey.svg');
        expect(file.existsSync(), isTrue,
            reason:
                'spot question $qId $side="$plateKey" but assets/plates/$plateKey.svg not found');
      }
    }
  });

  // ── Deck ────────────────────────────────────────────────────────────────────

  test('deck has exactly 8 images per domain, all CC0/PD with provenance', () {
    final byDomain = <String, int>{};
    for (final img in deck['images'] as List) {
      byDomain[img['domain'] as String] =
          (byDomain[img['domain'] as String] ?? 0) + 1;
      expect(['CC0', 'Public Domain'], contains(img['license']),
          reason: 'deck image ${img['id']} has invalid license "${img['license']}"');
      for (final k in ['institution', 'sourceUrl', 'title', 'creator', 'accessionId']) {
        expect((img[k] as String).isNotEmpty, isTrue,
            reason: 'deck image ${img['id']} has empty $k');
      }
    }
    expect(byDomain, {'architecture': 8, 'tailoring': 8, 'interiors': 8});
  });
}
