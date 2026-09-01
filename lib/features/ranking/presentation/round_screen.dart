// lib/features/ranking/presentation/round_screen.dart
//
// The full-bleed head-to-head pairing screen.
//
// No-peek guarantees (three guards):
//   (a) RoundPhase never exposes individual results — the only phases
//       exposed to the UI are loading, pairing, handoff, complete, error.
//   (b) Key('handoff-interstitial') is shown between members; the UI
//       cannot proceed until the next member taps "I'm ready."
//   (c) Key('reveal-ready') (the trigger for Task 13's reveal) is only
//       shown when allMembersComplete == true, gating the reveal route.
//       Key('reveal-spine') is NEVER rendered here — that's Task 13's widget.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../widgets/image_placeholder_tile.dart';
import '../../../widgets/member_dot.dart';
import '../../content/domain/domain.dart';
import '../../reveal/presentation/reveal_screen.dart';
import '../domain/round_service.dart';
import 'round_controller.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class RoundScreen extends ConsumerWidget {
  const RoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(roundControllerProvider);
    return switch (state.phase) {
      RoundPhase.loading => const _LoadingView(),
      RoundPhase.pairing => _PairingView(state: state),
      RoundPhase.handoff => _HandoffView(state: state),
      RoundPhase.complete => const _RevealReadyView(),
      RoundPhase.error => _ErrorView(state: state),
    };
  }
}

// ── Error ───────────────────────────────────────────────────────────────────

class _ErrorView extends ConsumerWidget {
  const _ErrorView({required this.state});
  final RoundState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notEnoughPeople = state.error == null;
    return Scaffold(
      appBar: AppBar(title: const Text('Round')),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: OhErrorState(
          title: notEnoughPeople ? 'Not enough people yet' : OhErrorState.defaultTitle,
          icon: notEnoughPeople ? Icons.people_outline : Icons.cloud_off_outlined,
          message: state.errorMessage ?? OhErrorMessages.generic,
          error: state.error,
          onRetry: notEnoughPeople
              ? null
              : () => ref.read(roundControllerProvider.notifier).retry(),
        ),
      ),
    );
  }
}

// ── Loading ───────────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// ── Pairing ───────────────────────────────────────────────────────────────────

