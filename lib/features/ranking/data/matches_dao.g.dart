// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'matches_dao.dart';

// ignore_for_file: type=lint
mixin _$MatchesDaoMixin on DatabaseAccessor<MantleDatabase> {
  $RankingMatchesTable get rankingMatches => attachedDatabase.rankingMatches;
  MatchesDaoManager get managers => MatchesDaoManager(this);
}

class MatchesDaoManager {
  final _$MatchesDaoMixin _db;
  MatchesDaoManager(this._db);
  $$RankingMatchesTableTableManager get rankingMatches =>
      $$RankingMatchesTableTableManager(
          _db.attachedDatabase, _db.rankingMatches);
}
