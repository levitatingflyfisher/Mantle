// test/a11y/primary_action_sweep_test.dart
//
// The release gate for Mantle's primary-action screens (C5-primaryScreens):
// at 360dp x 1.3 text the primary action is on screen and tappable, and at
// 320dp x 3.0 nothing overflows. Rendered with the real OhTheme.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:mantle/features/reveal/presentation/charter_screen.dart';
import 'package:mantle/features/ranking/presentation/members_screen.dart';
import 'package:mantle/features/ranking/presentation/round_screen.dart';
import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';
import 'package:sanctuary_backup_ui/testing.dart';

class _Deck extends ContentRepository {
  @override
  Future<List<DeckImage>> deck() async => [
        for (final d in Domain.values)
          for (var i = 0; i < 8; i++)
            DeckImage(
              id: '${d.name}_$i',
              domain: d,
              assetPath: 'assets/images/deck/missing_${d.name}_$i.jpg',
              features: const [],
              throughlines: const [],
              license: 'CC0',
              institution: 'Test',
              sourceUrl: '',
              title: 'Plate $i',
              accessionId: '${d.name}_$i',
              creator: 'Test',
            ),
      ];

  @override
  Future<List<Throughline>> throughlines() async => const [];
}

Future<void> _pump(WidgetTester tester, MantleDatabase db, Widget home) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      contentRepositoryProvider.overrideWithValue(_Deck()),
      secureKeyStoreProvider.overrideWithValue(InMemorySecureKeyStore()),
      cryptoServiceProvider.overrideWithValue(FakeCryptoService()),
      backupReminderStoreProvider
          .overrideWithValue(InMemoryBackupReminderStore()),
    ],
    child: MaterialApp(theme: OhTheme.light(), home: home),
  ));
  await tester.pumpAndSettle();
}

Future<void> _seedTwo(MantleDatabase db) async {
  await db.membersDao.add(
      id: 'm1',
      label: 'Alexandrina',
      color: OhColors.hearth400.toARGB32(),
      createdAt: DateTime(2026));
  await db.membersDao.add(
      id: 'm2',
      label: 'Bartholomew',
      color: OhColors.sage500.toARGB32(),
      createdAt: DateTime(2026, 2));
}

void main() {
  late MantleDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  testWidgets('Home: Start a round is reachable', (tester) async {
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => _pump(tester, db, const HomeScreen()),
      primaryAction: find.text('Start a round'),
    );
  });

  testWidgets('Members: Start a round is reachable with two people',
      (tester) async {
    await _seedTwo(db);
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => _pump(tester, db, const MembersScreen()),
      primaryAction: find.byKey(const Key('startRoundButton')),
    );
  });

  testWidgets('Round: both plates are reachable', (tester) async {
    await _seedTwo(db);
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => _pump(tester, db, const RoundScreen()),
      primaryAction: find.byKey(const Key('image-tile-b')),
    );
  });

  testWidgets('Charter: Save Charter is reachable, and the bar fits',
      (tester) async {
    final charter = await db.chartersDao
        .createFromReveal('round-1', const [], const [], const []);
    await runPrimaryActionSweep(
      tester,
      pumpScreen: () => _pump(tester, db, CharterScreen(charter: charter)),
      primaryAction: find.text('Save Charter'),
    );
  });
}
