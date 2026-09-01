// test/widget/member_edit_test.dart
//
// humane-10 / persona P1: a typo or an accidental person used to be
// permanent, and the only remedy was Clear all data. A tap on a member now
// opens an edit sheet: rename, recolour, or remove. Removing is deliberate,
// so it does not ask first; it offers an Undo that never expires while the
// list is open.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/ranking/presentation/members_screen.dart';
import 'package:mantle/widgets/member_dot.dart';
import 'package:openhearth_design/openhearth_design.dart';

void main() {
  late MantleDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: OhTheme.light(), home: const MembersScreen()),
    ));
    await tester.pumpAndSettle();
  }

  Future<void> seed({int? color}) async {
    await db.membersDao.add(
        id: 'm1',
        label: 'Aira',
        color: color ?? memberSwatches[0].color.toARGB32(),
        createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2',
        label: 'Guest',
        color: memberSwatches[1].color.toARGB32(),
        createdAt: DateTime(2026, 2));
  }

  Future<void> openEditor(WidgetTester tester, String name) async {
    await tester.tap(find.widgetWithText(ListTile, name));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('member-edit-sheet')), findsOneWidget);
  }

  testWidgets('a tap on a member renames them in place', (tester) async {
    await seed();
    await pump(tester);

    await openEditor(tester, 'Aira');
    await tester.enterText(find.byKey(const Key('member-edit-name')), 'Aria');
    await tester.pump();
    await tester.tap(find.byKey(const Key('member-edit-save')));
    await tester.pumpAndSettle();

    final m1 = (await db.membersDao.all()).firstWhere((m) => m.id == 'm1');
    expect(m1.label, 'Aria');
    expect(find.text('Aria'), findsOneWidget);
  });

  testWidgets('recolouring saves the new swatch', (tester) async {
    await seed();
    await pump(tester);

    await openEditor(tester, 'Aira');
    await tester.tap(find.byKey(const Key('member-edit-colour-2')));
    await tester.pump();
    await tester.tap(find.byKey(const Key('member-edit-save')));
    await tester.pumpAndSettle();

    final m1 = (await db.membersDao.all()).firstWhere((m) => m.id == 'm1');
    expect(m1.color, memberSwatches[2].color.toARGB32());
  });

  testWidgets('a colour saved before the palette changed is kept on rename',
      (tester) async {
    const legacy = 0xFFC47B6A; // hearth400 before openhearth_design 0.7.0
    await seed(color: legacy);
    await pump(tester);

    await openEditor(tester, 'Aira');
    await tester.enterText(find.byKey(const Key('member-edit-name')), 'Aria');
    await tester.pump();
    await tester.tap(find.byKey(const Key('member-edit-save')));
    await tester.pumpAndSettle();

    final m1 = (await db.membersDao.all()).firstWhere((m) => m.id == 'm1');
    expect(m1.color, legacy);
  });

  testWidgets('remove happens at once and Undo brings the person back',
      (tester) async {
    await seed();
    await pump(tester);

    await openEditor(tester, 'Guest');
    await tester.tap(find.byKey(const Key('member-edit-remove')));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing,
        reason: 'a deliberate remove does not ask first');
    expect((await db.membersDao.all()).map((m) => m.id), ['m1']);
    expect(find.byType(OhUndoBar), findsOneWidget);

    // The Undo never times out.
    await tester.pump(const Duration(hours: 1));
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    final back = await db.membersDao.all();
    expect(back.map((m) => m.id), ['m1', 'm2'],
        reason: 'same id and creation time, so the order and history hold');
    expect(back.last.label, 'Guest');
    expect(find.text('Guest'), findsOneWidget);
  });

  testWidgets('a removed member can be restored after leaving the screen',
      (tester) async {
    await seed();
    await pump(tester);
    await openEditor(tester, 'Guest');
    await tester.tap(find.byKey(const Key('member-edit-remove')));
    await tester.pumpAndSettle();

    // Leave the list (the in-screen Undo ends) and come back later.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpAndSettle();
    await pump(tester);

    expect(find.byType(OhUndoBar), findsOneWidget);
    expect(find.text('Undo'), findsNothing, reason: 'that Undo has ended');
    expect(find.text('Recently removed'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const Key('removed-restore-m2')));
    await tester.tap(find.byKey(const Key('removed-restore-m2')));
    await tester.pumpAndSettle();

    expect((await db.membersDao.all()).map((m) => m.id), ['m1', 'm2']);
    expect(find.text('Recently removed'), findsNothing);
  });

  testWidgets('delete forever asks first, then is gone', (tester) async {
    await seed();
    await db.membersDao.remove('m2');
    await pump(tester);

    await tester.ensureVisible(find.byKey(const Key('removed-forever-m2')));
    await tester.tap(find.byKey(const Key('removed-forever-m2')));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    await tester.tap(find.descendant(
        of: find.byType(AlertDialog), matching: find.text('Delete Guest')));
    await tester.pumpAndSettle();

    expect(await db.membersDao.removed(), isEmpty);
    expect(find.text('Recently removed'), findsNothing);
  });
}
