import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../widgets/plate.dart';
import '../content/domain/menswear_spot_question.dart';
import '../content/domain/menswear_term.dart';
import 'menswear_spot_screen.dart';

/// "What's it called" — term-card reveal (quickRead → tap → closerRead), plus
/// an optional Spot quiz. Learning a term writes a `ReadProgress` row (the
/// lexicon); menswear terms carry no through-lines, so — unlike the legacy
/// `ReadScreen` — this never touches `DiscoveredThroughlines`.
class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({
    super.key,
    required this.items,
    required this.memberId,
    this.spotQuestions = const [],
  });

  final List<MenswearTerm> items;
  final String memberId;
  final List<MenswearSpotQuestion> spotQuestions;

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  int _index = 0;
  bool _revealed = false;
  bool _saving = false;

  MenswearTerm get _term => widget.items[_index];
  bool get _hasNext => _index < widget.items.length - 1;

  void _next() {
    if (_hasNext) {
      setState(() {
        _index++;
        _revealed = false;
      });
    }
  }

  Future<void> _addToLexicon() async {
    if (_saving) return;
    setState(() => _saving = true);
    // knewIt:false — "add to my lexicon" records the encounter without a
    // value judgment; both "knew it" and "new to me" are equally valid.
    await ref
        .read(readProgressDaoProvider)
        .markRead(widget.memberId, _term.id, knewIt: false);
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final term = _term;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn'),
        actions: [
          if (widget.spotQuestions.isNotEmpty)
            TextButton(
              key: const Key('learn-open-quiz'),
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => MenswearSpotScreen(
                      questions: widget.spotQuestions,
                      memberId: widget.memberId),
                ),
              ),
              child: const Text('Quiz'),
            ),
        ],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: OhSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: Plate(plateKey: term.id, size: 200)),
              const SizedBox(height: OhSpacing.lg),
              Text(term.term,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium),
              if (term.handle != null) ...[
                const SizedBox(height: OhSpacing.xs),
                Text(term.handle!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              ],
              const SizedBox(height: OhSpacing.md),
              Text(term.gloss,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge
                      ?.copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: OhSpacing.lg),
              _LensCard(label: 'What you notice', body: term.quickRead),
              const SizedBox(height: OhSpacing.md),
              if (!_revealed)
                OutlinedButton(
                  key: const Key('learn-reveal'),
                  onPressed: () => setState(() => _revealed = true),
                  child: const Text('The tell'),
                )
              else
                _LensCard(label: 'The tell', body: term.closerRead),
              const SizedBox(height: OhSpacing.lg),
              OutlinedButton.icon(
                key: const Key('learn-add-to-lexicon'),
                onPressed: _saving ? null : _addToLexicon,
                icon: const Icon(Icons.add),
                label: const Text('Add to my lexicon'),
              ),
              const SizedBox(height: OhSpacing.lg),
              if (_hasNext)
                FilledButton.icon(
                  key: const Key('learn-next'),
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next term'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LensCard extends StatelessWidget {
  const _LensCard({required this.label, required this.body});
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
            Text(label,
                style: theme.textTheme.labelMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: OhSpacing.sm),
            Text(body, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
