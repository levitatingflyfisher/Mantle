import 'dart:convert';

import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

void main() {
  late MantleDatabase db;
  late MantleBackupSerializer serializer;

  final now = DateTime(2026, 7, 17);

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
    serializer = MantleBackupSerializer(db);
  });

  tearDown(() => db.close());

  /// Seeds every user table: one member, one round, one session with two
  /// matches, a charter, and one row in each solo/tutor progress table.
  Future<void> seedData() async {
    await db.into(db.members).insert(MembersCompanion.insert(
          id: 'm1',
          label: 'Alice',
          color: 0xFFCC4400,
          createdAt: now,
        ));
    await db.into(db.rounds).insert(RoundsCompanion.insert(
          id: 'r1',
          deckVersion: 1,
          createdAt: now,
        ));
    await db.into(db.rankingSessions).insert(RankingSessionsCompanion.insert(
          id: 's1',
          roundId: 'r1',
          memberId: 'm1',
          domain: 'interiors',
          isComplete: const Value(true),
          resultsLocked: const Value(false),
          createdAt: now,
        ));
    await db.into(db.rankingMatches).insert(RankingMatchesCompanion.insert(
          id: 'match1',
          sessionId: 's1',
          idA: 'deck-a',
          idB: 'deck-b',
          outcome: 'aWins',
          decidedAt: now,
        ));
    await db.into(db.rankingMatches).insert(RankingMatchesCompanion.insert(
          id: 'match2',
          sessionId: 's1',
          idA: 'deck-c',
          idB: 'deck-a',
          outcome: 'bWins',
          decidedAt: now.add(const Duration(minutes: 1)),
        ));
    await db.into(db.charters).insert(ChartersCompanion.insert(
          id: 'c1',
          roundId: 'r1',
          houseName: const Value('House Test'),
          motto: const Value('Warmth first'),
          createdAt: now,
          spineItemIds: '["deck-a"]',
          throughlines: '["warm-wood"]',
          contestedItemIds: '["deck-b"]',
          bodyOverrides: const Value('{"intro":"custom"}'),
        ));
    await db.into(db.spotProgress).insert(SpotProgressCompanion.insert(
          memberId: 'm1',
          questionId: 'q1',
          seenCount: const Value(3),
          correctCount: const Value(2),
        ));
    await db.into(db.readProgress).insert(ReadProgressCompanion.insert(
          memberId: 'm1',
          itemId: 'item1',
          knewIt: true,
        ));
    await db
        .into(db.discoveredThroughlines)
        .insert(DiscoveredThroughlinesCompanion.insert(
          memberId: 'm1',
          throughlineId: 'warm-wood',
          firstSeenAt: now,
        ));
  }

  group('dumpAll', () {
    test('emits the fleet envelope: app, schemaVersion, createdAt, payload',
        () async {
      final bytes = await serializer.dumpAll();
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

      expect(json['app'], equals('mantle'));
      expect(json['schemaVersion'], equals(db.schemaVersion));
      expect(json['createdAt'], isA<String>());
      final payload = json['payload'] as Map<String, dynamic>;
      expect(payload['tables'], isA<Map<String, dynamic>>());
    });

    test('dumps all eight user tables', () async {
      await seedData();
      final bytes = await serializer.dumpAll();
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final tables = (json['payload']
          as Map<String, dynamic>)['tables'] as Map<String, dynamic>;

      expect(tables.keys.toSet(), {
        'members',
        'rounds',
        'rankingSessions',
        'rankingMatches',
        'charters',
        'spotProgress',
        'readProgress',
        'discoveredThroughlines',
      });
      expect(tables['members'], hasLength(1));
      expect(tables['rankingMatches'], hasLength(2));
    });
  });

  group('restoreAll', () {
    test('round-trips every table exactly', () async {
      await seedData();
      final bytes = await serializer.dumpAll();

      await serializer.restoreAll(bytes);

      final members = await db.select(db.members).get();
      expect(members.single.label, equals('Alice'));
      expect(members.single.color, equals(0xFFCC4400));
      expect(members.single.createdAt, equals(now));

      final rounds = await db.select(db.rounds).get();
      expect(rounds.single.deckVersion, equals(1));

      final sessions = await db.select(db.rankingSessions).get();
      expect(sessions.single.domain, equals('interiors'));
      expect(sessions.single.isComplete, isTrue);
      expect(sessions.single.resultsLocked, isFalse);

      final matches = await db.select(db.rankingMatches).get();
      expect(matches.map((m) => m.id).toSet(), {'match1', 'match2'});
      expect(
        matches.firstWhere((m) => m.id == 'match1').outcome,
        equals('aWins'),
      );

      final charters = await db.select(db.charters).get();
      expect(charters.single.houseName, equals('House Test'));
      expect(charters.single.motto, equals('Warmth first'));
      expect(charters.single.spineItemIds, equals('["deck-a"]'));
      expect(charters.single.bodyOverrides, equals('{"intro":"custom"}'));

      final spot = await db.select(db.spotProgress).get();
      expect(spot.single.seenCount, equals(3));
      expect(spot.single.correctCount, equals(2));

      final read = await db.select(db.readProgress).get();
      expect(read.single.knewIt, isTrue);

      final discovered = await db.select(db.discoveredThroughlines).get();
      expect(discovered.single.throughlineId, equals('warm-wood'));
    });

    test('destructively replaces existing data', () async {
      await seedData();

      // A different device's dump: one other member, nothing else.
      final db2 = MantleDatabase.forTesting(NativeDatabase.memory());
      await db2.into(db2.members).insert(MembersCompanion.insert(
            id: 'm-other',
            label: 'Bob',
            color: 0xFF3D82C9,
            createdAt: now,
          ));
      final otherDump = await MantleBackupSerializer(db2).dumpAll();
      await db2.close();

      await serializer.restoreAll(otherDump);

      final members = await db.select(db.members).get();
      expect(members.map((m) => m.id).toList(), ['m-other']);
      expect(await db.select(db.rounds).get(), isEmpty);
      expect(await db.select(db.rankingSessions).get(), isEmpty);
      expect(await db.select(db.rankingMatches).get(), isEmpty);
      expect(await db.select(db.charters).get(), isEmpty);
      expect(await db.select(db.spotProgress).get(), isEmpty);
      expect(await db.select(db.readProgress).get(), isEmpty);
      expect(await db.select(db.discoveredThroughlines).get(), isEmpty);
    });

    test('rejects a backup from a different app', () async {
      final bytes = BackupEnvelope.wrap(
        appId: 'lilt',
        schemaVersion: 1,
        createdAt: now,
        payload: {'tables': <String, dynamic>{}},
      );

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects a future schema version', () async {
      final bytes = BackupEnvelope.wrap(
        appId: 'mantle',
        schemaVersion: 999,
        createdAt: now,
        payload: {'tables': <String, dynamic>{}},
      );

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<BackupSchemaException>()),
      );
    });

    test('rejects a payload with no tables', () async {
      final bytes = BackupEnvelope.wrap(
        appId: 'mantle',
        schemaVersion: 1,
        createdAt: now,
        payload: {'notTables': true},
      );

      expect(
        () => serializer.restoreAll(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test(
        'rejects a well-enveloped backup missing one table key, naming it, '
        'and touches nothing (a silent wipe of that table is the bug)',
        () async {
      await seedData();

      final dump = await serializer.dumpAll();
      final envelope =
          jsonDecode(utf8.decode(dump)) as Map<String, dynamic>;
      final tables = (envelope['payload']
          as Map<String, dynamic>)['tables'] as Map<String, dynamic>;
      tables.remove('readProgress');
      final truncated = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));

      await expectLater(
        () => serializer.restoreAll(truncated),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('readProgress'),
        )),
      );

      expect(await db.select(db.readProgress).get(), hasLength(1),
          reason: 'the table absent from the backup must NOT be emptied');
      expect(await db.select(db.members).get(), hasLength(1));
    });

    test(
        'a legitimate empty-table backup (key present, empty list) '
        'still restores', () async {
      await seedData();

      final freshDb = MantleDatabase.forTesting(NativeDatabase.memory());
      final emptyDump = await MantleBackupSerializer(freshDb).dumpAll();
      await freshDb.close();

      await serializer.restoreAll(emptyDump);

      expect(await db.select(db.members).get(), isEmpty);
      expect(await db.select(db.readProgress).get(), isEmpty);
      expect(await db.select(db.rankingMatches).get(), isEmpty);
    });

    test('a rejected restore never touches existing data (fail closed)',
        () async {
      await seedData();

      final bad = BackupEnvelope.wrap(
        appId: 'mantle',
        schemaVersion: 999,
        createdAt: now,
        payload: {'tables': <String, dynamic>{}},
      );

      await expectLater(
        () => serializer.restoreAll(bad),
        throwsA(isA<BackupSchemaException>()),
      );

      expect(await db.select(db.members).get(), hasLength(1),
          reason: 'original data must survive a rejected restore');
      expect(await db.select(db.rankingMatches).get(), hasLength(2));
    });

    test(
        'restores the legacy fleet spelling — top-level tables, exportedAt, '
        'no payload key (wire-compat: tolerant unwrap)', () async {
      final legacy = jsonEncode({
        'app': 'mantle',
        'schemaVersion': 1,
        'exportedAt': now.toUtc().toIso8601String(),
        'tables': {
          'members': [
            {
              'id': 'm-legacy',
              'label': 'Legacy',
              'color': 0xFF000000,
              'createdAt': now.millisecondsSinceEpoch,
            },
          ],
          // The gate requires every table key present — empty tables are
          // spelled as empty lists, never absent keys.
          'rounds': <Object>[],
          'rankingSessions': <Object>[],
          'rankingMatches': <Object>[],
          'charters': <Object>[],
          'spotProgress': <Object>[],
          'readProgress': <Object>[],
          'discoveredThroughlines': <Object>[],
        },
      });

      await serializer.restoreAll(Uint8List.fromList(utf8.encode(legacy)));

      final members = await db.select(db.members).get();
      expect(members.single.id, equals('m-legacy'));
    });
  });

  group('describeBackup', () {
    test('reports per-table row counts and envelope metadata', () async {
      await seedData();
      final bytes = await serializer.dumpAll();

      final manifest = await serializer.describeBackup(bytes);

      expect(manifest.appId, equals('mantle'));
      expect(manifest.schemaVersion, equals(db.schemaVersion));
      expect(manifest.createdAt, isA<DateTime>());
      expect(manifest.tableCounts['members'], equals(1));
      expect(manifest.tableCounts['rankingMatches'], equals(2));
    });

    test('shares restoreAll\'s exact gate: wrong app rejects', () async {
      final bytes = BackupEnvelope.wrap(
        appId: 'sundial',
        schemaVersion: 1,
        createdAt: now,
        payload: {'tables': <String, dynamic>{}},
      );

      expect(
        () => serializer.describeBackup(bytes),
        throwsA(isA<FormatException>()),
      );
    });

    test('shares restoreAll\'s exact gate: future schema rejects', () async {
      final bytes = BackupEnvelope.wrap(
        appId: 'mantle',
        schemaVersion: 999,
        createdAt: now,
        payload: {'tables': <String, dynamic>{}},
      );

      expect(
        () => serializer.describeBackup(bytes),
        throwsA(isA<BackupSchemaException>()),
      );
    });

    test('shares restoreAll\'s exact gate: a missing table key rejects',
        () async {
      final bytes = await serializer.dumpAll();
      final envelope =
          jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final tables = (envelope['payload']
          as Map<String, dynamic>)['tables'] as Map<String, dynamic>;
      tables.remove('spotProgress');
      final truncated = Uint8List.fromList(utf8.encode(jsonEncode(envelope)));

      expect(
        () => serializer.describeBackup(truncated),
        throwsA(isA<FormatException>().having(
          (e) => e.message,
          'message',
          contains('spotProgress'),
        )),
      );
    });

    test('shares restoreAll\'s exact gate: missing tables rejects', () async {
      final bytes = BackupEnvelope.wrap(
        appId: 'mantle',
        schemaVersion: 1,
        createdAt: now,
        payload: {'noTables': 1},
      );

      expect(
        () => serializer.describeBackup(bytes),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
