// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'charters_dao.dart';

// ignore_for_file: type=lint
mixin _$ChartersDaoMixin on DatabaseAccessor<MantleDatabase> {
  $ChartersTable get charters => attachedDatabase.charters;
  ChartersDaoManager get managers => ChartersDaoManager(this);
}

class ChartersDaoManager {
  final _$ChartersDaoMixin _db;
  ChartersDaoManager(this._db);
  $$ChartersTableTableManager get charters =>
      $$ChartersTableTableManager(_db.attachedDatabase, _db.charters);
}
