// test/ranking/round_controller_test.dart
//
// Regression test for the double-tap race in RoundController._record.
//
// Before the fix, two rapid chooseA() calls before the first await completed
// would both pass the `_processing` guard (it wasn't set yet), causing
// service.recordDecision() + _matchesDao.record() to execute twice for the
// same pair — producing duplicate rows in RankingMatches and corrupting ELO.
//
// After the fix, a `bool _processing` guard at the very top of _record ensures
// only one call executes at a time. This test drives two concurrent chooseA()
// calls (via Future.wait, no intermediate await) and asserts that exactly ONE
// match row is written to the DB.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/ranking/presentation/round_controller.dart';
import 'package:mantle/features/ranking/presentation/round_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Fake ContentRepository ────────────────────────────────────────────────────

/// 24-image deterministic deck (8 per domain) — no asset bundle needed.
class _FakeContentRepository extends ContentRepository {
  static final _deck = [
    for (final domain in Domain.values)
      for (var i = 0; i < 8; i++)
        DeckImage(
          id: '${domain.name}_$i',
          domain: domain,
          assetPath: 'assets/images/deck/${domain.name}_$i.jpg',
          features: [],
          throughlines: [],
          license: 'CC0',
          institution: 'Test',
          sourceUrl: '',
          title: 'Test $i',
          accessionId: '${domain.name}_$i',
          creator: 'Test',
        ),
  ];

  @override
  Future<List<DeckImage>> deck() async => _deck;
}

// ── Test helpers ──────────────────────────────────────────────────────────────

Widget _buildRoundScreen(MantleDatabase db) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      contentRepositoryProvider.overrideWithValue(_FakeContentRepository()),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: const RoundScreen(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('RoundController double-tap guard', () {
    testWidgets(
      'two simultaneous chooseA() calls produce exactly one match row',
      (tester) async {
        // Seed two members so _init can proceed.
        await db.membersDao.add(
          id: 'member-1',
          label: 'Alice',
          color: OhColors.hearth400.toARGB32(),
          createdAt: DateTime(2026, 1, 1),
        );
        await db.membersDao.add(
          id: 'member-2',
          label: 'Bob',
          color: OhColors.sage500.toARGB32(),
          createdAt: DateTime(2026, 1, 1),
        );

        await tester.pumpWidget(_buildRoundScreen(db));
        await tester.pumpAndSettle();

        // Locate the controller via ProviderScope.
        final element = tester.element(find.byType(RoundScreen));
        final container = ProviderScope.containerOf(element);
        final controller =
            container.read(roundControllerProvider.notifier);

        // Verify we're in pairing phase before the double-tap test.
        expect(
          container.read(roundControllerProvider).phase,
          RoundPhase.pairing,
          reason: '_init must have completed; controller must be in pairing',
        );

        // Fire two chooseA() concurrently — simulating a fast double-tap.
        // Future.wait starts both without awaiting the first.
        await Future.wait([
          controller.chooseA(),
          controller.chooseA(),
        ]);
        await tester.pump();

        // Count how many match rows were written.
        final allMatches = await db.select(db.rankingMatches).get();
        expect(
          allMatches.length,
          1,
          reason:
              'Exactly one match row must be written even when two chooseA() '
              'calls fire concurrently. The _processing guard must have dropped '
              'the second call.',
        );
      },
    );
  });
}
