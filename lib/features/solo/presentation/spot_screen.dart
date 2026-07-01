import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../widgets/plate.dart';
import '../../content/domain/spot_question.dart';
import '../domain/spot_grading.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Spot mode: training the eye on drawn contrast pairs.
///
/// Shows [promptText] and two plates side by side. After the reader picks one,
/// the explanation is revealed and the attempt is recorded in [SpotProgress].
/// This is eye-training — it is never presented as a taste test or scored
/// against the reveal.
class SpotScreen extends ConsumerStatefulWidget {
  const SpotScreen({
    super.key,
    required this.questions,
    required this.memberId,
    this.initialIndex = 0,
  });

  /// The list of spot questions to work through.
  final List<SpotQuestion> questions;

  /// The member whose [SpotProgress] rows will be written.
  final String memberId;

  /// Which question to open on first display.
  final int initialIndex;

  @override
  ConsumerState<SpotScreen> createState() => _SpotScreenState();
}

class _SpotScreenState extends ConsumerState<SpotScreen> {
  late int _index;
  String? _chosenSide; // null = not yet answered
  bool? _lastCorrect;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
  }

  SpotQuestion get _current => widget.questions[_index];
  bool get _answered => _chosenSide != null;
  bool get _hasNext => _index < widget.questions.length - 1;
  bool get _hasPrev => _index > 0;

  Future<void> _choose(String side) async {
    if (_answered || _saving) return;
    final q = _current;
    final correct = SpotGrading.grade(q, side);

    setState(() {
      _saving = true;
      _chosenSide = side;
      _lastCorrect = correct;
    });

    final dao = ref.read(spotProgressDaoProvider);
    await dao.recordAttempt(widget.memberId, q.id, correct: correct);

    if (mounted) setState(() => _saving = false);
  }

  void _goNext() {
    if (_hasNext) {
      setState(() {
        _index++;
        _chosenSide = null;
        _lastCorrect = null;
      });
    }
  }

  void _goPrev() {
    if (_hasPrev) {
      setState(() {
        _index--;
        _chosenSide = null;
        _lastCorrect = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final q = _current;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spot'),
      ),
      body: SingleChildScrollView(
        padding: OhSpacing.insetPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Progress indicator ─────────────────────────────────────────
            Text(
              '${_index + 1} of ${widget.questions.length}',
              key: const Key('spot-counter'),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OhSpacing.md),

            // ── Prompt ─────────────────────────────────────────────────────
            Text(
              q.promptText,
              key: const Key('spot-prompt'),
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Two plates ─────────────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _PlateOption(
                    key: const Key('spot-plate-A'),
                    plateKey: q.plateA,
                    side: 'A',
                    chosenSide: _chosenSide,
                    correctSide: _answered ? q.correctSide : null,
                    onTap: _answered ? null : () => _choose('A'),
                  ),
                ),
                const SizedBox(width: OhSpacing.md),
                Expanded(
                  child: _PlateOption(
                    key: const Key('spot-plate-B'),
                    plateKey: q.plateB,
                    side: 'B',
                    chosenSide: _chosenSide,
                    correctSide: _answered ? q.correctSide : null,
                    onTap: _answered ? null : () => _choose('B'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: OhSpacing.lg),

            // ── Explanation (shown after answering) ────────────────────────
            if (_answered) ...[
              _ExplanationCard(
                key: const Key('spot-explanation'),
                explanation: q.explanation,
                correct: _lastCorrect!,
              ),
              const SizedBox(height: OhSpacing.lg),
            ],

            // ── Navigation ──────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_hasPrev)
                  OutlinedButton.icon(
                    key: const Key('spot-prev-button'),
                    onPressed: _goPrev,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                if (_hasNext && _answered)
                  FilledButton.icon(
                    key: const Key('spot-next-button'),
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

/// A tappable plate option in the Spot pair.
class _PlateOption extends StatelessWidget {
  const _PlateOption({
    super.key,
    required this.plateKey,
    required this.side,
    required this.chosenSide,
    required this.correctSide,
    this.onTap,
  });

  final String plateKey;
  final String side;
  final String? chosenSide;
  final String? correctSide; // non-null once answered
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    // Determine visual state after answering.
    final isChosen = chosenSide == side;
    final isCorrect = correctSide == side;

    Color? borderColor;
    if (chosenSide != null) {
      // Show which was correct once the reader has answered.
      if (isCorrect) {
        borderColor = cs.primary;
      } else if (isChosen) {
        borderColor = cs.onSurfaceVariant;
      }
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(OhSpacing.sm),
          border: borderColor != null
              ? Border.all(color: borderColor, width: 2)
              : Border.all(
                  color: cs.outlineVariant,
                  width: 1,
                ),
        ),
        padding: OhSpacing.insetSm,
        child: Column(
          children: [
            Plate(
              key: Key('plate-option-$side-$plateKey'),
              plateKey: plateKey,
              size: 140,
            ),
            const SizedBox(height: OhSpacing.xs),
            Text(
              side,
              style: theme.textTheme.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Explanation card shown after the reader makes a choice.
///
/// Uses neutral language — "That's the one" / "Not quite" — framing this as
/// eye-training rather than a judgment of the reader's taste.
class _ExplanationCard extends StatelessWidget {
  const _ExplanationCard({
    super.key,
    required this.explanation,
    required this.correct,
  });

  final String explanation;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = correct ? "That's the one." : 'Not quite —';

    return Card(
      child: Padding(
        padding: OhSpacing.insetMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              key: const Key('spot-result-label'),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: OhSpacing.sm),
            Text(
              explanation,
              key: const Key('spot-explanation-text'),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
