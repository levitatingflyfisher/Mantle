import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/canon_item.dart';
import '../domain/deck_image.dart';
import '../domain/spot_question.dart';
import '../domain/throughline.dart';

/// Loads the bundled JSON content assets and returns typed domain models.
///
/// All methods use [rootBundle] so they work in both app and test contexts
/// (tests must call [TestWidgetsFlutterBinding.ensureInitialized] first).
class ContentRepository {
  Future<List<CanonItem>> canon() async {
    final raw = await rootBundle.loadString('assets/data/canon.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final items = data['canon'] as List<dynamic>;
    return items
        .map((e) => CanonItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Throughline>> throughlines() async {
    final raw = await rootBundle.loadString('assets/data/throughlines.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final items = data['throughlines'] as List<dynamic>;
    return items
        .map((e) => Throughline.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<DeckImage>> deck() async {
    final raw =
        await rootBundle.loadString('assets/images/deck/manifest.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final items = data['images'] as List<dynamic>;
    return items
        .map((e) => DeckImage.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SpotQuestion>> spotQuestions() async {
    final raw = await rootBundle.loadString('assets/data/spot.json');
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final items = data['questions'] as List<dynamic>;
    return items
        .map((e) => SpotQuestion.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
