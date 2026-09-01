import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../solo/domain/spot_grading.dart';
import '../../../widgets/plate.dart';
import '../content/domain/menswear_spot_question.dart';

/// Compact menswear discrimination quiz. Parallel to the legacy `SpotScreen`
/// (which is hard-typed to `SpotQuestion`), it grades `side == correctSide`
/// and records attempts to `SpotProgress` keyed by the menswear question id.
class MenswearSpotScreen extends ConsumerStatefulWidget {
  const MenswearSpotScreen(
      {super.key, required this.questions, required this.memberId});

  final List<MenswearSpotQuestion> questions;
  final String memberId;

  @override
  ConsumerState<MenswearSpotScreen> createState() =>
      _MenswearSpotScreenState();
}

class _MenswearSpotScreenState extends ConsumerState<MenswearSpotScreen> {
  int _index = 0;
  String? _chosenSide;
  bool? _lastCorrect;
  bool _saving = false;

  MenswearSpotQuestion get _q => widget.questions[_index];
  bool get _answered => _chosenSide != null;
  bool get _hasNext => _index < widget.questions.length - 1;

  Future<void> _choose(String side) async {
    if (_answered || _saving) return;
    final correct = side == _q.correctSide;
    setState(() {
      _saving = true;
      _chosenSide = side;
      _lastCorrect = correct;
    });
    await ref
        .read(spotProgressDaoProvider)
        .recordAttempt(widget.memberId, _q.id, correct: correct);
    if (mounted) setState(() => _saving = false);
  }

  void _next() {
    if (_hasNext) {
      setState(() {
        _index++;
        _chosenSide = null;
        _lastCorrect = null;
      });
    }
  }

  Widget _optionA() => Expanded(
        child: _SpotOption(
          key: const Key('ms-spot-plate-A'),
          plateKey: _q.plateA,
          side: 'A',
          correctSide: _answered ? _q.correctSide : null,
          onTap: _answered ? null : () => _choose('A'),
        ),
      );

  Widget _optionB() => Expanded(
        child: _SpotOption(
          key: const Key('ms-spot-plate-B'),
          plateKey: _q.plateB,
          side: 'B',
          correctSide: _answered ? _q.correctSide : null,
          onTap: _answered ? null : () => _choose('B'),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Spot the difference')),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: OhSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('${_index + 1} of ${widget.questions.length}',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelSmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
              const SizedBox(height: OhSpacing.md),
              Text(_q.promptText,
                  key: const Key('ms-spot-prompt'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium),
              const SizedBox(height: OhSpacing.lg),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Plate order varies by member and question (badass-01); keys
                // and the grade follow the plate, not the slot.
                children: SpotGrading.showBFirst(widget.memberId, _q.id)
                    ? [_optionB(), const SizedBox(width: OhSpacing.md), _optionA()]
                    : [_optionA(), const SizedBox(width: OhSpacing.md), _optionB()],
              ),
              const SizedBox(height: OhSpacing.lg),
              if (_answered) ...[
                Card(
                  key: const Key('ms-spot-explanation'),
                  child: Padding(
                    padding: OhSpacing.insetMd,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_lastCorrect! ? 'That’s the one.' : 'Not quite.',
                            style: theme.textTheme.labelMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: OhSpacing.sm),
                        Text(_q.explanation, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: OhSpacing.lg),
                if (_hasNext)
                  FilledButton.icon(
                    key: const Key('ms-spot-next'),
                    onPressed: _next,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpotOption extends StatelessWidget {
  const _SpotOption({
    super.key,
    required this.plateKey,
    required this.side,
    required this.correctSide,
    this.onTap,
  });

  final String plateKey;
  final String side;
  final String? correctSide;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final answered = correctSide != null;
    final isCorrect = correctSide == side;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: OhRadii.md,
          border: Border.all(
            color: answered && isCorrect ? cs.primary : cs.outlineVariant,
            width: answered && isCorrect ? 2 : 1,
          ),
        ),
        padding: OhSpacing.insetSm,
        child: Plate(plateKey: plateKey, size: 140),
      ),
    );
  }
}
