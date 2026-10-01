// lib/features/ranking/presentation/round_controller.dart
//
// Sequences the family ranking round: member 1 → 3 domains × 12 decisions →
// hand-off interstitial → member 2 → … → allMembersComplete.
//
// No-peek guards enforced here:
//   (a) RoundPhase never exposes individual results — only pairing or handoff.
//   (b) Hand-off interstitial phase inserted between members.
//   (c) allMembersComplete is false until every member's 3 domain sessions
//       are each at kDecisionsPerDomain, blocking the reveal route.

import 'dart:async';

import 'package:elo_engine/elo_engine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/utils/id.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/deck_image.dart';
import '../../content/domain/domain.dart';
import '../data/matches_dao.dart';
import '../data/members_dao.dart';
import '../data/rounds_dao.dart';
import '../data/sessions_dao.dart';
import '../data/unfinished_round.dart';
import '../domain/round_service.dart';

// ── State ─────────────────────────────────────────────────────────────────────

/// The phase the round screen is currently in.
enum RoundPhase {
  /// Loading data from the DB / content repository.
  loading,

  /// Presenting a pair to the current member in the current domain.
  pairing,

  /// Between members: hand-off interstitial shown ("Pass the device to …").
  handoff,

  /// All members have completed all domains — reveal can be unlocked.
  complete,

  /// An unrecoverable error occurred.
  error,
}

class RoundState {
  const RoundState({
    this.phase = RoundPhase.loading,
    this.members = const [],
    this.memberIndex = 0,
    this.domainIndex = 0,
    this.decisionCount = 0,
    this.currentPair,
    this.errorMessage,
    this.error,
    this.canUndo = false,
    this.notice,
  });

  final RoundPhase phase;

  /// One line the round screen shows under the prompt: why a Continue
  /// started a fresh round instead.
  final String? notice;

  /// Whether "Undo that" can take back the last pick: true after a pick in
  /// the current domain, false at its start (a domain's last pick moves the
  /// round on and is not undone from here).
  final bool canUndo;

  /// Ordered list of member labels.
  final List<RoundMember> members;

  /// Index into [members] for the current (or upcoming) member.
  final int memberIndex;

  /// Index into [Domain.values] for the current domain (0–2).
  final int domainIndex;

  /// Number of non-skip decisions made so far in the current domain.
  final int decisionCount;

  /// The pair currently being shown (only valid in [RoundPhase.pairing]).
  final RoundPair? currentPair;

  final String? errorMessage;

  /// The failure behind [RoundPhase.error], for the Details view only. Null
  /// for the known "not enough people" stop, which retrying cannot fix.
  final Object? error;

  // ── Derived ────────────────────────────────────────────────────────────────

  bool get allMembersComplete =>
      phase == RoundPhase.complete;

  RoundMember? get currentMember =>
      members.isNotEmpty && memberIndex < members.length
          ? members[memberIndex]
          : null;

  RoundMember? get nextMember =>
      memberIndex + 1 < members.length ? members[memberIndex + 1] : null;

  Domain get currentDomain => Domain.values[domainIndex];

  int get totalDecisionsForCurrentMember =>
      domainIndex * kDecisionsPerDomain + decisionCount;

  int get totalDecisionsExpected => 3 * kDecisionsPerDomain;

  /// Sentinel for [copyWith] — distinguishes "caller did not pass a value"
  /// from "caller explicitly passed null."
  static const _absent = Object();

  /// Returns a copy of this state with the given fields replaced.
  ///
  /// Both [currentPair] and [errorMessage] use a sentinel so that:
  ///   - Omitting the parameter retains the existing value.
  ///   - Passing `null` explicitly clears the field.
  ///
  /// Example:
  ///   `state.copyWith(currentPair: null)` → clears the pair (handoff/complete).
  ///   `state.copyWith(decisionCount: 0)` → retains existing pair + errorMessage.
  RoundState copyWith({
    RoundPhase? phase,
    List<RoundMember>? members,
    int? memberIndex,
    int? domainIndex,
    int? decisionCount,
    Object? currentPair = _absent,
    Object? errorMessage = _absent,
    Object? error = _absent,
    bool? canUndo,
    String? notice,
  }) {
    return RoundState(
      notice: notice ?? this.notice,
      canUndo: canUndo ?? this.canUndo,
      phase: phase ?? this.phase,
      members: members ?? this.members,
      memberIndex: memberIndex ?? this.memberIndex,
      domainIndex: domainIndex ?? this.domainIndex,
      decisionCount: decisionCount ?? this.decisionCount,
      currentPair: identical(currentPair, _absent)
          ? this.currentPair
          : currentPair as RoundPair?,
      errorMessage: identical(errorMessage, _absent)
          ? this.errorMessage
          : errorMessage as String?,
      error: identical(error, _absent) ? this.error : error,
    );
  }
}

