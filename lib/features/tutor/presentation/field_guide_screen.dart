import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../content/domain/menswear_term.dart';
import '../domain/axis_tally.dart';
import 'field_guide_controller.dart';

/// The solo payoff: the words you now own, your position on the three axes,
/// and — once past the confidence gate — your nearest named archetype, framed
/// descriptively ("you gravitate to…"), never as "better taste."
class FieldGuideScreen extends ConsumerWidget {
  const FieldGuideScreen({super.key, required this.memberId});

  final String memberId;

  static const _axisLabels = {
    'structured-relaxed': ['Relaxed', 'Structured'],
    'muted-graphic': ['Graphic', 'Muted'],
    'classic-directional': ['Directional', 'Classic'],
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(fieldGuideControllerProvider(memberId));

    if (state.status == FieldGuideStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.status == FieldGuideStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('Field Guide')),
        body: OhPage(
          padding: EdgeInsets.zero,
          child: OhErrorState(
            message: state.errorMessage ?? OhErrorMessages.generic,
            onRetry: () => ref.invalidate(fieldGuideControllerProvider(memberId)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Field Guide')),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: OhSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Your lean (always shown) ──────────────────────────────────
              Text('Your lean', style: theme.textTheme.headlineSmall),
              const SizedBox(height: OhSpacing.md),
              Column(
                key: const Key('field-guide-sliders'),
                children: [
                  for (final axis in AxisTally.kAxes)
                    _AxisSlider(
                      axis: axis,
                      lowLabel: _axisLabels[axis]![0],
                      highLabel: _axisLabels[axis]![1],
                      value: state.position.value(axis),
                    ),
                ],
              ),
              const SizedBox(height: OhSpacing.xl),

              // ── Your named look (gated) ───────────────────────────────────
              if (state.hasEnoughSignal && state.match != null)
                _ArchetypeCard(match: state.match!)
              else
                Card(
                  key: const Key('field-guide-keep-going'),
                  child: Padding(
                    padding: OhSpacing.insetMd,
                    child: Text(
                      'Keep going to name your look: a few more picks and your '
                      'lean will come into focus.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              const SizedBox(height: OhSpacing.xl),

              // ── Words you now own ─────────────────────────────────────────
              Text('Words you now own', style: theme.textTheme.headlineSmall),
              const SizedBox(height: OhSpacing.md),
              _Lexicon(
                  key: const Key('field-guide-lexicon'), terms: state.lexicon),
              const SizedBox(height: OhSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

/// One axis of the lean, drawn as what it is: a two-pole scale (audit
/// finding 11). A rule runs from pole to pole with a tick at the centre and
/// one marker at the value; the lean is said in words beside it. The filled
/// progress bar it replaces had its origin at the low pole, so no lean read
/// as half done, and the same widget meant literal progress elsewhere.
class _AxisSlider extends StatelessWidget {
  const _AxisSlider({
    required this.axis,
    required this.lowLabel,
    required this.highLabel,
    required this.value,
  });
  final String axis;
  final String lowLabel;
  final String highLabel;
  final double value; // -2..2, negative toward [lowLabel]

  /// Within this of zero the lean reads as even.
  static const _even = 0.25;

  String get _words {
    if (value.abs() < _even) return 'Even';
    final pole = value < 0 ? lowLabel : highLabel;
    return 'Leans $pole, ${value.abs().toStringAsFixed(1)} of 2';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = ((value + 2) / 4).clamp(0.0, 1.0);
    const marker = 14.0;
    return Semantics(
      label: '$lowLabel to $highLabel: $_words',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OhSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(lowLabel, style: theme.textTheme.labelSmall),
                Text(highLabel, style: theme.textTheme.labelSmall),
              ],
            ),
            const SizedBox(height: OhSpacing.xs),
            LayoutBuilder(
              builder: (context, constraints) {
                final w = constraints.maxWidth;
                final x = (t * w).clamp(marker / 2, w - marker / 2);
                return SizedBox(
                  height: marker + 4,
                  child: Stack(
                    children: [
                      // The rule, pole to pole.
                      Positioned(
                        left: 0,
                        right: 0,
                        top: (marker + 4) / 2 - 1,
                        child: Container(height: 2, color: cs.outlineVariant),
                      ),
                      // The centre: no lean.
                      Positioned(
                        left: w / 2 - 1,
                        top: 0,
                        child: Container(
                          key: Key('lean-centre-$axis'),
                          width: 2,
                          height: marker + 4,
                          color: cs.outline,
                        ),
                      ),
                      // The value.
                      Positioned(
                        left: x - marker / 2,
                        top: 2,
                        child: Container(
                          key: Key('lean-marker-$axis'),
                          width: marker,
                          height: marker,
                          decoration: BoxDecoration(
                            color: cs.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: OhSpacing.xs),
            Text(
              _words,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchetypeCard extends StatelessWidget {
  const _ArchetypeCard({required this.match});
  final ArchetypeMatch match;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = match.archetype;
    return Card(
      key: const Key('field-guide-archetype'),
      child: Padding(
        padding: OhSpacing.insetMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You gravitate to',
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: OhSpacing.xs),
            Text(a.name, style: theme.textTheme.headlineSmall),
            Text(a.handle,
                style: theme.textTheme.titleSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: OhSpacing.sm),
            Text(a.oneLiner, style: theme.textTheme.bodyMedium),
            if (match.isTie && match.runnerUp != null) ...[
              const SizedBox(height: OhSpacing.sm),
              Text('You are right between ${a.name} and ${match.runnerUp!.name}.',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: OhSpacing.md),
            Text('Signature pieces: ${a.signatureGarments.join(', ')}',
                style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _Lexicon extends StatelessWidget {
  const _Lexicon({super.key, required this.terms});
  final List<MenswearTerm> terms;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (terms.isEmpty) {
      return Text('No words yet. Learn a few terms to fill this in.',
          style: theme.textTheme.bodyMedium
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant));
    }
    // Group by facet.
    final byFacet = <String, List<MenswearTerm>>{};
    for (final t in terms) {
      (byFacet[t.facet] ??= []).add(t);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final entry in byFacet.entries) ...[
          Text(entry.key,
              style: theme.textTheme.labelMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: OhSpacing.xs),
          Wrap(
            spacing: OhSpacing.sm,
            children: [
              for (final t in entry.value) Chip(label: Text(t.term)),
            ],
          ),
          const SizedBox(height: OhSpacing.md),
        ],
      ],
    );
  }
}
