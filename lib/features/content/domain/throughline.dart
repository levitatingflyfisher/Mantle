/// A cross-cutting thematic thread that links canon items across domains.
class Throughline {
  final String key;
  final String label;

  const Throughline({required this.key, required this.label});

  factory Throughline.fromJson(Map<String, dynamic> json) => Throughline(
        key: json['key'] as String,
        label: json['label'] as String,
      );
}
