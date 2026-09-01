// tool/web_reveal_check.dart
//
// The reveal's pure-Dart path, compiled with dart2js and run under node.
//
// The Flutter suite runs on the Dart VM, so it stayed green while every
// reveal on the web build threw (`1 << 32` is 0 under dart2js; audit
// checklist-01/02). This check compiles the same code the reveal runs
// (SessionBuilder, RevealService, ThroughlineNamer) to JavaScript and runs
// one whole two-member, three-domain round through it. It needs no browser.
//
//   dart compile js tool/web_reveal_check.dart -o build/web_reveal_check.js
//   node tool/run_js.cjs build/web_reveal_check.js
//
// Exit code 0 means the reveal assembled; anything else is a failure. It does
// not open the built web app: the Flutter UI on web is still unverified by
// CI (see docs/how-to/build-and-run.md, "The reveal under dart2js").

import 'package:mantle/features/ranking/domain/round_models.dart';
import 'package:mantle/features/ranking/domain/session_builder.dart';
import 'package:mantle/features/reveal/domain/reveal_service.dart';
import 'package:mantle/features/reveal/domain/throughline_namer.dart';

void main() {
  const domains = ['architecture', 'tailoring', 'interiors'];
  const members = ['m1', 'm2'];
  final itemsByDomain = {
    for (final d in domains) d: [for (var i = 0; i < 8; i++) '${d}_$i'],
  };

  // Both members prefer lower-numbered plates, so there is a shared Spine.
  final byDomain = {
    for (final d in domains)
      d: [
        for (final m in members)
          SessionBuilder.buildSession(
            itemIds: itemsByDomain[d]!,
            sessionId: 'session-$d-$m',
            participantId: m,
            matches: [
              for (var i = 0; i < 7; i++)
                for (var j = i + 1; j < 8; j++)
                  MatchRow(
                    idA: '${d}_$i',
                    idB: '${d}_$j',
                    outcome: 'aWins',
                    decidedAt: DateTime(2026, 1, 1, 0, i, j),
                  ),
            ],
          ),
      ],
  };

  final reveal = RevealService.compute(byDomain);
  final named = ThroughlineNamer.name(reveal.spine, {
    for (final d in domains)
      for (final id in itemsByDomain[d]!) id: ['shared-thread'],
  });

  final problems = [
    if (reveal.spine.isEmpty) 'the Spine is empty',
    if (reveal.spineIsFallback) 'the Spine fell back though both agree',
    if (named.isEmpty) 'no through-line was named',
  ];
  if (problems.isNotEmpty) {
    // An uncaught error makes node exit non-zero.
    throw StateError('web reveal check FAILED: ${problems.join('; ')}');
  }
  // A command-line check: stdout is its report.
  // ignore: avoid_print
  print('web reveal check ok: ${reveal.spine.length} Spine items, '
      '${named.length} through-line(s)');
}
