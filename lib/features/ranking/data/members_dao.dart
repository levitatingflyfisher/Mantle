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

  /// Active members (not removed), ordered by creation time ascending.
  Future<List<MemberRow>> all() => (select(members)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .get();

  /// Removed members, most recently removed first, for "Recently removed".
  Future<List<MemberRow>> removed() => (select(members)
        ..where((t) => t.deletedAt.isNotNull())
        ..orderBy([(t) => OrderingTerm.desc(t.deletedAt)]))
      .get();

  /// Rename and/or recolour a member in place.
  Future<void> edit(String id, {String? label, int? color}) async {
    await (update(members)..where((t) => t.id.equals(id))).write(
      MembersCompanion(
        label: label != null ? Value(label) : const Value.absent(),
        color: color != null ? Value(color) : const Value.absent(),
      ),
    );
  }

  /// Soft-delete: the member leaves every list and round but the row stays,
  /// with their past rounds and progress (which reference them by id), until
  /// [restore] or [deleteForever]. Returns the row, or null if not active.
  Future<MemberRow?> remove(String id) async {
    final row = await (select(members)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .getSingleOrNull();
    if (row == null) return null;
    await (update(members)..where((t) => t.id.equals(id)))
        .write(MembersCompanion(deletedAt: Value(DateTime.now())));
    return row;
  }

  /// Bring a removed member back, in their original place in the list.
  Future<void> restore(String id) async {
    await (update(members)..where((t) => t.id.equals(id)))
        .write(const MembersCompanion(deletedAt: Value(null)));
  }

  /// Permanently delete a member who has already been removed. An active
  /// member is left alone.
  Future<void> deleteForever(String id) async {
    await (delete(members)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNotNull()))
        .go();
  }
}
