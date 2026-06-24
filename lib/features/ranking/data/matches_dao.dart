import 'package:drift/drift.dart';
import '../../../core/db/database.dart';
import '../../../core/utils/id.dart';
import '../domain/round_models.dart';

part 'matches_dao.g.dart';

@DriftAccessor(tables: [RankingMatches])
class MatchesDao extends DatabaseAccessor<MantleDatabase>
    with _$MatchesDaoMixin {
  MatchesDao(super.db);

  /// Record a match outcome and persist it.
  ///
  /// [outcome] must be `'aWins'` or `'bWins'`.
  /// [id] is optional; if omitted, a new ID is generated.
  Future<void> record({
    required String sessionId,
    required String idA,
    required String idB,
    required String outcome,
    DateTime? decidedAt,
    String? id,
  }) async {
    assert(outcome == 'aWins' || outcome == 'bWins', 'outcome must be aWins or bWins, got: $outcome');
    final now = decidedAt ?? DateTime.now();
    final matchId = id ?? secureHexId();
    await into(rankingMatches).insert(
      RankingMatchesCompanion.insert(
        id: matchId,
        sessionId: sessionId,
        idA: idA,
        idB: idB,
        outcome: outcome,
        decidedAt: now,
      ),
    );
  }

  /// Return all matches for [sessionId] as domain [MatchRow] DTOs,
  /// ordered by [decidedAt] ascending.
  Future<List<MatchRow>> forSession(String sessionId) async {
    final rows = await (select(rankingMatches)
          ..where((t) => t.sessionId.equals(sessionId))
          ..orderBy([(t) => OrderingTerm.asc(t.decidedAt)]))
        .get();

    return rows
        .map((r) => MatchRow(
              idA: r.idA,
              idB: r.idB,
              outcome: r.outcome,
              decidedAt: r.decidedAt,
            ))
        .toList();
  }

  /// Batch-load all matches for a list of [sessionIds] in a single query.
  ///
  /// Returns a map keyed by session ID. Sessions with no matches are
  /// represented as empty lists. This avoids an N+1 per-session query on
  /// the reveal hot path.
  Future<Map<String, List<MatchRow>>> forRound(
      List<String> sessionIds) async {
    if (sessionIds.isEmpty) return {};

    final rows = await (select(rankingMatches)
          ..where((t) => t.sessionId.isIn(sessionIds))
          ..orderBy([(t) => OrderingTerm.asc(t.decidedAt)]))
        .get();

    // Pre-populate all session IDs with empty lists so callers never get null.
    final result = <String, List<MatchRow>>{
      for (final id in sessionIds) id: [],
    };

    for (final r in rows) {
      result[r.sessionId]!.add(MatchRow(
        idA: r.idA,
        idB: r.idB,
        outcome: r.outcome,
        decidedAt: r.decidedAt,
      ));
    }

    return result;
  }
}
