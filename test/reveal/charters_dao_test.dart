import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/reveal/domain/reveal.dart';
import 'package:mantle/features/reveal/domain/throughline_namer.dart';

void main() {
  late MantleDatabase db;
  late ChartersDao dao;

  setUp(() async {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
    dao = db.chartersDao;
    // Seed prerequisite data
    await db.roundsDao.create(
        id: 'round-1', deckVersion: 1, createdAt: DateTime(2026, 1, 1));
    await db.roundsDao.create(
        id: 'round-2', deckVersion: 1, createdAt: DateTime(2026, 1, 2));
  });

  tearDown(() async => db.close());

  final spine = [
    const RevealItem(
        id: 'img-1',
        domain: Domain.tailoring,
        combinedScore: 5.0,
        agreement: 0.9),
    const RevealItem(
        id: 'img-2',
        domain: Domain.interiors,
        combinedScore: 4.5,
        agreement: 0.85),
  ];
  final contested = [
    const RevealItem(
        id: 'img-3',
        domain: Domain.architecture,
        combinedScore: 2.0,
        agreement: 0.1),
  ];
  final throughlines = [
    const NamedThroughline(key: 'interval', spineCount: 2)
  ];

  test('createFromReveal persists spine/contested/throughlines as JSON',
      () async {
    final charter =
        await dao.createFromReveal('round-1', spine, contested, throughlines);

    final spineIds =
        List<String>.from(jsonDecode(charter.spineItemIds) as List);
    expect(spineIds, ['img-1', 'img-2']);

    final contestedIds =
        List<String>.from(jsonDecode(charter.contestedItemIds) as List);
    expect(contestedIds, ['img-3']);

    final tls =
        List<String>.from(jsonDecode(charter.throughlines) as List);
    expect(tls, ['interval']);

    expect(charter.roundId, 'round-1');
    expect(charter.houseName, '');
    expect(charter.motto, '');
    expect(charter.bodyOverrides, '{}');
  });

  test('updateCharter mutates only editable fields', () async {
    final charter =
        await dao.createFromReveal('round-1', spine, contested, throughlines);

    await dao.updateCharter(
      id: charter.id,
      houseName: 'Thornwood',
      motto: 'Built to last.',
      bodyOverrides: {'section1': 'Custom text'},
    );

    final updated = await (db.select(db.charters)
          ..where((t) => t.id.equals(charter.id)))
        .getSingle();
    expect(updated.houseName, 'Thornwood');
    expect(updated.motto, 'Built to last.');
    final overrides =
        Map<String, dynamic>.from(jsonDecode(updated.bodyOverrides) as Map);
    expect(overrides['section1'], 'Custom text');

    // JSON fields unchanged
    expect(updated.spineItemIds, charter.spineItemIds);
    expect(updated.contestedItemIds, charter.contestedItemIds);
  });

  test(
      're-running a round creates a NEW charter row (count grows, history kept)',
      () async {
    await dao.createFromReveal('round-1', spine, contested, throughlines);
    await dao.createFromReveal('round-1', spine, contested, throughlines);

    final all = await db.select(db.charters).get();
    expect(all.length, 2);
  });

  test('latest() returns newest by createdAt', () async {
    // Pass explicit timestamps so that second-granularity SQLite storage
    // can distinguish the two rows without relying on wall-clock delays.
    final older = DateTime(2026, 1, 1, 10, 0, 0);
    final newer = DateTime(2026, 1, 1, 10, 0, 1);
    await dao.createFromReveal('round-1', spine, contested, throughlines,
        createdAt: older);
    final newerCharter = await dao.createFromReveal(
        'round-2', spine, contested, throughlines,
        createdAt: newer);

    final latest = await dao.latest();
    expect(latest?.id, newerCharter.id);
  });
}
