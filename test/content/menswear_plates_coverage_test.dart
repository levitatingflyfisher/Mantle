import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards that every menswear vocabulary term has a drawn plate SVG, so the
/// Learn / Lean / Spot / Charter surfaces never fall back to the placeholder
/// icon for a shipped term. (Before the plate batch, only a few proofs existed;
/// this now covers the full taxonomy.)
void main() {
  test('every menswear term has a plate SVG in assets/plates/', () {
    final data = jsonDecode(File('assets/data/menswear.json').readAsStringSync())
        as Map<String, dynamic>;
    final terms = data['terms'] as List<dynamic>;
    final missing = <String>[
      for (final t in terms)
        if (!File('assets/plates/${(t as Map)['id']}.svg').existsSync())
          t['id'] as String,
    ];
    expect(missing, isEmpty, reason: 'terms with no plate SVG: $missing');
    expect(terms.length, greaterThanOrEqualTo(50));
  });
}
