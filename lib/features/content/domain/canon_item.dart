import 'domain.dart';

/// The "echo" cross-reference embedded in each [CanonItem].
class Echo {
  final String toId;
  final String note;

  const Echo({required this.toId, required this.note});

  factory Echo.fromJson(Map<String, dynamic> json) => Echo(
        toId: json['toId'] as String,
        note: json['note'] as String,
      );
}

/// A single entry in the canon — one named, explainable aesthetic principle.
class CanonItem {
  final String id;
  final Domain domain;
  final String term;
  final String gloss;
  final String principle;
  final String quickRead;
  final String closerRead;
  final Echo echo;
  final String plate;
  final List<String> throughlines;

  const CanonItem({
    required this.id,
    required this.domain,
    required this.term,
    required this.gloss,
    required this.principle,
    required this.quickRead,
    required this.closerRead,
    required this.echo,
    required this.plate,
    required this.throughlines,
  });

  factory CanonItem.fromJson(Map<String, dynamic> json) => CanonItem(
        id: json['id'] as String,
        domain: Domain.values.byName(json['domain'] as String),
        term: json['term'] as String,
        gloss: json['gloss'] as String,
        principle: json['principle'] as String,
        quickRead: json['quickRead'] as String,
        closerRead: json['closerRead'] as String,
        echo: Echo.fromJson(json['echo'] as Map<String, dynamic>),
        plate: json['plate'] as String,
        throughlines: List<String>.from(json['throughlines'] as List),
      );
}
