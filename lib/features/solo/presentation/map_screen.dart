import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../widgets/error_view.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

/// Resolved through-line labels for [memberId].
///
/// Returns a list of human-readable labels (e.g. "the charged gap") in the
/// order those through-lines were first encountered. Returns an empty list when
/// none have been discovered yet.
final _mapThroughlineLabelsProvider =
    FutureProvider.autoDispose.family<List<String>, String>((ref, memberId) async {
  final dao = ref.watch(discoveredThroughlinesDaoProvider);
  final contentRepo = ref.watch(contentRepositoryProvider);

  final rows = await dao.forMember(memberId);
  if (rows.isEmpty) return [];

  final allThroughlines = await contentRepo.throughlines();
  final labelMap = {for (final t in allThroughlines) t.key: t.label};

  // Preserve first-seen order; skip any orphaned keys gracefully.
  return rows
      .map((r) => labelMap[r.throughlineId])
      .whereType<String>()
      .toList();
});

// ── Screen ────────────────────────────────────────────────────────────────────

/// Map mode — a qualitative coherence reading for a single member.
///
/// Surfaces through-lines that recur across a member's discovered canon items,
/// described in plain language (e.g. "the charged gap; material honesty").
/// This is an informational, solo view only.
///
/// Design constraints:
/// - NO numeric score, NO ranking, NO leaderboard.
/// - No language that implies one member is "better" or "more advanced" than
///   another.
/// - Does not alter the group reveal in any way.
class MapScreen extends ConsumerWidget {
  const MapScreen({
    super.key,
    required this.memberId,
    this.memberLabel,
  });

  /// The member whose discovered through-lines to surface.
  final String memberId;

  /// Optional display label for the member (shown in the heading).
  final String? memberLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final labelsAsync = ref.watch(_mapThroughlineLabelsProvider(memberId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
      ),
      body: labelsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          debugPrint('MapScreen error: $e');
          return ErrorView(
            message: "We couldn't load your map. Please try again.",
            onRetry: () => ref.invalidate(_mapThroughlineLabelsProvider(memberId)),
          );
        },
        data: (labels) {
          if (labels.isEmpty) {
            return _EmptyState(cs: cs, theme: theme);
          }
          return _MapBody(
            labels: labels,
            memberLabel: memberLabel,
            theme: theme,
            cs: cs,
          );
        },
      ),
    );
  }
}

// ── _MapBody ──────────────────────────────────────────────────────────────────

class _MapBody extends StatelessWidget {
  const _MapBody({
    required this.labels,
    required this.memberLabel,
    required this.theme,
    required this.cs,
  });

  final List<String> labels;
  final String? memberLabel;
  final ThemeData theme;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final sentence = labels.join('; ');

    return SingleChildScrollView(
      padding: OhSpacing.insetPage,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: OhSpacing.lg),

          // ── Heading ───────────────────────────────────────────────────────
          Text(
            'Your eye keeps returning to',
            key: const Key('map-heading'),
            style: theme.textTheme.titleMedium?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OhSpacing.md),

          // ── Through-line sentence ──────────────────────────────────────────
          Text(
            sentence,
            key: const Key('map-throughlines'),
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: OhSpacing.xl),

          // ── Chips row ─────────────────────────────────────────────────────
          Wrap(
            spacing: OhSpacing.sm,
            runSpacing: OhSpacing.sm,
            children: [
              for (final label in labels)
                Chip(
                  key: Key('map-chip-$label'),
                  label: Text(label),
                  backgroundColor: cs.surfaceContainerHighest,
                  side: BorderSide(color: cs.outlineVariant),
                ),
            ],
          ),
          const SizedBox(height: OhSpacing.xl),

          // ── Context note ──────────────────────────────────────────────────
          Text(
            'These threads surfaced as you explored. Keep reading and spotting — the picture fills in gradually.',
            key: const Key('map-context-note'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: OhSpacing.xl),
        ],
      ),
    );
  }
}

// ── _EmptyState ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.cs, required this.theme});

  final ColorScheme cs;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: OhSpacing.insetLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.explore_outlined,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: OhSpacing.md),
            Text(
              'Nothing has surfaced yet — keep exploring.',
              key: const Key('map-empty-state'),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
