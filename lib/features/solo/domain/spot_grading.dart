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
}
