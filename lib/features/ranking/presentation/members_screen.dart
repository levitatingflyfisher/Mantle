import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../widgets/member_dot.dart';
import '../../../core/theme/theme_preference.dart';
import 'round_screen.dart';

// The member palette (with names) lives in widgets/member_dot.dart.

const int _minMembers = 2;
const int _maxMembers = 5;

// ── Providers ────────────────────────────────────────────────────────────────

/// All members, ordered by creation time ascending. Refreshed on invalidation.
/// Removed members, most recent first, for the "Recently removed" rows.
final removedMembersProvider =
    FutureProvider.autoDispose<List<MemberRow>>((ref) {
  return ref.watch(membersDaoProvider).removed();
});

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

  /// Holds the Undo for a removed member. No timer: it lasts until Undo,
  /// Dismiss, the next removal, or leaving this screen.
  final _undo = OhUndoController();

  @override
  void dispose() {
    _labelController.removeListener(_onLabelChanged);
    _labelController.dispose();
    _undo.dispose();
    super.dispose();
  }

  Future<void> _editMember(MemberRow member) async {
    final result = await showModalBottomSheet<_MemberEdit>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _EditMemberSheet(member: member),
    );
    if (result == null || !mounted) return;
    final dao = ref.read(membersDaoProvider);
    if (result.remove) {
      final row = await dao.remove(member.id);
      if (row == null || !mounted) return;
      _refresh();
      _undo.show(
        message: 'Removed ${row.label}. They stay in Recently removed.',
        onUndo: () => _restore(row.id),
      );
    } else {
      await dao.edit(member.id, label: result.label, color: result.color);
      if (mounted) ref.invalidate(membersProvider);
    }
  }

  void _refresh() {
    ref.invalidate(membersProvider);
    ref.invalidate(removedMembersProvider);
  }

  Future<void> _restore(String id) async {
    await ref.read(membersDaoProvider).restore(id);
    if (mounted) _refresh();
  }

  /// Delete forever is the one irreversible step, from a list that has to be
  /// opened on purpose, so it asks first.
  Future<void> _deleteForever(MemberRow member) async {
    final go = await showOhConfirm(
      context,
      title: 'Delete ${member.label} for good?',
      message: 'They will be gone from this list and can’t be restored. '
          'Past rounds and Charters are kept.',
      confirmLabel: 'Delete ${member.label}',
      destructive: true,
    );
    if (!go || !mounted) return;
    await ref.read(membersDaoProvider).deleteForever(member.id);
    if (mounted) _refresh();
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
        color: memberSwatches[_selectedColorIndex].color.toARGB32(),
        createdAt: DateTime.now(),
      );

      if (!mounted) return;
      _labelController.clear();
      // Cycle to the next color automatically for the next person.
      setState(() {
        _selectedColorIndex =
            (_selectedColorIndex + 1) % memberSwatches.length;
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
    final removed =
        ref.watch(removedMembersProvider).valueOrNull ?? const <MemberRow>[];

    return Scaffold(
      bottomNavigationBar: OhUndoBar(controller: _undo),
      appBar: AppBar(
        title: const Text('Who’s playing?'),
        actions: const [MantleThemeToggle()],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) {
            debugPrint('MembersScreen error: $e');
            return OhErrorState(
              message: 'The list of people didn’t load.',
              error: e,
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
                  child: members.isEmpty && removed.isEmpty
                      ? _EmptyHint(cs: cs)
                      : ListView(
                          padding: OhSpacing.insetMd,
                          children: [
                            for (final m in members) ...[
                              _MemberTile(
                                member: m,
                                onTap: () => _editMember(m),
                              ),
                              const SizedBox(height: OhSpacing.sm),
                            ],
                            if (removed.isNotEmpty)
                              _RecentlyRemoved(
                                members: removed,
                                onRestore: (m) => _restore(m.id),
                                onDeleteForever: _deleteForever,
                              ),
                          ],
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
              'Add the people who’ll be playing.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Removed members, kept until restored or deleted for good, so a removal
/// always has a way back (fleet ruling: Undo never expires).
class _RecentlyRemoved extends StatelessWidget {
  const _RecentlyRemoved({
    required this.members,
    required this.onRestore,
    required this.onDeleteForever,
  });

  final List<MemberRow> members;
  final ValueChanged<MemberRow> onRestore;
  final ValueChanged<MemberRow> onDeleteForever;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: OhSpacing.md),
        Text('Recently removed',
            style: theme.textTheme.titleSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        for (final m in members)
          Padding(
            padding: const EdgeInsets.only(top: OhSpacing.xs),
            child: Row(
              children: [
                MemberDot(color: Color(m.color), label: m.label, radius: 12),
                const SizedBox(width: OhSpacing.sm),
                Expanded(
                  child: Text(m.label, overflow: TextOverflow.ellipsis),
                ),
                TextButton(
                  key: Key('removed-restore-${m.id}'),
                  onPressed: () => onRestore(m),
                  child: const Text('Restore'),
                ),
                IconButton(
                  key: Key('removed-forever-${m.id}'),
                  tooltip: 'Delete ${m.label} for good',
                  icon: const Icon(Icons.delete_forever_outlined),
                  onPressed: () => onDeleteForever(m),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member, required this.onTap});
  final MemberRow member;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final memberColor = Color(member.color);
    return Card(
      child: ListTile(
        leading: MemberDot(color: memberColor, label: member.label),
        title: Text(member.label),
        subtitle: memberColourName(member.color) == null
            ? null
            : Text(memberColourName(member.color)!),
        // The pencil says the row can be changed; the whole row is the
        // target.
        trailing: const Icon(Icons.edit_outlined),
        onTap: onTap,
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

          // Color picker row. The swatches live in a Wrap so they flow onto a
          // second line on narrow phones (≤320dp) or at large text scale rather
          // than overflowing the row.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: OhSpacing.sm),
                child: Text(
                  'Colour',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              const SizedBox(width: OhSpacing.md),
              Expanded(
                child: _SwatchPicker(
                  selectedIndex: selectedColorIndex,
                  onSelected: onColorSelected,
                  keyPrefix: 'colorSwatch_',
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

// ── Swatch picker ─────────────────────────────────────────────────────────────

/// The member colours as named, tappable swatches. The swatches live in a
/// Wrap so they flow onto a second line on narrow phones (320dp) or at large
/// text scale rather than overflowing. [selectedIndex] may be null when a
/// member's stored colour predates the current palette.
class _SwatchPicker extends StatelessWidget {
  const _SwatchPicker({
    required this.selectedIndex,
    required this.onSelected,
    required this.keyPrefix,
  });

  final int? selectedIndex;
  final ValueChanged<int> onSelected;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: OhSpacing.sm,
      runSpacing: OhSpacing.sm,
      children: [
        for (int i = 0; i < memberSwatches.length; i++)
          Semantics(
            label: 'Colour: ${memberSwatches[i].name}',
            selected: selectedIndex == i,
            button: true,
            child: GestureDetector(
              key: Key('$keyPrefix$i'),
              onTap: () => onSelected(i),
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AnimatedContainer(
                    duration: OhMotion.fast,
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: memberSwatches[i].color,
                      shape: BoxShape.circle,
                      border: selectedIndex == i
                          ? Border.all(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 2.5,
                            )
                          : null,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Edit sheet ────────────────────────────────────────────────────────────────

class _MemberEdit {
  const _MemberEdit({this.label, this.color, this.remove = false});
  final String? label;
  final int? color;
  final bool remove;
}

/// Rename, recolour or remove one member, with the same controls the add
/// form has. Remove is one of the edits; it does not ask first, because the
/// list offers an Undo that does not expire.
class _EditMemberSheet extends StatefulWidget {
  const _EditMemberSheet({required this.member});
  final MemberRow member;

  @override
  State<_EditMemberSheet> createState() => _EditMemberSheetState();
}

class _EditMemberSheetState extends State<_EditMemberSheet> {
  late final _name = TextEditingController(text: widget.member.label);
  int? _picked;

  @override
  void initState() {
    super.initState();
    _name.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  int? get _currentIndex {
    if (_picked != null) return _picked;
    for (var i = 0; i < memberSwatches.length; i++) {
      if (memberSwatches[i].color.toARGB32() == widget.member.color) return i;
    }
    return null;
  }

  void _save() {
    final label = _name.text.trim();
    if (label.isEmpty) return;
    Navigator.of(context).pop(_MemberEdit(
      label: label,
      color: _picked == null ? null : memberSwatches[_picked!].color.toARGB32(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final roles = OhColorRoles.of(context);
    return Padding(
      key: const Key('member-edit-sheet'),
      padding: EdgeInsets.only(
        left: OhSpacing.md,
        right: OhSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + OhSpacing.md,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Edit ${widget.member.label}',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: OhSpacing.md),
            TextField(
              key: const Key('member-edit-name'),
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: OhSpacing.md),
            Text('Colour', style: theme.textTheme.bodySmall),
            const SizedBox(height: OhSpacing.xs),
            _SwatchPicker(
              selectedIndex: _currentIndex,
              onSelected: (i) => setState(() => _picked = i),
              keyPrefix: 'member-edit-colour-',
            ),
            const SizedBox(height: OhSpacing.lg),
            FilledButton(
              key: const Key('member-edit-save'),
              onPressed: _name.text.trim().isEmpty ? null : _save,
              child: const Text('Save'),
            ),
            const SizedBox(height: OhSpacing.sm),
            TextButton.icon(
              key: const Key('member-edit-remove'),
              style: TextButton.styleFrom(foregroundColor: roles.urgency),
              icon: const Icon(Icons.person_remove_outlined),
              label: Text('Remove ${widget.member.label}'),
              onPressed: () =>
                  Navigator.of(context).pop(const _MemberEdit(remove: true)),
            ),
          ],
        ),
      ),
    );
  }
}

