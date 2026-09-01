import 'dart:async';

import 'package:elo_engine/elo_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/id.dart';
import '../../ranking/data/matches_dao.dart';
import '../../ranking/data/rounds_dao.dart';
import '../../ranking/data/sessions_dao.dart';
import '../../ranking/domain/round_service.dart';
import '../content/data/menswear_repository.dart';
import '../content/domain/menswear_term.dart';

/// Number of non-skip lean picks before the round completes. Set above
/// [kMinPicksForArchetype] (20) so a completed round always clears the Field
/// Guide's confidence gate.
const int kLeanPickTarget = 24;

enum LeanRoundPhase { loading, pairing, complete, error }

class LeanPair {
  const LeanPair(this.termA, this.termB);
  final MenswearTerm termA;
  final MenswearTerm termB;
}

class LeanRoundState {
  const LeanRoundState({
    this.phase = LeanRoundPhase.loading,
    this.currentPair,
    this.pickCount = 0,
    this.target = kLeanPickTarget,
    this.errorMessage,
    this.error,
  });

  final LeanRoundPhase phase;
  final LeanPair? currentPair;
  final int pickCount;
  final int target;
  final String? errorMessage;

  /// The failure behind [LeanRoundPhase.error], for the Details view only.
  final Object? error;

  double get progress => target == 0 ? 0 : (pickCount / target).clamp(0.0, 1.0);

  static const _absent = Object();

  LeanRoundState copyWith({
    LeanRoundPhase? phase,
    Object? currentPair = _absent,
    int? pickCount,
    int? target,
    Object? errorMessage = _absent,
    Object? error = _absent,
  }) =>
      LeanRoundState(
        phase: phase ?? this.phase,
        currentPair: identical(currentPair, _absent)
            ? this.currentPair
            : currentPair as LeanPair?,
        pickCount: pickCount ?? this.pickCount,
        target: target ?? this.target,
        errorMessage: identical(errorMessage, _absent)
            ? this.errorMessage
            : errorMessage as String?,
        error: identical(error, _absent) ? this.error : error,
      );
}

final leanRoundControllerProvider = StateNotifierProvider.autoDispose
    .family<LeanRoundController, LeanRoundState,
        ({String memberId, String? roundId})>(
  (ref, args) => LeanRoundController(
    memberId: args.memberId,
    roundId: args.roundId,
    roundsDao: ref.watch(roundsDaoProvider),
    sessionsDao: ref.watch(sessionsDaoProvider),
    matchesDao: ref.watch(matchesDaoProvider),
    repo: ref.watch(menswearRepositoryProvider),
  ),
);

/// Drives a single-member menswear lean round over the curated lean pool.
/// Mirrors `RoundController`'s `_processing` double-tap guard and `mounted`
/// checks, but is menswear/String-scoped and completes on a pick counter
/// ([kLeanPickTarget]) rather than the legacy per-domain counter.
class LeanRoundController extends StateNotifier<LeanRoundState> {
  LeanRoundController({
    required this.memberId,
    String? roundId,
    required RoundsDao roundsDao,
    required SessionsDao sessionsDao,
    required MatchesDao matchesDao,
    required MenswearRepository repo,
  })  : _externalRoundId = roundId,
        _roundsDao = roundsDao,
        _sessionsDao = sessionsDao,
        _matchesDao = matchesDao,
        _repo = repo,
        super(const LeanRoundState()) {
    unawaited(_init());
  }

  final String memberId;
  final String? _externalRoundId;
  final RoundsDao _roundsDao;
  final SessionsDao _sessionsDao;
  final MatchesDao _matchesDao;
  final MenswearRepository _repo;

  bool _processing = false;
  late RoundService _service;
  late Map<String, MenswearTerm> _byId;
  late String _roundId;
  late String _sessionId;

  String get roundId => _roundId;

  Future<void> _init() async {
    try {
      final pool = await _repo.leanPool();
      if (!mounted) return;
      if (pool.length < 2) {
        state = state.copyWith(
            phase: LeanRoundPhase.error,
            errorMessage: 'The lean pool is too small to run a round.');
        return;
      }
      _byId = {for (final t in pool) t.id: t};
      _service = RoundService(pool.map((t) => t.id).toList());

      if (_externalRoundId != null) {
        _roundId = _externalRoundId;
      } else {
        _roundId = secureHexId();
        await _roundsDao.create(
            id: _roundId, deckVersion: 1, createdAt: DateTime.now());
        if (!mounted) return;
      }

      _sessionId = secureHexId();
      await _sessionsDao.create(
        id: _sessionId,
        roundId: _roundId,
        memberId: memberId,
        domain: kMenswearDomainKey,
        createdAt: DateTime.now(),
      );
      if (!mounted) return;

      state = state.copyWith(
          phase: LeanRoundPhase.pairing, currentPair: _proposePair());
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
          phase: LeanRoundPhase.error,
          errorMessage: 'The round couldn’t start. Nothing was lost.',
          error: e);
    }
  }

  Future<void> chooseA() => _record(MatchOutcome.aWins);
  Future<void> chooseB() => _record(MatchOutcome.bWins);
  Future<void> skip() => _record(MatchOutcome.skip);

  Future<void> _record(MatchOutcome outcome) async {
    if (_processing) return;
    _processing = true;
    try {
      if (state.phase != LeanRoundPhase.pairing) return;
      final pair = state.currentPair;
      if (pair == null) return;

      _service.recordDecision(pair.termA.id, pair.termB.id, outcome);

      if (outcome == MatchOutcome.skip) {
        state = state.copyWith(currentPair: _proposePair());
        return;
      }

      await _matchesDao.record(
        sessionId: _sessionId,
        idA: pair.termA.id,
        idB: pair.termB.id,
        outcome: outcome.name,
      );
      final newCount = state.pickCount + 1;

      if (newCount >= state.target) {
        await _sessionsDao.markComplete(_sessionId);
        state = state.copyWith(
            phase: LeanRoundPhase.complete,
            pickCount: newCount,
            currentPair: null);
      } else {
        state = state.copyWith(
            pickCount: newCount, currentPair: _proposePair());
      }
    } finally {
      _processing = false;
    }
  }

  LeanPair? _proposePair() {
    final p = _service.nextPair();
    if (p == null) return null;
    return LeanPair(_byId[p.itemA.id]!, _byId[p.itemB.id]!);
  }
}
