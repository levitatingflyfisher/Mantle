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

  test('undoLastDecision restores the ratings from before that pick', () {
    final rs = RoundService(['a', 'b', 'c', 'd']);
    rs.recordDecision('a', 'b', MatchOutcome.aWins);
    rs.recordDecision('c', 'd', MatchOutcome.skip);
    rs.recordDecision('c', 'd', MatchOutcome.bWins);
    Map<String, double> ratings() =>
        {for (final i in rs.snapshot('p').items) i.id: i.rating};
    final before = ratings();

    rs.recordDecision('a', 'c', MatchOutcome.bWins);
    rs.recordDecision('b', 'd', MatchOutcome.skip); // a skip after the pick
    expect(rs.decisionCount, 3);
    expect(rs.undoLastDecision(), ('a', 'c'));
    expect(rs.decisionCount, 2);
    expect(ratings(), before);
  });

  test('undoLastDecision with nothing to undo returns null', () {
    final rs = RoundService(['a', 'b']);
    rs.recordDecision('a', 'b', MatchOutcome.skip);
    expect(rs.undoLastDecision(), isNull);
    expect(rs.decisionCount, 0);
  });
}
