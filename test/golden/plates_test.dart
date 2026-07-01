// test/golden/plates_test.dart
//
// Golden tests for the Plate widget.
// Run `flutter test --update-goldens test/golden/plates_test.dart` to
// regenerate baselines when plate SVGs change intentionally.
//
// These tests verify that:
// 1. The Plate widget renders without crashing for representative keys.
// 2. The visual output is stable across builds.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/widgets/plate.dart';
import 'package:openhearth_design/openhearth_design.dart';

// Representative plates — one per domain + a spot variant.
const _testPlates = [
  'xline',       // tailoring — waist suppression (complex path)
  'gorge',       // tailoring — gorge height (datum text)
  'poche',       // architecture — filled mass (most complex)
  'enfilade',    // architecture — rooms in sequence
  'japandi',     // interiors — organic + geometric
  'gorge-high',  // spot contrast variant
  'poche-filled', // spot contrast variant
];

Widget _buildPlate(String key, ThemeData theme) {
  return MaterialApp(
    theme: theme,
    home: Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Center(
        child: Plate(plateKey: key, size: 200),
      ),
    ),
  );
}

void main() {
  group('Plate widget golden tests', () {
    for (final plateKey in _testPlates) {
      testWidgets('$plateKey — light theme', (tester) async {
        await tester.pumpWidget(_buildPlate(plateKey, OhTheme.light()));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Plate),
          matchesGoldenFile('goldens/${plateKey}_light.png'),
        );
      });

      testWidgets('$plateKey — hearthDark theme', (tester) async {
        await tester.pumpWidget(_buildPlate(plateKey, OhTheme.hearthDark()));
        await tester.pumpAndSettle();
        await expectLater(
          find.byType(Plate),
          matchesGoldenFile('goldens/${plateKey}_hearthDark.png'),
        );
      });
    }

    testWidgets('Plate shows placeholder for unknown key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: OhTheme.light(),
          home: const Scaffold(
            body: Center(
              child: Plate(plateKey: 'does-not-exist', size: 200),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Should not throw — placeholder is shown.
      expect(find.byType(Plate), findsOneWidget);
      // The placeholder icon must actually be rendered.
      expect(find.byIcon(Icons.image_not_supported_outlined), findsOneWidget);
    });
  });
}
