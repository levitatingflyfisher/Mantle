// test/widget/read_test.dart
//
// Widget tests for ReadScreen (Task 15).
//
// Key assertions:
// 1. Both quickRead and closerRead text are present in the rendered tree.
// 2. Neither the word "better" nor "superior" appears anywhere in the tree
//    (tone requirement — neither lens is ranked above the other).
// 3. The plate, term, gloss, and principle are all visible.
// 4. The "Knew it" / "New to me" self-report buttons are present.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/content/domain/canon_item.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/solo/presentation/read_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Fixture data ──────────────────────────────────────────────────────────────

const _item = CanonItem(
  id: 'canon-001',
  domain: Domain.architecture,
  term: 'Poche',
  gloss: 'The solid mass between spaces in a plan.',
  principle: 'Mass gives meaning to void; void gives meaning to mass.',
  quickRead: 'The thick walls and columns you colour in on a plan.',
  closerRead: 'Poche reveals a building\'s structural and spatial logic.',
  echo: Echo(
    toId: 'canon-002',
    note: 'In tailoring, the seam allowance reads as a kind of structural poche.',
  ),
  plate: 'arch_poche',
  throughlines: ['weight', 'figure-void'],
);

const _item2 = CanonItem(
  id: 'canon-002',
  domain: Domain.tailoring,
  term: 'Gorge',
  gloss: 'The seam where collar meets lapel.',
  principle: 'Gorge height changes the visual weight of the chest.',
  quickRead: 'The V-notch at the top of the lapel.',
  closerRead: 'Gorge placement sets the eye\'s entry point into the jacket.',
  echo: Echo(
    toId: 'canon-001',
    note: 'Architecture\'s poche and tailoring\'s seam share the same logic of hidden structure.',
  ),
  plate: 'tail_gorge',
  throughlines: ['proportion'],
);

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildReadScreen(
  MantleDatabase db, {
  List<CanonItem> items = const [_item],
  String memberId = 'member-test',
  int initialIndex = 0,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: ReadScreen(
        items: items,
        memberId: memberId,
        initialIndex: initialIndex,
      ),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('ReadScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();
      expect(find.byType(ReadScreen), findsOneWidget);
    });

    testWidgets('reporting an item records its through-lines for the solo Map',
        (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      final knewIt = find.text('Knew it');
      await tester.ensureVisible(knewIt);
      await tester.pumpAndSettle();
      await tester.tap(knewIt);
      await tester.pumpAndSettle();

      final seen =
          await db.discoveredThroughlinesDao.forMember('member-test');
      expect(
        seen.map((t) => t.throughlineId).toSet(),
        _item.throughlines.toSet(),
        reason: 'reading an item must surface its through-lines on the Map '
            '(markSeen was never called, so Map mode was always empty)',
      );
    });

    testWidgets('shows both quickRead and closerRead text', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      expect(
        find.text(_item.quickRead),
        findsOneWidget,
        reason: 'quickRead body must appear in the rendered tree',
      );
      expect(
        find.text(_item.closerRead),
        findsOneWidget,
        reason: 'closerRead body must appear in the rendered tree',
      );
    });

    testWidgets('neither lens is labelled "better" or "superior"',
        (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      // Collect every Text widget's data.
      final allTexts = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => (t.data ?? '').toLowerCase())
          .toList();

      const forbiddenWords = [
        'better',
        'superior',
        'ugly',
        'wasted',
        'boring',
        'shabby',
      ];

      for (final text in allTexts) {
        for (final word in forbiddenWords) {
          expect(
            text.contains(word),
            isFalse,
            reason: 'No Text widget may contain "$word" — '
                'value judgments are the family\'s output, not the app\'s. '
                'Found: "$text"',
          );
        }
      }
    });

    testWidgets('shows lens labels "Quick read" and "Closer read"',
        (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      expect(find.text('Quick read'), findsOneWidget);
      expect(find.text('Closer read'), findsOneWidget);
    });

    testWidgets('shows term, gloss and principle', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      expect(find.text(_item.term), findsOneWidget);
      expect(find.text(_item.gloss), findsOneWidget);
      expect(find.text(_item.principle), findsOneWidget);
    });

    testWidgets('shows echo note', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      expect(find.text(_item.echo.note), findsOneWidget);
    });

    testWidgets('shows self-report buttons', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('read-knew-it')), findsOneWidget);
      expect(find.byKey(const Key('read-new-to-me')), findsOneWidget);
    });

    testWidgets('"Knew it" button persists to ReadProgress', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('read-knew-it')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('read-knew-it')));
      await tester.pumpAndSettle();

      final rows = await db.readProgressDao.progressForMember('member-test');
      expect(rows, hasLength(1));
      expect(rows.first.itemId, equals(_item.id));
      expect(rows.first.knewIt, isTrue);
    });

    testWidgets('"New to me" button persists to ReadProgress', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.byKey(const Key('read-new-to-me')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('read-new-to-me')));
      await tester.pumpAndSettle();

      final rows = await db.readProgressDao.progressForMember('member-test');
      expect(rows, hasLength(1));
      expect(rows.first.knewIt, isFalse);
    });

    testWidgets('navigates to next item when Next button tapped',
        (tester) async {
      await tester.pumpWidget(_buildReadScreen(
        db,
        items: [_item, _item2],
      ));
      await tester.pumpAndSettle();

      // First item should be shown.
      expect(find.text(_item.term), findsOneWidget);

      // Scroll to and tap next.
      await tester.ensureVisible(find.byKey(const Key('read-next-button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('read-next-button')));
      await tester.pumpAndSettle();

      // Second item should now be shown.
      expect(find.text(_item2.term), findsOneWidget);
      expect(find.text(_item.term), findsNothing);
    });

    testWidgets('no "Next" button when only one item', (tester) async {
      await tester.pumpWidget(_buildReadScreen(db));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('read-next-button')), findsNothing);
    });
  });
}
