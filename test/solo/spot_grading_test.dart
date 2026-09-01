import 'dart:convert';
import 'dart:io';

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

  group('SpotGrading.showBFirst (badass-01: the answer was always on the left)',
      () {
    final ids = [
      for (final q in (jsonDecode(File('assets/data/spot.json')
              .readAsStringSync()) as Map)['questions'] as List)
        (q as Map)['id'] as String,
    ];

    test('is stable for the same member and question', () {
      for (final id in ids) {
        expect(SpotGrading.showBFirst('m1', id),
            SpotGrading.showBFirst('m1', id));
      }
    });

    test('puts plate B first for a fair share of the real questions', () {
      for (final member in ['m1', 'anonymous', 'aria-1234']) {
        final bFirst = ids.where((id) => SpotGrading.showBFirst(member, id));
        expect(bFirst.length, inInclusiveRange(ids.length ~/ 4, ids.length * 3 ~/ 4),
            reason: 'with every correct answer stored as A, the side must '
                'vary or "press left" wins every time ($member)');
      }
    });

    test('differs between members for at least some questions', () {
      final differing = ids.where((id) =>
          SpotGrading.showBFirst('m1', id) != SpotGrading.showBFirst('m2', id));
      expect(differing, isNotEmpty);
    });
  });
}
