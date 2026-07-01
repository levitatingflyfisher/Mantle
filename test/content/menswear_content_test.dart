import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';

void main() {
  const kAxes = ['structured-relaxed', 'muted-graphic', 'classic-directional'];

  late Map<String, dynamic> menswear;
  late Map<String, dynamic> archetypes;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    menswear = jsonDecode(
            File('assets/data/menswear.json').readAsStringSync())
        as Map<String, dynamic>;
    archetypes = jsonDecode(
            File('assets/data/menswear_archetypes.json').readAsStringSync())
        as Map<String, dynamic>;
  });

  test('menswear.json has terms with unique ids', () {
    final ids = (menswear['terms'] as List).map((e) => e['id']).toList();
    expect(ids.length, greaterThanOrEqualTo(50));
    expect(ids.toSet().length, ids.length, reason: 'term ids must be unique');
  });

  test('every term axisSignal axis and pole are valid', () {
    for (final t in menswear['terms'] as List) {
      for (final s in ((t['axisSignals'] as List?) ?? const [])) {
        final axis = s['axis'] as String;
        expect(kAxes, contains(axis),
            reason: 'term ${t['id']} axis "$axis" not in kAxes');
        final poles = axis.split('-');
        expect(poles, contains(s['pole']),
            reason: 'term ${t['id']} pole "${s['pole']}" not a token of "$axis"');
      }
    }
  });

  test('archetypes.json: unique ids, full axisSignature, resolvable adjacency',
      () {
    final ids = {for (final a in archetypes['archetypes'] as List) a['id'] as String};
    expect(ids.length, (archetypes['archetypes'] as List).length);
    for (final a in archetypes['archetypes'] as List) {
      final sig = a['axisSignature'] as Map<String, dynamic>;
      for (final axis in kAxes) {
        expect(sig.keys, contains(axis),
            reason: 'archetype ${a['id']} missing axis "$axis"');
      }
      for (final adj in a['adjacentTo'] as List) {
        expect(ids, contains(adj),
            reason: 'archetype ${a['id']} adjacentTo "$adj" not found');
      }
    }
  });

  test('every leanPool id resolves to a term', () {
    final termIds = {for (final t in menswear['terms'] as List) t['id'] as String};
    for (final id in MenswearRepository.leanPoolIds) {
      expect(termIds, contains(id), reason: 'leanPool id "$id" not a term');
    }
    expect(MenswearRepository.leanPoolIds.length,
        greaterThanOrEqualTo(16),
        reason: 'lean pool must be a meaningful subset (>=16 items)');
  });

  testWidgets('MenswearRepository loads terms, archetypes, and leanPool',
      (tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final repo = MenswearRepository();
    final terms = await repo.terms();
    final arche = await repo.archetypes();
    final pool = await repo.leanPool();
    expect(terms.length, greaterThanOrEqualTo(50));
    expect(arche, hasLength(8));
    expect(pool.length, MenswearRepository.leanPoolIds.length);
    expect(pool.map((t) => t.id), containsAll(MenswearRepository.leanPoolIds));
  });

  test('menswear_spot.json questions have valid shape and A/B sides', () {
    final spot = jsonDecode(
            File('assets/data/menswear_spot.json').readAsStringSync())
        as Map<String, dynamic>;
    final questions = spot['questions'] as List;
    expect(questions, isNotEmpty);
    final ids = <String>{};
    for (final q in questions) {
      expect(ids.add(q['id'] as String), isTrue,
          reason: 'duplicate id ${q['id']}');
      expect(['A', 'B'], contains(q['correctSide']),
          reason: 'question ${q['id']} correctSide must be A or B');
      for (final k in ['facet', 'promptText', 'plateA', 'plateB', 'explanation']) {
        expect((q[k] as String).isNotEmpty, isTrue,
            reason: 'question ${q['id']} empty $k');
      }
      expect(q['plateA'], isNot(equals(q['plateB'])),
          reason: 'question ${q['id']} plateA must differ from plateB');
    }
  });

  test('every spot question plateA/plateB resolves to a term id', () {
    final spot = jsonDecode(
            File('assets/data/menswear_spot.json').readAsStringSync())
        as Map<String, dynamic>;
    final termIds = {for (final t in menswear['terms'] as List) t['id'] as String};
    for (final q in spot['questions'] as List) {
      expect(termIds, contains(q['plateA']),
          reason: 'question ${q['id']} plateA "${q['plateA']}" not a term');
      expect(termIds, contains(q['plateB']),
          reason: 'question ${q['id']} plateB "${q['plateB']}" not a term');
    }
  });

  // Proof-plate gate ONLY — do NOT assert the full term/spot plate set here;
  // undrawn keys render the placeholder and must not fail a build.
  test('the 2-3 proof plates exist in assets/plates/', () {
    for (final key in const ['henley', 'polo', 'oxford-shirt']) {
      expect(File('assets/plates/$key.svg').existsSync(), isTrue,
          reason: 'proof plate assets/plates/$key.svg missing');
    }
  });
}
