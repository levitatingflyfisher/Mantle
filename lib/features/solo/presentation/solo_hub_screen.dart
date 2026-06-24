import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../widgets/activity_card.dart';
import '../../../widgets/error_view.dart';
import '../../content/domain/canon_item.dart';
import '../../content/domain/spot_question.dart';
import 'map_screen.dart';
import 'read_screen.dart';
import 'spot_screen.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

final _membersForHubProvider = FutureProvider.autoDispose<List<MemberRow>>(
  (ref) => ref.watch(membersDaoProvider).all(),
);

final _canonForHubProvider = FutureProvider.autoDispose<List<CanonItem>>(
  (ref) => ref.watch(contentRepositoryProvider).canon(),
);

final _spotQuestionsForHubProvider =
    FutureProvider.autoDispose<List<SpotQuestion>>(
  (ref) => ref.watch(contentRepositoryProvider).spotQuestions(),
);

// ── Screen ────────────────────────────────────────────────────────────────────

/// Solo-exploration hub: entry point for Read, Spot, and Map modes.
///
/// The user first selects which member they are exploring as (or proceeds as
/// "Anyone" when no members exist yet).  Then they choose the activity.
class SoloHubScreen extends ConsumerStatefulWidget {
  const SoloHubScreen({super.key});

  @override
  ConsumerState<SoloHubScreen> createState() => _SoloHubScreenState();
}

class _SoloHubScreenState extends ConsumerState<SoloHubScreen> {
  String? _selectedMemberId;
  String? _selectedMemberLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final membersAsync = ref.watch(_membersForHubProvider);
    final canonAsync = ref.watch(_canonForHubProvider);
    final spotAsync = ref.watch(_spotQuestionsForHubProvider);

    // Loading state
    if (membersAsync is AsyncLoading ||
        canonAsync is AsyncLoading ||
        spotAsync is AsyncLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Explore')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Error state — surface asset load failures rather than silently disabling cards.
    if (canonAsync is AsyncError || spotAsync is AsyncError) {
      return const ErrorView(
        message: "We couldn't load the content. Please try again.",
      );
    }

    final members = membersAsync.valueOrNull ?? [];
    final canon = canonAsync.valueOrNull ?? [];
    final spotQuestions = spotAsync.valueOrNull ?? [];

    // Choose a default member id to use when none are registered yet.
    const anonymousId = 'anonymous';
    final effectiveMemberId = _selectedMemberId ??
        (members.isNotEmpty ? members.first.id : anonymousId);
    final effectiveLabel = _selectedMemberLabel ??
        (members.isNotEmpty ? members.first.label : null);

    return Scaffold(
      appBar: AppBar(title: const Text('Explore')),
      body: SingleChildScrollView(
        padding: OhSpacing.insetPage,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: OhSpacing.md),

            // ── Member selector ──────────────────────────────────────────────
            if (members.length > 1) ...[
              Text(
                'Exploring as',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: OhSpacing.sm),
              Wrap(
                spacing: OhSpacing.sm,
                children: [
                  for (final m in members)
                    ChoiceChip(
                      key: Key('solo-hub-member-${m.id}'),
                      label: Text(m.label),
                      selected: effectiveMemberId == m.id,
                      onSelected: (_) => setState(() {
                        _selectedMemberId = m.id;
                        _selectedMemberLabel = m.label;
                      }),
                    ),
                ],
              ),
              const SizedBox(height: OhSpacing.xl),
            ],

            // ── Activity cards ───────────────────────────────────────────────
            ActivityCard(
              key: const Key('solo-hub-read'),
              icon: Icons.menu_book_outlined,
              title: 'Read',
              subtitle: 'Explore the vocabulary of the canon — term by term.',
              onTap: canon.isEmpty
                  ? null
                  : () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => ReadScreen(
                            items: canon,
                            memberId: effectiveMemberId,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: OhSpacing.md),

            ActivityCard(
              key: const Key('solo-hub-spot'),
              icon: Icons.remove_red_eye_outlined,
              title: 'Spot',
              subtitle:
                  'Train your eye — pick the more resolved plate in each pair.',
              onTap: spotQuestions.isEmpty
                  ? null
                  : () => Navigator.push<void>(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => SpotScreen(
                            questions: spotQuestions,
                            memberId: effectiveMemberId,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: OhSpacing.md),

            ActivityCard(
              key: const Key('solo-hub-map'),
              icon: Icons.map_outlined,
              title: 'Map',
              subtitle:
                  'See which through-lines your eye keeps returning to.',
              onTap: () => Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (_) => MapScreen(
                    memberId: effectiveMemberId,
                    memberLabel: effectiveLabel,
                  ),
                ),
              ),
            ),

            const SizedBox(height: OhSpacing.xl),
          ],
        ),
      ),
    );
  }
}

