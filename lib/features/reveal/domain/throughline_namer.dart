import 'package:mantle/features/content/domain/domain.dart';
import 'reveal.dart';

/// A through-line key qualified by the House Spine, with its spine count.
class NamedThroughline {
  /// The canonical through-line key (e.g. `'material-honesty'`).
  final String key;

  /// Number of spine items that express this through-line key.
  final int spineCount;

  const NamedThroughline({required this.key, required this.spineCount});
}

/// Names the through-lines expressed by the House Spine.
///
/// A through-line key qualifies iff it is expressed by:
/// - **≥ 2 spine items** in total, AND
/// - those items span **≥ 2 distinct [Domain]s**.
///
/// Qualifying keys are ranked by [NamedThroughline.spineCount] descending;
/// the top 3 are returned.
class ThroughlineNamer {
  const ThroughlineNamer._();

  /// Name the through-lines for the given [spine] using the item-to-keys map.
  ///
  /// [throughlinesById] maps each item id to its list of through-line keys
  /// (from the DECK image manifest's throughlines map — not from canon directly).
  /// Items not present in the map are treated as having no keys.
  static List<NamedThroughline> name(
    List<RevealItem> spine,
    Map<String, List<String>> throughlinesById,
  ) {
    // Accumulate per-key: count of spine items and set of distinct domains.
    final keyCount = <String, int>{};
    final keyDomains = <String, Set<Domain>>{};

    for (final item in spine) {
      final keys = throughlinesById[item.id] ?? const [];
      for (final key in keys) {
        keyCount[key] = (keyCount[key] ?? 0) + 1;
        (keyDomains[key] ??= {}).add(item.domain);
      }
    }

    // Filter: >= 2 spine items AND >= 2 distinct domains.
    final qualifying = keyCount.entries
        .where((e) => e.value >= 2 && (keyDomains[e.key]?.length ?? 0) >= 2)
        .map((e) => NamedThroughline(key: e.key, spineCount: e.value))
        .toList();

    // Sort by spineCount descending, take top 3.
    qualifying.sort((a, b) => b.spineCount.compareTo(a.spineCount));
    return qualifying.take(3).toList();
  }
}
