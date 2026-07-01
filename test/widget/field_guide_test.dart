import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/core/utils/id.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/archetype.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/field_guide_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

MenswearTerm _t(String id, List<List<String>> sig) => MenswearTerm(
      id: id, facet: 'garment', term: id, handle: null, gloss: '',
      quickRead: '', closerRead: '',
      axisSignals: [for (final s in sig) AxisSignal(axis: s[0], pole: s[1])],
      plateHint: '');

// A relaxed/graphic/directional term repeated in the lean pool.
final _relaxedTerm = _t('hoodie', [
  ['structured-relaxed', 'relaxed'],
  ['muted-graphic', 'graphic'],
  ['classic-directional', 'directional'],
]);
final _classicTerm = _t('oxford-shirt', [
  ['structured-relaxed', 'structured'],
  ['classic-directional', 'classic'],
]);

class _FakeMenswearRepository extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async => [_relaxedTerm, _classicTerm];
  @override
  Future<List<MenswearTerm>> leanPool() async => [_relaxedTerm, _classicTerm];
  @override
  Future<List<Archetype>> archetypes() async => [
        const Archetype(
            id: 'streetwear', name: 'Streetwear', handle: 'Sneakers with something to say',
            oneLiner: 'Graphic tees and fresh sneakers.',
            axisSignature: {
              'structured-relaxed': 'relaxed',
              'muted-graphic': 'graphic',
              'classic-directional': 'directional',
            },
            signatureGarments: ['graphic tee'],
            description: 'Bold graphics.', adjacentTo: ['techwear']),
        const Archetype(
            id: 'classic-tailored', name: 'Classic Tailored', handle: 'A suit with somewhere to be',
            oneLiner: 'A well-cut suit.',
            axisSignature: {
              'structured-relaxed': 'structured',
              'muted-graphic': 'muted',
              'classic-directional': 'classic',
            },
            signatureGarments: ['two-button suit'],
            description: 'Clean lines.', adjacentTo: ['ivy-prep']),
      ];
}

Widget _build(MantleDatabase db) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider.overrideWithValue(_FakeMenswearRepository()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: const FieldGuideScreen(memberId: 'anonymous'),
      ),
    );

/// Seed a completed menswear session where the relaxed term wins [wins] times.
Future<void> _seedLean(MantleDatabase db, int wins) async {
  final roundId = secureHexId();
  await db.roundsDao.create(id: roundId, deckVersion: 1, createdAt: DateTime(2026));
  final sid = secureHexId();
  await db.sessionsDao.create(
      id: sid, roundId: roundId, memberId: 'anonymous',
      domain: kMenswearDomainKey, createdAt: DateTime(2026));
  for (var i = 0; i < wins; i++) {
    await db.matchesDao.record(
        sessionId: sid, idA: 'hoodie', idB: 'oxford-shirt', outcome: 'aWins');
  }
}

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('>= 20 relaxed picks names the streetwear archetype', (tester) async {
    await _seedLean(db, 22);
    await db.readProgressDao.markRead('anonymous', 'hoodie', knewIt: false);
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.text('Streetwear'), findsOneWidget);
    // Lexicon shows the learned term.
    expect(find.byKey(const Key('field-guide-lexicon')), findsOneWidget);
    expect(find.text('hoodie'), findsWidgets);
  });

  testWidgets('below the gate shows "keep going", no archetype name',
      (tester) async {
    await _seedLean(db, 5);
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.text('Streetwear'), findsNothing);
    expect(find.byKey(const Key('field-guide-keep-going')), findsOneWidget);
    // Sliders are always shown.
    expect(find.byKey(const Key('field-guide-sliders')), findsOneWidget);
  });
}
