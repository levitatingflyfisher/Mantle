// test/widget/backup_reminder_home_test.dart
//
// Fleet ruling on first run: open straight into the task, and keep a
// dismissable "finish setup" line so an unsaved recovery phrase is never
// forgotten. Mantle shows it on Home.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

Widget _home(MantleDatabase db, SecureKeyStore store) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        secureKeyStoreProvider.overrideWithValue(store),
        cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
        backupReminderStoreProvider
            .overrideWithValue(InMemoryBackupReminderStore()),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: const HomeScreen()),
    );

void main() {
  late MantleDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  testWidgets('Home reminds a household with no backup, and it dismisses',
      (tester) async {
    await tester.pumpWidget(_home(db, InMemorySecureKeyStore()));
    await tester.pumpAndSettle();

    expect(find.byType(BackupSetupReminder), findsOneWidget);
    expect(find.textContaining('Backup isn'), findsOneWidget);

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Backup isn'), findsNothing);
  });

  testWidgets('Home says nothing once backup is set up', (tester) async {
    await tester.pumpWidget(_home(
      db,
      InMemorySecureKeyStore(
        mnemonic: 'abandon abandon abandon abandon abandon abandon '
            'abandon abandon abandon abandon abandon about',
        acknowledged: true,
        lastBackupAt: DateTime.now(),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('Backup isn'), findsNothing);
    expect(find.textContaining('Finish backup setup'), findsNothing);
  });
}
