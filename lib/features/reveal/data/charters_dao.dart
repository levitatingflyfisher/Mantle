import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/database.dart';
import '../../../core/utils/id.dart';
import '../domain/reveal.dart';
import '../domain/throughline_namer.dart';

part 'charters_dao.g.dart';

@DriftAccessor(tables: [Charters])
class ChartersDao extends DatabaseAccessor<MantleDatabase>
    with _$ChartersDaoMixin {
  ChartersDao(super.db);

  Future<Charter> createFromReveal(
    String roundId,
    List<RevealItem> spine,
    List<RevealItem> contested,
    List<NamedThroughline> throughlines, {
    DateTime? createdAt,
  }) async {
    final id = secureHexId();
    final now = createdAt ?? DateTime.now();
    await into(charters).insert(ChartersCompanion.insert(
      id: id,
      roundId: roundId,
      createdAt: now,
      spineItemIds: jsonEncode(spine.map((i) => i.id).toList()),
      throughlines: jsonEncode(throughlines.map((t) => t.key).toList()),
      contestedItemIds: jsonEncode(contested.map((i) => i.id).toList()),
    ));
    return (select(charters)..where((t) => t.id.equals(id))).getSingle();
  }

  Future<void> updateCharter({
    required String id,
    String? houseName,
    String? motto,
    Map<String, String>? bodyOverrides,
  }) async {
    await (update(charters)..where((t) => t.id.equals(id))).write(
      ChartersCompanion(
        houseName:
            houseName != null ? Value(houseName) : const Value.absent(),
        motto: motto != null ? Value(motto) : const Value.absent(),
        bodyOverrides: bodyOverrides != null
            ? Value(jsonEncode(bodyOverrides))
            : const Value.absent(),
      ),
    );
  }

  Future<Charter?> byId(String id) async {
    final rows = await (select(charters)
          ..where((t) => t.id.equals(id))
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }

  Future<Charter?> latest() async {
    final rows = await (select(charters)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(1))
        .get();
    return rows.isEmpty ? null : rows.first;
  }
}
