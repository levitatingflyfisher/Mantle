import 'dart:async';

import 'package:elo_engine/elo_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../ranking/data/matches_dao.dart';
import '../../ranking/data/sessions_dao.dart';
import '../../ranking/domain/session_builder.dart';
import '../../reveal/domain/reveal.dart';
import '../../reveal/domain/reveal_service.dart';
import '../content/data/menswear_repository.dart';
import '../content/domain/menswear_term.dart';
import '../domain/axis_tally.dart';

enum MenswearCharterStatus { loading, ready, error }

class MenswearCharterState {
  const MenswearCharterState({
    this.status = MenswearCharterStatus.loading,
    this.spine = const [],
    this.contested = const [],
    this.spineIsFallback = false,
    this.throughlinePoles = const [],
    this.termsById = const {},
    this.errorMessage,
  });

  final MenswearCharterStatus status;
  final List<RevealItem> spine;
  final List<RevealItem> contested;
  final bool spineIsFallback;
  final List<AxisPole> throughlinePoles;
  final Map<String, MenswearTerm> termsById;
  final String? errorMessage;
}

final menswearCharterControllerProvider = StateNotifierProvider.autoDispose
    .family<MenswearCharterController, MenswearCharterState, String>(
  (ref, roundId) => MenswearCharterController(
    roundId: roundId,
    sessionsDao: ref.watch(sessionsDaoProvider),
    matchesDao: ref.watch(matchesDaoProvider),
    repo: ref.watch(menswearRepositoryProvider),
  ),
);

/// Builds the family menswear Charter: both members' lean picks over one
/// `'menswear'` bucket → the generalized `RevealService` (Spine/Contested) →
/// through-lines via `AxisTally` on the merged choices.
class MenswearCharterController extends StateNotifier<MenswearCharterState> {
  MenswearCharterController({
    required this.roundId,
    required SessionsDao sessionsDao,
    required MatchesDao matchesDao,
    required MenswearRepository repo,
  })  : _sessionsDao = sessionsDao,
        _matchesDao = matchesDao,
        _repo = repo,
        super(const MenswearCharterState()) {
    unawaited(_init());
  }

  final String roundId;
  final SessionsDao _sessionsDao;
  final MatchesDao _matchesDao;
  final MenswearRepository _repo;

  Future<void> _init() async {
    try {
      final pool = await _repo.leanPool();
      final terms = await _repo.terms();
      if (!mounted) return;
      final itemIds = pool.map((t) => t.id).toList();
      final byId = {for (final t in terms) t.id: t};

      final sessions = await _sessionsDao.forRound(roundId);
      final menswearSessions =
          sessions.where((s) => s.domain == kMenswearDomainKey).toList();
      final matchesBySession = await _matchesDao
          .forRound(menswearSessions.map((s) => s.id).toList());
      if (!mounted) return;

      final eloSessions = <EloSession>[];
      final allChosen = <MenswearTerm>[];
      for (final s in menswearSessions) {
        final rows = matchesBySession[s.id] ?? const [];
        eloSessions.add(SessionBuilder.buildSession(
          itemIds: itemIds,
          matches: rows,
          participantId: s.memberId,
        ));
        for (final m in rows) {
          final winnerId = m.outcome == 'aWins' ? m.idA : m.idB;
          final t = byId[winnerId];
          if (t != null) allChosen.add(t);
        }
      }

      // Single 'menswear' bucket — one facet-agnostic Spine over the pool.
      final reveal =
          RevealService.compute({kMenswearDomainKey: eloSessions});
      final poles = AxisTally.throughlinePoles(
          AxisTally.positionFromChoices(allChosen));

      if (!mounted) return;
      state = MenswearCharterState(
        status: MenswearCharterStatus.ready,
        spine: reveal.spine,
        contested: reveal.contested,
        spineIsFallback: reveal.spineIsFallback,
        throughlinePoles: poles,
        termsById: byId,
      );
    } catch (e, st) {
      debugPrint('Menswear charter failed: $e\n$st');
      if (!mounted) return;
      state = const MenswearCharterState(
        status: MenswearCharterStatus.error,
        errorMessage: "We couldn't assemble your House Charter.",
      );
    }
  }
}
