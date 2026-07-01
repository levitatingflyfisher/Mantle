import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/tutor/content/domain/archetype.dart';
import 'package:mantle/features/tutor/content/domain/menswear_term.dart';
import 'package:mantle/features/tutor/domain/axis_tally.dart';

MenswearTerm _term(String id, List<List<String>> signals) => MenswearTerm(
      id: id,
      facet: 'garment',
      term: id,
      handle: null,
      gloss: '',
      quickRead: '',
      closerRead: '',
      axisSignals: [
        for (final s in signals) AxisSignal(axis: s[0], pole: s[1])
      ],
      plateHint: '',
    );

Archetype _arche(String id, String sr, String mg, String cd) => Archetype(
      id: id,
      name: id,
      handle: '',
      oneLiner: '',
      axisSignature: {
        'structured-relaxed': sr,
        'muted-graphic': mg,
        'classic-directional': cd,
      },
      signatureGarments: const [],
      description: '',
      adjacentTo: const [],
    );

void main() {
  group('levelToInt', () {
    test('maps all five levels on each axis per the sign convention', () {
      expect(AxisTally.levelToInt('structured-relaxed', 'structured'), 2);
      expect(AxisTally.levelToInt('structured-relaxed', 'lean-structured'), 1);
      expect(AxisTally.levelToInt('structured-relaxed', 'mid'), 0);
      expect(AxisTally.levelToInt('structured-relaxed', 'lean-relaxed'), -1);
      expect(AxisTally.levelToInt('structured-relaxed', 'relaxed'), -2);
      expect(AxisTally.levelToInt('muted-graphic', 'muted'), 2);
      expect(AxisTally.levelToInt('muted-graphic', 'graphic'), -2);
      expect(AxisTally.levelToInt('classic-directional', 'classic'), 2);
      expect(AxisTally.levelToInt('classic-directional', 'directional'), -2);
    });

    test('throws on an unknown level', () {
      expect(() => AxisTally.levelToInt('structured-relaxed', 'sideways'),
          throwsArgumentError);
    });
  });

  group('positionFromChoices', () {
    test('empty choices → neutral position (0 on every axis)', () {
      final p = AxisTally.positionFromChoices([]);
      for (final ax in AxisTally.kAxes) {
        expect(p.value(ax), 0.0);
      }
    });

    test('pure one-pole choices peg that axis to the extreme', () {
      final p = AxisTally.positionFromChoices([
        _term('a', [['structured-relaxed', 'relaxed']]),
        _term('b', [['structured-relaxed', 'relaxed']]),
      ]);
      expect(p.value('structured-relaxed'), -2.0);
      // Untouched axes stay neutral.
      expect(p.value('muted-graphic'), 0.0);
    });

    test('balanced opposite choices cancel to mid', () {
      final p = AxisTally.positionFromChoices([
        _term('a', [['muted-graphic', 'muted']]),
        _term('b', [['muted-graphic', 'graphic']]),
      ]);
      expect(p.value('muted-graphic'), 0.0);
    });
  });

  group('nearestArchetype', () {
    final archetypes = [
      _arche('relaxed-street', 'relaxed', 'graphic', 'directional'),
      _arche('classic-tailored', 'structured', 'muted', 'classic'),
    ];

    test('a relaxed/graphic/directional position picks the street archetype',
        () {
      final pos = AxisTally.positionFromChoices([
        _term('a', [
          ['structured-relaxed', 'relaxed'],
          ['muted-graphic', 'graphic'],
          ['classic-directional', 'directional'],
        ]),
      ]);
      final m = AxisTally.nearestArchetype(pos, archetypes);
      expect(m.archetype.id, 'relaxed-street');
      expect(m.isTie, isFalse);
      expect(m.runnerUp?.id, 'classic-tailored');
    });

    test('a position exactly equidistant from two archetypes is a tie', () {
      // Midpoint between the two signatures on all three axes → equal distance.
      const tie = AxisPosition({
        'structured-relaxed': 0.0,
        'muted-graphic': 0.0,
        'classic-directional': 0.0,
      });
      final m = AxisTally.nearestArchetype(tie, archetypes);
      expect(m.isTie, isTrue);
      expect(m.runnerUp, isNotNull);
    });
  });

  group('throughlinePoles', () {
    test('emits dominant poles above threshold, strongest first', () {
      const pos = AxisPosition({
        'structured-relaxed': 2.0, // structured, strong
        'muted-graphic': 1.5, // muted, above threshold
        'classic-directional': 0.2, // below threshold → omitted
      });
      final poles = AxisTally.throughlinePoles(pos);
      expect(poles.map((p) => p.pole), ['structured', 'muted']);
      expect(poles.first.strength, greaterThan(poles.last.strength));
    });
  });

  group('hasEnoughSignal', () {
    test('gate is kMinPicksForArchetype', () {
      expect(AxisTally.hasEnoughSignal(kMinPicksForArchetype - 1), isFalse);
      expect(AxisTally.hasEnoughSignal(kMinPicksForArchetype), isTrue);
    });
  });

  test('every real archetype signature level parses (no throw)', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    final data = jsonDecode(
            File('assets/data/menswear_archetypes.json').readAsStringSync())
        as Map<String, dynamic>;
    for (final a in data['archetypes'] as List) {
      final sig = a['axisSignature'] as Map<String, dynamic>;
      for (final axis in AxisTally.kAxes) {
        // Must not throw.
        AxisTally.levelToInt(axis, sig[axis] as String);
      }
    }
  });
}
