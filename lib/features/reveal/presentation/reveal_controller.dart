// lib/features/reveal/presentation/reveal_controller.dart
//
// Loads all sessions for a round, rebuilds EloSessions, runs RevealService,
// and names the through-lines. State-notifier pattern mirrors RoundController.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elo_engine/elo_engine.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/deck_image.dart';
import '../../content/domain/domain.dart';
import '../../ranking/domain/session_builder.dart';
import '../domain/reveal.dart';
import '../domain/reveal_service.dart';
import '../domain/throughline_namer.dart';

// ── State ─────────────────────────────────────────────────────────────────────

enum RevealStatus { loading, ready, error }

class RevealState {
  const RevealState({
    this.status = RevealStatus.loading,
    this.spineItems = const [],
    this.contestedItems = const [],
    this.namedThroughlines = const [],
    this.throughlineLabels = const {},
    this.spineIsFallback = false,
    this.deckById = const {},
    this.errorMessage,
  });

  final RevealStatus status;
  final List<RevealItem> spineItems;
  final List<RevealItem> contestedItems;
  final List<NamedThroughline> namedThroughlines;

  /// Maps through-line key → human-readable label (e.g. 'figure-void' →
  /// 'mass & emptiness on purpose'). Loaded from throughlines.json.
  final Map<String, String> throughlineLabels;

  final bool spineIsFallback;

  /// Keyed by image id — used by the screen to look up assetPath/title.
  final Map<String, DeckImage> deckById;

  final String? errorMessage;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final revealControllerProvider = StateNotifierProvider.autoDispose
    .family<RevealController, RevealState, String>(
  (ref, roundId) {
    return RevealController(
      roundId: roundId,
      sessionsDao: ref.watch(sessionsDaoProvider),
      matchesDao: ref.watch(matchesDaoProvider),
      contentRepo: ref.watch(contentRepositoryProvider),
    );
  },
);

// ── Controller ────────────────────────────────────────────────────────────────

class RevealController extends StateNotifier<RevealState> {
  RevealController({
    required String roundId,
    required SessionsDao sessionsDao,
    required MatchesDao matchesDao,
    required ContentRepository contentRepo,
  })  : _roundId = roundId,
        _sessionsDao = sessionsDao,
        _matchesDao = matchesDao,
        _contentRepo = contentRepo,
        super(const RevealState()) {
    unawaited(_init());
  }

  final String _roundId;
  final SessionsDao _sessionsDao;
  final MatchesDao _matchesDao;
  final ContentRepository _contentRepo;

  Future<void> _init() async {
    try {
      // 1. Load deck and throughlines.json in parallel.
      final deckFuture = _contentRepo.deck();
      final throughlinesFuture = _contentRepo.throughlines();
      final deck = await deckFuture;
      final throughlineList = await throughlinesFuture;
      if (!mounted) return;

      final deckById = {for (final d in deck) d.id: d};
      final throughlinesById = {for (final d in deck) d.id: d.throughlines};
      final throughlineLabels = {
        for (final t in throughlineList) t.key: t.label
      };

      // 2. Load sessions and group by Domain.
      final sessions = await _sessionsDao.forRound(_roundId);
      if (!mounted) return;

      // Group by domain enum value.
      final byDomain = <Domain, List<RankingSession>>{};
      for (final s in sessions) {
        final domain = Domain.values.byName(s.domain);
        (byDomain[domain] ??= []).add(s);
      }

      // 3. Batch-load all match rows in one query (avoids N+1 per-session await).
      final allSessionIds = sessions.map((s) => s.id).toList();
      final matchesBySessionId =
          await _matchesDao.forRound(allSessionIds);
      if (!mounted) return;

      // Build per-domain EloSession lists.
      final eloByDomain = <Domain, List<EloSession>>{};

      for (final entry in byDomain.entries) {
        final domain = entry.key;
        final domainImages =
            deck.where((d) => d.domain == domain).toList();
        final itemIds = domainImages.map((d) => d.id).toList();

        final eloSessions = <EloSession>[];
        for (final session in entry.value) {
          final matchRows = matchesBySessionId[session.id] ?? [];
          final eloSession = SessionBuilder.buildSession(
            itemIds: itemIds,
            matches: matchRows,
            participantId: session.memberId,
          );
          eloSessions.add(eloSession);
        }
        eloByDomain[domain] = eloSessions;
      }

      // 4. Compute reveal.
      final reveal = RevealService.compute(eloByDomain);

      // 5. Name through-lines.
      final namedThroughlines =
          ThroughlineNamer.name(reveal.spine, throughlinesById);

      if (!mounted) return;
      state = RevealState(
        status: RevealStatus.ready,
        spineItems: reveal.spine,
        contestedItems: reveal.contested,
        namedThroughlines: namedThroughlines,
        throughlineLabels: throughlineLabels,
        spineIsFallback: reveal.spineIsFallback,
        deckById: deckById,
      );
    } catch (e, st) {
      debugPrint('Reveal failed: $e\n$st');
      if (!mounted) return;
      state = const RevealState(
        status: RevealStatus.error,
        errorMessage:
            "We couldn't put your results together. Try running a round again.",
      );
    }
  }
}
