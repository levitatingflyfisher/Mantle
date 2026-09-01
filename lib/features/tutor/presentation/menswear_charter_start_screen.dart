import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/utils/id.dart';
import '../../ranking/presentation/members_screen.dart';
import 'menswear_family_round_screen.dart';

const int _minFamilyMembers = 2;

/// Member picker for the two-or-more-member menswear House Charter flow.
/// Creates ONE shared round, then hands the checked members to
/// [MenswearFamilyRoundScreen] to each run their lean round under it.
///
/// Additive to the legacy `MembersScreen` — reuses it only as an add-people
/// affordance when fewer than [_minFamilyMembers] people exist yet.
class MenswearCharterStartScreen extends ConsumerStatefulWidget {
  const MenswearCharterStartScreen({super.key});

  @override
  ConsumerState<MenswearCharterStartScreen> createState() =>
      _MenswearCharterStartScreenState();
}

class _MenswearCharterStartScreenState
    extends ConsumerState<MenswearCharterStartScreen> {
  final Set<String> _selected = {};
  bool _starting = false;

  Future<void> _begin(List<MemberRow> members) async {
    if (_starting || _selected.length < _minFamilyMembers) return;
    setState(() => _starting = true);

    final roundId = secureHexId();
    await ref
        .read(roundsDaoProvider)
        .create(id: roundId, deckVersion: 1, createdAt: DateTime.now());
    if (!mounted) return;

    final chosen = [
      for (final m in members)
        if (_selected.contains(m.id)) m
    ];

    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            MenswearFamilyRoundScreen(members: chosen, roundId: roundId),
      ),
    );
    if (mounted) setState(() => _starting = false);
  }

  Future<void> _addMembers() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const MembersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(membersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your House Charter')),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: membersAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => OhErrorState(
            message: 'The list of people didn’t load.',
            error: e,
            onRetry: () => ref.invalidate(membersProvider),
          ),
          data: (members) {
            if (members.length < _minFamilyMembers) {
              return Center(
                child: Padding(
                  padding: OhSpacing.insetLg,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Add at least 2 people to build a House Charter',
                        style: theme.textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: OhSpacing.lg),
                      FilledButton(
                        key: const Key('family-add-members'),
                        onPressed: _addMembers,
                        child: const Text('Add people'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: OhSpacing.insetMd,
                    itemCount: members.length,
                    itemBuilder: (_, i) {
                      final m = members[i];
                      return CheckboxListTile(
                        key: Key('family-member-${m.id}'),
                        value: _selected.contains(m.id),
                        title: Text(m.label),
                        onChanged: (checked) => setState(() {
                          if (checked ?? false) {
                            _selected.add(m.id);
                          } else {
                            _selected.remove(m.id);
                          }
                        }),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: OhSpacing.insetMd,
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      key: const Key('family-begin'),
                      onPressed: _selected.length >= _minFamilyMembers
                          ? () => _begin(members)
                          : null,
                      child: const Text('Begin'),
                    ),
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
