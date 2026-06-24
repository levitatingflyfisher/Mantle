// test/widget/spot_test.dart
//
// Widget tests for SpotScreen (Task 16).
//
// Key assertions:
// 1. Both plates are rendered side by side.
// 2. Tapping a plate reveals the explanation card.
// 3. SpotGrading.grade is reflected in the result label.
// 4. Tapping the correct side shows "That's the one."
// 5. Tapping the incorrect side shows "Not quite —".
// 6. Progress is persisted to SpotProgress after answering.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/content/domain/spot_question.dart';
import 'package:mantle/features/solo/presentation/spot_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Fixture data ──────────────────────────────────────────────────────────────

const _qA = SpotQuestion(
  id: 'spot-001',
  domain: Domain.architecture,
  featureId: 'canon-001',
  promptText: 'Which shows a higher gorge line?',
  plateA: 'arch_high_gorge',
  plateB: 'arch_low_gorge',
  correctSide: 'A',
  explanation: 'The left plate shows the gorge cut high, above the break line.',
);

const _qB = SpotQuestion(
  id: 'spot-002',
  domain: Domain.tailoring,
  featureId: 'canon-002',
  promptText: 'Which shows more waist suppression?',
  plateA: 'tail_minimal_waist',
  plateB: 'tail_suppressed_waist',
  correctSide: 'B',
  explanation: 'The right plate has a visible, shaped waist seam.',
);

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildSpotScreen(
  MantleDatabase db, {
  List<SpotQuestion> questions = const [_qA],
  String memberId = 'member-test',
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: SpotScreen(
        questions: questions,
        memberId: memberId,
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

  group('SpotScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();
      expect(find.byType(SpotScreen), findsOneWidget);
    });

    testWidgets('shows prompt text', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      expect(find.text(_qA.promptText), findsOneWidget);
    });

    testWidgets('shows both plate options before answering', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('spot-plate-A')), findsOneWidget);
      expect(find.byKey(const Key('spot-plate-B')), findsOneWidget);
    });

    testWidgets('explanation is hidden before answering', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('spot-explanation')), findsNothing);
    });

    testWidgets('tapping a plate reveals explanation', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('spot-explanation')), findsOneWidget);
      expect(find.text(_qA.explanation), findsOneWidget);
    });

    testWidgets('correct choice shows "That\'s the one." label',
        (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      // _qA.correctSide == 'A'
      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      expect(find.text("That's the one."), findsOneWidget);
    });

    testWidgets('incorrect choice shows "Not quite —" label', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      // _qA.correctSide == 'A', so B is wrong
      await tester.tap(find.byKey(const Key('spot-plate-B')));
      await tester.pumpAndSettle();

      expect(find.text('Not quite —'), findsOneWidget);
    });

    testWidgets('correct answer on correctSide==B is graded right',
        (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db, questions: [_qB]));
      await tester.pumpAndSettle();

      // _qB.correctSide == 'B'
      await tester.tap(find.byKey(const Key('spot-plate-B')));
      await tester.pumpAndSettle();

      expect(find.text("That's the one."), findsOneWidget);
    });

    testWidgets('wrong answer on correctSide==B is graded wrong',
        (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db, questions: [_qB]));
      await tester.pumpAndSettle();

      // _qB.correctSide == 'B', so A is wrong
      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      expect(find.text('Not quite —'), findsOneWidget);
    });

    testWidgets('answering persists seenCount to SpotProgress', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      final rows =
          await db.spotProgressDao.progressForMember('member-test');
      expect(rows, hasLength(1));
      expect(rows.first.questionId, equals(_qA.id));
      expect(rows.first.seenCount, equals(1));
    });

    testWidgets('correct answer increments correctCount', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      // correctSide == 'A'
      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      final rows =
          await db.spotProgressDao.progressForMember('member-test');
      expect(rows.first.correctCount, equals(1));
    });

    testWidgets('wrong answer does not increment correctCount', (tester) async {
      await tester.pumpWidget(_buildSpotScreen(db));
      await tester.pumpAndSettle();

      // correctSide == 'A', so tapping B is wrong
      await tester.tap(find.byKey(const Key('spot-plate-B')));
      await tester.pumpAndSettle();

      final rows =
          await db.spotProgressDao.progressForMember('member-test');
      expect(rows.first.correctCount, equals(0));
    });

    // Regression test for the dead-code counter bug: on the second visit to
    // the same question seenCount must be 2, not reset to 1.
    test('recordAttempt increments seenCount on second attempt', () async {
      final dao = db.spotProgressDao;

      await dao.recordAttempt('member-test', _qA.id, correct: true);
      await dao.recordAttempt('member-test', _qA.id, correct: false);

      final rows = await dao.progressForMember('member-test');
      expect(rows, hasLength(1));
      expect(rows.first.seenCount, equals(2),
          reason: 'second attempt must increment seenCount to 2, not reset to 1');
      expect(rows.first.correctCount, equals(1),
          reason: 'only the first attempt was correct');
    });

    testWidgets('Next button appears after answering (multi-question)',
        (tester) async {
      await tester.pumpWidget(
          _buildSpotScreen(db, questions: [_qA, _qB]));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('spot-next-button')), findsNothing);

      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('spot-next-button')), findsOneWidget);
    });

    testWidgets('tapping Next advances to the next question', (tester) async {
      await tester.pumpWidget(
          _buildSpotScreen(db, questions: [_qA, _qB]));
      await tester.pumpAndSettle();

      // Answer first question.
      await tester.tap(find.byKey(const Key('spot-plate-A')));
      await tester.pumpAndSettle();

      // Advance.
      await tester.tap(find.byKey(const Key('spot-next-button')));
      await tester.pumpAndSettle();

      // Second question's prompt should now show.
      expect(find.text(_qB.promptText), findsOneWidget);
      expect(find.text(_qA.promptText), findsNothing);
    });
  });
}
