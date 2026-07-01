import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mantle/app/app.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/sanctuary_backup/data/backup_serializer.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

void main() => runApp(
      ProviderScope(
        overrides: [
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
          backupSerializerProvider.overrideWith(
            (ref) => MantleBackupSerializer(ref.watch(databaseProvider)),
          ),
        ],
        child: const MantleApp(),
      ),
    );
