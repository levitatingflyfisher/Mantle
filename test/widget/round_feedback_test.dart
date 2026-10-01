// test/widget/round_feedback_test.dart
//
// Audit finding 9: a tap on a plate produced nothing before the write
// returned (bare GestureDetector, no press mark, no chosen state, no
// haptic), so a registered pick and a missed one looked the same. The
// chosen plate is now marked in the very next frame, with a selection
// click, before the pair changes.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  testWidgets('a pick is marked at once, with a selection click',
      (tester) async {
    final db = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await db.membersDao.add(
        id: 'm1', label: 'Aria', color: 0xFF4CAF50, createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2', label: 'Ben', color: 0xFF2196F3, createdAt: DateTime(2026, 2));

    final haptics = <String>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') {
        haptics.add(call.arguments as String);
      }
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null));

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_Deck()),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: const RoundScreen()),
    ));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('plate-chosen-a')), findsNothing);
    await tester.tap(find.byKey(const Key('image-tile-a')));
    await tester.pump(); // one frame: no waiting on the write
    expect(find.byKey(const Key('plate-chosen-a')), findsOneWidget,
        reason: 'the chosen plate is marked before the pair changes');
    expect(haptics, contains('HapticFeedbackType.selectionClick'));

    await tester.pumpAndSettle();
    expect(find.text('Architecture · 1 of $kDecisionsPerDomain'), findsOneWidget);
    expect(find.byKey(const Key('plate-chosen-a')), findsNothing,
        reason: 'the next pair starts unmarked');
  });

  // The beat between the mark and the write must not let a pick land on a
  // different pair: Skip (or Undo) inside the beat cancels the pending pick.
  testWidgets('Skip inside the beat cancels the pending pick', (tester) async {
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

    await tester.tap(find.byKey(const Key('image-tile-a')));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(find.text('Skip this pair'));
    await tester.pumpAndSettle();

    expect(find.text('Architecture · 0 of $kDecisionsPerDomain'), findsOneWidget,
        reason: 'the pick was cancelled, not recorded on the next pair');
    expect(await tester.runAsync(() => db.select(db.rankingMatches).get()),
        isEmpty);
  });
}
