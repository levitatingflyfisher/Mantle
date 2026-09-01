// test/widget/theme_toggle_and_page_width_test.dart
//
// Fleet rulings: the theme is one tap (at most two) from every primary
// screen, and on a tablet or in the browser the phone layout is capped and
// centred instead of stretched edge to edge.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/canon_item.dart';
import 'package:mantle/features/content/domain/spot_question.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:mantle/features/ranking/presentation/members_screen.dart';
import 'package:mantle/features/solo/presentation/solo_hub_screen.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/menswear_spot_question.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/tutor_hub_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// Bundled-asset loads are real IO, which pumpAndSettle cannot wait out, so
// the hubs get in-memory content.
class _NoContent extends ContentRepository {
  @override
  Future<List<CanonItem>> canon() async => const [];
  @override
  Future<List<SpotQuestion>> spotQuestions() async => const [];
}

class _NoMenswear extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async => const [];
  @override
  Future<List<MenswearSpotQuestion>> spotQuestions() async => const [];
}

Widget _app(MantleDatabase db, Widget home) => ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        contentRepositoryProvider.overrideWithValue(_NoContent()),
        menswearRepositoryProvider.overrideWithValue(_NoMenswear()),
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

  final primaryScreens = <String, Widget>{
    'Home': const HomeScreen(),
    'Explore': const SoloHubScreen(),
    'Learn your style': const TutorHubScreen(),
    'Members': const MembersScreen(),
  };

  for (final entry in primaryScreens.entries) {
    testWidgets('${entry.key} has the theme toggle in its app bar',
        (tester) async {
      await tester.pumpWidget(_app(db, entry.value));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
            of: find.byType(AppBar), matching: find.byType(OhThemeToggle)),
        findsOneWidget,
      );
    });

    testWidgets('${entry.key} caps its content width at 1024dp',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(_app(db, entry.value));
      await tester.pumpAndSettle();

      expect(find.byType(OhPage), findsOneWidget);
      final body = tester.getRect(find.byType(OhPage));
      final content = tester.getRect(find
          .descendant(of: find.byType(OhPage), matching: find.byType(ConstrainedBox))
          .first);
      expect(content.width, lessThanOrEqualTo(OhPage.phoneMaxWidth + 1));
      expect(content.center.dx, closeTo(body.center.dx, 1));
      // The app bar still spans the window; only the content is capped.
      expect(tester.getRect(find.byType(AppBar)).width, 1024);
    });
  }

  testWidgets('picking Dark from the Home toggle saves it and applies it',
      (tester) async {
    await tester.pumpWidget(_app(db, const HomeScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(OhThemeToggle));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
        tester.element(find.byType(HomeScreen)));
    expect(await container.read(themePreferenceProvider.future),
        ThemePreference.dark);
  });
}
