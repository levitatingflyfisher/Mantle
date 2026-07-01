import 'package:elo_engine/elo_engine.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/ranking/domain/round_models.dart';
import 'package:mantle/features/ranking/domain/session_builder.dart';

void main() {
  test('rebuilds a session and ranks the consistent winner first', () {
    final s = SessionBuilder.buildSession(
        itemIds: ['a', 'b', 'c'],
        participantId: 'm1',
        matches: [
          MatchRow(idA: 'a', idB: 'b', outcome: 'aWins', decidedAt: DateTime(2026)),
          MatchRow(idA: 'a', idB: 'c', outcome: 'aWins', decidedAt: DateTime(2026)),
        ]);
    final ranked = List<EloItem>.from(s.items)
      ..sort((x, y) => y.rating.compareTo(x.rating));
    expect(ranked.first.id, 'a');
    expect(s.participantId, 'm1');
  });

  test('bWins outcome ranks item B above item A', () {
    // Verifies that the 'bWins' outcome string maps correctly — B is rated
    // higher than A after winning all head-to-head matches.
    final s = SessionBuilder.buildSession(
        itemIds: ['a', 'b', 'c'],
        participantId: 'm2',
        matches: [
          MatchRow(idA: 'a', idB: 'b', outcome: 'bWins', decidedAt: DateTime(2026)),
          MatchRow(idA: 'c', idB: 'b', outcome: 'bWins', decidedAt: DateTime(2026)),
        ]);
    final ranked = List<EloItem>.from(s.items)
      ..sort((x, y) => y.rating.compareTo(x.rating));
    expect(ranked.first.id, 'b',
        reason: 'B won all matches; it should rank first');
    expect(s.participantId, 'm2');
  });
}
