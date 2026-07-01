import 'package:elo_engine/elo_engine.dart';

/// Number of non-skip decisions required to complete one domain ranking round.
const int kDecisionsPerDomain = 12;

/// Manages a fixed-length pairing session for a single aesthetic domain.
///
/// Wraps an [EloEngine] and uses a simple counter (not convergence) to
/// determine completion. This means:
/// - [nextPair] keeps proposing pairs even after [isDomainComplete] is true.
/// - Skips (via [MatchOutcome.skip]) do NOT advance [decisionCount].
/// - Completion is reached as soon as [decisionCount] >= [kDecisionsPerDomain].
class RoundService {
  final EloEngine _engine;
  int _decisionCount = 0;

  /// Constructs a fresh [RoundService] for the given [itemIds].
  RoundService(List<String> itemIds)
      : _engine = EloEngine(
          items: [for (final id in itemIds) EloItem(id: id)],
          config: const EloConfig(
            allowTies: false,
            enabledAlgorithms: {AlgorithmId.elo},
          ),
        );

  /// Suggest the next pair to compare.
  ///
  /// Returns null only if N < 2. For N ≥ 2, keeps proposing past the
  /// fixed-count terminator — the caller decides whether to keep presenting
  /// pairs based on [isDomainComplete].
  MatchProposal? nextPair() => _engine.nextMatch();

  /// Record a decision for the pair ([idA], [idB]) with [outcome].
  ///
  /// [MatchOutcome.skip] is passed through to the engine (suppresses the pair
  /// briefly) but does NOT increment [decisionCount].
  void recordDecision(String idA, String idB, MatchOutcome outcome) {
    _engine.record(idA, idB, outcome);
    if (outcome != MatchOutcome.skip) {
      _decisionCount++;
    }
  }

  /// Number of non-skip decisions recorded so far.
  int get decisionCount => _decisionCount;

  /// True once [decisionCount] reaches [kDecisionsPerDomain].
  bool get isDomainComplete => _decisionCount >= kDecisionsPerDomain;

  /// Snapshot the current engine state for persistence or merging.
  EloSession snapshot(String participantId) =>
      _engine.snapshot(participantId: participantId);
}
