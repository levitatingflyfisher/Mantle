import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/reveal/domain/reveal.dart';
import 'package:mantle/features/reveal/domain/throughline_namer.dart';

void main() {
  test('names a key only with >=2 spine items across >=2 domains', () {
    final spine = [
      const RevealItem(id: 'a', domain: 'interiors', combinedScore: 5, agreement: 1),
      const RevealItem(id: 'b', domain: 'tailoring', combinedScore: 5, agreement: 1),
      const RevealItem(id: 'c', domain: 'interiors', combinedScore: 5, agreement: 1),
    ];
    final map = {'a': ['material-honesty'], 'b': ['material-honesty'], 'c': ['interval']};
    final named = ThroughlineNamer.name(spine, map);
    expect(named.map((n) => n.key), ['material-honesty']); // interval only 1 item → excluded
  });
  test('same-domain-only key is excluded', () {
    final spine = [
      const RevealItem(id: 'a', domain: 'interiors', combinedScore: 5, agreement: 1),
      const RevealItem(id: 'c', domain: 'interiors', combinedScore: 5, agreement: 1)
    ];
    expect(ThroughlineNamer.name(spine, {'a': ['interval'], 'c': ['interval']}), isEmpty);
  });
}
