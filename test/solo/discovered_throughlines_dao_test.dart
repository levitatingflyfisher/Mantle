import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('DiscoveredThroughlinesDao.markSeen', () {
    const memberId = 'member-1';
    const throughlineId = 'throughline-abc';

    test('calling markSeen twice for the same key produces exactly one row',
        () async {
      final dao = db.discoveredThroughlinesDao;

      await dao.markSeen(memberId, throughlineId);
      await dao.markSeen(memberId, throughlineId); // second call — must be no-op

      final rows = await dao.forMember(memberId);
      expect(rows, hasLength(1));
      expect(rows.first.memberId, memberId);
      expect(rows.first.throughlineId, throughlineId);
    });

    test('firstSeenAt is preserved and not overwritten on second markSeen',
        () async {
      final dao = db.discoveredThroughlinesDao;

      await dao.markSeen(memberId, throughlineId);
      final after1 = await dao.forMember(memberId);
      final firstSeen = after1.first.firstSeenAt;

      // Small delay so a second DateTime.now() would differ, then call again.
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await dao.markSeen(memberId, throughlineId);

      final after2 = await dao.forMember(memberId);
      expect(after2, hasLength(1));
      expect(after2.first.firstSeenAt, firstSeen,
          reason: 'firstSeenAt must not be overwritten by a duplicate markSeen');
    });

    test('a distinct (memberId, throughlineId) pair produces a second row',
        () async {
      final dao = db.discoveredThroughlinesDao;

      await dao.markSeen(memberId, 'throughline-abc');
      await dao.markSeen(memberId, 'throughline-xyz'); // different throughline

      final rows = await dao.forMember(memberId);
      expect(rows, hasLength(2));
      expect(
        rows.map((r) => r.throughlineId).toSet(),
        {'throughline-abc', 'throughline-xyz'},
      );
    });
  });
}
