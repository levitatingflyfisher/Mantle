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
  static EloSession buildSession({
    required List<String> itemIds,
    required List<MatchRow> matches,
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
    return engine.snapshot(participantId: participantId);
  }
}
