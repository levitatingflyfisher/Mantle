import 'package:drift/drift.dart';

import '../../features/ranking/data/members_dao.dart';
import '../../features/ranking/data/rounds_dao.dart';
import '../../features/ranking/data/sessions_dao.dart';
import '../../features/ranking/data/matches_dao.dart';
import '../../features/reveal/data/charters_dao.dart';
import '../../features/solo/data/discovered_throughlines_dao.dart';
import '../../features/solo/data/read_progress_dao.dart';
import '../../features/solo/data/spot_progress_dao.dart';

import 'connection/connection.dart';

export '../../features/ranking/data/members_dao.dart';
export '../../features/ranking/data/rounds_dao.dart';
export '../../features/ranking/data/sessions_dao.dart';
export '../../features/ranking/data/matches_dao.dart';
export '../../features/reveal/data/charters_dao.dart';
export '../../features/solo/data/discovered_throughlines_dao.dart';
export '../../features/solo/data/read_progress_dao.dart';
export '../../features/solo/data/spot_progress_dao.dart';

part 'database.g.dart';

// ── Tables ──────────────────────────────────────────────────────────────────

@DataClassName('MemberRow')
class Members extends Table {
  TextColumn get id => text()();
  TextColumn get label => text()();
  IntColumn get color => integer()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Rounds extends Table {
  TextColumn get id => text()();
  IntColumn get deckVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class RankingSessions extends Table {
  TextColumn get id => text()();
  TextColumn get roundId => text()();
  TextColumn get memberId => text()();
  TextColumn get domain => text()();
  BoolColumn get isComplete =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get resultsLocked =>
      boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RankingMatch')
@TableIndex(name: 'idx_matches_session', columns: {#sessionId})
class RankingMatches extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId => text()();
  TextColumn get idA => text()();
  TextColumn get idB => text()();
  TextColumn get outcome => text()();
  DateTimeColumn get decidedAt => dateTime()();
  @override
  Set<Column> get primaryKey => {id};
}

class Charters extends Table {
  TextColumn get id => text()();
  TextColumn get roundId => text()();
  TextColumn get houseName =>
      text().withDefault(const Constant(''))();
  TextColumn get motto =>
      text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get spineItemIds => text()();
  TextColumn get throughlines => text()();
  TextColumn get contestedItemIds => text()();
  TextColumn get bodyOverrides =>
      text().withDefault(const Constant('{}'))();
  @override
  Set<Column> get primaryKey => {id};
}

class SpotProgress extends Table {
  TextColumn get memberId => text()();
  TextColumn get questionId => text()();
  IntColumn get seenCount =>
      integer().withDefault(const Constant(0))();
  IntColumn get correctCount =>
      integer().withDefault(const Constant(0))();
  @override
  Set<Column> get primaryKey => {memberId, questionId};
}

class ReadProgress extends Table {
  TextColumn get memberId => text()();
  TextColumn get itemId => text()();
  BoolColumn get knewIt => boolean()();
  @override
  Set<Column> get primaryKey => {memberId, itemId};
}

class DiscoveredThroughlines extends Table {
  TextColumn get memberId => text()();
  TextColumn get throughlineId => text()();
  DateTimeColumn get firstSeenAt => dateTime()();
  @override
  Set<Column> get primaryKey => {memberId, throughlineId};
}

// ── Database ─────────────────────────────────────────────────────────────────

@DriftDatabase(
  tables: [
    Members,
    Rounds,
    RankingSessions,
    RankingMatches,
    Charters,
    SpotProgress,
    ReadProgress,
    DiscoveredThroughlines,
  ],
  daos: [MembersDao, RoundsDao, SessionsDao, MatchesDao, ChartersDao,
         ReadProgressDao, SpotProgressDao, DiscoveredThroughlinesDao],
)
class MantleDatabase extends _$MantleDatabase {
  /// Production constructor — opens the real on-disk database automatically.
  MantleDatabase() : super(openMantleConnection());

  /// In-memory constructor for tests.
  MantleDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration =>
      MigrationStrategy(onCreate: (m) async => m.createAll());
}
