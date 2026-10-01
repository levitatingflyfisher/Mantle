// test/widget/round_undo_test.dart
//
// Audit finding 5: chooseA/chooseB wrote the match and advanced in one
// frame, with no undo, so a mis-pick in a 36-tap rhythm became the
// Charter. "Undo that" (a fixed control beside Skip) takes the last pick
// back: the pair returns, the count drops, and its stored match is gone.

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

Future<String> _plateId(WidgetTester tester, String key) async {
  // The plates' placeholder tiles carry the image id as text.
  final tile = find.byKey(Key(key));
  final texts = find.descendant(of: tile, matching: find.byType(Text));
  return texts.evaluate().map((e) => (e.widget as Text).data ?? '').join();
}

void main() {
  testWidgets('Undo that brings the last pair back and forgets the pick',
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

    TextButton undo() => tester.widget<TextButton>(find.ancestor(
        of: find.text('Undo that'),
        matching: find.byWidgetPredicate((w) => w is TextButton)));
    expect(undo().onPressed, isNull, reason: 'nothing to undo yet');

    final firstA = await _plateId(tester, 'image-tile-a');
    final firstB = await _plateId(tester, 'image-tile-b');
    await tester.tap(find.byKey(const Key('image-tile-a')));
    await tester.pumpAndSettle();
    expect(find.text('Architecture · 1 of $kDecisionsPerDomain'), findsOneWidget);
    expect(await tester.runAsync(() => db.select(db.rankingMatches).get()),
        hasLength(1));

    await tester.tap(find.text('Undo that'));
    await tester.pumpAndSettle();
    expect(find.text('Architecture · 0 of $kDecisionsPerDomain'), findsOneWidget);
    expect(await _plateId(tester, 'image-tile-a'), firstA);
    expect(await _plateId(tester, 'image-tile-b'), firstB);
    expect(await tester.runAsync(() => db.select(db.rankingMatches).get()),
        isEmpty, reason: 'the undone pick never reaches the Charter');
    expect(undo().onPressed, isNull);
  });
}
