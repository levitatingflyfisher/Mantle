import 'package:elo_engine/elo_engine.dart';
import 'package:mantle/features/content/domain/domain.dart';
import 'reveal.dart';

/// Computes the House Spine and Contested partition from per-domain sessions.
///
/// Algorithm:
/// 1. Per domain, merge all participant [EloSession]s with
///    [EloMerge.combine] using [MergeStrategy.harmonicMean].
/// 2. Collect items with [agreement] >= [kSpineAgreementMin] as Spine
///    candidates; items with [agreement] <= [kContestedAgreementMax] as
///    Contested candidates.
/// 3. Sort Spine candidates by [combinedScore] descending; take up to
///    [kSpineCap] for the House Spine.
/// 4. If fewer than [kMinSpineCandidates] qualify, fall back to the top 3
///    items across all domains by [combinedScore] and set
///    [Reveal.spineIsFallback] = true.
/// 5. Sort Contested by agreement ascending (lowest agreement first); take
///    up to [kContestedCap].
class RevealService {
  const RevealService._();

  /// Compute the [Reveal] from per-domain session lists.
  static Reveal compute(Map<Domain, List<EloSession>> byDomain) {
    final candidates = <RevealItem>[];
    final contested = <RevealItem>[];
    final all = <RevealItem>[];

    byDomain.forEach((domain, sessions) {
      final merged =
          EloMerge.combine(sessions, strategy: MergeStrategy.harmonicMean);
      // Neutral midpoint for this domain: combinedScore ranges [1, n] where
      // higher = better, so the midpoint is (n+1)/2.0.
      final n = merged.length;
      final midpoint = (n + 1) / 2.0;
      for (final m in merged) {
        final ri = RevealItem(
          id: m.item.id,
          domain: domain,
          combinedScore: m.combinedScore,
          agreement: m.agreement,
        );
        all.add(ri);
        // Require both high agreement AND above-midpoint score so that a
        // mutually-disliked item (e.g. both rank it last → agreement 1.0 but
        // combinedScore = 1) cannot qualify as a Spine candidate.
        if (m.agreement >= kSpineAgreementMin && m.combinedScore > midpoint) {
          candidates.add(ri);
        }
        if (m.agreement <= kContestedAgreementMax) contested.add(ri);
      }
    });

    candidates.sort((a, b) => b.combinedScore.compareTo(a.combinedScore));
    contested.sort((a, b) => a.agreement.compareTo(b.agreement));

    if (candidates.length < kMinSpineCandidates) {
      all.sort((a, b) => b.combinedScore.compareTo(a.combinedScore));
      return Reveal(
        spine: all.take(kFallbackSpineSize).toList(),
        contested: contested.take(kContestedCap).toList(),
        spineIsFallback: true,
      );
    }

    return Reveal(
      spine: candidates.take(kSpineCap).toList(),
      contested: contested.take(kContestedCap).toList(),
      spineIsFallback: false,
    );
  }
}
