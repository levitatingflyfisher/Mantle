import 'domain.dart';

/// A spot-the-difference question pairing two plates for a quiz interaction.
class SpotQuestion {
  final String id;
  final Domain domain;
  final String featureId;
  final String promptText;
  final String plateA;
  final String plateB;
  final String correctSide;
  final String explanation;

  const SpotQuestion({
    required this.id,
    required this.domain,
    required this.featureId,
    required this.promptText,
    required this.plateA,
    required this.plateB,
    required this.correctSide,
    required this.explanation,
  });

  factory SpotQuestion.fromJson(Map<String, dynamic> json) => SpotQuestion(
        id: json['id'] as String,
        domain: Domain.values.byName(json['domain'] as String),
        featureId: json['featureId'] as String,
        promptText: json['promptText'] as String,
        plateA: json['plateA'] as String,
        plateB: json['plateB'] as String,
        correctSide: json['correctSide'] as String,
        explanation: json['explanation'] as String,
      );
}
