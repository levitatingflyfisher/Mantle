// test/widget/app_bar_labels_test.dart
//
// Fleet ruling: a top-bar command shows an icon and a short visible label;
// a tooltip is never its only name.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:mantle/features/reveal/presentation/charter_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

class _EmptyRepo extends ContentRepository {
  @override
  Future<List<DeckImage>> deck() async => const [];
  @override
  Future<List<Throughline>> throughlines() async => const [];
}

Finder _barLabel(String text) => find.descendant(
      of: find.byType(AppBar),
      matching: find.text(text),
    );

void main() {
  late MantleDatabase db;
  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });
  tearDown(() async => db.close());

  testWidgets('Home names Settings in its app bar', (tester) async {
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: MaterialApp(theme: OhTheme.light(), home: const HomeScreen()),
    ));
    await tester.pumpAndSettle();

    expect(_barLabel('Settings'), findsOneWidget);
    expect(find.byType(IconButton), findsNothing,
        reason: 'no icon-only command left in the bar');
  });

  testWidgets('Charter names its print command in its app bar',
      (tester) async {
    final container =
        ProviderContainer(overrides: [databaseProvider.overrideWithValue(db)]);
    addTearDown(container.dispose);
    final charter = await container
        .read(chartersDaoProvider)
        .createFromReveal('round-1', const [], const [], const []);

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_EmptyRepo()),
      ],
      child: MaterialApp(
          theme: OhTheme.light(), home: CharterScreen(charter: charter)),
    ));
    await tester.pumpAndSettle();

    expect(_barLabel('Print'), findsOneWidget);
    expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.byType(IconButton)),
        findsNothing);
  });
}
