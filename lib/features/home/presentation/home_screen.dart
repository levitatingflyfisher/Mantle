import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

import '../../../core/providers.dart';
import '../../../core/theme/theme_preference.dart';
import '../../../widgets/activity_card.dart';
import '../../ranking/data/unfinished_round.dart';
import '../../ranking/presentation/members_screen.dart';
import '../../ranking/presentation/round_screen.dart';
import '../../reveal/presentation/charter_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../solo/presentation/solo_hub_screen.dart';
import '../../tutor/presentation/tutor_hub_screen.dart';

/// The Hearth — Mantle's home screen.
///
/// Three entry points:
/// - Start a round (→ [MembersScreen], then round in Task 12)
/// - Open last Charter (→ [CharterScreen] when a charter exists)
/// - Explore solo depth (placeholder — Read/Spot/Map arrive in later tasks)
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final offer = ref.watch(roundResumeOfferProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantle'),
        // Two labelled actions only fit a 320dp bar up to 2x text, so the
        // labels stop growing there; the page itself scales fully.
        actions: [
          MediaQuery.withClampedTextScaling(
            maxScaleFactor: 2.0,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MantleThemeToggle(),
                TextButton.icon(
                  key: const Key('home-settings-button'),
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Settings'),
                  onPressed: () => Navigator.push<void>(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const SettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: OhPage(
        padding: EdgeInsets.zero,
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: OhSpacing.insetPage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: OhSpacing.xl),

                  // ── Wordmark / title ─────────────────────────────────────────
                  Text(
                    'Mantle',
                    style: theme.textTheme.displayMedium,
                  ),
                  const SizedBox(height: OhSpacing.xs),
                  Text(
                    'Discover what is recognizably yours.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),

                  // ── Finish setup (fleet first-run ruling) ───────────────────
                  // Takes no space once backup is set up or dismissed.
                  const BackupSetupReminder(),

                  const SizedBox(height: OhSpacing.xl),

                  // ── An unfinished round comes first (audit finding 8) ────────
                  if (offer != null && !offer.peopleChanged) ...[
                    ActivityCard(
                      key: const Key('home-continue-round'),
                      icon: Icons.play_arrow_outlined,
                      title: 'Continue the round',
                      subtitle: offer.line,
                      onTap: () async {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => const RoundScreen(resume: true),
                          ),
                        );
                        ref.invalidate(roundResumeOfferProvider);
                      },
                    ),
                    const SizedBox(height: OhSpacing.md),
                  ],

                  // ── Primary action, first (audit finding 3): Start a round ──
                  ActivityCard(
                    icon: Icons.people_outline,
                    title: 'Start a round',
                    subtitle:
                        'Gather the household and rank together to find the thread that runs through your home.',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) => const MembersScreen(),
                        ),
                      );
                      ref.invalidate(roundResumeOfferProvider);
                    },
                  ),
                  if (offer != null && offer.peopleChanged)
                    Padding(
                      padding: const EdgeInsets.only(top: OhSpacing.sm),
                      child: Text(
                        offer.line,
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  const SizedBox(height: OhSpacing.md),

                  // ── The menswear tutor: a room off Home, below the primary ─────
                  ActivityCard(
                    key: const Key('home-tutor-card'),
                    icon: Icons.checkroom_outlined,
                    title: 'Learn your style',
                    subtitle:
                        'Learn the names, find your lean, and see your Field Guide.',
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const TutorHubScreen(),
                      ),
                    ),
                  ),

                  const SizedBox(height: OhSpacing.md),

                  // ── Open last Charter ────────────────────────────────────────
                  ActivityCard(
                    icon: Icons.auto_stories_outlined,
                    title: 'Open last Charter',
                    subtitle: 'Your House’s spine and named through-lines.',
                    onTap: () async {
                      final chartersDao = ref.read(chartersDaoProvider);
                      final charter = await chartersDao.latest();
                      if (charter != null && context.mounted) {
                        await Navigator.push<void>(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CharterScreen(charter: charter),
                          ),
                        );
                      } else if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('No charter yet. Complete a round first.'),
                          ),
                        );
                      }
                    },
                  ),

                  const SizedBox(height: OhSpacing.md),

                  // ── Explore solo depth ───────────────────────────────────────
                  ActivityCard(
                    icon: Icons.explore_outlined,
                    title: 'Explore',
                    subtitle:
                        'Read the vocabulary, train your eye, or map your through-lines: solo, any time.',
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const SoloHubScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
