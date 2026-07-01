import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/core/utils/id.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/menswear_charter_controller.dart';
import 'package:mantle/features/tutor/presentation/menswear_charter_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

MenswearTerm _t(String id, List<List<String>> sig) => MenswearTerm(
      id: id, facet: 'garment', term: id, handle: null, gloss: '',
      quickRead: '', closerRead: '',
      axisSignals: [for (final s in sig) AxisSignal(axis: s[0], pole: s[1])],
      plateHint: '');

// A pool of 8 real `leanPoolIds` (axisSignals mirror assets/data/menswear.json):
//  - 3 shared favorites both members agree on (structured/classic).
//  - 1 favorite unique to each member, on OPPOSITE poles of both the
//    classic-directional and muted-graphic axes, so the two members'
//    picks genuinely conflict rather than merely differing in degree.
//  - 3 shared items both members dislike (relaxed).
final _pool = <MenswearTerm>[
  _t('oxford-shirt', [['structured-relaxed', 'structured'], ['classic-directional', 'classic']]),
  _t('peacoat', [['structured-relaxed', 'structured'], ['classic-directional', 'classic']]),
  _t('derby', [['structured-relaxed', 'structured'], ['classic-directional', 'classic']]),
  _t('field-jacket-m65', [['classic-directional', 'classic'], ['muted-graphic', 'muted']]),
  _t('chunky-dad-sneaker', [['classic-directional', 'directional'], ['muted-graphic', 'graphic']]),
  _t('hoodie', [['structured-relaxed', 'relaxed']]),
  _t('puffer', [['structured-relaxed', 'relaxed']]),
  _t('low-top-sneaker', [['structured-relaxed', 'relaxed']]),
];
const _sharedWinners = ['oxford-shirt', 'peacoat', 'derby'];
const _sharedLosers = ['hoodie', 'puffer', 'low-top-sneaker'];

/// Member A's clear favorite (classic/muted) — member B's clear least-favorite.
const _memberAFavorite = 'field-jacket-m65';

/// Member B's clear favorite (directional/graphic) — member A's clear
/// least-favorite. The mirror image of [_memberAFavorite].
const _memberBFavorite = 'chunky-dad-sneaker';

class _FakeMenswearRepository extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async => _pool;
  @override
  Future<List<MenswearTerm>> leanPool() async => _pool;
}

/// Seed a member's session with a strict tier-dominance order: every item in
/// an earlier tier beats every item in every later tier (no matches within a
/// tier, so within-tier order is unconstrained — we only rely on cross-tier
/// separation). This gives [topPick] the #1 rank and [bottomPick] the last
/// rank, with the shared winners/losers occupying the middle tiers
/// identically for every member.
Future<void> _seedMember(MantleDatabase db, String roundId, String memberId,
    {required String topPick, required String bottomPick}) async {
  final sid = secureHexId();
  await db.sessionsDao.create(
      id: sid, roundId: roundId, memberId: memberId,
      domain: kMenswearDomainKey, createdAt: DateTime(2026));
  final tiers = [
    [topPick],
    _sharedWinners,
    _sharedLosers,
    [bottomPick],
  ];
  for (var hi = 0; hi < tiers.length; hi++) {
    for (var lo = hi + 1; lo < tiers.length; lo++) {
      for (final w in tiers[hi]) {
        for (final l in tiers[lo]) {
          await db.matchesDao
              .record(sessionId: sid, idA: w, idB: l, outcome: 'aWins');
        }
      }
    }
  }
}

Widget _build(MantleDatabase db, String roundId) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider.overrideWithValue(_FakeMenswearRepository()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: MenswearCharterScreen(roundId: roundId),
      ),
    );

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets(
      'two DIVERGENT members merge into an agreed Spine and a genuine '
      'Contested set', (tester) async {
    final roundId = secureHexId();
    await db.roundsDao.create(id: roundId, deckVersion: 1, createdAt: DateTime(2026));
    // Member A ranks field-jacket-m65 top and chunky-dad-sneaker last.
    await _seedMember(db, roundId, 'member-1',
        topPick: _memberAFavorite, bottomPick: _memberBFavorite);
    // Member B is the mirror image: chunky-dad-sneaker top, field-jacket-m65
    // last. If only ONE of these two members were seeded, the divergent item
    // would land in the Spine (it's that member's clear favorite) and
    // Contested would be empty — exactly the gap this test closes.
    await _seedMember(db, roundId, 'member-2',
        topPick: _memberBFavorite, bottomPick: _memberAFavorite);

    await tester.pumpWidget(_build(db, roundId));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
        tester.element(find.byType(MenswearCharterScreen)));
    final state = container.read(menswearCharterControllerProvider(roundId));

    expect(state.status, MenswearCharterStatus.ready);
    // 3 genuine candidates (the shared winners) clear the Spine gate.
    expect(state.spineIsFallback, isFalse);

    // The Spine holds what BOTH members agree on...
    final spineIds = state.spine.map((i) => i.id).toList();
    expect(spineIds, containsAll(_sharedWinners));
    // ...and excludes the two items the members fight over. This is the
    // assertion the old identical-member seeding could never produce: with
    // only one member seeded, [_memberAFavorite] (that member's undisputed
    // #1 pick) lands in the Spine instead.
    expect(spineIds, isNot(contains(_memberAFavorite)));
    expect(spineIds, isNot(contains(_memberBFavorite)));

    // Contested holds exactly the items the members disagree on — non-empty
    // only because the two members' picks genuinely diverge.
    final contestedIds = state.contested.map((i) => i.id).toList();
    expect(contestedIds, containsAll([_memberAFavorite, _memberBFavorite]));

    // The through-line reflects the MERGED axis position: both members
    // independently favor the shared structured/classic pieces, so the
    // house still leans structured & classic even though they clash on the
    // muted/graphic and classic/directional extremes.
    final poles = state.throughlinePoles.map((p) => p.pole).toList();
    expect(poles, contains('structured'));
    expect(poles, contains('classic'));
    // This pair is what makes the through-line assertion merge-sensitive
    // (not just true-in-either-member-alone): member A's 'muted' wins and
    // member B's 'graphic' wins are equal in count, so they cancel to a net
    // position of 0 on the muted-graphic axis and NEITHER pole clears the
    // threshold. With only one member seeded, that member's pole (muted, or
    // graphic) would appear instead.
    expect(poles, isNot(contains('muted')));
    expect(poles, isNot(contains('graphic')));

    expect(find.byKey(const Key('menswear-charter-spine')), findsOneWidget);
    // The Contested section only renders when state.contested is non-empty.
    expect(find.text('Where the House Argues'), findsOneWidget);
    expect(find.text(_memberAFavorite), findsOneWidget);
    expect(find.text(_memberBFavorite), findsOneWidget);
  });
}
