import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/tutor/content/domain/menswear_spot_question.dart';
import 'package:mantle/features/tutor/presentation/menswear_spot_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

const _q = MenswearSpotQuestion(
  id: 'ms-spot-01',
  facet: 'garment',
  promptText: 'Which is the henley?',
  plateA: 'henley',
  plateB: 'polo',
  correctSide: 'A',
  explanation: 'The buttoned placket with no collar is the tell.',
);

Widget _build(MantleDatabase db) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: const MenswearSpotScreen(
            questions: [_q], memberId: 'anonymous'),
      ),
    );

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('tapping the correct plate reveals the explanation and records',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ms-spot-explanation')), findsNothing);
    await tester.tap(find.byKey(const Key('ms-spot-plate-A')));
    await tester.pumpAndSettle();

    expect(find.text(_q.explanation), findsOneWidget);
    final rows = await db.spotProgressDao.progressForMember('anonymous');
    expect(rows, hasLength(1));
    expect(rows.first.questionId, 'ms-spot-01');
    expect(rows.first.seenCount, 1);
    expect(rows.first.correctCount, 1);
  });

  testWidgets('wrong plate records an attempt with correctCount 0',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('ms-spot-plate-B')));
    await tester.pumpAndSettle();
    final rows = await db.spotProgressDao.progressForMember('anonymous');
    expect(rows.first.correctCount, 0);
  });
}