class RoundMember {
  const RoundMember({required this.id, required this.label, required this.color});
  final String id;
  final String label;
  final int color;
}

class RoundPair {
  const RoundPair({
    required this.imageA,
    required this.imageB,
    required this.sessionId,
  });
  final DeckImage imageA;
  final DeckImage imageB;
  final String sessionId;
}

// ── Provider ──────────────────────────────────────────────────────────────────

/// The round controller, by whether the screen asked to pick up an
/// unfinished round (`true`, Home's Continue) or start one (`false`).
final roundControllerFamily =
    StateNotifierProvider.autoDispose.family<RoundController, RoundState, bool>(
  (ref, resume) {
    final roundsDao = ref.watch(roundsDaoProvider);
    final sessionsDao = ref.watch(sessionsDaoProvider);
    final matchesDao = ref.watch(matchesDaoProvider);
    final membersDao = ref.watch(membersDaoProvider);
    final contentRepo = ref.watch(contentRepositoryProvider);
    return RoundController(
      roundsDao: roundsDao,
      sessionsDao: sessionsDao,
      matchesDao: matchesDao,
      membersDao: membersDao,
      contentRepo: contentRepo,
      resume: resume,
    );
  },
);

/// A fresh round: the controller "Start a round" opens.
final roundControllerProvider = roundControllerFamily(false);

// ── Controller ────────────────────────────────────────────────────────────────

class RoundController extends StateNotifier<RoundState> {
  RoundController({
    required RoundsDao roundsDao,
    required SessionsDao sessionsDao,
    required MatchesDao matchesDao,
    required MembersDao membersDao,
    required ContentRepository contentRepo,
    bool resume = false,
  })  : _resume = resume,
        _roundsDao = roundsDao,
        _sessionsDao = sessionsDao,
        _matchesDao = matchesDao,
        _membersDao = membersDao,
        _contentRepo = contentRepo,
        super(const RoundState()) {
    unawaited(_init());
  }

  /// Pick up the newest unfinished round if it is for the same people.
  final bool _resume;
  final RoundsDao _roundsDao;
  final SessionsDao _sessionsDao;
  final MatchesDao _matchesDao;
  final MembersDao _membersDao;
  final ContentRepository _contentRepo;

  /// Guards against double-tap race: ensures only one [_record] call is
  /// in-flight at a time. Set to true at entry, cleared in the finally block.
  bool _processing = false;

  /// The stored match behind the last pick in the current domain, while it
  /// can still be undone. One step deep.
  String? _lastMatchId;

  // Per-member per-domain: _services[memberIndex][domainIndex]
  late List<List<RoundService>> _services;

  // Per-member per-domain session IDs for DB persistence.
  late List<List<String>> _sessionIds;

  // Domain item IDs (same for all members, per domain).
  late List<List<DeckImage>> _domainImages; // [domainIndex] → images
  late List<Map<String, DeckImage>> _domainImageMaps; // [domainIndex] → id→image

  late String _roundId;

  /// Exposed for [_RevealReadyView] to navigate to [RevealScreen].
  String get roundId => _roundId;

