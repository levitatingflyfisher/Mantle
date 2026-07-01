import 'package:drift/drift.dart';
import '../../../core/db/database.dart';

part 'rounds_dao.g.dart';

@DriftAccessor(tables: [Rounds])
class RoundsDao extends DatabaseAccessor<MantleDatabase> with _$RoundsDaoMixin {
  RoundsDao(super.db);

  /// Insert a new round and return the persisted row.
  Future<Round> create({
    required String id,
    required int deckVersion,
    required DateTime createdAt,
  }) async {
    await into(rounds).insert(
      RoundsCompanion.insert(
        id: id,
        deckVersion: deckVersion,
        createdAt: createdAt,
      ),
    );
    return (select(rounds)..where((t) => t.id.equals(id))).getSingle();
  }
}
