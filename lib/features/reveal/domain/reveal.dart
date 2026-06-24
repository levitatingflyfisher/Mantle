import 'package:mantle/features/content/domain/domain.dart';

// ── Reveal constants ────────────────────────────────────────────────────────

/// Minimum agreement score (inclusive) for an item to qualify as a Spine item.
const double kSpineAgreementMin = 0.75;

/// Maximum agreement score (inclusive) for an item to qualify as Contested.
const double kContestedAgreementMax = 0.25;

/// Maximum items in the House Spine.
const int kSpineCap = 8;

/// Maximum items in the Contested list.
const int kContestedCap = 5;

/// Minimum number of Spine candidates needed before falling back to
/// top-N-by-combinedScore.
const int kMinSpineCandidates = 3;

/// Number of items taken from the top-by-combinedScore fallback list when
/// fewer than [kMinSpineCandidates] qualify normally.
///
/// Kept distinct from [kMinSpineCandidates] so the threshold (when to fall
/// back) and the output size (how many to return) are independently tunable.
const int kFallbackSpineSize = 3;

// ── Data types ───────────────────────────────────────────────────────────────

/// One item in the reveal output, drawn from the merged results of one domain.
class RevealItem {
  final String id;
  final Domain domain;
  final double combinedScore;
  final double agreement;

  const RevealItem({
    required this.id,
    required this.domain,
    required this.combinedScore,
    required this.agreement,
  });
}

/// The computed reveal for a household session.
///
/// - [spine]: agreed-upon favourites, up to [kSpineCap] items.
/// - [contested]: most-disagreed-upon items, up to [kContestedCap].
/// - [spineIsFallback]: true when there were fewer than [kMinSpineCandidates]
///   items above [kSpineAgreementMin], forcing a top-3-by-score fallback.
class Reveal {
  final List<RevealItem> spine;
  final List<RevealItem> contested;
  final bool spineIsFallback;

  const Reveal({
    required this.spine,
    required this.contested,
    required this.spineIsFallback,
  });
}
