import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/app/app.dart';
import 'package:mantle/core/theme/theme_preference.dart';

void main() => testWidgets('app builds', (t) async {
      await t.pumpWidget(
        ProviderScope(
          overrides: [
            // Override the theme provider to resolve synchronously without
            // touching flutter_secure_storage (which has no MethodChannel
            // implementation in the VM test environment).
            themePreferenceProvider
                .overrideWith((ref) async => ThemePreference.light),
          ],
          child: const MantleApp(),
        ),
      );
      await t.pumpAndSettle();
      expect(find.byType(MantleApp), findsOneWidget);
    });
