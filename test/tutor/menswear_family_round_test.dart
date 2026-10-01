import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/lean_round_controller.dart';
import 'package:mantle/features/tutor/presentation/menswear_charter_screen.dart';
import 'package:mantle/features/tutor/presentation/menswear_family_round_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

MenswearTerm _t(String id) => MenswearTerm(
    id: id,
    facet: 'garment',
    term: id,
    handle: null,
    gloss: '',
    quickRead: '',
    closerRead: '',
    axisSignals: const [],
    plateHint: '');

class _FakeMenswearRepository extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async =>
      [for (final id in MenswearRepository.leanPoolIds) _t(id)];
  @override
  Future<List<MenswearTerm>> leanPool() async =>
      [for (final id in MenswearRepository.leanPoolIds) _t(id)];
}

Widget _build(MantleDatabase db, List<MemberRow> members, String roundId) =>
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider.overrideWithValue(_FakeMenswearRepository()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: MenswearFamilyRoundScreen(members: members, roundId: roundId),
      ),
    );

/// Drives [controller] through a full lean round (picking A every time) then
/// taps the resulting "Continue" button, mirroring how `LeanRoundScreen`
/// wires `onComplete` to a user tap rather than firing it automatically.
Future<void> _completeAndContinue(
    WidgetTester tester, LeanRoundController controller) async {
  for (var i = 0; i < kLeanPickTarget; i++) {
    await controller.chooseA();
    await tester.pump();
  }
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('lean-continue')), findsOneWidget);
  await tester.tap(find.byKey(const Key('lean-continue')));
  await tester.pumpAndSettle();
}

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets(
      'two-member handoff drives both members and lands on the Charter with '
      'two sessions under one shared round', (tester) async {
    const roundId = 'family-round-1';
    await db.roundsDao
        .create(id: roundId, deckVersion: 1, createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm1',
        label: 'Alice',
        color: OhColors.hearth400.toARGB32(),
        createdAt: DateTime(2026, 1, 1));
    await db.membersDao.add(
        id: 'm2',
        label: 'Bob',
        color: OhColors.sage500.toARGB32(),
        createdAt: DateTime(2026, 1, 2));
    final members = await db.membersDao.all();
    expect(members, hasLength(2));

    await tester.pumpWidget(_build(db, members, roundId));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
        tester.element(find.byType(MenswearFamilyRoundScreen)));

    // Drive member 0 (Alice) to completion.
    final controllerA = container.read(leanRoundControllerProvider(
            (memberId: members[0].id, roundId: roundId))
        .notifier);
    await _completeAndContinue(tester, controllerA);

    // Completing member 0 must land on the handoff interstitial, not the
    // Charter — there's still a member left to run.
    expect(find.byKey(const Key('family-handoff-continue')), findsOneWidget);
    expect(find.byType(MenswearCharterScreen), findsNothing);

    await tester.tap(find.byKey(const Key('family-handoff-continue')));
    await tester.pumpAndSettle();

    // Drive member 1 (Bob) to completion.
    final controllerB = container.read(leanRoundControllerProvider(
            (memberId: members[1].id, roundId: roundId))
        .notifier);
    await _completeAndContinue(tester, controllerB);

    // The last member's completion must land on the shared Wardrobe Charter.
    expect(find.byType(MenswearCharterScreen), findsOneWidget);

    final sessions = await db.select(db.rankingSessions).get();
    expect(sessions, hasLength(2));
    expect(sessions.every((s) => s.roundId == roundId), isTrue);
    expect(sessions.every((s) => s.domain == kMenswearDomainKey), isTrue);
    expect(sessions.map((s) => s.memberId).toSet(), {'m1', 'm2'});

    final rounds = await db.select(db.rounds).get();
    expect(rounds, hasLength(1),
        reason: 'the orchestrator must reuse the pre-created round, not '
            'create a second one per member');
  });
}
