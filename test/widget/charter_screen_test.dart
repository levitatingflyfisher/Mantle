import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/reveal/domain/throughline_namer.dart';
import 'package:mantle/features/reveal/presentation/charter_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// A content repo that knows one through-line's human label.
class _LabeledRepo extends ContentRepository {
  @override
  Future<List<DeckImage>> deck() async => const [];
  @override
  Future<List<Throughline>> throughlines() async =>
      const [Throughline(key: 'figure-void', label: 'mass & emptiness')];
}

void main() {
  testWidgets(
      'CharterScreen renders the human through-line label, not the raw key',
      (tester) async {
    final db = MantleDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);

    // A charter that stores the raw through-line key 'figure-void'.
    final charter = await container.read(chartersDaoProvider).createFromReveal(
      'round-1',
      const [],
      const [],
      const [NamedThroughline(key: 'figure-void', spineCount: 2)],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_LabeledRepo()),
      ],
      child: MaterialApp(
        theme: OhTheme.light(),
        home: CharterScreen(charter: charter),
      ),
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('mass & emptiness'), findsOneWidget,
        reason: 'the human label must be shown');
    expect(find.textContaining('figure-void'), findsNothing,
        reason: 'the raw key must not leak into the charter');
  });
}
