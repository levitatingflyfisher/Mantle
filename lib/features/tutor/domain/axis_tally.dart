import 'dart:math' as math;

import '../content/domain/archetype.dart';
import '../content/domain/menswear_term.dart';

/// Minimum lean picks before an archetype is named. Below this the Field Guide
/// shows only the sliders and "keep going to name your look."
const int kMinPicksForArchetype = 20;

/// Two archetypes whose distances differ by no more than this are "too close
/// to call" — the Field Guide says "you're between X and Y."
const double kTieBand = 0.5;

/// An axis whose absolute position is at least this becomes a through-line
/// pole ("the house leans structured & muted").
const double kPoleThreshold = 1.0;

/// A reader's normalized position on one axis in each axis. Values are in
/// [-2.0, 2.0]; the sign follows the axis's `<poleA>-<poleB>` token order
/// (poleA positive, poleB negative).
class AxisPosition {
  final Map<String, double> byAxis;
  const AxisPosition(this.byAxis);

  double value(String axis) => byAxis[axis] ?? 0.0;
}

/// The nearest archetype to a position, with tie information.
class ArchetypeMatch {
  final Archetype archetype;
  final double distance;

  /// True when [runnerUp] is within [kTieBand] of [archetype] — render as
  /// "between X and Y."
  final bool isTie;

  /// The second-nearest archetype (null only when fewer than 2 exist).
  final Archetype? runnerUp;

  const ArchetypeMatch({
    required this.archetype,
    required this.distance,
    required this.isTie,
    required this.runnerUp,
  });
}

/// A dominant axis pole for the Charter's through-line sentence.
class AxisPole {
  final String axis;
  final String pole;
  final double strength;
  const AxisPole(
      {required this.axis, required this.pole, required this.strength});
}

/// Pure-Dart lean math: pairwise picks → axis position → nearest archetype
/// (solo Field Guide) and dominant poles (family Charter). No I/O; the DRY
/// spine feeding BOTH payoffs. This is NOT `ThroughlineNamer` (that is the
/// legacy deck-based computation).
class AxisTally {
  const AxisTally._();

  /// The three lean axes, each `<positivePole>-<negativePole>`.
  static const List<String> kAxes = [
    'structured-relaxed',
    'muted-graphic',
    'classic-directional',
  ];

  /// Map a 5-level archetype signature string to −2..+2 for the given axis.
  /// Convention: the axis's first token is +2/+1, "mid" is 0, second token is
  /// −2/−1. Throws [ArgumentError] on an unrecognized level.
  static int levelToInt(String axis, String level) {
    final tokens = axis.split('-');
    final poleA = tokens[0];
    final poleB = tokens[1];
    if (level == 'mid') return 0;
    if (level == poleA) return 2;
    if (level == 'lean-$poleA') return 1;
    if (level == poleB) return -2;
    if (level == 'lean-$poleB') return -1;
    throw ArgumentError('Unknown axis level "$level" for axis "$axis"');
  }

  /// Fold each chosen term's signals into a position. Each axis is normalized
  /// by its own signal count — so magnitude reflects *consistency* (how
  /// one-sided the picks were), not volume — then scaled into [-2, 2]. Axes
  /// with no signals stay at 0.0 (mid). (Modeling note: per-axis-count
  /// normalization can peg an axis on thin evidence; the confidence gate
  /// [hasEnoughSignal] guards naming, and the lean pool is curated for
  /// balanced axis coverage, so a lean is never named off one lopsided pick.)
  static AxisPosition positionFromChoices(List<MenswearTerm> chosen) {
    final net = {for (final ax in kAxes) ax: 0.0};
    final count = {for (final ax in kAxes) ax: 0};
    for (final term in chosen) {
      for (final sig in term.axisSignals) {
        final ax = sig.axis;
        if (!net.containsKey(ax)) continue; // ignore unknown axes defensively
        final tokens = ax.split('-');
        final delta = sig.pole == tokens[0]
            ? 1.0
            : (sig.pole == tokens[1] ? -1.0 : 0.0);
        if (delta == 0.0) continue;
        net[ax] = net[ax]! + delta;
        count[ax] = count[ax]! + 1;
      }
    }
    return AxisPosition({
      for (final ax in kAxes)
        ax: count[ax]! == 0 ? 0.0 : (net[ax]! / count[ax]!) * 2.0,
    });
  }

  /// Nearest archetype by Euclidean distance over the three axes (each
  /// archetype level mapped to the same −2..+2 space). [runnerUp] is the
  /// second-nearest; [ArchetypeMatch.isTie] is true when it is within
  /// [kTieBand].
  static ArchetypeMatch nearestArchetype(
      AxisPosition pos, List<Archetype> archetypes) {
    assert(archetypes.isNotEmpty, 'need at least one archetype');
    final scored = archetypes
        .map((a) {
          var sumSq = 0.0;
          for (final ax in kAxes) {
            final level = a.axisSignature[ax];
            final target =
                level == null ? 0.0 : levelToInt(ax, level).toDouble();
            final d = pos.value(ax) - target;
            sumSq += d * d;
          }
          return (archetype: a, distance: math.sqrt(sumSq));
        })
        .toList()
      ..sort((x, y) => x.distance.compareTo(y.distance));

    final nearest = scored.first;
    final runnerUp = scored.length > 1 ? scored[1] : null;
    final isTie = runnerUp != null &&
        (runnerUp.distance - nearest.distance) <= kTieBand;
    return ArchetypeMatch(
      archetype: nearest.archetype,
      distance: nearest.distance,
      isTie: isTie,
      runnerUp: runnerUp?.archetype,
    );
  }

  /// Dominant poles (|value| >= [kPoleThreshold]) as through-lines, strongest
  /// first — the Charter's "your house leans structured & muted."
  static List<AxisPole> throughlinePoles(AxisPosition pos) {
    final poles = <AxisPole>[];
    for (final ax in kAxes) {
      final v = pos.value(ax);
      if (v.abs() < kPoleThreshold) continue;
      final tokens = ax.split('-');
      poles.add(AxisPole(
        axis: ax,
        pole: v > 0 ? tokens[0] : tokens[1],
        strength: v.abs(),
      ));
    }
    poles.sort((a, b) => b.strength.compareTo(a.strength));
    return poles;
  }

  /// Whether enough picks exist to name an archetype.
  static bool hasEnoughSignal(int pickCount) =>
      pickCount >= kMinPicksForArchetype;
}
