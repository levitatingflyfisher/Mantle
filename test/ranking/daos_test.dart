import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/ranking/domain/round_models.dart';

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('MembersDao', () {
    test('add and retrieve all members', () async {
      final dao = db.membersDao;
      final now = DateTime.now();

      await dao.add(
        id: 'member-1',
        label: 'Alice',
        color: 0xFF4CAF50,
        createdAt: now,
      );
      await dao.add(
        id: 'member-2',
        label: 'Bob',
        color: 0xFF2196F3,
        createdAt: now,
      );

      final members = await dao.all();
      expect(members.length, 2);
      expect(members.map((m) => m.id), containsAll(['member-1', 'member-2']));
      expect(members.map((m) => m.label), containsAll(['Alice', 'Bob']));
    });
  });

  group('RoundsDao', () {
    test('create and retrieve a round', () async {
      final dao = db.roundsDao;
      final now = DateTime.now();

      final round = await dao.create(
        id: 'round-1',
        deckVersion: 3,
        createdAt: now,
      );

      expect(round.id, 'round-1');
      expect(round.deckVersion, 3);
    });
  });

  group('SessionsDao', () {
    setUp(() async {
      // Create prerequisite data
      final now = DateTime.now();
      await db.membersDao.add(
        id: 'member-1',
        label: 'Alice',
        color: 0xFF4CAF50,
        createdAt: now,
      );
      await db.roundsDao.create(
        id: 'round-1',
        deckVersion: 1,
        createdAt: now,
      );
    });

    test('create and retrieve sessions for a round', () async {
      final dao = db.sessionsDao;
      final now = DateTime.now();

      await dao.create(
        id: 'session-1',
        roundId: 'round-1',
        memberId: 'member-1',
        domain: 'aesthetic',
        createdAt: now,
      );

      final sessions = await dao.forRound('round-1');
      expect(sessions.length, 1);
      expect(sessions.first.id, 'session-1');
      expect(sessions.first.roundId, 'round-1');
      expect(sessions.first.domain, 'aesthetic');
    });

    test('new session defaults: isComplete false, resultsLocked true', () async {
      final dao = db.sessionsDao;
      final now = DateTime.now();

      await dao.create(
        id: 'session-2',
        roundId: 'round-1',
        memberId: 'member-1',
        domain: 'aesthetic',
        createdAt: now,
      );

      final sessions = await dao.forRound('round-1');
      final session = sessions.first;
      expect(session.isComplete, isFalse);
      expect(session.resultsLocked, isTrue);
    });

    test('markComplete flips isComplete true and does NOT change resultsLocked', () async {
      final dao = db.sessionsDao;
      final now = DateTime.now();

      await dao.create(
        id: 'session-3',
        roundId: 'round-1',
        memberId: 'member-1',
        domain: 'aesthetic',
        createdAt: now,
      );

      // Confirm initial state
      final before = (await dao.forRound('round-1')).first;
      expect(before.isComplete, isFalse);
      expect(before.resultsLocked, isTrue);

      await dao.markComplete('session-3');

      final after = (await dao.forRound('round-1')).first;
      expect(after.isComplete, isTrue,
          reason: 'markComplete should flip isComplete to true');
      expect(after.resultsLocked, isTrue,
          reason: 'markComplete must NOT touch resultsLocked');
    });
  });

  group('MatchesDao', () {
    setUp(() async {
      final now = DateTime.now();
      await db.membersDao.add(
        id: 'member-1',
        label: 'Alice',
        color: 0xFF4CAF50,
        createdAt: now,
      );
      await db.roundsDao.create(
        id: 'round-1',
        deckVersion: 1,
        createdAt: now,
      );
      await db.sessionsDao.create(
        id: 'session-1',
        roundId: 'round-1',
        memberId: 'member-1',
        domain: 'aesthetic',
        createdAt: now,
      );
    });

    test('record and retrieve matches as MatchRow DTOs', () async {
      final dao = db.matchesDao;
      final now = DateTime.now();

      await dao.record(
        sessionId: 'session-1',
        idA: 'item-a',
        idB: 'item-b',
        outcome: 'aWins',
        decidedAt: now,
      );
      await dao.record(
        sessionId: 'session-1',
        idA: 'item-c',
        idB: 'item-d',
        outcome: 'bWins',
        decidedAt: now,
      );

      final matches = await dao.forSession('session-1');
      expect(matches.length, 2);

      // Verify they are plain MatchRow DTOs (Drift-free)
      expect(matches, everyElement(isA<MatchRow>()));

      final aWins = matches.where((m) => m.outcome == 'aWins').toList();
      expect(aWins.length, 1);
      expect(aWins.first.idA, 'item-a');
      expect(aWins.first.idB, 'item-b');

      final bWins = matches.where((m) => m.outcome == 'bWins').toList();
      expect(bWins.length, 1);
      expect(bWins.first.idA, 'item-c');
      expect(bWins.first.idB, 'item-d');
    });

    test('forSession returns empty list for session with no matches', () async {
      final matches = await db.matchesDao.forSession('session-1');
      expect(matches, isEmpty);
    });

    test('forSession is scoped: only returns matches for the given session', () async {
      final dao = db.matchesDao;
      final now = DateTime.now();

      // Create a second session
      await db.sessionsDao.create(
        id: 'session-2',
        roundId: 'round-1',
        memberId: 'member-1',
        domain: 'character',
        createdAt: now,
      );

      await dao.record(
        sessionId: 'session-1',
        idA: 'item-a',
        idB: 'item-b',
        outcome: 'aWins',
        decidedAt: now,
      );
      await dao.record(
        sessionId: 'session-2',
        idA: 'item-c',
        idB: 'item-d',
        outcome: 'bWins',
        decidedAt: now,
      );

      final s1Matches = await dao.forSession('session-1');
      expect(s1Matches.length, 1);
      expect(s1Matches.first.outcome, 'aWins');

      final s2Matches = await dao.forSession('session-2');
      expect(s2Matches.length, 1);
      expect(s2Matches.first.outcome, 'bWins');
    });
  });
}
