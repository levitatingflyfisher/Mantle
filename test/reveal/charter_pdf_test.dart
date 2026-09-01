import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/reveal/domain/reveal.dart';
import 'package:mantle/features/reveal/presentation/charter_pdf.dart';

/// Counts image XObjects in an uncompressed PDF.
int _imageCount(List<int> bytes) =>
    RegExp(r'/Subtype\s*/Image').allMatches(latin1.decode(bytes)).length;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  test('buildCharterPdf returns a non-empty Document', () async {
    await db.roundsDao
        .create(id: 'round-1', deckVersion: 1, createdAt: DateTime(2026, 1, 1));
    final charter = await db.chartersDao.createFromReveal(
      'round-1',
      [],
      [],
      [],
    );
    // Update with some data
    await db.chartersDao.updateCharter(
        id: charter.id, houseName: 'Thornwood', motto: 'Built to last.');
    final updatedCharter = await (db.select(db.charters)
          ..where((t) => t.id.equals(charter.id)))
        .getSingle();

    final doc = buildCharterPdf(updatedCharter);
    // Structural assertion: document must have at least one page.
    expect(doc.document.pdfPageList.pages.length, greaterThanOrEqualTo(1));
    final bytes = await doc.save();
    expect(bytes.length, greaterThan(0));
  });

  test('the printed Charter carries the plates themselves (visual-02)',
      () async {
    // Real deck images, loaded the way the Charter screen loads them.
    final deck = await ContentRepository().deck();
    final spine = deck.take(3).toList();
    final contested = deck.skip(3).take(2).toList();
    final charter = await db.chartersDao.createFromReveal(
      'round-1',
      [
        for (final d in spine)
          RevealItem(
              id: d.id,
              domain: d.domain.name,
              combinedScore: 1,
              agreement: 1),
      ],
      [
        for (final d in contested)
          RevealItem(
              id: d.id,
              domain: d.domain.name,
              combinedScore: 1,
              agreement: 0),
      ],
      [],
    );

    final plates = await loadCharterPlates(
        {for (final d in deck) d.id: d}, [...spine, ...contested].map((d) => d.id));
    expect(plates.values.where((p) => p.bytes != null), hasLength(5),
        reason: 'every plate on the Charter loads its image');
    expect(plates[spine.first.id]!.title, spine.first.title);

    final doc = buildCharterPdf(charter, plates: plates, compress: false);
    expect(_imageCount(await doc.save()), 5,
        reason: 'three spine and two contested plates are printed, not counted');
  });

  test('the printed Charter is dated in words', () {
    expect(charterDateLine(DateTime(2026, 9, 26)), 'Made on 26 September 2026');
  });
}
