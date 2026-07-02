import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../widgets/plate.dart';
import '../../content/domain/canon_item.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Displays a single canon item for solo reading.
///
/// Layout: plate → term → gloss → principle → two equal lenses
/// (quickRead / closerRead) → cross-domain echo note.
/// Neither lens is presented as more advanced or preferred than the other —
/// they are two ways of looking at the same thing.
///
/// An optional self-report row lets the reader record whether the term was
/// already known to them. This is informational only — it does NOT feed the
/// reveal or alter any ranking.
class ReadScreen extends ConsumerStatefulWidget {
  const ReadScreen({
    super.key,
    required this.items,
    required this.memberId,
    this.initialIndex = 0,
  });

  /// The full list of canon items to page through.
  final List<CanonItem> items;

  /// The member whose [ReadProgress] rows will be written.
  final String memberId;

  /// Which item to open on first display.
  final int initialIndex;

  @override
  ConsumerState<ReadScreen> createState() => _ReadScreenState();
}

class _ReadScreenState extends ConsumerState<ReadScreen> {
  late int _index;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  CanonItem get _current => widget.items[_index];
  bool get _hasPrev => _index > 0;
  bool get _hasNext => _index < widget.items.length - 1;

  Future<void> _report({required bool knewIt}) async {
    final item = _current; // capture before any await to avoid race on navigation
    final dao = ref.read(readProgressDaoProvider);
    await dao.markRead(widget.memberId, item.id, knewIt: knewIt);
    // Reading an item means the member has encountered its through-lines — record
    // each so they surface on the solo Map (markSeen had no callers, so Map mode
    // was permanently "Nothing has surfaced yet").
    final discovered = ref.read(discoveredThroughlinesDaoProvider);
    for (final throughlineId in item.throughlines) {
      await discovered.markSeen(widget.memberId, throughlineId);
    }
  }

  void _goNext() {
    if (_hasNext) setState(() => _index++);
  }

  void _goPrev() {
    if (_hasPrev) setState(() => _index--);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = _current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read'),
        actions: [
          if (_hasNext)
            TextButton(
              key: const Key('read-next'),
              onPressed: _goNext,
              child: const Text('Next'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: OhSpacing.insetPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Plate ──────────────────────────────────────────────────────
            Center(
              child: Plate(
                key: Key('read-plate-${item.plate}'),
                plateKey: item.plate,
                size: 200,
              ),
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Term ───────────────────────────────────────────────────────
            Text(
              item.term,
              key: const Key('read-term'),
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OhSpacing.sm),

            // ── Gloss ──────────────────────────────────────────────────────
            Text(
              item.gloss,
              key: const Key('read-gloss'),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Principle ──────────────────────────────────────────────────
            Text(
              item.principle,
              key: const Key('read-principle'),
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Two equal lenses ────────────────────────────────────────────
            // quickRead and closerRead are two ways of looking at the same
            // concept. Neither is a "better" or "deeper" reading than the
            // other — they are different angles on the same truth.
            _LensCard(
              key: const Key('read-quick-read'),
              label: 'Quick read',
              body: item.quickRead,
            ),
            const SizedBox(height: OhSpacing.md),
            _LensCard(
              key: const Key('read-closer-read'),
              label: 'Closer read',
              body: item.closerRead,
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Cross-domain echo ───────────────────────────────────────────
            if (item.echo.note.isNotEmpty) ...[
              _EchoNote(
                key: const Key('read-echo'),
                note: item.echo.note,
              ),
              const SizedBox(height: OhSpacing.lg),
            ],

            // ── Self-report ────────────────────────────────────────────────
            // Key is scoped to the current item so Flutter creates a fresh
            // _SelfReportState (resetting _choice to null) when the user
            // navigates to a different item.
            _SelfReport(
              key: Key('read-self-report-${item.id}'),
              onReport: _report,
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Navigation ─────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_hasPrev)
                  OutlinedButton.icon(
                    key: const Key('read-prev-button'),
                    onPressed: _goPrev,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                if (_hasNext)
                  FilledButton.icon(
                    key: const Key('read-next-button'),
                    onPressed: _goNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  )
                else
                  const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: OhSpacing.xl),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

/// One of the two equal reading lenses (quickRead or closerRead).
///
/// Both lenses share identical visual weight — same card style, same label
/// treatment. The labels "Quick read" / "Closer read" describe when each
/// naturally arises, not which is more correct.
class _LensCard extends StatelessWidget {
  const _LensCard({
    super.key,
    required this.label,
    required this.body,
  });

  final String label;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: OhSpacing.insetMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: OhSpacing.sm),
            Text(
              body,
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Cross-domain echo note shown beneath the two lenses.
class _EchoNote extends StatelessWidget {
  const _EchoNote({super.key, required this.note});
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.link,
          size: 16,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: OhSpacing.sm),
        Expanded(
          child: Text(
            note,
            key: const Key('read-echo-text'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

/// Self-report row: "Knew it" / "New to me".
///
/// Both options are presented with equal visual weight — there is no penalty
/// for finding something new, and no reward for already knowing it.
class _SelfReport extends StatefulWidget {
  const _SelfReport({super.key, required this.onReport});
  final Future<void> Function({required bool knewIt}) onReport;

  @override
  State<_SelfReport> createState() => _SelfReportState();
}

class _SelfReportState extends State<_SelfReport> {
  bool? _choice;
  bool _saving = false;

  Future<void> _tap(bool knewIt) async {
    if (_saving) return;
    setState(() {
      _saving = true;
      _choice = knewIt;
    });
    await widget.onReport(knewIt: knewIt);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Was this term already familiar?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: OhSpacing.sm),
        Row(
          children: [
            OutlinedButton(
              key: const Key('read-knew-it'),
              onPressed: _saving ? null : () => _tap(true),
              style: _choice == true
                  ? OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 2),
                    )
                  : null,
              child: const Text('Knew it'),
            ),
            const SizedBox(width: OhSpacing.md),
            OutlinedButton(
              key: const Key('read-new-to-me'),
              onPressed: _saving ? null : () => _tap(false),
              style: _choice == false
                  ? OutlinedButton.styleFrom(
                      side: BorderSide(
                          color: theme.colorScheme.primary, width: 2),
                    )
                  : null,
              child: const Text('New to me'),
            ),
          ],
        ),
      ],
    );
  }
}
