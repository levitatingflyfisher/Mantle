import 'package:drift/drift.dart';
import '../../../core/db/database.dart';

part 'sessions_dao.g.dart';

@DriftAccessor(tables: [RankingSessions])
class SessionsDao extends DatabaseAccessor<MantleDatabase>
    with _$SessionsDaoMixin {
  SessionsDao(super.db);

  /// Insert a new ranking session. Defaults: isComplete=false, resultsLocked=true.
  Future<void> create({
    required String id,
    required String roundId,
    required String memberId,
    required String domain,
    required DateTime createdAt,
  }) async {
    await into(rankingSessions).insert(
      RankingSessionsCompanion.insert(
        id: id,
        roundId: roundId,
        memberId: memberId,
        domain: domain,
        createdAt: createdAt,
        // isComplete defaults to false, resultsLocked defaults to true per schema
      ),
    );
  }

  /// Flip [isComplete] to true. Does NOT touch [resultsLocked].
  Future<void> markComplete(String sessionId) async {
    await (update(rankingSessions)..where((t) => t.id.equals(sessionId)))
        .write(const RankingSessionsCompanion(isComplete: Value(true)));
  }

  /// Return all sessions belonging to [roundId].
  Future<List<RankingSession>> forRound(String roundId) =>
      (select(rankingSessions)
            ..where((t) => t.roundId.equals(roundId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();
}
