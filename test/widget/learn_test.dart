import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/learn_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

const _term = MenswearTerm(
  id: 'polo',
  facet: 'garment',
  term: 'Polo shirt',
  handle: 'the tennis shirt',
  gloss: 'A collared knit pullover.',
  quickRead: 'A collared short-sleeve shirt.',
  closerRead: 'The soft folded collar and piqué knit are the tells.',
  axisSignals: [],
  plateHint: '',
);

Widget _build(MantleDatabase db) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: const LearnScreen(
            items: [_term], memberId: 'anonymous', spotQuestions: []),
      ),
    );

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('shows quickRead first, reveals closerRead on tap', (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.text(_term.quickRead), findsOneWidget);
    expect(find.text(_term.closerRead), findsNothing);

    await tester.tap(find.byKey(const Key('learn-reveal')));
    await tester.pumpAndSettle();

    expect(find.text(_term.closerRead), findsOneWidget);
  });

  testWidgets('adding to lexicon writes a ReadProgress row', (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('learn-reveal')));
    await tester.pumpAndSettle();
    // Revealing the closer-read card pushes this button below the default
    // test viewport (800x600); scroll it into view before tapping, mirroring
    // read_test.dart's handling of the same SingleChildScrollView pattern.
    await tester.ensureVisible(find.byKey(const Key('learn-add-to-lexicon')));
    await tester.tap(find.byKey(const Key('learn-add-to-lexicon')));
    await tester.pumpAndSettle();

    final rows = await db.readProgressDao.progressForMember('anonymous');
    expect(rows, hasLength(1));
    expect(rows.first.itemId, 'polo');
  });

  testWidgets('never labels the plain reading as lesser', (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    final texts = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => (t.data ?? '').toLowerCase());
    for (final t in texts) {
      for (final w in const ['better', 'boring', 'basic', 'wrong']) {
        expect(t.contains(w), isFalse, reason: 'found "$w" in "$t"');
      }
    }
  });
}
