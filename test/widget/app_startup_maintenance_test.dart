import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/app/app.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

/// Proves the silent app-open freshness net (BACKUP_RETENTION_SPEC §3) is
/// wired: booting MantleApp with a key present and an empty vault must land
/// one freshness snapshot post-first-frame, and booting with no key must
/// stay silent.
void main() {
  late MantleDatabase db;
  late InMemoryVaultStore vault;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
    vault = InMemoryVaultStore();
  });

  tearDown(() async => db.close());

  Widget buildApp({required SecureKeyStore store}) {
    return ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider
            .overrideWith((_) async => ThemePreference.light),
        secureKeyStoreProvider.overrideWithValue(store),
        cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
        sanctuaryAppDomainProvider.overrideWithValue('mantle'),
        vaultStoreProvider.overrideWithValue(vault),
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
      child: const MantleApp(),
    );
  }

  testWidgets('app boot takes a freshness snapshot when a key exists',
      (tester) async {
    await tester.pumpWidget(buildApp(
      store: InMemorySecureKeyStore(
        mnemonic: 'abandon abandon abandon abandon abandon abandon '
            'abandon abandon abandon abandon abandon about',
        acknowledged: true,
      ),
    ));
    await tester.pumpAndSettle();

    expect(await vault.list(), isNotEmpty,
        reason: 'post-frame startup maintenance must vault a snapshot');
  });

  testWidgets('app boot stays silent with no key (ghost state)',
      (tester) async {
    await tester.pumpWidget(buildApp(store: InMemorySecureKeyStore()));
    await tester.pumpAndSettle();

    expect(await vault.list(), isEmpty,
        reason: 'no key means no snapshot and no surfaced error');
  });
}
