import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'package:mantle/features/content/domain/spot_question.dart';
import 'package:mantle/features/solo/domain/spot_grading.dart';

void main() {
  const sampleQ = SpotQuestion(
    id: 'spot-001',
    domain: Domain.architecture,
    featureId: 'canon-001',
    promptText: 'Which shows a higher gorge?',
    plateA: 'arch_high_gorge',
    plateB: 'arch_low_gorge',
    correctSide: 'A',
    explanation: 'The left plate shows the gorge cut high above the break line.',
  );

  group('SpotGrading.grade', () {
    test('returns true when chosenSide matches correctSide', () {
      expect(SpotGrading.grade(sampleQ, 'A'), isTrue);
    });

    test('returns false when chosenSide does not match correctSide', () {
      expect(SpotGrading.grade(sampleQ, 'B'), isFalse);
    });

    test('is case-sensitive — lowercase does not match', () {
      expect(SpotGrading.grade(sampleQ, 'a'), isFalse);
    });

    test('works when correctSide is B and answer is B', () {
      const qB = SpotQuestion(
        id: 'spot-002',
        domain: Domain.tailoring,
        featureId: 'canon-002',
        promptText: 'Which shows more waist suppression?',
        plateA: 'tail_minimal_waist',
        plateB: 'tail_suppressed_waist',
        correctSide: 'B',
        explanation: 'The right plate has visible waist shaping.',
      );
      expect(SpotGrading.grade(qB, 'B'), isTrue);
    });

    test('works when correctSide is B and answer is A (wrong)', () {
      const qB = SpotQuestion(
        id: 'spot-003',
        domain: Domain.tailoring,
        featureId: 'canon-003',
        promptText: 'Which shows roped shoulder?',
        plateA: 'tail_soft_shoulder',
        plateB: 'tail_roped_shoulder',
        correctSide: 'B',
        explanation: 'The right plate shows a raised roped head.',
      );
      expect(SpotGrading.grade(qB, 'A'), isFalse);
    });
  });
}
