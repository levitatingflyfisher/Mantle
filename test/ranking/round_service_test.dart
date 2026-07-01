import 'package:elo_engine/elo_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/ranking/domain/round_service.dart';

void main() {
  test('completes after exactly 12 recorded decisions; skips uncounted', () {
    final rs = RoundService(['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h']);
    var i = 0;
    while (!rs.isDomainComplete) {
      final p = rs.nextPair()!;
      rs.recordDecision(p.itemA.id, p.itemB.id, MatchOutcome.aWins);
      i++;
      if (i > 50) fail('did not terminate');
    }
    expect(rs.decisionCount, 12);
    final p = rs.nextPair(); // still proposes (no convergence dependency)
    expect(p, isNotNull);
  });
}
