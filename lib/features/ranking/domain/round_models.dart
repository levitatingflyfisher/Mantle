/// Plain domain DTO for a completed ranking match.
///
/// This is intentionally Drift-free — it decouples the pure-Dart domain
/// layer (SessionBuilder, ELO engine, etc.) from the persistence layer.
///
/// [outcome] is one of: `'aWins'` | `'bWins'`
class MatchRow {
  final String idA;
  final String idB;
  final String outcome;
  final DateTime decidedAt;

  const MatchRow({
    required this.idA,
    required this.idB,
    required this.outcome,
    required this.decidedAt,
  });
}
