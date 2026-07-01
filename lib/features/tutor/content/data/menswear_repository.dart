import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/archetype.dart';
import '../domain/menswear_spot_question.dart';
import '../domain/menswear_term.dart';

/// The `RankingSessions.domain` value used for every menswear lean session.
/// A distinct namespace from the legacy `Domain` enum names, so it never
/// collides and legacy per-domain grouping never picks it up.
const String kMenswearDomainKey = 'menswear';

/// Loads the bundled menswear JSON assets and returns typed models.
///
/// Mirrors `ContentRepository`: `rootBundle.loadString` → `jsonDecode` →
/// `fromJson`, no caching. Methods are overridable so tests can subclass with
/// deterministic fixtures (see the `_FakeMenswearRepository` pattern).
class MenswearRepository {
  /// Curated subset of term ids used for the Lean pairwise pool. ~20
  /// recognizable garments/outerwear/footwear spanning all three axes — a
  /// meaningful Spine needs density, which all 51 terms with ~24 picks lacks.
  static const List<String> leanPoolIds = [
    // garment
    'crew-tee', 'henley', 'polo', 'flannel-shirt', 'hoodie', 'oxford-shirt',
    // outerwear
    'trucker-denim-jacket', 'chore-coat', 'bomber', 'field-jacket-m65',
    'peacoat', 'moto-jacket', 'puffer',
    // footwear
    'low-top-sneaker', 'chunky-dad-sneaker', 'loafer', 'chelsea-boot',
    'derby', 'service-boot', 'chukka-desert-boot',
  ];

  Future<List<MenswearTerm>> terms() async {
    final raw = await rootBundle.loadString('assets/data/menswear.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['terms'] as List<dynamic>)
        .map((e) => MenswearTerm.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Archetype>> archetypes() async {
    final raw =
        await rootBundle.loadString('assets/data/menswear_archetypes.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['archetypes'] as List<dynamic>)
        .map((e) => Archetype.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<MenswearSpotQuestion>> spotQuestions() async {
    final raw = await rootBundle.loadString('assets/data/menswear_spot.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    return (data['questions'] as List<dynamic>)
        .map((e) => MenswearSpotQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// The curated lean pool, in [leanPoolIds] order, skipping any id missing
  /// from the taxonomy (defensive; the content test asserts all resolve).
  Future<List<MenswearTerm>> leanPool() async {
    final all = await terms();
    final byId = {for (final t in all) t.id: t};
    return [
      for (final id in leanPoolIds)
        if (byId[id] != null) byId[id]!,
    ];
  }
}
