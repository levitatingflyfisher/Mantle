import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../widgets/activity_card.dart';
import '../../ranking/presentation/members_screen.dart';
import '../../reveal/presentation/charter_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../solo/presentation/solo_hub_screen.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mantle'),
        actions: [
          IconButton(
            key: const Key('home-settings-button'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
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

                const SizedBox(height: OhSpacing.xl),

                // ── Primary action — Start a round ───────────────────────────
                ActivityCard(
                  icon: Icons.people_outline,
                  title: 'Start a round',
                  subtitle:
                      'Gather the household and rank together to find the thread that runs through your home.',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const MembersScreen(),
                    ),
                  ),
                ),

                const SizedBox(height: OhSpacing.md),

                // ── Open last Charter ────────────────────────────────────────
                ActivityCard(
                  icon: Icons.auto_stories_outlined,
                  title: 'Open last Charter',
                  subtitle: "Your House's spine and named through-lines.",
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
                              Text('No charter yet — complete a round first.'),
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
                      'Read the vocabulary, train your eye, or map your through-lines — solo, any time.',
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
    );
  }
}
