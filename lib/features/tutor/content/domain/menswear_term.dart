/// One directional signal a term sends on a lean axis.
///
/// [axis] is one of `AxisTally.kAxes` (e.g. `'structured-relaxed'`); [pole] is
/// one of that axis's two tokens (e.g. `'structured'` or `'relaxed'`).
class AxisSignal {
  final String axis;
  final String pole;

  const AxisSignal({required this.axis, required this.pole});

  factory AxisSignal.fromJson(Map<String, dynamic> json) => AxisSignal(
        axis: json['axis'] as String,
        pole: json['pole'] as String,
      );
}

/// A single menswear vocabulary term — the menswear analogue of `CanonItem`,
/// but keyed by a String [facet] rather than the legacy `Domain` enum.
class MenswearTerm {
  final String id;
  final String facet;
  final String term;

  /// Playful nickname, or null when the term has no handle.
  final String? handle;

  final String gloss;
  final String quickRead;
  final String closerRead;

  /// 0–2 directional signals used by `AxisTally` to place a lean.
  final List<AxisSignal> axisSignals;

  /// Illustration brief for the drawn flat (art input, not shown to users).
  final String plateHint;

  const MenswearTerm({
    required this.id,
    required this.facet,
    required this.term,
    required this.handle,
    required this.gloss,
    required this.quickRead,
    required this.closerRead,
    required this.axisSignals,
    required this.plateHint,
  });

  factory MenswearTerm.fromJson(Map<String, dynamic> json) => MenswearTerm(
        id: json['id'] as String,
        facet: json['facet'] as String,
        term: json['term'] as String,
        handle: json['handle'] as String?,
        gloss: json['gloss'] as String,
        quickRead: json['quickRead'] as String,
        closerRead: json['closerRead'] as String,
        axisSignals: ((json['axisSignals'] as List<dynamic>?) ?? const [])
            .map((e) => AxisSignal.fromJson(e as Map<String, dynamic>))
            .toList(),
        plateHint: json['plateHint'] as String,
      );
}
