import 'package:elo_engine/elo_engine.dart';
import 'round_models.dart';

/// Rebuilds an [EloSession] from a list of persisted [MatchRow]s.
///
/// This is the pure-Dart bridge between the Drift persistence layer and the
/// elo_engine: it replays all recorded decisions to reconstruct the engine
/// state, then snapshots it into an immutable session for merging or display.
class SessionBuilder {
  const SessionBuilder._();

  /// Reconstruct an [EloSession] for [participantId] over [itemIds],
  /// replaying every [MatchRow] in [matches] (chronological order assumed).
  ///
  /// [sessionId] is the persisted RankingSession's id. Passing it means the
  /// engine never mints one: minting went through `1 << 32`, which is 0
  /// under dart2js and threw on every reveal on web. `EloEngine.snapshot()`
  /// takes no id, so the session is built directly from the engine state.
  static EloSession buildSession({
    required List<String> itemIds,
    required List<MatchRow> matches,
    required String sessionId,
    required String participantId,
  }) {
    final engine = EloEngine(
      items: [for (final id in itemIds) EloItem(id: id)],
      history: [
        for (final m in matches)
          EloMatch(
            idA: m.idA,
            idB: m.idB,
            outcome: MatchOutcome.values.byName(m.outcome),
            timestamp: m.decidedAt,
          ),
      ],
      config: const EloConfig(
        allowTies: false,
        enabledAlgorithms: {AlgorithmId.elo},
      ),
    );
    return EloSession(
      sessionId: sessionId,
      participantId: participantId,
      items: engine.items,
      history: List.of(engine.history),
    );
  }
}
