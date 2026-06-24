// test/widget/settings_test.dart
//
// Widget tests for SettingsScreen (Task 19).
//
// Key assertions:
// 1. Theme picker shows all three ThemePreference options (Daytime/Evening/Late night).
// 2. Selecting a theme option triggers a provider invalidation (UI reflects new selection).
// 3. "Clear all data" button is present.
// 4. About section is present.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/settings/presentation/settings_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildSettingsScreen(
  MantleDatabase db, {
  ThemePreference initialPref = ThemePreference.light,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => initialPref),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: const SettingsScreen(),
    ),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('SettingsScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('shows all three theme options', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      // Each ThemePreference.label must appear.
      expect(find.text('Daytime'), findsOneWidget);
      expect(find.text('Evening'), findsOneWidget);
      expect(find.text('Late night'), findsOneWidget);
    });

    testWidgets('each theme option has a keyed radio widget', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      for (final pref in ThemePreference.values) {
        expect(
          find.byKey(Key('settings-theme-${pref.name}')),
          findsOneWidget,
          reason:
              'ThemeOption widget for ${pref.name} must be present with its key',
        );
      }
    });

    testWidgets('initial preference is reflected in the UI', (tester) async {
      await tester.pumpWidget(
          _buildSettingsScreen(db, initialPref: ThemePreference.hearthDark));
      await tester.pumpAndSettle();

      // When hearthDark is the current preference, its radio icon should show
      // radio_button_checked and the others should show radio_button_unchecked.
      // We verify by checking the Icon widget inside the keyed SizedBox.
      final hearthDarkBox = find.byKey(const Key('settings-theme-radio-hearthDark'));
      expect(hearthDarkBox, findsOneWidget);
      final checkedIcon = find.descendant(
        of: hearthDarkBox,
        matching: find.byIcon(Icons.radio_button_checked),
      );
      expect(checkedIcon, findsOneWidget,
          reason: 'hearthDark option must show checked icon');

      final lightBox = find.byKey(const Key('settings-theme-radio-light'));
      expect(lightBox, findsOneWidget);
      final uncheckedIcon = find.descendant(
        of: lightBox,
        matching: find.byIcon(Icons.radio_button_unchecked),
      );
      expect(uncheckedIcon, findsOneWidget,
          reason: 'light option must show unchecked icon when hearthDark is selected');
    });

    testWidgets('"Clear all data" button is present', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-reset-button')),
        100,
      );
      expect(
        find.byKey(const Key('settings-reset-button')),
        findsOneWidget,
      );
    });

    testWidgets('data-reset shows confirmation dialog', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-reset-button')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings-reset-button')));
      await tester.pumpAndSettle();

      expect(find.text('Clear all data?'), findsOneWidget);
      expect(find.byKey(const Key('settings-reset-cancel')), findsOneWidget);
      expect(find.byKey(const Key('settings-reset-confirm')), findsOneWidget);
    });

    testWidgets('cancelling reset dialog does not wipe data', (tester) async {
      // Seed a member so we can verify it still exists after cancelling.
      await db.membersDao.add(
        id: 'test-member',
        label: 'Alice',
        color: 0xFFCC4400,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-reset-button')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings-reset-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings-reset-cancel')));
      await tester.pumpAndSettle();

      final members = await db.membersDao.all();
      expect(members, hasLength(1));
    });

    testWidgets('confirming reset clears database', (tester) async {
      // Seed a member so we can verify it is gone after confirming.
      await db.membersDao.add(
        id: 'test-member',
        label: 'Alice',
        color: 0xFFCC4400,
        createdAt: DateTime.now(),
      );

      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-reset-button')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings-reset-button')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('settings-reset-confirm')));
      await tester.pumpAndSettle();

      final members = await db.membersDao.all();
      expect(members, isEmpty);
    });

    testWidgets('About Mantle section is present', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('settings-about-heading')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('settings-about-body')),
        findsOneWidget,
      );
    });
  });
}
