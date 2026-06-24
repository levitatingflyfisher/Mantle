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
  });

  final RoundPhase phase;

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
  }) {
    return RoundState(
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

final roundControllerProvider =
    StateNotifierProvider.autoDispose<RoundController, RoundState>(
  (ref) {
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
    );
  },
);

// ── Controller ────────────────────────────────────────────────────────────────

class RoundController extends StateNotifier<RoundState> {
  RoundController({
    required RoundsDao roundsDao,
    required SessionsDao sessionsDao,
    required MatchesDao matchesDao,
    required MembersDao membersDao,
    required ContentRepository contentRepo,
  })  : _roundsDao = roundsDao,
        _sessionsDao = sessionsDao,
        _matchesDao = matchesDao,
        _membersDao = membersDao,
        _contentRepo = contentRepo,
        super(const RoundState()) {
    unawaited(_init());
  }

  final RoundsDao _roundsDao;
  final SessionsDao _sessionsDao;
  final MatchesDao _matchesDao;
  final MembersDao _membersDao;
  final ContentRepository _contentRepo;

  /// Guards against double-tap race: ensures only one [_record] call is
  /// in-flight at a time. Set to true at entry, cleared in the finally block.
  bool _processing = false;

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
          errorMessage: 'Need at least 2 members to start a round.',
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
        errorMessage: e.toString(),
      );
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Record that Image A was preferred. Forced choice — no ties.
  Future<void> chooseA() => _record(MatchOutcome.aWins);

  /// Record that Image B was preferred. Forced choice — no ties.
  Future<void> chooseB() => _record(MatchOutcome.bWins);

  /// Skip the current pair without counting it as a decision.
  Future<void> skip() => _record(MatchOutcome.skip);

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
      await _matchesDao.record(
        sessionId: pair.sessionId,
        idA: pair.imageA.id,
        idB: pair.imageB.id,
        outcome: outcome.name,
      );

      final newCount = service.decisionCount;

      if (service.isDomainComplete) {
        // Mark session complete in DB.
        await _sessionsDao.markComplete(pair.sessionId);

        if (di < 2) {
          // More domains for this member → auto-advance.
          final nextDi = di + 1;
          state = state.copyWith(
            domainIndex: nextDi,
            decisionCount: 0,
            currentPair: _proposePair(mi, nextDi),
          );
        } else {
          // All 3 domains done for this member.
          if (mi + 1 < state.members.length) {
            // Show hand-off interstitial for next member.
            state = state.copyWith(
              phase: RoundPhase.handoff,
              domainIndex: di,
              decisionCount: newCount,
              currentPair: null,
            );
          } else {
            // All members done.
            state = state.copyWith(
              phase: RoundPhase.complete,
              decisionCount: newCount,
              currentPair: null,
            );
          }
        }
      } else {
        // Still within this domain.
        state = state.copyWith(
          decisionCount: newCount,
          currentPair: _proposePair(mi, di),
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
