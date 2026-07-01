import 'package:flutter/material.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// A shared placeholder shown in image grids when the asset is unavailable.
///
/// Renders the [imageId] label on a [surfaceContainerHighest] background,
/// suitable for use in spine grids across reveal, round, and charter screens.
class ImagePlaceholderTile extends StatelessWidget {
  const ImagePlaceholderTile({super.key, required this.imageId});

  final String imageId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: OhSpacing.insetSm,
          child: Text(
            imageId,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
