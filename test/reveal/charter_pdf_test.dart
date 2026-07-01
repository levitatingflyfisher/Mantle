import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/reveal/presentation/charter_pdf.dart';

void main() {
  test('buildCharterPdf returns a non-empty Document', () async {
    final db = MantleDatabase.forTesting(NativeDatabase.memory());
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

    await db.close();
  });
}
