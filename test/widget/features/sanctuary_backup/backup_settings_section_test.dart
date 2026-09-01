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

/// Proves the encrypted-backup section is really embedded in Mantle's
/// Settings screen with Mantle's own config (appId 'mantle', appDomain
/// 'mantle', context 'mantle-backup/v1') — modeled on Lilt's section test,
/// but pumping the real SettingsScreen so the embed itself is under test.
Widget _buildSettingsScreen(
  MantleDatabase db, {
  required SecureKeyStore store,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      secureKeyStoreProvider.overrideWithValue(store),
      // Deterministic + fast — skips real PBKDF2 so tests don't need a
      // multi-second pumpAndSettle for key derivation.
      cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
      sanctuaryAppDomainProvider.overrideWithValue('mantle'),
      vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
          appId: 'mantle',
          aadContext: 'mantle-backup/v1',
          appDisplayName: 'Mantle',
        ),
      ),
      backupSerializerProvider
          .overrideWith((ref) => MantleBackupSerializer(db)),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: const SettingsScreen(),
    ),
  );
}

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  Future<void> scrollToBackupSection(WidgetTester tester) async {
    await tester.scrollUntilVisible(find.text('Backup'), 100);
    await tester.pumpAndSettle();
  }

  group('BackupSettingsSection embed', () {
    testWidgets('Settings shows the Backup section', (tester) async {
      await tester.pumpWidget(
        _buildSettingsScreen(db, store: InMemorySecureKeyStore()),
      );
      await tester.pumpAndSettle();

      await scrollToBackupSection(tester);

      expect(find.byType(BackupSettingsSection), findsOneWidget);
      expect(find.text('Backup'), findsOneWidget);
    });

    testWidgets('ghost state offers setup, restore, vault, and plain export',
        (tester) async {
      await tester.pumpWidget(
        _buildSettingsScreen(db, store: InMemorySecureKeyStore()),
      );
      await tester.pumpAndSettle();

      await scrollToBackupSection(tester);

      expect(find.text('Set up encrypted backup'), findsOneWidget);
      expect(find.text('Restore from backup'), findsOneWidget);
      expect(find.text('Previous backups'), findsOneWidget);
      expect(find.text('Export as plain JSON'), findsOneWidget);
      expect(find.text('Export backup'), findsNothing);
    });

    testWidgets('shows Export backup once a seed is acknowledged',
        (tester) async {
      await tester.pumpWidget(
        _buildSettingsScreen(
          db,
          store: InMemorySecureKeyStore(
            mnemonic: 'abandon abandon abandon abandon abandon abandon '
                'abandon abandon abandon abandon abandon about',
            acknowledged: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await scrollToBackupSection(tester);

      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Set up encrypted backup'), findsNothing);
    });
  });
}
