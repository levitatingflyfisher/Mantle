// lib/features/ranking/data/unfinished_round.dart
//
// Finds a household round left part-way so it can be picked up again
// (audit finding 8). Nothing new is stored: every pick is already a row in
// ranking_matches, so the round is rebuilt by replaying them.

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../content/domain/domain.dart';
import '../domain/round_service.dart';

/// Where an unfinished round stands, for a given order of members.
class RoundPosition {
  const RoundPosition({
    required this.memberIndex,
    required this.domainIndex,
    required this.decisions,
    required this.atHandoff,
  });

  /// At the hand-off: [memberIndex] is the member who finished; the next
  /// one has not started. Otherwise the member whose turn it is.
  final int memberIndex;
  final int domainIndex;

  /// Picks already made in [domainIndex] (0 at a hand-off).
  final int decisions;
  final bool atHandoff;
}

/// The newest household round, when it is neither finished nor untouched.
class UnfinishedRound {
  UnfinishedRound._(this.roundId, this.sessions, this.matches);

  final String roundId;

  /// (memberId, domain name) → session.
  final Map<(String, String), RankingSession> sessions;

  /// Session id → its picks, in the order they were made.
  final Map<String, List<RankingMatch>> matches;

  Set<String> get memberIds => {for (final k in sessions.keys) k.$1};

  /// True when [currentMemberIds] are exactly the round's people. Only then
  /// is it resumed; a round for other people starts fresh.
  bool isFor(Iterable<String> currentMemberIds) =>
      memberIds.length == currentMemberIds.toSet().length &&
      memberIds.containsAll(currentMemberIds);

  /// Where the round stands for [memberOrder] (ids, the round's order).
  RoundPosition position(List<String> memberOrder) {
    for (var mi = 0; mi < memberOrder.length; mi++) {
      for (var di = 0; di < Domain.values.length; di++) {
        final s = sessions[(memberOrder[mi], Domain.values[di].name)]!;
        if (s.isComplete) continue;
        final made = matches[s.id]?.length ?? 0;
        if (mi > 0 && di == 0 && made == 0) {
          return RoundPosition(
              memberIndex: mi - 1,
              domainIndex: Domain.values.length - 1,
              decisions: 0,
              atHandoff: true);
        }
        return RoundPosition(
            memberIndex: mi, domainIndex: di, decisions: made, atHandoff: false);
      }
    }
    // Unreachable for an unfinished round.
    return const RoundPosition(
        memberIndex: 0, domainIndex: 0, decisions: 0, atHandoff: false);
  }
}

/// The newest household round, if it was left part-way. A round that is
/// complete, or that nobody has made a pick in, is not offered.
Future<UnfinishedRound?> findUnfinishedRound(MantleDatabase db) async {
  final rounds = await (db.select(db.rounds)
        ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
      .get();
  final household = {for (final d in Domain.values) d.name};
  for (final round in rounds) {
    final sessions = await db.sessionsDao.forRound(round.id);
    // The menswear tutor's rounds share the table; skip them.
    if (sessions.isEmpty ||
        !sessions.every((s) => household.contains(s.domain))) {
      continue;
    }
    if (sessions.every((s) => s.isComplete)) return null;
    final matches = <String, List<RankingMatch>>{};
    var total = 0;
    for (final s in sessions) {
      // decidedAt is stored to the second; rowid keeps picks made within
      // one second in the order they were made, which the replay needs.
      final rows = await (db.select(db.rankingMatches)
            ..where((t) => t.sessionId.equals(s.id))
            ..orderBy([
              (t) => OrderingTerm.asc(t.decidedAt),
              (_) => OrderingTerm.asc(const CustomExpression<int>('rowid')),
            ]))
          .get();
      matches[s.id] = rows;
      total += rows.length;
    }
    if (total == 0) return null;
    return UnfinishedRound._(
      round.id,
      {for (final s in sessions) (s.memberId, s.domain): s},
      matches,
    );
  }
  return null;
}

/// What Home offers about an unfinished round.
class RoundResumeOffer {
  const RoundResumeOffer.continueWith(this.line) : peopleChanged = false;
  const RoundResumeOffer.setAside()
      : line = 'Your unfinished round was set aside: the people have '
            'changed since.',
        peopleChanged = true;

  /// Where it stands ("Aria is 8 of 12 into Tailoring."), or why it is not
  /// offered.
  final String line;
  final bool peopleChanged;
}

String domainLabel(Domain d) => switch (d) {
      Domain.architecture => 'Architecture',
      Domain.tailoring => 'Tailoring',
      Domain.interiors => 'Interiors',
    };

final roundResumeOfferProvider =
    FutureProvider.autoDispose<RoundResumeOffer?>((ref) async {
  final db = ref.watch(databaseProvider);
  final round = await findUnfinishedRound(db);
  if (round == null) return null;
  final members = await db.membersDao.all();
  if (!round.isFor(members.map((m) => m.id))) {
    return const RoundResumeOffer.setAside();
  }
  final order = [for (final m in members) m.id];
  final p = round.position(order);
  if (p.atHandoff) {
    return RoundResumeOffer.continueWith(
        '${members[p.memberIndex + 1].label}’s turn is next.');
  }
  return RoundResumeOffer.continueWith(
      '${members[p.memberIndex].label} is ${p.decisions} of '
      '$kDecisionsPerDomain into '
      '${domainLabel(Domain.values[p.domainIndex])}.');
});
