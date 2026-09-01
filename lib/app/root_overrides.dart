import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

import '../core/providers.dart';
import '../features/sanctuary_backup/data/backup_serializer.dart';

/// The root `ProviderScope` overrides for the running app. [web] exists for
/// tests; the app always uses the platform default.
List<Override> mantleRootOverrides({bool web = kIsWeb}) => [
      // Encrypted-backup wiring (sanctuary_backup_ui). Mantle is
      // greenfield here — its own isolated key material (appDomain
      // 'mantle') and its own AEAD context, so a Mantle blob can never
      // decrypt under another app's context (SANCTUARY-BRIEF §2.1, §2.3).
      sanctuaryAppDomainProvider.overrideWithValue('mantle'),
      sanctuaryBackupConfigProvider.overrideWithValue(
        const SanctuaryBackupConfig(
          appId: 'mantle',
          aadContext: 'mantle-backup/v1',
          appDisplayName: 'Mantle',
          restoreReplaceConsequence:
              'Restoring will delete all household members, ranking '
              'rounds, charters, and solo/tutor progress on this device, '
              'then replace them with data from the backup file.',
          // No onAfterRestore invalidations: Mantle's core providers hold
          // DAOs (not cached rows), and every screen re-reads the
          // database when (re)built — there is no long-lived
          // FutureProvider caching wiped rows the way Lilt's home/
          // shortlist lists did.
        ),
      ),
      // On web every fleet PWA shares one origin, so the recovery words go
      // under Mantle's own key names; native keeps the platform keychain.
      appScopedKeyStoreOverride(web: web),
      backupSerializerProvider.overrideWith(
        (ref) => MantleBackupSerializer(ref.watch(databaseProvider)),
      ),
    ];
