import 'package:drift/drift.dart';

import '../../../core/db/database.dart';

part 'spot_progress_dao.g.dart';

@DriftAccessor(tables: [SpotProgress])
class SpotProgressDao extends DatabaseAccessor<MantleDatabase>
    with _$SpotProgressDaoMixin {
  SpotProgressDao(super.db);

  /// Record an attempt on [questionId] for [memberId].
  ///
  /// Increments [seenCount] always; increments [correctCount] only when
  /// [correct] is true. Uses a single atomic upsert so the first attempt
  /// auto-creates the row and subsequent attempts increment the counters
  /// without a separate read-then-write.
  Future<void> recordAttempt(
    String memberId,
    String questionId, {
    required bool correct,
  }) async {
    await into(spotProgress).insert(
      SpotProgressCompanion.insert(
        memberId: memberId,
        questionId: questionId,
        seenCount: const Value(1),
        correctCount: Value(correct ? 1 : 0),
      ),
      onConflict: DoUpdate.withExcluded(
        (old, excluded) => SpotProgressCompanion.custom(
          seenCount: old.seenCount + const Constant(1),
          correctCount: old.correctCount +
              (correct ? const Constant(1) : const Constant(0)),
        ),
      ),
    );
  }

  /// Returns all spot-progress rows for [memberId].
  Future<List<SpotProgressData>> progressForMember(String memberId) =>
      (select(spotProgress)
            ..where((t) => t.memberId.equals(memberId)))
          .get();
}
