# Concepts

The domain model in prose. For the exact tables and constants, see the
[data model reference](reference/data-model.md); for the reveal's decision
procedure, the [yellow paper](spec/yellow-paper.md).

## The frame: "which is more *us*?"

Everything starts from one reframing. "What's your style?" invites a defensive,
one-person label. "Which of these is more *us*, right now?" produces an honest
answer in two seconds. Mantle is built entirely around the second question,
repeated: a household discovers its aesthetic from a stream of tiny forced choices
rather than declaring it.

## Domains

Choices are collected in three **domains**:

- **Architecture** — buildings, ruins, structure.
- **Tailoring** — garments, cut, drape.
- **Interiors** — rooms, light, arrangement.

Three domains, because a shared aesthetic that shows up in *more than one* of them
is the interesting thing — a thread that crosses from how you dress to how you
build is a real signature, not a mood.

## The affinity deck

The **deck** is 24 real images — 8 per domain — spanning a warm-traditional →
austere-modern range. Every image is CC0 or true Public Domain, verified
per-object (Cleveland Museum of Art + the Met), and carries a full provenance
record (`institution`, `accessionId`, `sourceUrl`, `license`, `creator`, `title`).
A content-validation test refuses any deck record with an incomplete provenance
block. Each image also declares the **through-line keys** it expresses, which is
what lets the reveal name cross-domain threads. See the
[sourcing playbook](cc0-image-sourcing.md).

## The round

Per member, per domain, Mantle runs a **fixed-length pairing round**: 12 recorded
head-to-head decisions. It is deliberately *not* run to convergence —
`RoundService` counts decisions and stops at 12, so every sitting is the same
predictable length (36 decisions per member across the three domains). Skips are
allowed and don't count toward the 12. Each recorded decision is stored as a
`RankingMatches` row; the member's ranking is reconstructed later by replaying
those rows through the `elo_engine`.

Why Elo? Because pairwise comparison is the whole point — nobody assigns scores,
they just keep picking. Elo turns a stream of "A beats B" outcomes into a stable
ranking. See [ADR-0005](adr/0005-pairwise-elo-discovery.md).

## The merge

When everyone is done, each domain's per-member sessions are combined with
`EloMerge.combine` using the **harmonic-mean** strategy. Each item gets:

- a **combined score** — higher is better, aggregated so that *agreement*, not
  enthusiasm, wins. An item one person ranked #1 and another ranked last scores
  worse than an item both put in the middle. The harmonic mean is what penalizes
  the split.
- an **agreement** value in `[0, 1]` — `1.0` means everyone ranked the item
  identically; `0.0` means someone put it first and someone put it last.

Both quantities are defined in the `elo_engine` package. Mantle consumes them; it
does not compute them. See the [yellow paper](spec/yellow-paper.md) for the exact
definitions.

## The reveal: Spine, Contested, through-lines

`RevealService` partitions each domain's merged items:

- **The House Spine** — the family's shared favourites. An item qualifies as a
  Spine *candidate* only if it has **both** high agreement (≥ 0.75) **and** an
  above-midpoint combined score. Both conditions are required on purpose: high
  agreement alone would admit an item everyone *dis*likes equally. Candidates
  across all domains are ranked by score, capped at 8. If fewer than three
  qualify, Mantle falls back to the top three by score and says so ("you're still
  finding your common ground").
- **Where the House argues (Contested)** — the most-*dis*agreed items (agreement
  ≤ 0.25), lowest agreement first, up to five. Shown warmly: disagreement is part
  of a family, not a failure.
- **Named through-lines** — a cross-domain thread (e.g. `material-honesty`)
  qualifies if the Spine expresses it with **≥ 2 items spanning ≥ 2 domains**. The
  top three are named. This is the "aha": the family sees that the same idea runs
  through what they love in *both* how they build and how they dress.

## Why ≥ 2 rankers

The Spine and Contested partition is only meaningful when there are at least two
people to (dis)agree. With a single ranker, every item has agreement `1.0` and a
lone "Spine" would be a mirror, not a discovery. Mantle enforces this at the
**routing layer**: a solo user reaches Read / Spot / Map but never the House
reveal; the reveal route is gated on `allMembersComplete`. The merge math itself
does *not* enforce it — so the gate is load-bearing.

## The Charter

The **House Charter** is the durable output: the family names their House, writes
an optional motto, and the app fills in the Spine images and named through-lines.
It's editable and exports to PDF. The Charter is self-authored heraldry — the
family's own heirloom. The app supplies the raw material; it never declares the
family's identity for them.

## Solo depth (optional, never scored)

Any one adult can explore, any time, without affecting a reveal:

- **Read** — a real vocabulary. Each canon item shows a plate, a plain gloss, the
  neutral principle, the common "quick read" (always valid), a more particular
  "closer read" (*not* better), and a cross-domain echo. Self-reported "knew it" /
  "new to me."
- **Spot** — train the eye. A drawn contrast pair, "which shows X?", with an
  explanation after. Tracks seen/correct counts.
- **Map** — see which through-lines you've personally discovered, with a
  qualitative coherence reading. No score, no ranking, no leaderboard — ever.

These exist to make taste-literacy *available*, never mandatory, and never dressed
up as more than it is.
