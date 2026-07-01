import 'package:drift/drift.dart';
import '../../../core/db/database.dart';

part 'members_dao.g.dart';

@DriftAccessor(tables: [Members])
class MembersDao extends DatabaseAccessor<MantleDatabase>
    with _$MembersDaoMixin {
  MembersDao(super.db);

  /// Insert a new member.
  Future<void> add({
    required String id,
    required String label,
    required int color,
    required DateTime createdAt,
  }) async {
    await into(members).insert(
      MembersCompanion.insert(
        id: id,
        label: label,
        color: color,
        createdAt: createdAt,
      ),
    );
  }

  /// Return all members, ordered by creation time ascending.
  Future<List<MemberRow>> all() =>
      (select(members)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();
}
