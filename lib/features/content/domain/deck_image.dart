import 'domain.dart';

/// A single image card in the swipe deck, with provenance metadata.
class DeckImage {
  final String id;
  final Domain domain;

  /// Derived as `assets/images/deck/$id.jpg` — assumes a `.jpg` extension.
  /// If Task 17 sources real images that use a different extension or naming
  /// scheme, update [DeckImage.fromJson] and this field accordingly.
  /// Placeholder images may not exist on disk until Task 17.
  final String assetPath;

  final List<String> features;
  final List<String> throughlines;

  // Provenance fields
  final String license;
  final String institution;
  final String sourceUrl;
  final String title;
  final String accessionId;
  final String creator;

  const DeckImage({
    required this.id,
    required this.domain,
    required this.assetPath,
    required this.features,
    required this.throughlines,
    required this.license,
    required this.institution,
    required this.sourceUrl,
    required this.title,
    required this.accessionId,
    required this.creator,
  });

  factory DeckImage.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as String;
    return DeckImage(
      id: id,
      domain: Domain.values.byName(json['domain'] as String),
      assetPath: 'assets/images/deck/$id.jpg',
      features: List<String>.from(json['features'] as List),
      throughlines: List<String>.from(json['throughlines'] as List),
      license: json['license'] as String,
      institution: json['institution'] as String,
      sourceUrl: json['sourceUrl'] as String,
      title: json['title'] as String,
      accessionId: json['accessionId'] as String,
      creator: json['creator'] as String,
    );
  }
}
