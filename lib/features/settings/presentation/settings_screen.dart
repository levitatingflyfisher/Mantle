import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';

import '../../../core/providers.dart';
import '../../../core/theme/theme_preference.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

/// Settings — theme picker, About Mantle blurb, data-reset affordance.
///
/// Theme is a user-owned preference. We never auto-switch based on system
/// dark-mode. Three choices: Daytime / Evening / Late night.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final prefAsync = ref.watch(themePreferenceProvider);
    final currentPref = prefAsync.valueOrNull ?? ThemePreference.light;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: OhSpacing.insetPage,
        children: [
          const SizedBox(height: OhSpacing.md),

          // ── Theme section ─────────────────────────────────────────────────
          Text(
            'Appearance',
            key: const Key('settings-appearance-heading'),
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OhSpacing.sm),

          for (final pref in ThemePreference.values)
            _ThemeOption(
              key: Key('settings-theme-${pref.name}'),
              pref: pref,
              selected: currentPref == pref,
              onTap: () async {
                await setThemePreference(pref);
                ref.invalidate(themePreferenceProvider);
              },
            ),

          const SizedBox(height: OhSpacing.xl),
          const Divider(),
          const SizedBox(height: OhSpacing.lg),

          // ── About section ─────────────────────────────────────────────────
          Text(
            'About Mantle',
            key: const Key('settings-about-heading'),
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OhSpacing.sm),
          Text(
            'Mantle helps households discover the aesthetic thread that runs through their home — not by expertise, but by noticing what they\'re already drawn to.\n\n'
            'Everything stays on your device. No account required, no data leaves without your say-so.\n\n'
            'Part of the OpenHearth family of tools for domestic life.',
            key: const Key('settings-about-body'),
            style: theme.textTheme.bodyMedium,
          ),
          Text(
            'v1.0 · MIT license',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: OhSpacing.xl),
          const Divider(),
          const SizedBox(height: OhSpacing.lg),

          // ── Data reset section ────────────────────────────────────────────
          Text(
            'Data',
            key: const Key('settings-data-heading'),
            style: theme.textTheme.titleSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OhSpacing.sm),
          Text(
            'Clear all local data — members, rounds, charters, and solo progress. This cannot be undone.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: OhSpacing.md),
          OutlinedButton(
            key: const Key('settings-reset-button'),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
            onPressed: () => _confirmReset(context, ref),
            child: const Text('Clear all data'),
          ),

          const SizedBox(height: OhSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all data?'),
        content: const Text(
          'Members, rounds, charters, and solo progress will be permanently deleted.',
        ),
        actions: [
          TextButton(
            key: const Key('settings-reset-cancel'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            key: const Key('settings-reset-confirm'),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final db = ref.read(databaseProvider);
      await db.transaction(() async {
        // Delete rows from every table — schema version stays intact so the
        // app remains functional immediately after the wipe.
        await db.delete(db.members).go();
        await db.delete(db.rounds).go();
        await db.delete(db.rankingSessions).go();
        await db.delete(db.rankingMatches).go();
        await db.delete(db.charters).go();
        await db.delete(db.readProgress).go();
        await db.delete(db.spotProgress).go();
        await db.delete(db.discoveredThroughlines).go();
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('All local data cleared.')),
        );
      }
    }
  }
}

// ── _ThemeOption ──────────────────────────────────────────────────────────────

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    super.key,
    required this.pref,
    required this.selected,
    required this.onTap,
  });

  final ThemePreference pref;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(OhSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: OhSpacing.sm),
        child: Row(
          children: [
            SizedBox(
              key: Key('settings-theme-radio-${pref.name}'),
              width: 24,
              height: 24,
              child: Icon(
                selected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                size: 20,
                color: selected ? cs.primary : cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: OhSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pref.label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    pref.hint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
