import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/archetype.dart';
import 'package:mantle/features/tutor/content/domain/menswear_spot_question.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/learn_screen.dart';
import 'package:mantle/features/tutor/presentation/menswear_charter_start_screen.dart';
import 'package:mantle/features/tutor/presentation/menswear_spot_screen.dart';
import 'package:mantle/features/tutor/presentation/tutor_hub_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

MenswearTerm _t(String id) => MenswearTerm(
    id: id,
    facet: 'garment',
    term: id,
    handle: null,
    gloss: '',
    quickRead: '',
    closerRead: '',
    axisSignals: const [],
    plateHint: '');

MenswearSpotQuestion _q(String id) => MenswearSpotQuestion(
    id: id,
    facet: 'garment',
    promptText: 'Which is the $id?',
    plateA: 'polo',
    plateB: 'henley',
    correctSide: 'A',
    explanation: '');

class _FakeMenswearRepository extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async => [_t('polo'), _t('henley')];
  @override
  Future<List<MenswearTerm>> leanPool() async => [_t('polo'), _t('henley')];
  @override
  Future<List<Archetype>> archetypes() async => const [];
  @override
  Future<List<MenswearSpotQuestion>> spotQuestions() async => [_q('spot-1')];
}

/// Terms load fine, but the spot-question asset load fails — exercises the
/// "spot failure must not block the hub" resilience path.
class _SpotFailsMenswearRepository extends MenswearRepository {
  @override
  Future<List<MenswearTerm>> terms() async => [_t('polo'), _t('henley')];
  @override
  Future<List<MenswearTerm>> leanPool() async => [_t('polo'), _t('henley')];
  @override
  Future<List<Archetype>> archetypes() async => const [];
  @override
  Future<List<MenswearSpotQuestion>> spotQuestions() async =>
      throw Exception('spot asset missing');
}

Widget _build(
  MantleDatabase db, {
  Widget home = const HomeScreen(),
  MenswearRepository? menswearRepository,
}) =>
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
        menswearRepositoryProvider
            .overrideWithValue(menswearRepository ?? _FakeMenswearRepository()),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: home),
    );

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('home leads with a tutor entry that opens the tutor hub',
      (tester) async {
    await tester.pumpWidget(_build(db));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('home-tutor-card')), findsOneWidget);
    await tester.tap(find.byKey(const Key('home-tutor-card')));
    await tester.pumpAndSettle();
    expect(find.byType(TutorHubScreen), findsOneWidget);
  });

  testWidgets('tutor hub shows Learn / Find your lean / Field Guide',
      (tester) async {
    await tester.pumpWidget(_build(db, home: const TutorHubScreen()));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('tutor-learn')), findsOneWidget);
    expect(find.byKey(const Key('tutor-lean')), findsOneWidget);
    expect(find.byKey(const Key('tutor-field-guide')), findsOneWidget);
    expect(find.byKey(const Key('tutor-charter')), findsOneWidget);
  });

  testWidgets('tutor-charter card opens the House Charter start screen',
      (tester) async {
    await tester.pumpWidget(_build(db, home: const TutorHubScreen()));
    await tester.pumpAndSettle();

    // Audit finding 3: the tutor made a second "Your House Charter" from a
    // different deck. Its artifact has its own name, used nowhere else.
    expect(find.text('Your Wardrobe Charter'), findsOneWidget);
    expect(find.text('Your House Charter'), findsNothing);

    await tester.tap(find.byKey(const Key('tutor-charter')));
    await tester.pumpAndSettle();

    expect(find.byType(MenswearCharterStartScreen), findsOneWidget);
    expect(find.text('Your Wardrobe Charter'), findsOneWidget);
  });

  test('the tutor never calls its artifact a House Charter', () {
    final offenders = <String>[];
    for (final f in Directory('lib/features/tutor').listSync(recursive: true)) {
      if (f is! File || !f.path.endsWith('.dart')) continue;
      final lines = f.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i].trimLeft();
        if (l.startsWith('//')) continue;
        if (RegExp(r"'[^']*House Charter[^']*'").hasMatch(l)) {
          offenders.add('${f.path}:${i + 1}');
        }
      }
    }
    expect(offenders, isEmpty);
  });

  testWidgets('Learn carries spot questions through to a reachable Quiz',
      (tester) async {
    await tester.pumpWidget(_build(db, home: const TutorHubScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tutor-learn')));
    await tester.pumpAndSettle();

    expect(find.byType(LearnScreen), findsOneWidget);
    expect(find.byKey(const Key('learn-open-quiz')), findsOneWidget);

    await tester.tap(find.byKey(const Key('learn-open-quiz')));
    await tester.pumpAndSettle();

    expect(find.byType(MenswearSpotScreen), findsOneWidget);
  });

  testWidgets(
      'a spot-load failure does not block the hub — Learn just has no Quiz button',
      (tester) async {
    await tester.pumpWidget(_build(db,
        home: const TutorHubScreen(),
        menswearRepository: _SpotFailsMenswearRepository()));
    await tester.pumpAndSettle();

    // Hub still renders (not the error state) — terms loaded fine.
    expect(find.byKey(const Key('tutor-learn')), findsOneWidget);
    expect(find.byType(OhErrorState), findsNothing);

    await tester.tap(find.byKey(const Key('tutor-learn')));
    await tester.pumpAndSettle();

    expect(find.byType(LearnScreen), findsOneWidget);
    expect(find.byKey(const Key('learn-open-quiz')), findsNothing);
  });
}
