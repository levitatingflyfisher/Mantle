/// A named menswear look. Its [axisSignature] holds a 5-level string per axis
/// (e.g. `'lean-structured'`), parsed to −2..+2 by `AxisTally.levelToInt`.
class Archetype {
  final String id;
  final String name;
  final String handle;
  final String oneLiner;

  /// Axis key → 5-level string. Keys are `AxisTally.kAxes`.
  final Map<String, String> axisSignature;

  final List<String> signatureGarments;
  final String description;

  /// Ids of the 1–3 nearest neighbouring archetypes.
  final List<String> adjacentTo;

  const Archetype({
    required this.id,
    required this.name,
    required this.handle,
    required this.oneLiner,
    required this.axisSignature,
    required this.signatureGarments,
    required this.description,
    required this.adjacentTo,
  });

  factory Archetype.fromJson(Map<String, dynamic> json) => Archetype(
        id: json['id'] as String,
        name: json['name'] as String,
        handle: json['handle'] as String,
        oneLiner: json['oneLiner'] as String,
        axisSignature: Map<String, String>.from(
            json['axisSignature'] as Map<String, dynamic>),
        signatureGarments: List<String>.from(json['signatureGarments'] as List),
        description: json['description'] as String,
        adjacentTo: List<String>.from(json['adjacentTo'] as List),
      );
}