  Future<void> _init() async {
    try {
      // 1. Load members.
      final memberRows = await _membersDao.all();
      if (!mounted) return;
      if (memberRows.length < 2) {
        state = state.copyWith(
          phase: RoundPhase.error,
          errorMessage: 'Add at least two people before starting a round.',
        );
        return;
      }

      final members = memberRows
          .map((m) => RoundMember(id: m.id, label: m.label, color: m.color))
          .toList();

      // 2. Load deck and partition by domain.
      final deck = await _contentRepo.deck();
      if (!mounted) return;
      _domainImages = List.generate(
        Domain.values.length,
        (i) =>
            deck.where((img) => img.domain == Domain.values[i]).toList(),
      );
      _domainImageMaps = _domainImages
          .map((imgs) => {for (final img in imgs) img.id: img})
          .toList();

      // 2b. Continue: pick the unfinished round up again, but only for the
      // same people. Anyone added or removed since starts a fresh round,
      // and the screen says why.
      String? notice;
      if (_resume) {
        final unfinished =
            await findUnfinishedRound(_roundsDao.attachedDatabase);
        if (!mounted) return;
        if (unfinished != null && unfinished.isFor(members.map((m) => m.id))) {
          _resumeFrom(unfinished, members);
          return;
        }
        if (unfinished != null) {
          notice = 'A new round: the people have changed since the '
              'unfinished one.';
        }
      }

      // 3. Create a Round row.
      _roundId = secureHexId();
      await _roundsDao.create(
        id: _roundId,
        deckVersion: 1,
        createdAt: DateTime.now(),
      );
      if (!mounted) return;

      // 4. Create per-member per-domain sessions and RoundServices.
      _sessionIds = List.generate(members.length, (_) => List.filled(3, ''));
      _services = List.generate(members.length, (_) => []);

      for (var mi = 0; mi < members.length; mi++) {
        for (var di = 0; di < 3; di++) {
          final sid = secureHexId();
          _sessionIds[mi][di] = sid;
          await _sessionsDao.create(
            id: sid,
            roundId: _roundId,
            memberId: members[mi].id,
            domain: Domain.values[di].name,
            createdAt: DateTime.now(),
          );
          if (!mounted) return;
          _services[mi].add(
            RoundService(_domainImages[di].map((img) => img.id).toList()),
          );
        }
      }

      // 5. Show first pair.
      state = state.copyWith(
        notice: notice,
        phase: RoundPhase.pairing,
        members: members,
        memberIndex: 0,
        domainIndex: 0,
        decisionCount: 0,
        currentPair: _proposePair(0, 0),
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        phase: RoundPhase.error,
        errorMessage: 'The round couldn’t be set up. Nothing was lost.',
        error: e,
      );
    }
  }

