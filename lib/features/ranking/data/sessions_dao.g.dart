// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sessions_dao.dart';

// ignore_for_file: type=lint
mixin _$SessionsDaoMixin on DatabaseAccessor<MantleDatabase> {
  $RankingSessionsTable get rankingSessions => attachedDatabase.rankingSessions;
  SessionsDaoManager get managers => SessionsDaoManager(this);
}

class SessionsDaoManager {
  final _$SessionsDaoMixin _db;
  SessionsDaoManager(this._db);
  $$RankingSessionsTableTableManager get rankingSessions =>
      $$RankingSessionsTableTableManager(
          _db.attachedDatabase, _db.rankingSessions);
}
