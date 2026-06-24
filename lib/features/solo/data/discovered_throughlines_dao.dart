import 'package:drift/drift.dart';

import '../../../core/db/database.dart';

part 'discovered_throughlines_dao.g.dart';

@DriftAccessor(tables: [DiscoveredThroughlines])
class DiscoveredThroughlinesDao extends DatabaseAccessor<MantleDatabase>
    with _$DiscoveredThroughlinesDaoMixin {
  DiscoveredThroughlinesDao(super.db);

  /// Returns all [DiscoveredThroughline] rows for [memberId], ordered by
  /// [firstSeenAt] ascending.
  Future<List<DiscoveredThroughline>> forMember(String memberId) =>
      (select(discoveredThroughlines)
            ..where((t) => t.memberId.equals(memberId))
            ..orderBy([(t) => OrderingTerm.asc(t.firstSeenAt)]))
          .get();

  /// Records that [memberId] encountered [throughlineId].
  ///
  /// If the row already exists the call is a no-op (first-seen date is
  /// preserved — we never update it).
  Future<void> markSeen(String memberId, String throughlineId) =>
      into(discoveredThroughlines).insert(
        DiscoveredThroughlinesCompanion.insert(
          memberId: memberId,
          throughlineId: throughlineId,
          firstSeenAt: DateTime.now(),
        ),
        mode: InsertMode.insertOrIgnore,
      );
}
