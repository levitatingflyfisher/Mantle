import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/ranking/presentation/members_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Builds a [MembersScreen] inside a [ProviderScope] with:
/// - An in-memory [MantleDatabase] (overrides [databaseProvider]).
/// - A synchronous light theme (overrides [themePreferenceProvider]).
Widget _buildMembersScreen(MantleDatabase db) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((ref) async => ThemePreference.light),
    ],
    child: const MaterialApp(
      home: MembersScreen(),
    ),
  );
}

/// Pumps the screen and settles, returning the current members from the DB.
Future<void> _pump(WidgetTester tester, MantleDatabase db) async {
  await tester.pumpWidget(_buildMembersScreen(db));
  await tester.pumpAndSettle();
}

/// Enters a member name and taps Add.
///
/// The extra [pump] after [enterText] is required because the "Add person"
/// button is disabled when the field is empty. The controller listener that
/// re-enables the button schedules a [setState], which needs one additional
/// frame to flush before the tap is recognised.
Future<void> _addMember(WidgetTester tester, String name) async {
  await tester.enterText(find.byKey(const Key('memberNameField')), name);
  await tester.pump(); // flush the setState that enables the Add button
  await tester.tap(find.byKey(const Key('addMemberButton')));
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  group('MembersScreen', () {
    testWidgets('renders without crashing', (tester) async {
      await _pump(tester, db);
      expect(find.byType(MembersScreen), findsOneWidget);
    });

    testWidgets('can add a member and it appears in the list', (tester) async {
      await _pump(tester, db);

      await _addMember(tester, 'Alice');

      expect(find.text('Alice'), findsOneWidget);
    });

    testWidgets('"Start a round" is disabled with 0 members', (tester) async {
      await _pump(tester, db);

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('startRoundButton')),
      );
      expect(btn.onPressed, isNull,
          reason: 'button must be disabled when no members exist');
    });

    testWidgets('"Start a round" is disabled with 1 member', (tester) async {
      await _pump(tester, db);

      await _addMember(tester, 'Alice');

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('startRoundButton')),
      );
      expect(btn.onPressed, isNull,
          reason: 'button must be disabled with only 1 member');
    });

    testWidgets('"Start a round" is enabled at exactly 2 members',
        (tester) async {
      await _pump(tester, db);

      await _addMember(tester, 'Alice');
      await _addMember(tester, 'Bob');

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('startRoundButton')),
      );
      expect(btn.onPressed, isNotNull,
          reason: 'button must be enabled with 2 members');
    });

    testWidgets('"Start a round" remains enabled with 3 members',
        (tester) async {
      await _pump(tester, db);

      await _addMember(tester, 'Alice');
      await _addMember(tester, 'Bob');
      await _addMember(tester, 'Cara');

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('startRoundButton')),
      );
      expect(btn.onPressed, isNotNull,
          reason: 'button must be enabled with 3 members');
    });

    testWidgets('add form disappears at 5 members (max reached)', (tester) async {
      await _pump(tester, db);

      await _addMember(tester, 'Alice');
      await _addMember(tester, 'Bob');
      await _addMember(tester, 'Cara');
      await _addMember(tester, 'Dan');
      await _addMember(tester, 'Eve');

      // At max, the add form should be gone.
      expect(find.byKey(const Key('addMemberButton')), findsNothing,
          reason: 'add form must be hidden at max member count');
    });

    testWidgets('cannot exceed 5 members — 6th add is a no-op', (tester) async {
      // Pre-populate 5 members directly in the DB to keep the test fast.
      final dao = db.membersDao;
      for (var i = 0; i < 5; i++) {
        await dao.add(
          id: 'member-$i',
          label: 'Member $i',
          color: OhColors.hearth400.toARGB32(),
          createdAt: DateTime.now().add(Duration(seconds: i)),
        );
      }

      await _pump(tester, db);

      // The add form should not be visible.
      expect(find.byKey(const Key('addMemberButton')), findsNothing);
      expect(find.byKey(const Key('memberNameField')), findsNothing);

      // The DB must still have exactly 5 members.
      final members = await db.membersDao.all();
      expect(members.length, 5,
          reason: 'DB must remain at exactly 5 members');
    });

    testWidgets('"Start a round" is enabled with 5 members', (tester) async {
      final dao = db.membersDao;
      for (var i = 0; i < 5; i++) {
        await dao.add(
          id: 'member-$i',
          label: 'Member $i',
          color: OhColors.hearth400.toARGB32(),
          createdAt: DateTime.now().add(Duration(seconds: i)),
        );
      }

      await _pump(tester, db);

      final btn = tester.widget<ElevatedButton>(
        find.byKey(const Key('startRoundButton')),
      );
      expect(btn.onPressed, isNotNull,
          reason: 'button must be enabled with 5 members');
    });
  });
}
