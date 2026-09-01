// test/ranking/member_soft_delete_test.dart
//
// Fleet ruling: Undo never expires. A removed member is kept (deletedAt set)
// so the person can be brought back later from "Recently removed", not only
// while the list is open. Removed people drop out of every list and round.

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/sanctuary_backup/data/backup_serializer.dart';

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  Future<void> seed() async {
    await db.membersDao.add(
        id: 'm1', label: 'Aria', color: 1, createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2', label: 'Guest', color: 2, createdAt: DateTime(2026, 2));
  }

  test('remove keeps the row but hides it from the active list', () async {
    await seed();
    await db.membersDao.remove('m2');

    expect((await db.membersDao.all()).map((m) => m.id), ['m1']);
    final removed = await db.membersDao.removed();
    expect(removed.map((m) => m.id), ['m2']);
    expect(removed.single.deletedAt, isNotNull);
  });

  test('restore brings the person back in their place, any time later',
      () async {
    await seed();
    await db.membersDao.remove('m2');
    await db.membersDao.restore('m2');

    expect((await db.membersDao.all()).map((m) => m.id), ['m1', 'm2']);
    expect(await db.membersDao.removed(), isEmpty);
  });

  test('delete forever removes only a removed member', () async {
    await seed();
    await db.membersDao.deleteForever('m1');
    expect((await db.membersDao.all()), hasLength(2),
        reason: 'an active member cannot be deleted forever by mistake');

    await db.membersDao.remove('m2');
    await db.membersDao.deleteForever('m2');
    expect(await db.membersDao.removed(), isEmpty);
    expect((await db.membersDao.all()).map((m) => m.id), ['m1']);
  });

  test('a backup carries the removed state and restores it', () async {
    await seed();
    await db.membersDao.remove('m2');
    final serializer = MantleBackupSerializer(db);
    final bytes = await serializer.dumpAll();
    await serializer.restoreAll(bytes);

    expect((await db.membersDao.all()).map((m) => m.id), ['m1']);
    expect((await db.membersDao.removed()).map((m) => m.id), ['m2']);
  });

  test('a v1 database upgrades in place and keeps its members', () async {
    // The v1 members table exactly as schemaVersion 1 created it, with a
    // row, set up before Drift opens the database and runs its migration.
    final upgraded = MantleDatabase.forTesting(NativeDatabase.memory(
      setup: (raw) {
        raw.execute('CREATE TABLE "members" ("id" TEXT NOT NULL, "label" '
            'TEXT NOT NULL, "color" INTEGER NOT NULL, "created_at" INTEGER '
            'NOT NULL, PRIMARY KEY ("id"));');
        raw.execute(
            "INSERT INTO members VALUES ('m1', 'Aria', 1, 1767225600);");
        raw.execute('PRAGMA user_version = 1;');
      },
    ));
    addTearDown(upgraded.close);
    final members = await upgraded.membersDao.all();
    expect(members.single.label, 'Aria');
    expect(members.single.deletedAt, isNull);
    await upgraded.membersDao.remove('m1');
    expect(await upgraded.membersDao.all(), isEmpty);
    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .map((r) => r.read<int>('user_version'))
        .getSingle();
    expect(version, upgraded.schemaVersion);
  });
}
