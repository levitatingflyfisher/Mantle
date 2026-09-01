import 'package:flutter/material.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// A member colour with the name a screen reader (and a colour-blind
/// household member) can use for it.
class MemberSwatch {
  const MemberSwatch(this.color, this.name);
  final Color color;
  final String name;
}

/// The member palette. Colours come from OhColors; no inlined hex values.
/// Terracotta and sage, the first two, are close for a deuteranope and in
/// greyscale, which is why a member is never shown by colour alone: every
/// [MemberDot] carries the member's initial.
const List<MemberSwatch> memberSwatches = [
  MemberSwatch(OhColors.hearth400, 'Terracotta'),
  MemberSwatch(OhColors.sage500, 'Sage'),
  MemberSwatch(OhColors.slate500, 'Slate blue'),
  MemberSwatch(OhColors.amber400, 'Amber'),
  MemberSwatch(OhColors.hearth700, 'Brick'),
];

/// The swatch name for a stored member colour, or null for a colour saved
/// before the palette changed.
String? memberColourName(int argb) {
  for (final s in memberSwatches) {
    if (s.color.toARGB32() == argb) return s.name;
  }
  return null;
}

/// A member's colour dot with their initial inside, so whose turn it is
/// reads without telling colours apart.
class MemberDot extends StatelessWidget {
  const MemberDot({
    super.key,
    required this.color,
    required this.label,
    this.radius = 16,
  });

  final Color color;
  final String label;
  final double radius;

  /// Black or white, whichever contrasts more with [background].
  static Color initialColorOn(Color background) {
    final l = background.computeLuminance();
    final onBlack = (l + 0.05) / 0.05;
    final onWhite = 1.05 / (l + 0.05);
    return onBlack >= onWhite ? Colors.black : Colors.white;
  }

  static String initialOf(String label) {
    final t = label.trim();
    if (t.isEmpty) return '?';
    return String.fromCharCodes(t.runes.take(1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CircleAvatar(
        backgroundColor: color,
        radius: radius,
        child: Text(
          initialOf(label),
          textScaler: TextScaler.noScaling,
          style: TextStyle(
            color: initialColorOn(color),
            fontSize: radius,
            fontWeight: FontWeight.w700,
            height: 1,
          ),
        ),
      ),
    );
  }
}
