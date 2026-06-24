import 'package:drift/drift.dart';

import '../../../core/db/database.dart';

part 'read_progress_dao.g.dart';

@DriftAccessor(tables: [ReadProgress])
class ReadProgressDao extends DatabaseAccessor<MantleDatabase>
    with _$ReadProgressDaoMixin {
  ReadProgressDao(super.db);

  /// Record that [memberId] has read canon item [itemId], with self-report.
  ///
  /// Inserts a new row or replaces an existing one (last-write wins per item).
  Future<void> markRead(
    String memberId,
    String itemId, {
    required bool knewIt,
  }) async {
    await into(readProgress).insertOnConflictUpdate(
      ReadProgressCompanion.insert(
        memberId: memberId,
        itemId: itemId,
        knewIt: knewIt,
      ),
    );
  }

  /// Returns all read-progress rows for [memberId].
  Future<List<ReadProgressData>> progressForMember(String memberId) =>
      (select(readProgress)
            ..where((t) => t.memberId.equals(memberId)))
          .get();
}
