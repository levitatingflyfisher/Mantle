import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/db/database.dart';
import '../../../core/providers.dart';
import '../../../core/theme/theme_preference.dart';
import '../../../widgets/activity_card.dart';
import '../content/domain/menswear_spot_question.dart';
import '../content/domain/menswear_term.dart';
import 'field_guide_screen.dart';
import 'learn_screen.dart';
import 'lean_round_screen.dart';
import 'menswear_charter_start_screen.dart';

final _tutorMembersProvider = FutureProvider.autoDispose<List<MemberRow>>(
  (ref) => ref.watch(membersDaoProvider).all(),
);
final _tutorTermsProvider = FutureProvider.autoDispose<List<MenswearTerm>>(
  (ref) => ref.watch(menswearRepositoryProvider).terms(),
);
final _tutorSpotProvider =
    FutureProvider.autoDispose<List<MenswearSpotQuestion>>(
  (ref) => ref.watch(menswearRepositoryProvider).spotQuestions(),
);

/// Entry point for the menswear tutor: Learn · Find your lean · Field Guide.
/// Owns the single `effectiveMemberId` threaded into all three stages so the
/// lexicon and the archetype are computed for the *same* member.
class TutorHubScreen extends ConsumerStatefulWidget {
  const TutorHubScreen({super.key});

  @override
  ConsumerState<TutorHubScreen> createState() => _TutorHubScreenState();
}

class _TutorHubScreenState extends ConsumerState<TutorHubScreen> {
  String? _selectedMemberId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final membersAsync = ref.watch(_tutorMembersProvider);
    final termsAsync = ref.watch(_tutorTermsProvider);
    final spotAsync = ref.watch(_tutorSpotProvider);

    if (membersAsync is AsyncLoading ||
        termsAsync is AsyncLoading ||
        spotAsync is AsyncLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn your style')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (termsAsync is AsyncError) {
      return Scaffold(
        appBar: AppBar(title: const Text('Learn your style')),
        body: OhPage(
          padding: EdgeInsets.zero,
          child: OhErrorState(
            message: 'The menswear guide didn’t load.',
            error: termsAsync.error,
            onRetry: () => ref.invalidate(_tutorTermsProvider),
          ),
        ),
      );
    }

    final members = membersAsync.valueOrNull ?? [];
    final terms = termsAsync.valueOrNull ?? [];
    // A spot-load error must not block the hub — Learn's term cards still
    // work without the quiz; it just means no Quiz button.
    final spotQuestions =
        spotAsync.valueOrNull ?? const <MenswearSpotQuestion>[];

    // Single member-id source (invariant 1): selection, else first member,
    // else 'anonymous' for the solo-no-household path.
    const anonymousId = 'anonymous';
    final memberId = _selectedMemberId ??
        (members.isNotEmpty ? members.first.id : anonymousId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learn your style'),
        actions: const [MantleThemeToggle()],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          padding: OhSpacing.insetPage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: OhSpacing.md),
              if (members.length > 1) ...[
                Text('Exploring as',
                    style: theme.textTheme.labelMedium
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                const SizedBox(height: OhSpacing.sm),
                Wrap(
                  spacing: OhSpacing.sm,
                  children: [
                    for (final m in members)
                      ChoiceChip(
                        key: Key('tutor-member-${m.id}'),
                        label: Text(m.label),
                        selected: memberId == m.id,
                        onSelected: (_) =>
                            setState(() => _selectedMemberId = m.id),
                      ),
                  ],
                ),
                const SizedBox(height: OhSpacing.xl),
              ],
              ActivityCard(
                key: const Key('tutor-learn'),
                icon: Icons.menu_book_outlined,
                title: 'Learn the names',
                subtitle: 'What is it called, and what is the tell?',
                onTap: terms.isEmpty
                    ? null
                    : () => Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => LearnScreen(
                              items: terms,
                              spotQuestions: spotQuestions,
                              memberId: memberId,
                            ),
                          ),
                        ),
              ),
              const SizedBox(height: OhSpacing.md),
              ActivityCard(
                key: const Key('tutor-lean'),
                icon: Icons.swipe_outlined,
                title: 'Find your lean',
                subtitle: 'Which draws you? Pairwise picks shape your look.',
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => LeanRoundScreen(memberId: memberId),
                  ),
                ),
              ),
              const SizedBox(height: OhSpacing.md),
              ActivityCard(
                key: const Key('tutor-field-guide'),
                icon: Icons.explore_outlined,
                title: 'Your Field Guide',
                subtitle: 'The words you own and where your taste lands.',
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => FieldGuideScreen(memberId: memberId),
                  ),
                ),
              ),
              const SizedBox(height: OhSpacing.md),
              ActivityCard(
                key: const Key('tutor-charter'),
                icon: Icons.workspaces_outline,
                title: 'Your House Charter',
                subtitle: 'Discover the look your household shares.',
                onTap: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const MenswearCharterStartScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
