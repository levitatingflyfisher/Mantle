# Mantle — Yellow Paper (reveal semantics)

*A precise specification of how a household's ranking decisions become a House
Spine, a Contested set, and named through-lines.*

**Register note.** "Yellow paper" is the convention for a rigorous formal spec.
This document is precise about intent and current behaviour; it is **not** a
machine-checked proof. The code it describes was written by an AI assistant — treat
it as an accurate record of what currently exists, and check it against this spec
rather than assuming they agree. Where they diverge, the code is the fact and this
spec is the bug.

**Scope.** This paper specifies **Mantle's own** decision procedure: the
Spine/Contested partition, the fallback, and the through-line naming predicate. The
underlying ranking, merge, and agreement definitions live in the `elo_engine`
package; they are *cited as given* here (§1), not re-derived. Mantle's contribution
is the layer built on top of them (§2–§4), and the one soundness property that
layer guarantees (§2.3).

Source of truth: [`reveal_service.dart`](../../lib/features/reveal/domain/reveal_service.dart),
[`reveal.dart`](../../lib/features/reveal/domain/reveal.dart) (constants + types),
[`throughline_namer.dart`](../../lib/features/reveal/domain/throughline_namer.dart).

---

## 1. Given definitions (from `elo_engine`)

Fix one domain with **N** items ranked by **P** participants (P ≥ 1). Each
participant *p* sorts the items by Elo rating (descending) and assigns each item a
0-indexed **rank** `r(p,i) ∈ {0, …, N−1}` (0 = best). For item *i*:

- **Per-participant score** `s(p,i) = N − r(p,i) ∈ {1, …, N}` (best item scores N,
  worst scores 1). Strictly positive by construction.
- **Combined score** `c(i) = harmonicMean_p s(p,i) = P / Σ_p (1 / s(p,i))`. Range
  `[1, N]`. Higher is better; the harmonic mean is *dominated by the smallest
  score*, so a single low rank from any participant pulls `c(i)` down hard.
- **Agreement** `a(i) = 1` if `N ≤ 1`, else
  `a(i) = 1 − (max_p r(p,i) − min_p r(p,i)) / (N − 1) ∈ [0, 1]`. `1.0` = every
  participant ranked *i* identically; `0.0` = someone ranked it first and someone
  ranked it last.

These come from `EloMerge.combine(sessions, strategy: harmonicMean)`. Mantle does
not compute them.

## 2. The Spine/Contested partition

Let `μ = (N + 1) / 2` be the **domain midpoint** — the mean of the score range
`[1, N]`. Mantle uses the constants in [`reveal.dart`](../../lib/features/reveal/domain/reveal.dart):

| Symbol | Constant | Value |
|---|---|---|
| `A⁺` | `kSpineAgreementMin` | `0.75` |
| `A⁻` | `kContestedAgreementMax` | `0.25` |
| `K_spine` | `kSpineCap` | `8` |
| `K_cont` | `kContestedCap` | `5` |
| `K_min` | `kMinSpineCandidates` | `3` |
| `K_fb` | `kFallbackSpineSize` | `3` |

### 2.1 Candidate predicates (per domain)

For every merged item *i* in a domain:

```
SpineCandidate(i)  ≝  a(i) ≥ A⁺   ∧   c(i) > μ
Contested(i)       ≝  a(i) ≤ A⁻
```

The **conjunction** in `SpineCandidate` is load-bearing (§2.3). Contested is
agreement-only by design — a disputed item is disputed regardless of its average
rank.

### 2.2 Selection (across all domains)

Let `C` be the multiset of `SpineCandidate` items pooled over all domains, and `X`
the pooled `Contested` items.

```
Spine     = take(K_spine, sortByScoreDesc(C))          if |C| ≥ K_min
Contested = take(K_cont,  sortByAgreementAsc(X))        -- lowest agreement first
```

Contested selection is independent of the Spine outcome. If `X = ∅` the section is
omitted entirely.

### 2.3 Soundness property (the one real theorem)

> **Claim.** No item that the household ranks, on merged preference, at or below the
> domain midpoint can enter the Spine — *regardless of how strongly the household
> agrees about it.*

**Proof.** Admission requires `c(i) > μ`. Any item with `c(i) ≤ μ` fails this
conjunct and is excluded, independent of `a(i)`. ∎

The sharp corollary is the case the conjunction exists to defeat:

> **Corollary (mutual dislike cannot masquerade as consensus).** Suppose every
> participant ranks item *i* last: `r(p,i) = N − 1` for all *p*. Then
> `a(i) = 1 − 0/(N−1) = 1.0` (perfect agreement) but `s(p,i) = 1` for all *p*, so
> `c(i) = 1`. For any real domain (`N ≥ 2`), `μ = (N+1)/2 > 1 = c(i)`, so *i* fails
> the score conjunct and is **not** a Spine candidate — despite maximal agreement.

