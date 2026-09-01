import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../widgets/plate.dart';
import 'menswear_charter_controller.dart';

/// Thin family-Charter screen for the menswear slice: a Spine grid (agreed
/// pieces), the through-line sentence ("your house leans structured & muted"),
/// and the Contested list. Reuses the generalized RevealService via the
/// controller; renders MenswearTerm plates rather than DeckImage photos.
class MenswearCharterScreen extends ConsumerWidget {
  const MenswearCharterScreen({super.key, required this.roundId});

  final String roundId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final state = ref.watch(menswearCharterControllerProvider(roundId));

    if (state.status == MenswearCharterStatus.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.status == MenswearCharterStatus.error) {
      return Scaffold(
        appBar: AppBar(title: const Text('House Charter')),
        body: OhPage(
          padding: EdgeInsets.zero,
          child: OhErrorState(
            message: state.errorMessage ?? OhErrorMessages.generic,
            onRetry: () =>
                ref.invalidate(menswearCharterControllerProvider(roundId)),
          ),
        ),
      );
    }

    final poleWords = state.throughlinePoles.map((p) => p.pole).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Your House Charter')),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: OhSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Your House Spine', style: theme.textTheme.headlineSmall),
              const SizedBox(height: OhSpacing.sm),
              if (state.spineIsFallback)
                Padding(
                  padding: const EdgeInsets.only(bottom: OhSpacing.sm),
                  child: Text(
                    'You’re still finding your common ground. This is just the beginning.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              GridView.count(
                key: const Key('menswear-charter-spine'),
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: OhSpacing.xs,
                crossAxisSpacing: OhSpacing.xs,
                children: [
                  for (final item in state.spine)
                    Column(
                      children: [
                        Plate(plateKey: item.id, size: 90),
                        Text(
                          state.termsById[item.id]?.term ?? item.id,
                          style: theme.textTheme.labelSmall,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: OhSpacing.lg),
              if (poleWords.isNotEmpty) ...[
                Text('Your house leans ${poleWords.join(' & ')}.',
                    style: theme.textTheme.bodyLarge),
                const SizedBox(height: OhSpacing.lg),
              ],
              if (state.contested.isNotEmpty) ...[
                Text('Where the House Argues',
                    style: theme.textTheme.headlineSmall),
                const SizedBox(height: OhSpacing.sm),
                Column(
                  children: [
                    for (final item in state.contested)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: SizedBox(
                            width: 40, height: 40,
                            child: Plate(plateKey: item.id, size: 40)),
                        title: Text(state.termsById[item.id]?.term ?? item.id,
                            style: theme.textTheme.bodyMedium),
                      ),
                  ],
                ),
                const SizedBox(height: OhSpacing.lg),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
