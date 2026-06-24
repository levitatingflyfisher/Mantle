// lib/features/reveal/presentation/reveal_screen.dart
//
// The House Reveal — shows the Spine grid, named through-lines, and
// Contested section. "Make our Charter" saves a Charter and navigates forward.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../widgets/image_placeholder_tile.dart';
import '../../content/domain/deck_image.dart';
import '../domain/reveal.dart';
import '../domain/throughline_namer.dart';
import 'charter_screen.dart';
import 'reveal_controller.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class RevealScreen extends ConsumerStatefulWidget {
  const RevealScreen({super.key, required this.roundId});

  final String roundId;

  @override
  ConsumerState<RevealScreen> createState() => _RevealScreenState();
}

class _RevealScreenState extends ConsumerState<RevealScreen> {
  bool _creating = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(revealControllerProvider(widget.roundId));

    return switch (state.status) {
      RevealStatus.loading => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      RevealStatus.error => _buildError(context, state.errorMessage),
      RevealStatus.ready => _buildReady(context, state),
    };
  }

  Widget _buildError(BuildContext context, String? message) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Your Mantle')),
      body: Center(
        child: Padding(
          padding: OhSpacing.insetLg,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline,
                  size: 48, color: theme.colorScheme.error),
              const SizedBox(height: OhSpacing.md),
              Text(
                message ?? 'Something went wrong.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReady(BuildContext context, RevealState state) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Mantle')),
      body: SingleChildScrollView(
        child: Padding(
          padding: OhSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── House Spine header ─────────────────────────────────────────
              Text(
                'Your House Spine',
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: OhSpacing.sm),

              // ── Warm fallback copy ─────────────────────────────────────────
              if (state.spineIsFallback)
                Padding(
                  padding: const EdgeInsets.only(bottom: OhSpacing.sm),
                  child: Text(
                    "You're still finding your common ground — this is just the beginning.",
                    style: theme.textTheme.bodyMedium,
                  ),
                ),

              // ── Spine grid — always render ─────────────────────────────────
              _SpineGrid(
                items: state.spineItems,
                deckById: state.deckById,
              ),
              const SizedBox(height: OhSpacing.lg),

              // ── Through-line sentence ──────────────────────────────────────
              if (state.namedThroughlines.isNotEmpty) ...[
                _ThroughlineSentence(
                  throughlines: state.namedThroughlines,
                  labels: state.throughlineLabels,
                ),
                const SizedBox(height: OhSpacing.lg),
              ],

              // ── Contested section ──────────────────────────────────────────
              if (state.contestedItems.isNotEmpty) ...[
                Text(
                  'Where the House Argues',
                  style: theme.textTheme.headlineSmall,
                ),
                const SizedBox(height: OhSpacing.sm),
                _ContestedList(
                  items: state.contestedItems,
                  deckById: state.deckById,
                ),
                const SizedBox(height: OhSpacing.lg),
              ],

              // ── Make Charter button ────────────────────────────────────────
              ElevatedButton(
                key: const Key('make-charter-button'),
                onPressed: _creating ? null : () => _makeCharter(state),
                child: const Text('Make our Charter'),
              ),
              const SizedBox(height: OhSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _makeCharter(RevealState state) async {
    if (_creating) return;
    setState(() => _creating = true);
    try {
      final chartersDao = ref.read(chartersDaoProvider);
      final charter = await chartersDao.createFromReveal(
        widget.roundId,
        state.spineItems,
        state.contestedItems,
        state.namedThroughlines,
      );
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      await Navigator.push<void>(
        context,
        MaterialPageRoute<void>(
          builder: (_) => CharterScreen(charter: charter),
        ),
      );
    } finally {
      if (mounted) setState(() => _creating = false);
    }
  }
}

// ── Spine Grid ────────────────────────────────────────────────────────────────

class _SpineGrid extends StatelessWidget {
  const _SpineGrid({required this.items, required this.deckById});

  final List<RevealItem> items;
  final Map<String, DeckImage> deckById;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      key: const Key('reveal-spine'),
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: OhSpacing.xs,
      crossAxisSpacing: OhSpacing.xs,
      children: [
        for (final item in items)
          _SpineTile(item: item, deck: deckById[item.id]),
      ],
    );
  }
}

class _SpineTile extends StatelessWidget {
  const _SpineTile({required this.item, required this.deck});

  final RevealItem item;
  final DeckImage? deck;

  @override
  Widget build(BuildContext context) {
    final assetPath = deck?.assetPath;
    if (assetPath == null) {
      return ImagePlaceholderTile(imageId: item.id);
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: Image.asset(
        assetPath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => ImagePlaceholderTile(imageId: item.id),
      ),
    );
  }
}

// ── Through-line sentence ─────────────────────────────────────────────────────

class _ThroughlineSentence extends StatelessWidget {
  const _ThroughlineSentence({
    required this.throughlines,
    required this.labels,
  });

  final List<NamedThroughline> throughlines;

  /// Maps through-line key → human-readable label.
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final names =
        throughlines.map((t) => labels[t.key] ?? t.key).join(', ');
    return Text(
      'A thread runs through your Mantle: $names.',
      style: theme.textTheme.bodyLarge,
    );
  }
}

// ── Contested list ────────────────────────────────────────────────────────────

class _ContestedList extends StatelessWidget {
  const _ContestedList({required this.items, required this.deckById});

  final List<RevealItem> items;
  final Map<String, DeckImage> deckById;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: SizedBox(
              width: 48,
              height: 48,
              child: ClipRRect(
                borderRadius: OhRadii.sm,
                child: deckById[item.id] != null
                    ? Image.asset(
                        deckById[item.id]!.assetPath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => ColoredBox(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                      )
                    : ColoredBox(
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
              ),
            ),
            title: Text(
              deckById[item.id]?.title ?? item.id,
              style: theme.textTheme.bodyMedium,
            ),
            subtitle: Text(
              item.domain.name,
              style: theme.textTheme.bodySmall,
            ),
          ),
      ],
    );
  }
}
