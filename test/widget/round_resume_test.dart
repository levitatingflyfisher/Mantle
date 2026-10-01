// test/widget/round_resume_test.dart
//
// Audit finding 8: every visit to the round minted a new round, so a round
// left part-way (dinner, a child waking) was lost and had to start again.
// Every pick is already stored, so a round is resumed by replaying its
// matches; Home offers Continue, and the round bar has Pause. A round is
// picked up only for the same people: if anyone was added or removed since,
// a fresh round starts and says why in one line.

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
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:mantle/features/ranking/domain/round_service.dart';
import 'package:mantle/features/ranking/presentation/round_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

class _Deck extends ContentRepository {
  @override
  Future<List<DeckImage>> deck() async => [
        for (final d in Domain.values)
          for (var i = 0; i < 8; i++)
            DeckImage(
              id: '${d.name}_$i',
              domain: d,
              assetPath: 'assets/images/deck/missing_${d.name}_$i.jpg',
              features: const [],
              throughlines: const [],
              license: 'CC0',
              institution: 'Test',
              sourceUrl: '',
              title: 'Plate $i',
              accessionId: '${d.name}_$i',
              creator: 'Test',
            ),
      ];

  @override
  Future<List<Throughline>> throughlines() async => const [];
}

void main() {
  late MantleDatabase db;

  setUp(() async {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
    await db.membersDao.add(
        id: 'm1', label: 'Aria', color: 0xFF4CAF50, createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2', label: 'Ben', color: 0xFF2196F3, createdAt: DateTime(2026, 2));
  });
  tearDown(() => db.close());

  Widget app(Widget home) => ProviderScope(
        overrides: [
          databaseProvider.overrideWithValue(db),
          contentRepositoryProvider.overrideWithValue(_Deck()),
          themePreferenceProvider
              .overrideWith((ref) async => ThemePreference.light),
        ],
        child: MaterialApp(theme: OhTheme.light(), home: home),
      );

  /// Opens the round from a plain page, so Pause has somewhere to go back to.
  Future<void> openRound(WidgetTester tester, {bool resume = false}) async {
    await tester.pumpWidget(app(Builder(
      builder: (context) => Scaffold(
        body: TextButton(
          onPressed: () => Navigator.push<void>(
            context,
            MaterialPageRoute<void>(
                builder: (_) => RoundScreen(resume: resume)),
          ),
          child: const Text('go'),
        ),
      ),
    )));
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  /// A fresh app on Home, as after the app was closed and reopened.
  Future<void> home(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(app(const HomeScreen()));
    await tester.pumpAndSettle();
  }

  Future<void> pick(WidgetTester tester, int times) async {
    for (var i = 0; i < times; i++) {
      await tester.tap(find.byKey(const Key('image-tile-a')));
      await tester.pumpAndSettle();
    }
  }

  testWidgets('Pause leaves the round; Home offers Continue; Continue picks '
      'up at the same pick', (tester) async {
    await openRound(tester);
    await pick(tester, 3);
    expect(find.text('Architecture · 3 of $kDecisionsPerDomain'),
        findsOneWidget);

    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    expect(find.text('go'), findsOneWidget, reason: 'Pause went back');

    await home(tester);
    expect(find.text('Continue the round'), findsOneWidget);
    expect(find.text('Aria is 3 of $kDecisionsPerDomain into Architecture.'),
        findsOneWidget);
    expect(
        tester.getTopLeft(find.text('Continue the round')).dy,
        lessThan(tester.getTopLeft(find.text('Start a round')).dy),
        reason: 'the unfinished round is the first thing offered');

    await tester.tap(find.text('Continue the round'));
    await tester.pumpAndSettle();
    expect(find.text('Architecture · 3 of $kDecisionsPerDomain'),
        findsOneWidget);
    expect(find.text('Aria'), findsWidgets);

    // The resumed round is the same round: no second one was minted.
    expect(await db.select(db.rounds).get(), hasLength(1));
    await pick(tester, 1);
    expect(find.text('Architecture · 4 of $kDecisionsPerDomain'),
        findsOneWidget);
  });

  testWidgets('with a person added since, Home says the round was set aside '
      'and the round starts fresh', (tester) async {
    await openRound(tester);
    await pick(tester, 2);
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();

    await db.membersDao.add(
        id: 'm3', label: 'Cleo', color: 0xFFFF9800, createdAt: DateTime(2026, 3));

    await home(tester);
    expect(find.text('Continue the round'), findsNothing);
    expect(
        find.text('Your unfinished round was set aside: the people have '
            'changed since.'),
        findsOneWidget);

    // Asked to resume anyway (a stale Continue): start fresh, say why.
    await openRound(tester, resume: true);
    expect(find.text('Architecture · 0 of $kDecisionsPerDomain'),
        findsOneWidget);
    expect(find.textContaining('the people have changed'), findsOneWidget);
    expect(await db.select(db.rounds).get(), hasLength(2));
  });

  testWidgets('a round whose first person finished resumes at the hand-off, '
      'not inside the next person\'s turn', (tester) async {
    await openRound(tester);
    await pick(tester, 3 * kDecisionsPerDomain);
    expect(find.textContaining('Ben'), findsWidgets,
        reason: 'the hand-off names the next person');
    await home(tester);
    expect(find.text('Ben’s turn is next.'), findsOneWidget);

    await tester.tap(find.text('Continue the round'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pass'), findsWidgets,
        reason: 'no peeking: the device is handed over first');
  });

  testWidgets('a finished round, or one with no picks, offers nothing',
      (tester) async {
    await openRound(tester);
    await tester.tap(find.text('Pause'));
    await tester.pumpAndSettle();
    await home(tester);
    expect(find.text('Continue the round'), findsNothing);
    expect(find.textContaining('set aside'), findsNothing);
  });
}
