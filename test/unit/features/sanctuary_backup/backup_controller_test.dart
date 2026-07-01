import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

/// End-to-end net for Mantle's wiring: the real serializer + real crypto,
/// driven through the package's BackupController with Mantle's actual config
/// (appId 'mantle', appDomain 'mantle', context 'mantle-backup/v1'). The
/// generic controller behaviour is unit-tested in the package; this proves
/// Mantle's wiring works against the real sanctuary_auth_core.
///
/// Every restore path overrides vaultStoreProvider with InMemoryVaultStore:
/// the mandatory pre-restore snapshot otherwise hits the platform store and
/// fails with RestoreOutcome.snapshotFailed in tests.
const _validPhrase =
    'abandon abandon abandon abandon abandon abandon abandon abandon '
    'abandon abandon abandon about';

void main() {
  late MantleDatabase db;
  final now = DateTime(2026, 7, 17);

  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  ProviderContainer makeContainer({
    required MantleDatabase database,
    required SecureKeyStore store,
    InMemoryVaultStore? vault,
    void Function(Ref ref)? onAfterRestore,
  }) {
    final c = ProviderContainer(overrides: [
      secureKeyStoreProvider.overrideWithValue(store),
      vaultStoreProvider.overrideWithValue(vault ?? InMemoryVaultStore()),
      cryptoServiceProvider.overrideWithValue(const DefaultCryptoService()),
      sanctuaryAppDomainProvider.overrideWithValue('mantle'),
      backupSerializerProvider
          .overrideWith((ref) => MantleBackupSerializer(database)),
      sanctuaryBackupConfigProvider.overrideWithValue(
        SanctuaryBackupConfig(
          appId: 'mantle',
          aadContext: 'mantle-backup/v1',
          appDisplayName: 'Mantle',
          onAfterRestore: onAfterRestore,
        ),
      ),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  Future<void> seed(MantleDatabase target) async {
    await target.into(target.members).insert(MembersCompanion.insert(
          id: 'm1',
          label: 'Alice',
          color: 0xFFCC4400,
          createdAt: now,
        ));
    await target.into(target.rounds).insert(RoundsCompanion.insert(
          id: 'r1',
          deckVersion: 1,
          createdAt: now,
        ));
    await target
        .into(target.charters)
        .insert(ChartersCompanion.insert(
          id: 'c1',
          roundId: 'r1',
          createdAt: now,
          spineItemIds: '["deck-a"]',
          throughlines: '["warm-wood"]',
          contestedItemIds: '[]',
        ));
  }

  test('export → restore round-trips Mantle data through the controller',
      () async {
    await seed(db);

    final src = makeContainer(
      database: db,
      store:
          InMemorySecureKeyStore(mnemonic: _validPhrase, acknowledged: true),
    );
    final result =
        await src.read(backupControllerProvider.notifier).exportBackup();
    expect(result, isNotNull);
    expect(result!.filename,
        matches(RegExp(r'^mantle-backup-\d{4}-\d{2}-\d{2}\.ohbk$')));
    // OHBK magic bytes.
    expect(result.bytes.sublist(0, 4), equals([0x4F, 0x48, 0x42, 0x4B]));
    expect(result.manifest.tableCounts['members'], equals(1));

    // Restore into a fresh DB and a fresh (empty) keychain, by phrase.
    final db2 = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);

    var refreshed = false;
    final dst = makeContainer(
      database: db2,
      store: InMemorySecureKeyStore(),
      onAfterRestore: (_) => refreshed = true,
    );
    final outcome = await dst
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(result.bytes, _validPhrase);

    expect(outcome, RestoreOutcome.success);
    expect(refreshed, isTrue, reason: 'onAfterRestore must fire');

    final members = await db2.select(db2.members).get();
    expect(members.single.label, equals('Alice'));
    final charters = await db2.select(db2.charters).get();
    expect(charters.single.spineItemIds, equals('["deck-a"]'));
  });

  test('a non-OHBK blob restores as corruptFile', () async {
    final c = makeContainer(database: db, store: InMemorySecureKeyStore());
    final outcome = await c
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(
            Uint8List.fromList(List.filled(64, 0)), _validPhrase);
    expect(outcome, RestoreOutcome.corruptFile);
  });

  test('a backup encrypted for a different appDomain fails to decrypt',
      () async {
    // Export under appDomain 'mantle' (the container default above)...
    final src = makeContainer(
      database: db,
      store:
          InMemorySecureKeyStore(mnemonic: _validPhrase, acknowledged: true),
    );
    final result =
        await src.read(backupControllerProvider.notifier).exportBackup();

    // ...restoring under no domain (legacy/null) must not silently succeed:
    // the derived key differs, so this is the wrong-phrase path.
    final db2 = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);
    final c = ProviderContainer(overrides: [
      secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore()),
      vaultStoreProvider.overrideWithValue(InMemoryVaultStore()),
      cryptoServiceProvider.overrideWithValue(const DefaultCryptoService()),
      // No sanctuaryAppDomainProvider override — stays at the null default.
      backupSerializerProvider
          .overrideWith((ref) => MantleBackupSerializer(db2)),
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
          appId: 'mantle',
          aadContext: 'mantle-backup/v1',
          appDisplayName: 'Mantle',
        ),
      ),
    ]);
    addTearDown(c.dispose);

    final outcome = await c
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(result!.bytes, _validPhrase);

    expect(outcome, RestoreOutcome.wrongPhrase);
  });

  test(
      'restore refuses to touch data when the mandatory pre-restore snapshot '
      'cannot be saved (fail closed)', () async {
    final src = makeContainer(
      database: db,
      store:
          InMemorySecureKeyStore(mnemonic: _validPhrase, acknowledged: true),
    );
    await seed(db);
    final result =
        await src.read(backupControllerProvider.notifier).exportBackup();

    // A destination with existing data and a vault that fails its next put.
    final db2 = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db2.close);
    await db2.into(db2.members).insert(MembersCompanion.insert(
          id: 'm-existing',
          label: 'Existing',
          color: 0xFF000000,
          createdAt: now,
        ));
    final failingVault = InMemoryVaultStore()..failNextPut = true;
    final dst = makeContainer(
      database: db2,
      store: InMemorySecureKeyStore(),
      vault: failingVault,
    );

    final outcome = await dst
        .read(backupControllerProvider.notifier)
        .restoreWithPhrase(result!.bytes, _validPhrase);

    expect(outcome, RestoreOutcome.snapshotFailed);
    final members = await db2.select(db2.members).get();
    expect(members.single.id, equals('m-existing'),
        reason: 'a refused restore must never touch existing data');
  });
}
