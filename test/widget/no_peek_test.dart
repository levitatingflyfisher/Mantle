// test/widget/no_peek_test.dart
//
// The load-bearing no-peek regression test.
//
// Guards verified:
//   (a) No individual-result screen reachable during a sitting.
//   (b) Hand-off interstitial appears between members.
//   (c) Merged reveal route is gated until all members are complete.
//
// Strategy: pump RoundScreen with 2 pre-seeded members (no network, in-memory
// DB, fake ContentRepository with deterministic deck). Drive member 1 through
// all 3 domains × 12 decisions via the controller directly (72 taps would work
// but takes very long in a test runner; we call controller methods and pump the
// widget so the assertions are on the rendered tree). After member 1 completes:
//   - Key('handoff-interstitial') must be present.
//   - Key('reveal-spine') must NOT be present.
//   - controller.allMembersComplete must be false.

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

/// Returns a fully deterministic 24-image deck (8/domain) so tests never
/// touch the asset bundle.
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

  testWidgets(
    'no individual results shown mid-sitting; reveal gated until all complete',
    (tester) async {
      // ── Seed 2 members directly in the DB ────────────────────────────────
      await db.membersDao.add(
        id: 'member-1',
        label: 'Alice',
        color: OhColors.hearth400.toARGB32(),
        createdAt: DateTime(2026, 1, 1, 10, 0),
      );
      await db.membersDao.add(
        id: 'member-2',
        label: 'Bob',
        color: OhColors.sage500.toARGB32(),
        createdAt: DateTime(2026, 1, 1, 10, 1),
      );

      await tester.pumpWidget(_buildRoundScreen(db));
      await tester.pumpAndSettle();

      // The screen should have loaded and show the first pair.
      // Locate the RoundController via the ProviderContainer.
      final element = tester.element(find.byType(RoundScreen));
      final container = ProviderScope.containerOf(element);
      final controller = container.read(roundControllerProvider.notifier);

      // ── Complete member 1 across all 3 domains via the controller ────────
      // Drive 12 decisions × 3 domains = 36 decisions for member 1.
      // _record() auto-advances the domain on the 12th decision of each domain,
      // so we must NOT call advanceDomain() — that would double-advance and
      // skip a domain entirely. We rely solely on the auto-advance in _record().
      for (var domainIdx = 0; domainIdx < 3; domainIdx++) {
        for (var decision = 0; decision < 12; decision++) {
          await controller.chooseA(); // forced choice: always pick A
          await tester.pump();
        }
        // No advanceDomain() call here — _record() auto-advanced on decision 12.
      }

      // Member 1's three domains are now complete.
      await tester.pumpAndSettle();

      // ── Guard (b): hand-off interstitial must be visible ─────────────────
      expect(
        find.byKey(const Key('handoff-interstitial')),
        findsOneWidget,
        reason:
            'Hand-off interstitial must appear after member 1 finishes and '
            'before member 2 begins',
      );

      // ── Guard (a): no results/spine widget reachable ─────────────────────
      expect(
        find.byKey(const Key('reveal-spine')),
        findsNothing,
        reason:
            'No individual result or spine widget must be visible mid-sitting',
      );

      // ── Guard (c): reveal gated until all members complete ────────────────
      final state = container.read(roundControllerProvider);
      expect(
        state.allMembersComplete,
        isFalse,
        reason:
            'allMembersComplete must be false until member 2 also finishes',
      );

      // ── Guard (d): all 3 of member 1's domain sessions are complete ───────
      // This proves no domain was skipped (the double-advance foot-gun is gone).
      final member1Sessions = await (db.select(db.rankingSessions)
            ..where((t) => t.memberId.equals('member-1')))
          .get();
      expect(
        member1Sessions.length,
        equals(3),
        reason: 'Member 1 must have exactly 3 domain sessions (one per domain)',
      );
      for (final session in member1Sessions) {
        expect(
          session.isComplete,
          isTrue,
          reason:
              'All 3 of member 1\'s domain sessions must be complete — '
              'domain "${session.domain}" was not marked complete, '
              'indicating a domain was skipped by double-advancing',
        );
      }
    },
  );
}
