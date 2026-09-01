import '../../content/domain/spot_question.dart';

/// Pure grading logic for Spot mode.
///
/// Spot trains the eye on named visual features — it is never a taste test
/// and never produces a global score. The grade here simply checks whether the
/// chosen side matches the question's correct side.
class SpotGrading {
  const SpotGrading._();

  /// Returns `true` when [chosenSide] matches [q.correctSide].
  ///
  /// Both values are case-sensitive; the data layer guarantees they are either
  /// `'A'` or `'B'` (see [SpotQuestion.correctSide]).
  static bool grade(SpotQuestion q, String chosenSide) =>
      chosenSide == q.correctSide;

  /// Whether plate B is shown first (on the left) for [memberId] on
  /// [questionId].
  ///
  /// Every correct answer in the bundled data is plate A, so a fixed layout
  /// taught "press left" rather than the feature (badass-01). The side is
  /// chosen per member and question, so a revisit looks the same, and the
  /// grade stays by plate identity ([grade] compares the data side, not the
  /// screen slot). A 24-bit FNV-style hash: every product stays below 2^53,
  /// so it gives the same answer on the VM and under dart2js.
  static bool showBFirst(String memberId, String questionId) {
    var x = 0x811C9D;
    for (final c in '$memberId|$questionId'.codeUnits) {
      x = ((x ^ c) * 16777619) & 0xFFFFFF;
    }
    x ^= x >> 13;
    x = (x * 0x9E3779) & 0xFFFFFF;
    x ^= x >> 11;
    return (x >> 5) & 1 == 1;
  }
}
