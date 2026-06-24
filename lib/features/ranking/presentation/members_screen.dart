import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../widgets/error_view.dart';
import 'round_screen.dart';

// ── Member-color palette ─────────────────────────────────────────────────────
// A fixed set of warm, theme-derived swatches for member chips.
// Colors are taken from OhColors named constants — no inlined hex values.
const List<Color> _memberSwatches = [
  OhColors.hearth400, // terracotta
  OhColors.sage500, // sage green
  OhColors.slate500, // calm slate blue
  OhColors.amber400, // warm amber
  OhColors.hearth700, // deep brick
];

const int _minMembers = 2;
const int _maxMembers = 5;

// ── Providers ────────────────────────────────────────────────────────────────

/// All members, ordered by creation time ascending. Refreshed on invalidation.
final membersProvider = FutureProvider.autoDispose<List<MemberRow>>((ref) {
  return ref.watch(membersDaoProvider).all();
});

// ── Screen ───────────────────────────────────────────────────────────────────

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});

  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  final _labelController = TextEditingController();
  int _selectedColorIndex = 0;
  bool _adding = false;
  bool _labelIsEmpty = true;

  @override
  void initState() {
    super.initState();
    _labelController.addListener(_onLabelChanged);
  }

  void _onLabelChanged() {
    final empty = _labelController.text.trim().isEmpty;
    if (empty != _labelIsEmpty) {
      setState(() => _labelIsEmpty = empty);
    }
  }

  @override
  void dispose() {
    _labelController.removeListener(_onLabelChanged);
    _labelController.dispose();
    super.dispose();
  }

  Future<void> _addMember(List<MemberRow> current) async {
    if (_adding) return;
    final label = _labelController.text.trim();
    if (label.isEmpty || current.length >= _maxMembers) return;

    _adding = true;
    final dao = ref.read(membersDaoProvider);
    try {
      final rng = math.Random();
      final id =
          '${DateTime.now().microsecondsSinceEpoch}-${rng.nextInt(1 << 30)}';
      await dao.add(
        id: id,
        label: label,
        color: _memberSwatches[_selectedColorIndex].toARGB32(),
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      _labelController.clear();
      // Cycle to the next color automatically for the next person.
      setState(() {
        _selectedColorIndex =
            (_selectedColorIndex + 1) % _memberSwatches.length;
      });
      ref.invalidate(membersProvider);
    } finally {
      _adding = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Who's playing?"),
      ),
      body: membersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          debugPrint('MembersScreen error: $e');
          return ErrorView(
            message: "We couldn't load members. Please try again.",
            onRetry: () => ref.invalidate(membersProvider),
          );
        },
        data: (members) {
          final atMax = members.length >= _maxMembers;
          final canStart = members.length >= _minMembers;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Member list ──────────────────────────────────────────────
              Expanded(
                child: members.isEmpty
                    ? _EmptyHint(cs: cs)
                    : ListView.separated(
                        padding: OhSpacing.insetMd,
                        itemCount: members.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: OhSpacing.sm),
                        itemBuilder: (_, i) =>
                            _MemberTile(member: members[i]),
                      ),
              ),

              // ── Add-member form ──────────────────────────────────────────
              if (!atMax) ...[
                const Divider(height: 1),
                _AddMemberForm(
                  controller: _labelController,
                  selectedColorIndex: _selectedColorIndex,
                  labelIsEmpty: _labelIsEmpty,
                  onColorSelected: (i) =>
                      setState(() => _selectedColorIndex = i),
                  onAdd: () => _addMember(members),
                ),
              ] else
                Padding(
                  padding: OhSpacing.insetMd,
                  child: Text(
                    'Maximum of $_maxMembers members reached.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),

              // ── Start round ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(OhSpacing.lg, OhSpacing.sm, OhSpacing.lg, OhSpacing.lg),
                child: ElevatedButton(
                  key: const Key('startRoundButton'),
                  onPressed: canStart
                      ? () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const RoundScreen(),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Start a round'),
                ),
              ),

              if (!canStart && members.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: OhSpacing.md),
                  child: Text(
                    'Add at least $_minMembers people to begin.',
                    style: theme.textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: OhSpacing.insetLg,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline,
              size: 48,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
            ),
            const SizedBox(height: OhSpacing.md),
            Text(
              "Add the people who'll be playing.",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});
  final MemberRow member;

  @override
  Widget build(BuildContext context) {
    final memberColor = Color(member.color);
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: memberColor,
          radius: 16,
        ),
        title: Text(member.label),
      ),
    );
  }
}

class _AddMemberForm extends StatelessWidget {
  const _AddMemberForm({
    required this.controller,
    required this.selectedColorIndex,
    required this.labelIsEmpty,
    required this.onColorSelected,
    required this.onAdd,
  });

  final TextEditingController controller;
  final int selectedColorIndex;
  final bool labelIsEmpty;
  final ValueChanged<int> onColorSelected;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: OhSpacing.insetMd,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name field
          TextField(
            key: const Key('memberNameField'),
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Name',
              hintText: 'e.g. Aria, Dad, Mum...',
            ),
            textCapitalization: TextCapitalization.words,
            onSubmitted: (_) => onAdd(),
          ),
          const SizedBox(height: OhSpacing.sm),

          // Color picker row
          Row(
            children: [
              Text(
                'Color',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: OhSpacing.md),
              for (int i = 0; i < _memberSwatches.length; i++)
                Padding(
                  padding: const EdgeInsets.only(right: OhSpacing.sm),
                  child: Semantics(
                    label: 'Member colour ${i + 1}',
                    selected: selectedColorIndex == i,
                    button: true,
                    child: GestureDetector(
                      key: Key('colorSwatch_$i'),
                      onTap: () => onColorSelected(i),
                      child: SizedBox(
                        width: 44,
                        height: 44,
                        child: Center(
                          child: AnimatedContainer(
                            duration: OhMotion.fast,
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: _memberSwatches[i],
                              shape: BoxShape.circle,
                              border: selectedColorIndex == i
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      width: 2.5,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: OhSpacing.md),

          // Add button — disabled when the name field is empty.
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const Key('addMemberButton'),
              onPressed: labelIsEmpty ? null : onAdd,
              child: const Text('Add person'),
            ),
          ),
        ],
      ),
    );
  }
}
