import 'package:drift/drift.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

import '../../../core/db/database.dart';

/// Serializes Mantle's user data to/from a JSON [Uint8List] for encrypted
/// backup via `sanctuary_backup_ui`.
///
/// Implements the package's [BackupSerializer] interface directly over
/// [MantleDatabase]: every user table (members, rounds, sessions, matches,
/// charters, and the three solo/tutor progress tables) is dumped in full —
/// Mantle bundles no per-user catalog rows, so unlike Lilt there is nothing
/// to exclude. The bundled deck/canon/menswear content lives in assets, never
/// in the database.
class MantleBackupSerializer
    implements BackupSerializer, PreviewableBackupSerializer {
  static const String _appId = 'mantle';

  final MantleDatabase _db;

  const MantleBackupSerializer(this._db);

  /// Dumps all eight user tables under the fleet-standard envelope
  /// (`{app, schemaVersion, createdAt, payload: {tables: {...}}}`,
  /// BACKUP_RETENTION_SPEC §2.F). Mantle is greenfield — no shipped legacy
  /// shape to stay compatible with — so it adopts the canonical
  /// [BackupEnvelope.wrap] shape outright.
  @override
  Future<Uint8List> dumpAll() async {
    final members = await _db.select(_db.members).get();
    final rounds = await _db.select(_db.rounds).get();
    final sessions = await _db.select(_db.rankingSessions).get();
    // Ranking is replayed from match history in recorded order; restore
    // re-inserts in list order, so make the dump order explicit rather than
    // relying on a bare SELECT's incidental rowid order.
    final matches = await (_db.select(_db.rankingMatches)
          ..orderBy([(t) => OrderingTerm.asc(t.decidedAt)]))
        .get();
    final charters = await _db.select(_db.charters).get();
    final spotProgress = await _db.select(_db.spotProgress).get();
    final readProgress = await _db.select(_db.readProgress).get();
    final discovered = await _db.select(_db.discoveredThroughlines).get();

    return BackupEnvelope.wrap(
      appId: _appId,
      schemaVersion: _db.schemaVersion,
      createdAt: DateTime.now(),
      payload: {
        'tables': {
          'members': members.map((r) => r.toJson()).toList(),
          'rounds': rounds.map((r) => r.toJson()).toList(),
          'rankingSessions': sessions.map((r) => r.toJson()).toList(),
          'rankingMatches': matches.map((r) => r.toJson()).toList(),
          'charters': charters.map((r) => r.toJson()).toList(),
          'spotProgress': spotProgress.map((r) => r.toJson()).toList(),
          'readProgress': readProgress.map((r) => r.toJson()).toList(),
          'discoveredThroughlines':
              discovered.map((r) => r.toJson()).toList(),
        },
      },
    );
  }

  /// The dry-run parse behind preview-before-restore and export
  /// verify-by-read-back: validates exactly like [restoreAll] (wrong app,
  /// future schema, missing tables) and reports row counts — never writes.
  @override
  Future<BackupManifest> describeBackup(Uint8List plaintext) async {
    final tables = _requireTables(_unwrap(plaintext).payload);
    final base = BackupEnvelope.describe(plaintext);
    // The generic describe only counts lists directly under `payload` (or a
    // top-level `tables`) — it does not traverse the nested `payload.tables`
    // map this app emits, so build the counts from the gated tables map.
    return BackupManifest(
      appId: base.appId,
      schemaVersion: base.schemaVersion,
      createdAt: base.createdAt,
      tableCounts: {
        for (final entry in tables.entries)
          if (entry.value is List) entry.key: (entry.value as List).length,
      },
    );
  }

  /// Every table [restoreAll] wipes — and therefore every key a backup must
  /// carry before the wipe is allowed to happen.
  static const List<String> _expectedTables = [
    'members',
    'rounds',
    'rankingSessions',
    'rankingMatches',
    'charters',
    'spotProgress',
    'readProgress',
    'discoveredThroughlines',
  ];

  /// The payload-content gate [restoreAll] applies — shared so describe and
  /// restore can never drift apart (the Sundial/Lullaby pattern).
  ///
  /// Looks for `tables` in the unwrapped payload and requires all eight
  /// expected table keys to be present: restore wipes every table, so a
  /// backup silently missing one key would destructively empty that table
  /// while looking like a success. An empty table is spelled as a present
  /// key with an empty list, never an absent key. Because
  /// [BackupEnvelope.unwrap] falls back to the whole envelope map when there
  /// is no `payload` key, a `{app, schemaVersion, exportedAt, tables}` blob
  /// (the fleet's legacy spelling) restores here too.
  static Map<String, dynamic> _requireTables(Map<String, Object?> payload) {
    final tables = payload['tables'];
    if (tables is! Map<String, dynamic>) {
      throw const FormatException('Missing tables in backup payload');
    }
    for (final key in _expectedTables) {
      if (!tables.containsKey(key)) {
        throw FormatException('Missing table “$key” in backup payload');
      }
    }
    return tables;
  }

  UnwrappedBackup _unwrap(Uint8List data) => BackupEnvelope.unwrap(
        data,
        expectedAppId: _appId,
        currentSchemaVersion: _db.schemaVersion,
      );

  /// Restores all user data from a payload previously produced by [dumpAll].
  ///
  /// **Destructive:** wipes all eight tables and re-inserts from the backup
  /// inside a single transaction — never a partial restore (SANCTUARY-BRIEF
  /// §2.5). All validation happens before the transaction opens: a rejected
  /// restore must never touch existing data (fail closed, §2.4/§2.8).
  ///
  /// Throws [FormatException] for a malformed envelope, a mismatched `app`,
  /// or missing `schemaVersion`/`tables`; throws [BackupSchemaException]
  /// when the backup's schema version is newer than this build understands.
  @override
  Future<void> restoreAll(Uint8List data) async {
    final tables = _requireTables(_unwrap(data).payload);

    await _db.transaction(() async {
      // Wipe children before parents (matches, sessions, charters reference
      // rounds/members; progress tables reference members). Mantle's schema
      // declares no SQL FK constraints, but the order is kept FK-safe so a
      // future `references()` migration doesn't break restore.
      await _db.delete(_db.rankingMatches).go();
      await _db.delete(_db.rankingSessions).go();
      await _db.delete(_db.charters).go();
      await _db.delete(_db.spotProgress).go();
      await _db.delete(_db.readProgress).go();
      await _db.delete(_db.discoveredThroughlines).go();
      await _db.delete(_db.rounds).go();
      await _db.delete(_db.members).go();

      // Insert parents before children.
      for (final row in _jsonList(tables, 'members')) {
        await _db.into(_db.members).insert(MembersCompanion.insert(
              id: row['id'] as String,
              label: row['label'] as String,
              color: row['color'] as int,
              createdAt: _dateTime(row['createdAt']),
              // Absent in schema-1 backups: those members are all active.
              deletedAt: Value(row['deletedAt'] == null
                  ? null
                  : _dateTime(row['deletedAt'])),
            ));
      }

      for (final row in _jsonList(tables, 'rounds')) {
        await _db.into(_db.rounds).insert(RoundsCompanion.insert(
              id: row['id'] as String,
              deckVersion: row['deckVersion'] as int,
              createdAt: _dateTime(row['createdAt']),
            ));
      }

      for (final row in _jsonList(tables, 'rankingSessions')) {
        await _db
            .into(_db.rankingSessions)
            .insert(RankingSessionsCompanion.insert(
              id: row['id'] as String,
              roundId: row['roundId'] as String,
              memberId: row['memberId'] as String,
              domain: row['domain'] as String,
              isComplete: Value(row['isComplete'] as bool? ?? false),
              resultsLocked: Value(row['resultsLocked'] as bool? ?? true),
              createdAt: _dateTime(row['createdAt']),
            ));
      }

      for (final row in _jsonList(tables, 'rankingMatches')) {
        await _db
            .into(_db.rankingMatches)
            .insert(RankingMatchesCompanion.insert(
              id: row['id'] as String,
              sessionId: row['sessionId'] as String,
              idA: row['idA'] as String,
              idB: row['idB'] as String,
              outcome: row['outcome'] as String,
              decidedAt: _dateTime(row['decidedAt']),
            ));
      }

      for (final row in _jsonList(tables, 'charters')) {
        await _db.into(_db.charters).insert(ChartersCompanion.insert(
              id: row['id'] as String,
              roundId: row['roundId'] as String,
              houseName: Value(row['houseName'] as String? ?? ''),
              motto: Value(row['motto'] as String? ?? ''),
              createdAt: _dateTime(row['createdAt']),
              spineItemIds: row['spineItemIds'] as String,
              throughlines: row['throughlines'] as String,
              contestedItemIds: row['contestedItemIds'] as String,
              bodyOverrides: Value(row['bodyOverrides'] as String? ?? '{}'),
            ));
      }

      for (final row in _jsonList(tables, 'spotProgress')) {
        await _db.into(_db.spotProgress).insert(SpotProgressCompanion.insert(
              memberId: row['memberId'] as String,
              questionId: row['questionId'] as String,
              seenCount: Value(row['seenCount'] as int? ?? 0),
              correctCount: Value(row['correctCount'] as int? ?? 0),
            ));
      }

      for (final row in _jsonList(tables, 'readProgress')) {
        await _db.into(_db.readProgress).insert(ReadProgressCompanion.insert(
              memberId: row['memberId'] as String,
              itemId: row['itemId'] as String,
              knewIt: row['knewIt'] as bool,
            ));
      }

      for (final row in _jsonList(tables, 'discoveredThroughlines')) {
        await _db
            .into(_db.discoveredThroughlines)
            .insert(DiscoveredThroughlinesCompanion.insert(
              memberId: row['memberId'] as String,
              throughlineId: row['throughlineId'] as String,
              firstSeenAt: _dateTime(row['firstSeenAt']),
            ));
      }
    });
  }

  List<Map<String, dynamic>> _jsonList(
    Map<String, dynamic> tables,
    String key,
  ) {
    // _requireTables already guaranteed the key exists; an absent key must
    // never read as "empty" — that is exactly the silent-wipe bug the gate
    // exists to prevent.
    final list = tables[key];
    if (list is! List) {
      throw FormatException('Table “$key” is not a list in backup payload');
    }
    return list.cast<Map<String, dynamic>>();
  }

  /// Drift's default serializer encodes DateTime as Unix milliseconds (int);
  /// tolerate ISO-8601 strings too so hand-repaired plaintext exports load.
  DateTime _dateTime(dynamic value) {
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.parse(value);
    throw FormatException('Cannot parse DateTime from: $value');
  }
}
