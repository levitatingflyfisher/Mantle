// test/widget/member_identity_test.dart
//
// mind-18 / hackers-08: member colour was the only mark of whose turn it
// was, the default first two swatches (terracotta and sage) collapse for a
// deuteranope and in greyscale, and the swatches were read out as "Member
// colour 3". Every member dot now carries the member's initial, and every
// swatch has a name.

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
import 'package:mantle/features/ranking/presentation/members_screen.dart';
import 'package:mantle/features/ranking/presentation/round_screen.dart';
import 'package:mantle/widgets/member_dot.dart';
import 'package:openhearth_design/openhearth_design.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  return ((la > lb ? la : lb) + 0.05) / ((la > lb ? lb : la) + 0.05);
}

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

Widget _app(MantleDatabase db, Widget home) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_Deck()),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: home),
    );

void main() {
  late MantleDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  Future<void> seed() async {
    await db.membersDao.add(
        id: 'm1',
        label: 'aria',
        color: memberSwatches[0].color.toARGB32(),
        createdAt: DateTime(2026));
    await db.membersDao.add(
        id: 'm2',
        label: 'Ben',
        color: memberSwatches[1].color.toARGB32(),
        createdAt: DateTime(2026, 2));
  }

  test('every swatch has a name, and its initial reads at 4.5:1', () {
    expect(memberSwatches.map((s) => s.name).toSet(), hasLength(memberSwatches.length));
    for (final s in memberSwatches) {
      expect(_contrast(s.color, MemberDot.initialColorOn(s.color)),
          greaterThanOrEqualTo(4.5),
          reason: '${s.name} initial');
    }
  });

  testWidgets('the member list shows each person by initial as well as colour',
      (tester) async {
    await seed();
    await tester.pumpWidget(_app(db, const MembersScreen()));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(MemberDot), matching: find.text('A')),
        findsOneWidget);
    expect(find.descendant(of: find.byType(MemberDot), matching: find.text('B')),
        findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Member colour')), findsNothing);
    expect(find.bySemanticsLabel(RegExp(memberSwatches[1].name)), findsWidgets);
  });

  testWidgets('the round names whose turn it is by initial and name',
      (tester) async {
    await seed();
    await tester.pumpWidget(_app(db, const RoundScreen()));
    await tester.pumpAndSettle();

    expect(find.descendant(of: find.byType(MemberDot), matching: find.text('A')),
        findsOneWidget);
    expect(find.text('aria'), findsOneWidget);
  });
}
