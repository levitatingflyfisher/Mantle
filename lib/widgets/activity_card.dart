import 'package:flutter/material.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// A tappable card showing an activity entry point with icon, title, subtitle,
/// and an optional chevron.
///
/// When [onTap] is null the card is rendered in a disabled visual state: the
/// icon and text are dimmed and the trailing chevron is hidden.
class ActivityCard extends StatelessWidget {
  const ActivityCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final disabled = onTap == null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: OhSpacing.insetMd,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: 28,
                color: disabled
                    ? cs.onSurface.withValues(alpha: 0.3)
                    : cs.primary,
              ),
              const SizedBox(width: OhSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: disabled
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : null,
                      ),
                    ),
                    const SizedBox(height: OhSpacing.xs),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: disabled
                            ? cs.onSurface.withValues(alpha: 0.4)
                            : cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (!disabled)
                Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
