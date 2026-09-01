import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../widgets/plate.dart';
import '../content/domain/menswear_term.dart';
import 'field_guide_screen.dart';
import 'lean_round_controller.dart';

/// Pairwise "which draws you?" over the curated menswear lean pool. Each pick
/// feeds the ELO ranking (for the Charter) and the axis tally (for the Field
/// Guide) from one input. On completion, offers the solo Field Guide.
class LeanRoundScreen extends ConsumerWidget {
  const LeanRoundScreen(
      {super.key, required this.memberId, this.roundId, this.onComplete});

  final String memberId;
  final String? roundId;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final args = (memberId: memberId, roundId: roundId);
    final state = ref.watch(leanRoundControllerProvider(args));
    final controller = ref.read(leanRoundControllerProvider(args).notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Find your lean')),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: switch (state.phase) {
          LeanRoundPhase.loading =>
            const Center(child: CircularProgressIndicator()),
          LeanRoundPhase.error => OhErrorState(
              message: state.errorMessage ?? OhErrorMessages.generic,
              error: state.error,
              onRetry: state.error == null
                  ? null
                  : () => ref.invalidate(leanRoundControllerProvider(args)),
            ),
          LeanRoundPhase.complete =>
            _CompleteView(memberId: memberId, onComplete: onComplete),
          LeanRoundPhase.pairing => _PairingView(
              pair: state.currentPair!,
              progress: state.progress,
              pickCount: state.pickCount,
              target: state.target,
              onChooseA: controller.chooseA,
              onChooseB: controller.chooseB,
              onSkip: controller.skip,
              theme: theme,
            ),
        },
      ),
    );
  }
}

class _PairingView extends StatelessWidget {
  const _PairingView({
    required this.pair,
    required this.progress,
    required this.pickCount,
    required this.target,
    required this.onChooseA,
    required this.onChooseB,
    required this.onSkip,
    required this.theme,
  });

  final LeanPair pair;
  final double progress;
  final int pickCount;
  final int target;
  final Future<void> Function() onChooseA;
  final Future<void> Function() onChooseB;
  final Future<void> Function() onSkip;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: OhSpacing.insetPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: progress),
          const SizedBox(height: OhSpacing.sm),
          Text('$pickCount of $target',
              key: const Key('lean-counter'),
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          const SizedBox(height: OhSpacing.md),
          Text('Which draws you?',
              textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
          const SizedBox(height: OhSpacing.lg),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _LeanOption(
                  key: const Key('lean-choose-A'),
                  term: pair.termA,
                  onTap: onChooseA,
                ),
              ),
              const SizedBox(width: OhSpacing.md),
              Expanded(
                child: _LeanOption(
                  key: const Key('lean-choose-B'),
                  term: pair.termB,
                  onTap: onChooseB,
                ),
              ),
            ],
          ),
          const SizedBox(height: OhSpacing.lg),
          TextButton(
            key: const Key('lean-skip'),
            onPressed: onSkip,
            child: const Text('Skip this pair'),
          ),
        ],
      ),
    );
  }
}

class _LeanOption extends StatelessWidget {
  const _LeanOption({super.key, required this.term, required this.onTap});
  final MenswearTerm term;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: OhRadii.md,
      child: Padding(
        padding: OhSpacing.insetSm,
        child: Column(
          children: [
            Plate(plateKey: term.id, size: 140),
            const SizedBox(height: OhSpacing.xs),
            Text(term.term,
                textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}

class _CompleteView extends StatelessWidget {
  const _CompleteView({required this.memberId, this.onComplete});
  final String memberId;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: OhSpacing.insetLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Your lean is taking shape.',
                style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: OhSpacing.lg),
            if (onComplete != null)
              FilledButton(
                key: const Key('lean-continue'),
                onPressed: onComplete,
                child: const Text('Continue'),
              )
            else
              FilledButton(
                key: const Key('lean-see-field-guide'),
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => FieldGuideScreen(memberId: memberId),
                  ),
                ),
                child: const Text('See your Field Guide'),
              ),
          ],
        ),
      ),
    );
  }
}
