/// A menswear discrimination question — like the legacy `SpotQuestion` but
/// keyed by a String [facet] instead of the `Domain` enum, so it never throws
/// on `Domain.values.byName`.
class MenswearSpotQuestion {
  final String id;
  final String facet;
  final String promptText;
  final String plateA;
  final String plateB;

  /// `'A'` or `'B'`.
  final String correctSide;
  final String explanation;

  const MenswearSpotQuestion({
    required this.id,
    required this.facet,
    required this.promptText,
    required this.plateA,
    required this.plateB,
    required this.correctSide,
    required this.explanation,
  });

  factory MenswearSpotQuestion.fromJson(Map<String, dynamic> json) =>
      MenswearSpotQuestion(
        id: json['id'] as String,
        facet: json['facet'] as String,
        promptText: json['promptText'] as String,
        plateA: json['plateA'] as String,
        plateB: json['plateB'] as String,
        correctSide: json['correctSide'] as String,
        explanation: json['explanation'] as String,
      );
}
