// lib/widgets/plate.dart
//
// Renders an SVG plate diagram for a given plate key.
// SVGs live in assets/plates/<key>.svg.
// Uses flutter_svg with a ColorFilter so the main stroke (currentColor)
// tints to the theme's onSurface colour, making plates adapt to light,
// hearthDark and night themes automatically.
//
// v1 plates render MONOCHROME: BlendMode.srcIn tints every SVG pixel —
// including accent lines — to the theme's onSurface colour. The terracotta
// "thread" (#C4553B) and chalkblue guide (#8FB3C7) are narrative motifs
// preserved in the SVG source for authoring clarity, but they do NOT survive
// the srcIn filter at render time. Per-channel accent rendering is a deferred
// future enhancement (e.g. a two-layer render with a separate accent overlay).

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Plate extends StatelessWidget {
  const Plate({
    super.key,
    required this.plateKey,
    this.size,
  });

  /// Key that maps to assets/plates/<plateKey>.svg.
  final String plateKey;

  /// Optional fixed size. If null, the plate fills its parent.
  final double? size;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    final assetPath = 'assets/plates/$plateKey.svg';

    Widget svg = SvgPicture.asset(
      assetPath,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      semanticsLabel: plateKey,
      // Graceful fallback: if the asset is missing, flutter_svg throws —
      // wrap in a placeholder so the UI never crashes.
      placeholderBuilder: (_) => _Placeholder(size: size),
      errorBuilder: (_, __, ___) => _Placeholder(size: size),
    );

    if (size != null) {
      svg = SizedBox(width: size, height: size, child: svg);
    }

    return svg;
  }
}

/// Shown while the SVG loads or if the asset is unavailable.
class _Placeholder extends StatelessWidget {
  const _Placeholder({this.size});
  final double? size;

  @override
  Widget build(BuildContext context) {
    final dim = size ?? 200.0;
    return SizedBox(
      width: dim,
      height: dim,
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.outlineVariant,
          size: dim * 0.25,
        ),
      ),
    );
  }
}