An agreement-only rule (`a(i) ≥ A⁺` alone) would wrongly admit this item. That is
exactly why `SpineCandidate` is a conjunction and not a threshold on agreement. See
the comment in `reveal_service.dart` and the tests in
[`reveal_service_test.dart`](../../test/reveal/reveal_service_test.dart).

### 2.4 Fallback (fail-soft, not fail-open)

If too few items clear the bar — `|C| < K_min` — Mantle does **not** show an empty
or padded Spine. It degrades explicitly:

```
Spine          = take(K_fb, sortByScoreDesc(AllItems))   -- pooled over all domains
spineIsFallback = true
```

`AllItems` is every merged item across domains, so the fallback always yields up to
three items (the family's top-scoring overall), and the `spineIsFallback` flag lets
the UI say so honestly ("you're still finding your common ground"). Note the
fallback selects by score only — it is a graceful degradation, not the sound
partition, and it is *flagged as such*. `K_fb` is kept distinct from `K_min` so the
"when to fall back" threshold and the "how many to show" size are independently
tunable.

## 3. Through-line naming

Input: the selected `Spine` (§2.2) and a map `T : itemId → [throughlineKey]` drawn
from the **deck manifest** (each `DeckImage.throughlines`), *not* from canon. Items
absent from `T` contribute nothing.

For each key *k*, over the Spine items that express it, let `count(k)` be how many
Spine items list *k*, and `domains(k)` the set of distinct domains those items
belong to. Then:

```
Qualifies(k)  ≝  count(k) ≥ 2   ∧   |domains(k)| ≥ 2
Named         =  take(3, sortByCountDesc({ k : Qualifies(k) }))
```

The **cross-domain** conjunct (`|domains(k)| ≥ 2`) is the point: a through-line is
only *named* when the same thread recurs in the family's shared favourites across
at least two domains — two Spine items in the *same* domain do not qualify it. This
is what makes a named through-line a genuine signature rather than a within-domain
coincidence. Spec'd behaviour is pinned in
[`throughline_namer_test.dart`](../../test/reveal/throughline_namer_test.dart).

## 4. Honesty boundaries

Three lines separate what is *proved*, what is *tuned*, and what is *design
intuition*. A spec that blurs them is marketing.

1. **Proved (sound by construction).** §2.3: the Spine cannot admit a
   below-midpoint item, and in particular cannot admit a mutually-disliked one.
   This holds for any `N ≥ 2` and any `P ≥ 2` and follows directly from the
   conjunction.
2. **Tuned, not proved.** The constants `A⁺ = 0.75` and `A⁻ = 0.25` are calibrated
   for **two rankers**. Agreement is `1 − (spread)/(N−1)`, so with `P ≥ 3` a single
   outlier can drive `a(i)` toward 0 and collapse the Spine / inflate Contested.
   These thresholds are *chosen*, not derived; treat them as parameters, and see
   [limitations.md](../limitations.md) for the N > 2 caveat.
3. **Design intuition, not theorem.** "The harmonic mean surfaces genuine
   consensus, not enthusiastic outliers" is the *rationale* for choosing that merge
   strategy (its domination by the smallest score makes disagreement expensive). It
   is a well-motivated modelling choice, not a proved optimality result.

### 4.1 The ≥ 2-ranker requirement lives in routing, not here

The partition is only *meaningful* with at least two participants — but
`RevealService.compute` does **not** enforce that. With `P = 1`, every item has
`max_p r = min_p r`, so `a(i) = 1.0` for all *i*, and the score conjunct alone
admits the top items — a **spurious Spine**. Mantle prevents this upstream: the
reveal route is gated on `allMembersComplete` (all non-removed members finished),
and a solo user is routed to Read / Spot / Map, never the House reveal (see
[`round_controller.dart`](../../lib/features/ranking/presentation/round_controller.dart)
and [`no_peek_test.dart`](../../test/widget/no_peek_test.dart)). **Maintainer
invariant:** any new path to the reveal must keep the ≥ 2-member gate in front of
it; do not hand a single-session merge to the UI.

### 4.2 Degenerate cases

- **`N ≤ 1` in a domain** — agreement is defined as `1.0`; not a real configuration
  (each domain ships 8 deck images), but the definition is total.
- **No candidates and no items** — an empty domain contributes nothing; the pooled
  fallback still draws from other domains.
- **Empty Contested** — the section is omitted rather than shown empty.

## 5. Summary

Given per-participant Elo rankings merged by `elo_engine` (§1), Mantle partitions
each domain by the conjunction *high-agreement ∧ above-midpoint* for the Spine and
*low-agreement* for Contested (§2), degrades fail-soft with an explicit flag when
too few items qualify (§2.4), and names only the through-lines that recur across
domains (§3). The sound core is the midpoint conjunct (§2.3); the thresholds and
merge strategy are tuned/chosen (§4); and the "needs two rankers" guarantee is a
routing property, not a property of this arithmetic (§4.1).
