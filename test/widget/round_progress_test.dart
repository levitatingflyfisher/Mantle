// test/widget/round_progress_test.dart
//
// dmmt-04 / doet-06: the round computed "done of total" and hid it in a
// screen-reader value while the bar under the domain name measured the
// whole round. The count for the current domain is printed beside its name,
// and the bar's label says it is the whole round.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/content/domain/throughline.dart';
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
  testWidgets('the domain count is visible beside the domain name',
      (tester) async {
    final db = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.membersDao.add(
        id: 'm1', label: 'Aria', color: 0xFF4CAF50, createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2', label: 'Ben', color: 0xFF2196F3, createdAt: DateTime(2026, 2));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_Deck()),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: const RoundScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Architecture · 0 of $kDecisionsPerDomain'), findsOneWidget);

    await tester.tap(find.byKey(const Key('image-tile-a')));
    await tester.pumpAndSettle();
    expect(find.text('Architecture · 1 of $kDecisionsPerDomain'), findsOneWidget);

    final bar = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator));
    expect(bar.semanticsLabel, 'Whole round');
    expect(bar.semanticsValue, '1 of ${3 * kDecisionsPerDomain}');
  });

  // Finding 2 / persona H2: the bar measured the whole round with nothing to
  // say where one domain ends. Ticks at the domain boundaries let one mark do
  // both jobs.
  testWidgets('the round bar is ticked at each domain boundary',
      (tester) async {
    final db = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.membersDao.add(
        id: 'm1', label: 'Aria', color: 0xFF4CAF50, createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2', label: 'Ben', color: 0xFF2196F3, createdAt: DateTime(2026, 2));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_Deck()),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: const RoundScreen()),
    ));
    await tester.pumpAndSettle();

    final bar = tester.getRect(find.byType(LinearProgressIndicator));
    final n = Domain.values.length;
    for (var i = 1; i < n; i++) {
      final tick = find.byKey(Key('round-domain-tick-$i'));
      expect(tick, findsOneWidget);
      final r = tester.getRect(tick);
      expect(r.center.dx, closeTo(bar.left + bar.width * i / n, 1.5));
      expect(r.height, greaterThan(bar.height),
          reason: 'a tick stands proud of the track, so it reads as a mark');
    }
    expect(find.byKey(Key('round-domain-tick-$n')), findsNothing);
  });
}