class _PairingView extends ConsumerWidget {
  const _PairingView({required this.state});
  final RoundState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(roundControllerProvider.notifier);
    final theme = Theme.of(context);
    final pair = state.currentPair;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: _DomainProgressTitle(state: state),
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: pair == null
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Prompt ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OhSpacing.lg,
                      OhSpacing.md,
                      OhSpacing.lg,
                      OhSpacing.sm,
                    ),
                    child: Text(
                      'Which is more us?',
                      style: theme.textTheme.headlineSmall,
                      textAlign: TextAlign.center,
                    ),
                  ),

                  // ── Member indicator ────────────────────────────────────────
                  if (state.currentMember != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: OhSpacing.sm),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          MemberDot(
                            color: Color(state.currentMember!.color),
                            label: state.currentMember!.label,
                            radius: 12,
                          ),
                          const SizedBox(width: OhSpacing.sm),
                          Flexible(
                            child: Text(
                              state.currentMember!.label,
                              style: theme.textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // ── Side-by-side pair ───────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: OhSpacing.sm,
                        vertical: OhSpacing.xs,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image A
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Choose the left image',
                              child: GestureDetector(
                                onTap: controller.chooseA,
                                child: _ImageTile(
                                  key: const Key('image-tile-a'),
                                  assetPath: pair.imageA.assetPath,
                                  imageId: pair.imageA.id,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: OhSpacing.sm),
                          // Image B
                          Expanded(
                            child: Semantics(
                              button: true,
                              label: 'Choose the right image',
                              child: GestureDetector(
                                onTap: controller.chooseB,
                                child: _ImageTile(
                                  key: const Key('image-tile-b'),
                                  assetPath: pair.imageB.assetPath,
                                  imageId: pair.imageB.id,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── Skip ────────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      OhSpacing.lg,
                      OhSpacing.sm,
                      OhSpacing.lg,
                      OhSpacing.lg,
                    ),
                    child: TextButton(
                      onPressed: controller.skip,
                      child: const Text('Skip this pair'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _DomainProgressTitle extends StatelessWidget {
  const _DomainProgressTitle({required this.state});
  final RoundState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final domainLabel = _domainLabel(state.currentDomain);
    final done = state.totalDecisionsForCurrentMember;
    final total = state.totalDecisionsExpected;

    // The words carry this domain's count; the bar under them is the whole
    // round, and its screen-reader label says so.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$domainLabel · ${state.decisionCount} of $kDecisionsPerDomain',
          style: theme.textTheme.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: OhSpacing.xs),
        LinearProgressIndicator(
          value: total > 0 ? done / total : 0.0,
          minHeight: 4,
          semanticsLabel: 'Whole round',
          semanticsValue: '$done of $total',
        ),
      ],
    );
  }

  static String _domainLabel(Domain d) => switch (d) {
        Domain.architecture => 'Architecture',
        Domain.tailoring => 'Tailoring',
        Domain.interiors => 'Interiors',
      };
}

// ── Image tile ────────────────────────────────────────────────────────────────

class _ImageTile extends StatelessWidget {
  const _ImageTile({
    super.key,
    required this.assetPath,
    required this.imageId,
  });

  final String assetPath;
  final String imageId;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ImagePlaceholderTile(imageId: imageId),
      ),
    );
  }
}

// ── Hand-off interstitial ─────────────────────────────────────────────────────
// Guard (b): Key('handoff-interstitial') is present between members.
// Guard (a): No results or spine widget is rendered here.

class _HandoffView extends ConsumerWidget {
  const _HandoffView({required this.state});
  final RoundState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(roundControllerProvider.notifier);
    final theme = Theme.of(context);
    final nextMember = state.nextMember;

    return Scaffold(
      key: const Key('handoff-interstitial'),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: OhSpacing.insetLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: OhSpacing.lg),
                  Text(
                    'Great work!',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OhSpacing.sm),
                  if (nextMember != null) ...[
                    Text(
                      'Pass the device to',
                      style: theme.textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: OhSpacing.sm),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        MemberDot(
                          color: Color(nextMember.color),
                          label: nextMember.label,
                        ),
                        const SizedBox(width: OhSpacing.sm),
                        Flexible(
                          child: Text(
                            nextMember.label,
                            style: theme.textTheme.headlineSmall,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: OhSpacing.xl),
                  ElevatedButton(
                    onPressed: controller.beginNextMember,
                    child: Text(
                      nextMember != null
                          ? 'I’m ready. Let’s go'
                          : "Continue",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Reveal-ready ──────────────────────────────────────────────────────────────
// Guard (c): This view only appears when allMembersComplete == true.
// Key('reveal-ready') is the entry point for Task 13's reveal.
// Key('reveal-spine') is intentionally ABSENT — the spine lives in Task 13.

class _RevealReadyView extends ConsumerWidget {
  const _RevealReadyView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Scaffold(
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: Center(
            key: const Key('reveal-ready'),
            child: Padding(
              padding: OhSpacing.insetLg,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 64,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: OhSpacing.lg),
                  Text(
                    'Everyone has finished!',
                    style: theme.textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OhSpacing.sm),
                  Text(
                    'Your shared aesthetic is ready.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: OhSpacing.xl),
                  ElevatedButton(
                    key: const Key('reveal-ready-button'),
                    onPressed: () {
                      final roundId =
                          ref.read(roundControllerProvider.notifier).roundId;
                      Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => RevealScreen(roundId: roundId),
                        ),
                      );
                    },
                    child: const Text('See your Mantle'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
