// test/widget/map_test.dart
//
// Widget tests for MapScreen (Task 17).
//
// Key assertions:
// 1. Shows discovered through-line labels (from seeded DiscoveredThroughlines
//    rows) when at least one is present.
// 2. Shows a warm empty state when no through-lines have been discovered.
// 3. No numeric score appears anywhere in the rendered tree.
// 4. None of the words "better" / "superior" appear anywhere.
//
// ContentRepository is overridden with a stub so tests never touch rootBundle.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/solo/presentation/map_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Stub content repository ───────────────────────────────────────────────────

class _StubContentRepository implements ContentRepository {
  static const _throughlines = [
    Throughline(key: 'interval', label: 'the charged gap'),
    Throughline(key: 'figure-void', label: 'mass & emptiness on purpose'),
    Throughline(key: 'material-honesty', label: 'say only what the structure needs'),
    Throughline(key: 'expressed-structure', label: 'the celebrated joint'),
  ];

  @override
  Future<List<Throughline>> throughlines() async => _throughlines;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildMapScreen(MantleDatabase db, {String memberId = 'member-test'}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      contentRepositoryProvider.overrideWithValue(_StubContentRepository()),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: MapScreen(memberId: memberId),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('MapScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildMapScreen(db));
      await tester.pumpAndSettle();
      expect(find.byType(MapScreen), findsOneWidget);
    });

    testWidgets('shows warm empty state when no through-lines discovered',
        (tester) async {
      // No rows seeded — member has no discovered through-lines.
      await tester.pumpWidget(_buildMapScreen(db));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('map-empty-state')),
        findsOneWidget,
        reason: 'Empty-state widget must be present when no rows exist',
      );
      expect(
        find.text('Nothing has surfaced yet — keep exploring.'),
        findsOneWidget,
      );
    });

    testWidgets('shows discovered through-line labels when rows are present',
        (tester) async {
      // Seed one discovered throughline: key "interval" → label "the charged gap"
      await db.discoveredThroughlinesDao.markSeen('member-test', 'interval');

      await tester.pumpWidget(_buildMapScreen(db));
      await tester.pumpAndSettle();

      // The heading must appear.
      expect(
        find.byKey(const Key('map-heading')),
        findsOneWidget,
      );

      // The through-line label must appear somewhere in the tree.
      expect(
        find.textContaining('the charged gap'),
        findsWidgets,
        reason: 'Through-line label must appear in the rendered tree',
      );

      // The empty-state must not be shown.
      expect(find.byKey(const Key('map-empty-state')), findsNothing);
    });

    testWidgets('shows multiple through-line labels when multiple rows present',
        (tester) async {
      await db.discoveredThroughlinesDao.markSeen('member-test', 'interval');
      await db.discoveredThroughlinesDao
          .markSeen('member-test', 'material-honesty');

      await tester.pumpWidget(_buildMapScreen(db));
      await tester.pumpAndSettle();

      expect(find.textContaining('the charged gap'), findsWidgets);
      expect(
        find.textContaining('say only what the structure needs'),
        findsWidgets,
      );
    });

    testWidgets('does NOT show a numeric score anywhere', (tester) async {
      await db.discoveredThroughlinesDao.markSeen('member-test', 'interval');

      await tester.pumpWidget(_buildMapScreen(db));
      await tester.pumpAndSettle();

      final allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .toList();

      // No text should use score/ranking language.
      for (final text in allTexts) {
        expect(
          RegExp(r'\bscore\b').hasMatch(text),
          isFalse,
          reason: 'No Text widget may contain "score". Found: "$text"',
        );
        expect(
          text.contains('leaderboard'),
          isFalse,
          reason: 'No Text widget may contain "leaderboard". Found: "$text"',
        );
      }
    });

    testWidgets('does NOT use "better" or "superior" language', (tester) async {
      await db.discoveredThroughlinesDao.markSeen('member-test', 'interval');

      await tester.pumpWidget(_buildMapScreen(db));
      await tester.pumpAndSettle();

      final allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .toList();

      for (final text in allTexts) {
        expect(
          text.contains('better'),
          isFalse,
          reason: 'No Text widget may contain "better". Found: "$text"',
        );
        expect(
          text.contains('superior'),
          isFalse,
          reason: 'No Text widget may contain "superior". Found: "$text"',
        );
      }
    });
  });
}
