import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/db/database.dart';
import 'package:mantle/core/providers.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/content/data/content_repository.dart';
import 'package:mantle/features/content/domain/deck_image.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/content/domain/throughline.dart';
import 'package:mantle/features/reveal/domain/reveal.dart';
import 'package:mantle/features/reveal/domain/throughline_namer.dart';
import 'package:mantle/features/reveal/presentation/reveal_controller.dart';
import 'package:mantle/features/reveal/presentation/reveal_screen.dart';
import 'package:openhearth_design/openhearth_design.dart';

// ── Fake content repos ────────────────────────────────────────────────────────

class _FakeContentRepository extends ContentRepository {
  final Map<String, List<String>> throughlineMap;

  _FakeContentRepository({this.throughlineMap = const {}});

  static List<DeckImage> buildDeck(
      {Map<String, List<String>> throughlineMap = const {}}) {
    return [
      for (final domain in Domain.values)
        for (var i = 0; i < 8; i++)
          DeckImage(
            id: '${domain.name}_$i',
            domain: domain,
            assetPath: 'assets/images/deck/${domain.name}_$i.jpg',
            features: [],
            throughlines: throughlineMap['${domain.name}_$i'] ?? [],
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
  Future<List<DeckImage>> deck() async =>
      buildDeck(throughlineMap: throughlineMap);

  @override
  Future<List<Throughline>> throughlines() async => const [];
}

/// A content repo with only 1 item per domain (3 items total).
///
/// With 1 item: combinedScore = 1.0 = midpoint (1+1)/2.0, so `> midpoint`
/// is false for every item. This guarantees spineIsFallback = true.
class _TinyContentRepository extends ContentRepository {
  @override
  Future<List<DeckImage>> deck() async => [
        for (final domain in Domain.values)
          DeckImage(
            id: '${domain.name}_only',
            domain: domain,
            assetPath: 'assets/images/deck/${domain.name}_only.jpg',
            features: [],
            throughlines: [],
            license: 'CC0',
            institution: 'Test',
            sourceUrl: '',
            title: 'Only ${domain.name}',
            accessionId: '${domain.name}_only',
            creator: 'Test',
          ),
      ];

  @override
  Future<List<Throughline>> throughlines() async => const [];
}

// ── Helper ────────────────────────────────────────────────────────────────────

Widget _buildRevealScreen(
  MantleDatabase db,
  String roundId, {
  ContentRepository? fakeRepo,
}) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      contentRepositoryProvider
          .overrideWithValue(fakeRepo ?? _FakeContentRepository()),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: RevealScreen(roundId: roundId),
    ),
  );
}

/// Seed a round with two members and empty sessions (no matches).
Future<void> _seedRoundWithSessions(MantleDatabase db, String roundId) async {
  await db.membersDao.add(
      id: 'member-1',
      label: 'Alice',
      color: 0xFF4CAF50,
      createdAt: DateTime(2026, 1, 1));
  await db.membersDao.add(
      id: 'member-2',
      label: 'Bob',
      color: 0xFF2196F3,
      createdAt: DateTime(2026, 1, 1));
  await db.roundsDao
      .create(id: roundId, deckVersion: 1, createdAt: DateTime(2026, 1, 1));
  for (final domain in Domain.values) {
    await db.sessionsDao.create(
      id: 'session-${domain.name}-1',
      roundId: roundId,
      memberId: 'member-1',
      domain: domain.name,
      createdAt: DateTime(2026, 1, 1),
    );
    await db.sessionsDao.create(
      id: 'session-${domain.name}-2',
      roundId: roundId,
      memberId: 'member-2',
      domain: domain.name,
      createdAt: DateTime(2026, 1, 1),
    );
  }
}

// ── Static controller for label tests ─────────────────────────────────────────

/// A RevealController that immediately holds a fixed state — no async loading.
class _StaticRevealController extends StateNotifier<RevealState>
    implements RevealController {
  _StaticRevealController(super.state);
}

Widget _buildRevealScreenWithState(MantleDatabase db, RevealState revealState) {
  return ProviderScope(
    overrides: [
      databaseProvider.overrideWithValue(db),
      themePreferenceProvider.overrideWith((_) async => ThemePreference.light),
      contentRepositoryProvider
          .overrideWithValue(_FakeContentRepository()),
      revealControllerProvider('static-round').overrideWith(
        (ref) => _StaticRevealController(revealState),
      ),
    ],
    child: MaterialApp(
      theme: OhTheme.light(),
      home: const RevealScreen(roundId: 'static-round'),
    ),
  );
}

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late MantleDatabase db;

  setUp(() {
    db = MantleDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  testWidgets(
      'empty contested → "Where the House Argues" section is hidden',
      (tester) async {
    await _seedRoundWithSessions(db, 'round-1');
    // No matches → all items at equal ranks → no contested items
    await tester.pumpWidget(_buildRevealScreen(db, 'round-1'));
    await tester.pumpAndSettle();

    expect(find.text('Where the House Argues'), findsNothing);
  });

  testWidgets(
      'spineIsFallback → warm fallback copy is shown when spine is a fallback',
      (tester) async {
    // Use a content repo with only 2 items per domain (fewer than
    // kMinSpineCandidates=3 total), which forces the fallback path because
    // there can be at most 1 candidate per domain (only 1 item above midpoint).
    final tinyRepo = _TinyContentRepository();
    await _seedRoundWithSessions(db, 'round-1');
    await tester.pumpWidget(
        _buildRevealScreen(db, 'round-1', fakeRepo: tinyRepo));
    await tester.pumpAndSettle();

    expect(
        find.textContaining('still finding your common ground'),
        findsOneWidget);
  });

  testWidgets(
      'no qualifying through-lines → through-line sentence is omitted',
      (tester) async {
    await _seedRoundWithSessions(db, 'round-1');
    // Fake repo has no throughlines → namedThroughlines will be empty
    await tester.pumpWidget(
      _buildRevealScreen(
        db,
        'round-1',
        fakeRepo: _FakeContentRepository(throughlineMap: {}),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('A thread runs through'), findsNothing);
  });

  testWidgets('reveal screen renders spine grid key', (tester) async {
    await _seedRoundWithSessions(db, 'round-1');
    await tester.pumpWidget(_buildRevealScreen(db, 'round-1'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('reveal-spine')), findsOneWidget);
  });

  testWidgets('"Make our Charter" button is present', (tester) async {
    await _seedRoundWithSessions(db, 'round-1');
    await tester.pumpWidget(_buildRevealScreen(db, 'round-1'));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('make-charter-button')), findsOneWidget);
  });

  testWidgets(
      'through-line sentence shows human label, not raw key',
      (tester) async {
    // Build a ready state with one named through-line and its label map.
    const revealState = RevealState(
      status: RevealStatus.ready,
      spineItems: [
        RevealItem(
          id: 'architecture_0',
          domain: Domain.architecture,
          combinedScore: 7.0,
          agreement: 0.90,
        ),
      ],
      namedThroughlines: [
        NamedThroughline(key: 'figure-void', spineCount: 2),
      ],
      throughlineLabels: {
        'figure-void': 'mass & emptiness on purpose',
        'material-honesty': 'say only what the structure needs',
      },
    );

    await tester.pumpWidget(_buildRevealScreenWithState(db, revealState));
    await tester.pumpAndSettle();

    // Must show the human label.
    expect(
      find.textContaining('mass & emptiness on purpose'),
      findsOneWidget,
    );
    // Must NOT show the raw key.
    expect(find.textContaining('figure-void'), findsNothing);
  });
}
