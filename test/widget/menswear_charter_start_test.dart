import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/ranking/presentation/members_screen.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/menswear_charter_start_screen.dart';
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

Widget _build(MantleDatabase db) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider.overrideWithValue(_FakeMenswearRepository()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: const MenswearCharterStartScreen(),
      ),
    );

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> seedMembers(int n) async {
    for (var i = 0; i < n; i++) {
      await db.membersDao.add(
        id: 'member-$i',
        label: 'Member $i',
        color: OhColors.hearth400.toARGB32(),
        createdAt: DateTime(2026).add(Duration(seconds: i)),
      );
    }
  }

  testWidgets('family-begin is disabled until 2 members are checked',
      (tester) async {
    await seedMembers(2);
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    var btn =
        tester.widget<FilledButton>(find.byKey(const Key('family-begin')));
    expect(btn.onPressed, isNull, reason: 'nothing selected yet');

    await tester.tap(find.byKey(const Key('family-member-member-0')));
    await tester.pump();
    btn = tester.widget<FilledButton>(find.byKey(const Key('family-begin')));
    expect(btn.onPressed, isNull, reason: 'only 1 of 2 selected');

    await tester.tap(find.byKey(const Key('family-member-member-1')));
    await tester.pump();
    btn = tester.widget<FilledButton>(find.byKey(const Key('family-begin')));
    expect(btn.onPressed, isNotNull, reason: '2 selected — Begin unlocks');
  });

  testWidgets(
      'tapping Begin creates a round row and pushes the orchestrator with '
      'the selected members in list order', (tester) async {
    await seedMembers(3);
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('family-member-member-0')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('family-member-member-1')));
    await tester.pump();

    expect((await db.select(db.rounds).get()), isEmpty);

    await tester.tap(find.byKey(const Key('family-begin')));
    await tester.pumpAndSettle();

    expect(find.byType(MenswearFamilyRoundScreen), findsOneWidget);

    final rounds = await db.select(db.rounds).get();
    expect(rounds, hasLength(1));

    final screen = tester
        .widget<MenswearFamilyRoundScreen>(find.byType(MenswearFamilyRoundScreen));
    expect(screen.roundId, rounds.first.id);
    expect(screen.members.map((m) => m.id).toList(), ['member-0', 'member-1'],
        reason: 'only the checked members, in list order — member-2 excluded');
  });

  testWidgets(
      'with 0 members, the add-people affordance shows and Begin is absent',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('family-add-members')), findsOneWidget);
    expect(find.byKey(const Key('family-begin')), findsNothing);
  });

  testWidgets(
      'with 1 member, the add-people affordance shows and Begin is absent',
      (tester) async {
    await seedMembers(1);
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('family-add-members')), findsOneWidget);
    expect(find.byKey(const Key('family-begin')), findsNothing);
  });

  testWidgets('family-add-members pushes the existing MembersScreen',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('family-add-members')));
    await tester.pumpAndSettle();

    expect(find.byType(MembersScreen), findsOneWidget);
  });
}