  /// Rebuilds [unfinished] by replaying each session's stored picks into a
  /// fresh engine (the replay Undo uses), then shows where it stopped: the
  /// next pair, or the hand-off if the last person had just finished.
  void _resumeFrom(UnfinishedRound unfinished, List<RoundMember> members) {
    _roundId = unfinished.roundId;
    final n = Domain.values.length;
    _sessionIds = List.generate(members.length, (_) => List.filled(n, ''));
    _services = List.generate(members.length, (_) => []);
    for (var mi = 0; mi < members.length; mi++) {
      for (var di = 0; di < n; di++) {
        final session =
            unfinished.sessions[(members[mi].id, Domain.values[di].name)]!;
        _sessionIds[mi][di] = session.id;
        final service =
            RoundService(_domainImages[di].map((img) => img.id).toList());
        for (final m in unfinished.matches[session.id] ?? const []) {
          service.recordDecision(
              m.idA, m.idB, MatchOutcome.values.byName(m.outcome));
        }
        _services[mi].add(service);
      }
    }
    final p = unfinished.position([for (final m in members) m.id]);
    state = state.copyWith(
      phase: p.atHandoff ? RoundPhase.handoff : RoundPhase.pairing,
      members: members,
      memberIndex: p.memberIndex,
      domainIndex: p.domainIndex,
      decisionCount: p.atHandoff ? kDecisionsPerDomain : p.decisions,
      currentPair:
          p.atHandoff ? null : _proposePair(p.memberIndex, p.domainIndex),
      canUndo: false,
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Set the round up again after a load failure.
  Future<void> retry() async {
    if (state.phase != RoundPhase.error) return;
    state = const RoundState();
    await _init();
  }

  /// Record that Image A was preferred. Forced choice — no ties.
  Future<void> chooseA() => _record(MatchOutcome.aWins);

  /// Record that Image B was preferred. Forced choice — no ties.
  Future<void> chooseB() => _record(MatchOutcome.bWins);

  /// Record a pick made on [pair], but only if [pair] is still the one on
  /// screen. The round screen marks a pick and writes it a beat later; if
  /// Skip or Undo changed the pair in between, the pick is dropped rather
  /// than recorded against a pair nobody chose from.
  Future<void> chooseOn(RoundPair pair, MatchOutcome outcome) async {
    if (!identical(state.currentPair, pair)) return;
    await _record(outcome);
  }

  /// Skip the current pair without counting it as a decision.
  Future<void> skip() => _record(MatchOutcome.skip);

  /// Take back the last pick in the current domain (audit finding 5): its
  /// pair comes back, the count drops, and its stored match is deleted so it
  /// never reaches the Charter.
  Future<void> undo() async {
    if (_processing || state.phase != RoundPhase.pairing) return;
    final matchId = _lastMatchId;
    if (matchId == null) return;
    _processing = true;
    try {
      final mi = state.memberIndex;
      final di = state.domainIndex;
      final pairIds = _services[mi][di].undoLastDecision();
      if (pairIds == null) return;
      await _matchesDao.deleteById(matchId);
      _lastMatchId = null;
      final imgMap = _domainImageMaps[di];
      state = state.copyWith(
        decisionCount: _services[mi][di].decisionCount,
        currentPair: RoundPair(
          imageA: imgMap[pairIds.$1]!,
          imageB: imgMap[pairIds.$2]!,
          sessionId: _sessionIds[mi][di],
        ),
        canUndo: false,
      );
    } finally {
      _processing = false;
    }
  }

  /// Dismiss the hand-off interstitial and begin the next member's turn.
  Future<void> beginNextMember() async {
    if (state.phase != RoundPhase.handoff) return;
    final nextMemberIndex = state.memberIndex + 1;
    if (nextMemberIndex >= state.members.length) {
      // All members done.
      state = state.copyWith(phase: RoundPhase.complete);
      return;
    }
    state = state.copyWith(
      phase: RoundPhase.pairing,
      memberIndex: nextMemberIndex,
      domainIndex: 0,
      decisionCount: 0,
      currentPair: _proposePair(nextMemberIndex, 0),
      canUndo: false,
    );
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  Future<void> _record(MatchOutcome outcome) async {
    if (_processing) return;
    _processing = true;
    try {
    if (state.phase != RoundPhase.pairing) return;
    final pair = state.currentPair;
    if (pair == null) return;

    final mi = state.memberIndex;
    final di = state.domainIndex;
    final service = _services[mi][di];

    service.recordDecision(pair.imageA.id, pair.imageB.id, outcome);

    // Persist non-skip decisions only (skips are not decisions per spec).
    if (outcome != MatchOutcome.skip) {
      final matchId = secureHexId();
      await _matchesDao.record(
        id: matchId,
        sessionId: pair.sessionId,
        idA: pair.imageA.id,
        idB: pair.imageB.id,
        outcome: outcome.name,
      );
      _lastMatchId = matchId;

      final newCount = service.decisionCount;

      if (service.isDomainComplete) {
        // Mark session complete in DB.
        await _sessionsDao.markComplete(pair.sessionId);

        if (di < 2) {
          // More domains for this member → auto-advance.
          final nextDi = di + 1;
          _lastMatchId = null;
          state = state.copyWith(
            domainIndex: nextDi,
            decisionCount: 0,
            currentPair: _proposePair(mi, nextDi),
            canUndo: false,
          );
        } else {
          // All 3 domains done for this member.
          if (mi + 1 < state.members.length) {
            // Show hand-off interstitial for next member.
            _lastMatchId = null;
            state = state.copyWith(
              phase: RoundPhase.handoff,
              domainIndex: di,
              decisionCount: newCount,
              currentPair: null,
              canUndo: false,
            );
          } else {
            // All members done.
            _lastMatchId = null;
            state = state.copyWith(
              phase: RoundPhase.complete,
              decisionCount: newCount,
              currentPair: null,
              canUndo: false,
            );
          }
        }
      } else {
        // Still within this domain.
        state = state.copyWith(
          decisionCount: newCount,
          currentPair: _proposePair(mi, di),
          canUndo: true,
        );
      }
    } else {
      // Skip: propose a new pair, don't advance count.
      state = state.copyWith(currentPair: _proposePair(mi, di));
    }
    } finally {
      _processing = false;
    }
  }

  RoundPair? _proposePair(int mi, int di) {
    final proposal = _services[mi][di].nextPair();
    if (proposal == null) return null;
    final imgMap = _domainImageMaps[di];
    final imgA = imgMap[proposal.itemA.id]!;
    final imgB = imgMap[proposal.itemB.id]!;
    return RoundPair(
      imageA: imgA,
      imageB: imgB,
      sessionId: _sessionIds[mi][di],
    );
  }
}
