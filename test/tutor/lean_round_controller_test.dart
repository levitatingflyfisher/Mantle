import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/field_guide_screen.dart';
import 'package:mantle/features/tutor/presentation/lean_round_controller.dart';
import 'package:mantle/features/tutor/presentation/lean_round_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

MenswearTerm _t(String id) => MenswearTerm(
      id: id, facet: 'garment', term: id, handle: null, gloss: '',
      quickRead: '', closerRead: '', axisSignals: const [], plateHint: '');

class _FakeMenswearRepository extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async =>
      [for (final id in MenswearRepository.leanPoolIds) _t(id)];
  @override
  Future<List<MenswearTerm>> leanPool() async =>
      [for (final id in MenswearRepository.leanPoolIds) _t(id)];
}

Widget _build(MantleDatabase db, {String memberId = 'anonymous', String? roundId}) =>
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider.overrideWithValue(_FakeMenswearRepository()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: LeanRoundScreen(memberId: memberId, roundId: roundId),
      ),
    );

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('reaches pairing and shows two term choices', (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    final element = tester.element(find.byType(LeanRoundScreen));
    final container = ProviderScope.containerOf(element);
    final state = container.read(
        leanRoundControllerProvider((memberId: 'anonymous', roundId: null)));
    expect(state.phase, LeanRoundPhase.pairing);
    expect(find.byKey(const Key('lean-choose-A')), findsOneWidget);
    expect(find.byKey(const Key('lean-choose-B')), findsOneWidget);
  });

  testWidgets('a pick persists exactly one match row and increments pickCount',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
        tester.element(find.byType(LeanRoundScreen)));
    final controller = container.read(leanRoundControllerProvider(
            (memberId: 'anonymous', roundId: null))
        .notifier);

    await controller.chooseA();
    await tester.pump();

    final rows = await db.select(db.rankingMatches).get();
    expect(rows, hasLength(1));
    expect(rows.first.outcome, 'aWins');
    expect(
        container
            .read(leanRoundControllerProvider(
                (memberId: 'anonymous', roundId: null)))
            .pickCount,
        1);
  });

  testWidgets('double-tap guard: two concurrent chooseA -> one row',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    final controller = ProviderScope
        .containerOf(tester.element(find.byType(LeanRoundScreen)))
        .read(leanRoundControllerProvider(
                (memberId: 'anonymous', roundId: null))
            .notifier);

    await Future.wait([controller.chooseA(), controller.chooseA()]);
    await tester.pump();

    expect((await db.select(db.rankingMatches).get()), hasLength(1));
  });

  testWidgets('completes after kLeanPickTarget picks and marks session complete',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
        tester.element(find.byType(LeanRoundScreen)));
    final controller = container.read(leanRoundControllerProvider(
            (memberId: 'anonymous', roundId: null))
        .notifier);

    for (var i = 0; i < kLeanPickTarget; i++) {
      await controller.chooseA();
      await tester.pump();
    }
    expect(
        container
            .read(leanRoundControllerProvider(
                (memberId: 'anonymous', roundId: null)))
            .phase,
        LeanRoundPhase.complete);
    final sessions = await db.select(db.rankingSessions).get();
    expect(sessions, hasLength(1));
    expect(sessions.first.isComplete, isTrue);
    expect(sessions.first.domain, kMenswearDomainKey);
  });

  testWidgets(
      'shared roundId: two members complete under the SAME round, no extra round row created',
      (tester) async {
    const sharedRoundId = 'shared-round-id';
    await db.roundsDao
        .create(id: sharedRoundId, deckVersion: 1, createdAt: DateTime(2026));

    await tester.pumpWidget(_build(db,
        memberId: 'parentA', roundId: sharedRoundId));
    await tester.pumpAndSettle();
    final containerA = ProviderScope.containerOf(
        tester.element(find.byType(LeanRoundScreen)));
    final controllerA = containerA.read(leanRoundControllerProvider(
            (memberId: 'parentA', roundId: sharedRoundId))
        .notifier);
    for (var i = 0; i < kLeanPickTarget; i++) {
      await controllerA.chooseA();
      await tester.pump();
    }

    // Force a full teardown of parentA's ProviderScope/Navigator before
    // mounting parentB's screen. A same-type MaterialApp-rooted tree swap
    // via pumpWidget alone reuses elements (Navigator caches its initial
    // route), which would otherwise leave parentA's controller alive
    // alongside parentB's and corrupt this test's session count.
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();

    await tester.pumpWidget(_build(db,
        memberId: 'parentB', roundId: sharedRoundId));
    await tester.pumpAndSettle();
    final containerB = ProviderScope.containerOf(
        tester.element(find.byType(LeanRoundScreen)));
    final controllerB = containerB.read(leanRoundControllerProvider(
            (memberId: 'parentB', roundId: sharedRoundId))
        .notifier);
    for (var i = 0; i < kLeanPickTarget; i++) {
      await controllerB.chooseA();
      await tester.pump();
    }

    final sessions = await db.select(db.rankingSessions).get();
    expect(sessions, hasLength(2));
    expect(sessions.every((s) => s.roundId == sharedRoundId), isTrue);
    expect(sessions.every((s) => s.domain == kMenswearDomainKey), isTrue);

    final rounds = await db.select(db.rounds).get();
    expect(rounds, hasLength(1));
  });

  testWidgets('onComplete callback fires instead of navigating to Field Guide',
      (tester) async {
    const sharedRoundId = 'callback-round-id';
    await db.roundsDao
        .create(id: sharedRoundId, deckVersion: 1, createdAt: DateTime(2026));

    var called = false;
    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider.overrideWithValue(_FakeMenswearRepository()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: LeanRoundScreen(
          memberId: 'anonymous',
          roundId: sharedRoundId,
          onComplete: () => called = true,
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final container = ProviderScope.containerOf(
        tester.element(find.byType(LeanRoundScreen)));
    final controller = container.read(leanRoundControllerProvider(
            (memberId: 'anonymous', roundId: sharedRoundId))
        .notifier);

    for (var i = 0; i < kLeanPickTarget; i++) {
      await controller.chooseA();
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('lean-continue')), findsOneWidget);
    expect(find.byKey(const Key('lean-see-field-guide')), findsNothing);

    await tester.tap(find.byKey(const Key('lean-continue')));
    await tester.pumpAndSettle();

    expect(called, isTrue);
    expect(find.byType(FieldGuideScreen), findsNothing);
  });
}
