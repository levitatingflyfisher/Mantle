import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:mantle/features/solo/presentation/solo_hub_screen.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

Widget _buildHomeScreen(MantleDatabase db) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((ref) async => ThemePreference.light),
    ],
    child: const MaterialApp(
      home: HomeScreen(),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('HomeScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(db));
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('"Start a round" card is present and tappable', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(db));
      await tester.pumpAndSettle();

      expect(find.text('Start a round'), findsOneWidget);
    });

    testWidgets('"Open last Charter" card is present and tappable', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(db));
      await tester.pumpAndSettle();

      expect(find.text('Open last Charter'), findsOneWidget);
      // Card is enabled — tapping it when no charter exists shows a snackbar.
      await tester.tap(find.text('Open last Charter'));
      await tester.pumpAndSettle();
      expect(find.text('No charter yet — complete a round first.'), findsOneWidget);
    });

    testWidgets('"Explore" card is present and navigates to solo hub', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(db));
      await tester.pumpAndSettle();

      expect(find.text('Explore'), findsOneWidget);

      // Tapping Explore navigates to the SoloHubScreen.
      await tester.tap(find.text('Explore'));
      await tester.pumpAndSettle();
      // Assert on the destination widget type, not the ambiguous AppBar title.
      expect(find.byType(SoloHubScreen), findsOneWidget);
    });

    testWidgets(
        '"Start a round" tapping navigates to MembersScreen', (tester) async {
      await tester.pumpWidget(_buildHomeScreen(db));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Start a round'));
      await tester.pumpAndSettle();

      // MembersScreen has the "Who's playing?" AppBar title.
      expect(find.text("Who's playing?"), findsOneWidget);
    });
  });
}
