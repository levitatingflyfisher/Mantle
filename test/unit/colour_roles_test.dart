// test/unit/colour_roles_test.dart
//
// mind-07 / hackers-04: the brand and the error red used to be grey-
// identical (1.13:1), so a greyscale or low-vision reader could not tell a
// primary button from an error. Pin that they now differ in lightness in
// both hearth themes (light 1.37:1, hearthDark 1.41:1 on 0.7.0).
//
// Night is not pinned: its primary is sage, a different hue from the red,
// but the two sit only 1.18:1 apart in lightness. Mantle's errors always
// carry an icon and a word (OhErrorState), which is what the fleet colour
// ruling relies on; the night pair is reported, not hidden.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:openhearth_design/openhearth_design.dart';

double _ratio(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  final themes = {
    'light': OhTheme.light(),
    'hearthDark': OhTheme.hearthDark(),
  };
  for (final e in themes.entries) {
    test('${e.key}: primary and error are not grey-identical', () {
      final cs = e.value.colorScheme;
      final r = _ratio(cs.primary, cs.error);
      expect(r, greaterThanOrEqualTo(1.3));
    });
  }
}
