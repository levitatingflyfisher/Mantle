// test/widget/error_states_test.dart
//
// Every failure state keeps its screen's AppBar (so there is a way out),
// offers Try again, and never prints the raw exception. The reveal's error
// says the household's choices are saved and retries the same round rather
// than telling them to play it again.

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/canon_item.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/content/domain/spot_question.dart';
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/ranking/presentation/round_screen.dart';
import 'package:mantle/features/reveal/presentation/reveal_screen.dart';
import 'package:mantle/features/solo/presentation/solo_hub_screen.dart';
import 'package:mantle/features/tutor/content/data/menswear_repository.dart';
import 'package:mantle/features/tutor/content/domain/menswear_spot_question.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/presentation/lean_round_screen.dart';
import 'package:mantle/features/tutor/presentation/tutor_hub_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

const _secret = 'SECRET-internal-detail';

/// Fails the first [failures] calls of every method, then serves a small deck.
class _FlakyContent extends ContentRepository {
  _FlakyContent();
  final int failures = 1;
  int _calls = 0;

  void _maybeThrow() {
    _calls++;
    if (_calls <= failures) throw StateError(_secret);
  }

  @override
  Future<List<DeckImage>> deck() async {
    _maybeThrow();
    return [
      for (final domain in Domain.values)
        for (var i = 0; i < 6; i++)
          DeckImage(
            id: '${domain.name}_$i',
            domain: domain,
            assetPath: 'assets/images/deck/${domain.name}_$i.jpg',
            features: const [],
            throughlines: const [],
            license: 'CC0',
            institution: 'Test',
            sourceUrl: '',
            title: 'Test $i',
            accessionId: '${domain.name}_$i',
            creator: 'Test',
          ),
    ];
  }

  @override
  Future<List<Throughline>> throughlines() async => const [];

  @override
  Future<List<CanonItem>> canon() async {
    _maybeThrow();
    return const [];
  }

  @override
  Future<List<SpotQuestion>> spotQuestions() async => const [];
}

class _FlakyMenswear extends MenswearRepository {
  _FlakyMenswear();
  final int failures = 1;
  int _calls = 0;

  @override
  Future<List<MenswearTerm>> terms() async {
    _calls++;
    if (_calls <= failures) throw StateError(_secret);
    return const [];
  }

  @override
  Future<List<MenswearSpotQuestion>> spotQuestions() async => const [];

  @override
  Future<List<MenswearTerm>> leanPool() async => throw StateError(_secret);
}

Widget _app(
  MantleDatabase db,
  Widget home, {
  ContentRepository? content,
  MenswearRepository? menswear,
}) =>
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        if (content != null) contentRepositoryProvider.overrideWithValue(content),
        if (menswear != null)
          menswearRepositoryProvider.overrideWithValue(menswear),
      ],
      child: MaterialApp(theme: OhTheme.light(), home: home),
    );

Future<void> _seedTwoMembers(MantleDatabase db) async {
  await db.membersDao.add(
      id: 'm1', label: 'Aria', color: 0xFF4CAF50, createdAt: DateTime(2026));
  await db.membersDao.add(
      id: 'm2', label: 'Ben', color: 0xFF2196F3, createdAt: DateTime(2026, 2));
}

void _expectDoorAndNoLeak() {
  expect(find.byType(AppBar), findsOneWidget,
      reason: 'the error branch keeps its AppBar, so there is a way out');
  expect(find.byType(OhErrorState), findsOneWidget);
  expect(find.text('Try again'), findsOneWidget);
  expect(find.textContaining(_secret), findsNothing,
      reason: 'the raw exception never reaches the screen');
}

void main() {
  late MantleDatabase db;
  setUp(() => db = MantleDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() async => db.close());

  testWidgets('Reveal error says the choices are saved and retries the round',
      (tester) async {
    await _seedTwoMembers(db);
    await db.roundsDao
        .create(id: 'r1', deckVersion: 1, createdAt: DateTime(2026));
    for (final d in Domain.values) {
      for (final m in ['m1', 'm2']) {
        await db.sessionsDao.create(
            id: 's-${d.name}-$m',
            roundId: 'r1',
            memberId: m,
            domain: d.name,
            createdAt: DateTime(2026));
      }
    }

    await tester.pumpWidget(
        _app(db, const RevealScreen(roundId: 'r1'), content: _FlakyContent()));
    await tester.pumpAndSettle();

    _expectDoorAndNoLeak();
    expect(find.textContaining('saved'), findsOneWidget);
    expect(find.textContaining('round again'), findsNothing,
        reason: 'never tell the household to redo work that is stored');

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();

    expect(find.byType(OhErrorState), findsNothing);
    expect(find.byKey(const Key('reveal-spine')), findsOneWidget,
        reason: 'retry assembles the same round without a new sitting');
  });

  testWidgets('Round load failure keeps an AppBar, retries, hides the error',
      (tester) async {
    await _seedTwoMembers(db);
    await tester
        .pumpWidget(_app(db, const RoundScreen(), content: _FlakyContent()));
    await tester.pumpAndSettle();

    _expectDoorAndNoLeak();

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(OhErrorState), findsNothing);
    expect(find.text('Which is more us?'), findsOneWidget);
  });

  testWidgets('Explore hub error keeps its AppBar and a Try again',
      (tester) async {
    await tester
        .pumpWidget(_app(db, const SoloHubScreen(), content: _FlakyContent()));
    await tester.pumpAndSettle();

    _expectDoorAndNoLeak();

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(OhErrorState), findsNothing);
  });

  testWidgets('Tutor hub error keeps its AppBar and a Try again',
      (tester) async {
    await tester.pumpWidget(
        _app(db, const TutorHubScreen(), menswear: _FlakyMenswear()));
    await tester.pumpAndSettle();

    _expectDoorAndNoLeak();

    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.byType(OhErrorState), findsNothing);
  });

  testWidgets('Lean round failure never prints the exception', (tester) async {
    await tester.pumpWidget(_app(db, const LeanRoundScreen(memberId: 'm1'),
        menswear: _FlakyMenswear()));
    await tester.pumpAndSettle();

    _expectDoorAndNoLeak();
  });
}
