# 0005 — Pairwise Elo + harmonic-mean merge over a style quiz

**Status:** Accepted

## Context

The product goal is to discover a *household's* shared aesthetic and to do it
without asking anyone to describe their taste. Two design questions follow: how
does one person express preference, and how are several people's preferences
combined into a *shared* result that means "we both like this," not "one of us
does"?

## Decision

- **Elicit preference by forced pairwise choice**, not a quiz or a slider. Each
  member answers "which is more *us*?" over head-to-head image pairs, per domain.
- **Rank with Elo.** A per-member-per-domain `EloEngine` (from the `elo_engine`
  sibling package) turns the stream of "A beats B" outcomes into a stable ranking.
  Ties are disabled; only the base Elo algorithm is enabled.
- **Run a fixed-length round, not to convergence.** 12 recorded decisions per
  domain (`RoundService` counts and stops), so every sitting is a predictable
  length. Skips don't count. (Convergence-based termination would make sitting
  length unpredictable and depend on how decisive a person is.)
- **Merge with the harmonic mean.** `EloMerge.combine(..., harmonicMean)`
  aggregates per-member rankings so that *agreement* wins over *enthusiasm*: an
  item ranked #1 by one and last by another scores worse than an item both put in
  the middle. The Spine is thus a genuine shared core.

## Consequences

- The on-ramp is fast, visual, and judgement-free — a two-second answer instead of
  a self-description. Kids can play unaided.
- Persistence stores *decisions*, so a ranking is a pure replay — reproducible, and
  the natural unit for a future sync (merge decision logs, not ratings).
- The harmonic mean plus the Spine partition (agreement **and** above-midpoint
  score) is what lets Mantle claim a shared favourite honestly — specified and
  proved sound-by-construction in the [yellow paper](../spec/yellow-paper.md).
- The merge/agreement math is **not** in this repo — it's `elo_engine`. Changes to
  "how consensus is computed" may belong there; Mantle owns only the partition and
  naming on top.
- The partition thresholds (0.75 / 0.25) are **tuned for two rankers**; larger
  households need recalibration (a single outlier collapses agreement). This is a
  known limitation, not a proved constant — see [limitations.md](../limitations.md).
