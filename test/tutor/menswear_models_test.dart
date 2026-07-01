import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/content/domain/archetype.dart';
import 'package:mantle/features/tutor/content/domain/menswear_spot_question.dart';

void main() {
  group('MenswearTerm.fromJson', () {
    test('parses a full term with handle and axis signals', () {
      final t = MenswearTerm.fromJson({
        'id': 'polo',
        'facet': 'garment',
        'term': 'Polo shirt',
        'handle': 'the tennis shirt',
        'gloss': 'A collared knit pullover.',
        'quickRead': 'A collared short-sleeve shirt.',
        'closerRead': 'The soft folded collar and piqué knit are the tells.',
        'axisSignals': [
          {'axis': 'classic-directional', 'pole': 'classic'}
        ],
        'plateHint': 'A flat polo showing the ribbed collar.',
      });
      expect(t.id, 'polo');
      expect(t.facet, 'garment');
      expect(t.handle, 'the tennis shirt');
      expect(t.axisSignals, hasLength(1));
      expect(t.axisSignals.first.axis, 'classic-directional');
      expect(t.axisSignals.first.pole, 'classic');
    });

    test('handle may be null and axisSignals may be empty/absent', () {
      final t = MenswearTerm.fromJson({
        'id': 'straight-fit',
        'facet': 'fit',
        'term': 'Straight fit',
        'handle': null,
        'gloss': 'Same width from the top down.',
        'quickRead': 'A fit that hangs straight down.',
        'closerRead': 'No narrowing, no flare.',
        'axisSignals': <dynamic>[],
        'plateHint': 'A trouser silhouette with vertical guide lines.',
      });
      expect(t.handle, isNull);
      expect(t.axisSignals, isEmpty);
    });
  });

  test('Archetype.fromJson parses signature map and adjacency', () {
    final a = Archetype.fromJson({
      'id': 'ivy-prep',
      'name': 'Ivy / Prep',
      'handle': 'Boat shoes, no boat required',
      'oneLiner': 'Repp-stripe ties and penny loafers.',
      'axisSignature': {
        'structured-relaxed': 'lean-structured',
        'muted-graphic': 'mid',
        'classic-directional': 'classic',
      },
      'signatureGarments': ['OCBD', 'penny loafer'],
      'description': 'Rooted in mid-century collegiate style.',
      'adjacentTo': ['classic-tailored', 'mod'],
    });
    expect(a.id, 'ivy-prep');
    expect(a.axisSignature['classic-directional'], 'classic');
    expect(a.signatureGarments, contains('penny loafer'));
    expect(a.adjacentTo, contains('mod'));
  });

  test('MenswearSpotQuestion.fromJson parses facet (no Domain)', () {
    final q = MenswearSpotQuestion.fromJson({
      'id': 'ms-spot-01',
      'facet': 'garment',
      'promptText': 'Which is the henley?',
      'plateA': 'henley',
      'plateB': 'polo',
      'correctSide': 'A',
      'explanation': 'The buttoned placket with no collar is the tell.',
    });
    expect(q.id, 'ms-spot-01');
    expect(q.facet, 'garment');
    expect(q.correctSide, 'A');
  });
}
