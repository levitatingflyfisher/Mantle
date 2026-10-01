// test/content/spot_balance_test.dart
//
// The Spot answer sat on A in 26 of 28 questions. The screen shuffles which
// slot shows which plate per member and question, so the skew no longer
// shows; the data is balanced too, as a second guard should that shuffle
// ever regress. The answer key pins that the rebalance swapped plates with
// their side, so every question still has the same right plate.

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _answerKey = {
  'assets/data/spot.json': {
    'spot-t01': 'gorge-high',
    'spot-t02': 'suppression-strong',
    'spot-t03': 'drape-full',
    'spot-t04': 'shoulder-roped',
    'spot-t05': 'armhole-high',
    'spot-t06': 'aline-open',
    'spot-t07': 'collar-stand',
    'spot-t08': 'sack-straight',
    'spot-a01': 'brut-raw',
    'spot-a02': 'poche-filled',
    'spot-a03': 'enfilade-aligned',
    'spot-a04': 'ma-gap',
    'spot-a05': 'pilotis-lifted',
    'spot-a06': 'tectonic-expressed',
    'spot-i01': 'wabisabi-repaired',
    'spot-i02': 'shibui-quiet',
    'spot-i03': 'truth-honest',
    'spot-i04': 'patina-earned',
    'spot-i05': 'biophilic-full',
    'spot-i06': 'japandi-blend',
  },
  'assets/data/menswear_spot.json': {
    'ms-spot-henley-polo': 'henley',
    'ms-spot-henley-crew': 'henley',
    'ms-spot-point-spread': 'spread-collar',
    'ms-spot-buttondown-point': 'button-down-collar',
    'ms-spot-oxford-chambray': 'oxford-shirt',
    'ms-spot-chelsea-chukka': 'chelsea-boot',
    'ms-spot-chino-jean': 'flat-front-chino',
    'ms-spot-derby-loafer': 'derby',
  },
};

void main() {
  for (final entry in _answerKey.entries) {
    final questions = ((jsonDecode(File(entry.key).readAsStringSync())
            as Map<String, dynamic>)['questions'] as List)
        .cast<Map<String, dynamic>>();

    test('${entry.key}: every question keeps its right plate', () {
      final got = {
        for (final q in questions)
          q['id'] as String:
              (q['correctSide'] == 'A' ? q['plateA'] : q['plateB']) as String,
      };
      expect(got, entry.value);
    });

    test('${entry.key}: the right answer is on A and B about equally', () {
      final a = questions.where((q) => q['correctSide'] == 'A').length;
      final b = questions.length - a;
      expect((a - b).abs(), lessThanOrEqualTo(1), reason: '$a on A, $b on B');
    });

    test('${entry.key}: each domain is balanced too', () {
      final byDomain = <String, List<String>>{};
      for (final q in questions) {
        final d = (q['domain'] ?? q['facet'] ?? '') as String;
        (byDomain[d] ??= []).add(q['correctSide'] as String);
      }
      for (final e in byDomain.entries) {
        final a = e.value.where((s) => s == 'A').length;
        expect((a - (e.value.length - a)).abs(), lessThanOrEqualTo(1),
            reason: '${e.key}: $a of ${e.value.length} on A');
      }
    });
  }
}
