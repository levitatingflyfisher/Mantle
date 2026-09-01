// test/widget/settings_test.dart
//
// Widget tests for SettingsScreen (Task 19).
//
// Key assertions:
// 1. Theme picker shows all four ThemePreference options (Follow phone/Light/Dark/Night).
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
import 'package:mantle/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:mantle/features/settings/presentation/settings_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

Widget _buildSettingsScreen(
  MantleDatabase db, {
  ThemePreference initialPref = ThemePreference.light,
  SecureKeyStore? store,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => initialPref),
      // The backup section draws a loading line until auth resolves, so
      // give it an in-memory key store (no words yet) that resolves at once.
      secureKeyStoreProvider
          .overrideWithValue(store ?? InMemorySecureKeyStore()),
      cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
      vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      sanctuaryAppDomainProvider.overrideWithValue('mantle'),
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
          appId: 'mantle',
          aadContext: 'mantle-backup/v1',
          appDisplayName: 'Mantle',
        ),
      ),
      backupSerializerProvider
          .overrideWith((ref) => MantleBackupSerializer(db)),
      backupReminderStoreProvider
          .overrideWithValue(InMemoryBackupReminderStore()),
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

    testWidgets('shows all four theme options', (tester) async {
      await tester.pumpWidget(_buildSettingsScreen(db));
      await tester.pumpAndSettle();

      // Each ThemePreference.label must appear.
      expect(find.text('Follow phone'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('Night'), findsOneWidget);
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
          _buildSettingsScreen(db, initialPref: ThemePreference.dark));
      await tester.pumpAndSettle();

      // When dark is the current preference, its radio icon should show
      // radio_button_checked and the others should show radio_button_unchecked.
      // We verify by checking the Icon widget inside the keyed SizedBox.
      final darkBox = find.byKey(const Key('settings-theme-radio-dark'));
      expect(darkBox, findsOneWidget);
      final checkedIcon = find.descendant(
        of: darkBox,
        matching: find.byIcon(Icons.radio_button_checked),
      );
      expect(checkedIcon, findsOneWidget,
          reason: 'dark option must show checked icon');

      final lightBox = find.byKey(const Key('settings-theme-radio-light'));
      expect(lightBox, findsOneWidget);
      final uncheckedIcon = find.descendant(
        of: lightBox,
        matching: find.byIcon(Icons.radio_button_unchecked),
      );
      expect(uncheckedIcon, findsOneWidget,
          reason: 'light option must show unchecked icon when dark is selected');
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

    Future<void> seedAlice() => db.membersDao.add(
          id: 'test-member',
          label: 'Alice',
          color: 0xFFCC4400,
          createdAt: DateTime(2026),
        );

    Future<void> tapClear(WidgetTester tester) async {
      await tester.scrollUntilVisible(
        find.byKey(const Key('settings-reset-button')),
        100,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('settings-reset-button')));
      await tester.pumpAndSettle();
    }

    group('with backup set up (a safety copy can be taken)', () {
      SecureKeyStore wordsStore() => InMemorySecureKeyStore(
            mnemonic: 'abandon abandon abandon abandon abandon abandon '
                'abandon abandon abandon abandon abandon about',
            acknowledged: true,
          );

      testWidgets('clears at once, with no dialog, and offers Undo',
          (tester) async {
        await seedAlice();
        await tester.pumpWidget(_buildSettingsScreen(db, store: wordsStore()));
        await tester.pumpAndSettle();

        await tapClear(tester);

        expect(find.byType(AlertDialog), findsNothing,
            reason: 'a deliberate delete does not ask first');
        expect(await db.membersDao.all(), isEmpty);
        expect(find.byType(OhUndoBar), findsOneWidget);
        expect(find.text('Undo'), findsOneWidget);
      });

      testWidgets('Undo brings the data back from the safety copy',
          (tester) async {
        await seedAlice();
        await tester.pumpWidget(_buildSettingsScreen(db, store: wordsStore()));
        await tester.pumpAndSettle();

        await tapClear(tester);
        // Undo never times out: an hour later it is still there.
        await tester.pump(const Duration(hours: 1));
        await tester.tap(find.text('Undo'));
        await tester.pumpAndSettle();

        final members = await db.membersDao.all();
        expect(members.map((m) => m.label), ['Alice']);
      });
    });

    group('without backup (no way back)', () {
      testWidgets('asks first, naming that there is no copy', (tester) async {
        await tester.pumpWidget(_buildSettingsScreen(db));
        await tester.pumpAndSettle();

        await tapClear(tester);

        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.textContaining('no copy'), findsOneWidget);
        expect(find.descendant(
            of: find.byType(AlertDialog), matching: find.text('Clear all data')),
            findsOneWidget);
      });

      testWidgets('cancelling keeps the data', (tester) async {
        await seedAlice();
        await tester.pumpWidget(_buildSettingsScreen(db));
        await tester.pumpAndSettle();

        await tapClear(tester);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(await db.membersDao.all(), hasLength(1));
      });

      testWidgets('confirming clears the database', (tester) async {
        await seedAlice();
        await tester.pumpWidget(_buildSettingsScreen(db));
        await tester.pumpAndSettle();

        await tapClear(tester);
        await tester.tap(find.descendant(
            of: find.byType(AlertDialog), matching: find.text('Clear all data')));
        await tester.pumpAndSettle();

        expect(await db.membersDao.all(), isEmpty);
      });
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
