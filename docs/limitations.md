# Limitations

Read this before adopting or extending Mantle. It states, honestly, what the app
does *not* do. For the built/aspirational split at a glance, see the
[vision scorecard](../VISION.md#honest-scorecard--built-vs-aspirational).

## Single device only

There is **no cross-device sync**. A sitting happens on one device, passed around.
The data model is *shaped* for a future sync (`EloSession` carries dormant
`sessionCode` / `hostParticipantId` / `expiresAt` fields; persistence stores
mergeable decision logs), and the intended design is encrypted-blob relay with a
shared BIP39 seed — but **none of it is built**. Members ranking on separate phones
is a v2 idea, not a feature.

## No accounts, no recovery

Ghost mode has no account and therefore no account recovery. If the device is lost
or the app's data is cleared, the family's rounds and Charters are gone. There is
no backup story beyond exporting a Charter PDF yourself. A Named tier (backup /
recovery / cross-device identity) is deferred until a real "lost my phone" need
drives it.

## The reveal needs ≥ 2 rankers — and the math doesn't enforce it

The Spine / Contested partition is only meaningful with at least two people. A solo
user is routed to Read / Spot / Map and never reaches the House reveal. **Important
for maintainers:** this is enforced by the *routing gate* (`allMembersComplete`),
**not** by `RevealService.compute`. Handed a single session, `compute` returns
`agreement = 1.0` for every item and produces a spurious full Spine. If you add a
new path to the reveal, keep the ≥ 2-member gate in front of it.

## Thresholds are tuned for two, not proved for many

The partition constants — Spine at `agreement ≥ 0.75`, Contested at
`agreement ≤ 0.25` — are calibrated for two rankers. With three or more, a single
outlier collapses agreement (agreement is `1 − (max_rank − min_rank)/(N−1)`, so one
dissenter drags it toward 0), which can shrink the Spine and inflate Contested.
Max party size is 5 and the ~15-minute budget assumes 2–3, but the thresholds have
**not** been recalibrated for larger households. Don't treat them as universal.

## Only three domains, and a fixed deck

There are three domains (architecture, tailoring, interiors) and a fixed 24-image
deck. An **Art** domain is a natural v2 addition but isn't built. The deck doesn't
rotate or grow within a version; every family ranks the same 24 images.

## Reference content is small and hand-authored

The canon is 20 items; through-lines are 4 keys; Spot has ~6–8 questions per
domain. It's a curated starter vocabulary, not an encyclopedia. The "closer read"
is one particular lens offered warmly — never presented as more correct than the
common reading.

## Solo depth does not feed the reveal

Read / Spot / Map are informational only. Which through-lines you personally
discover does **not** change the group reveal in v1. Coupling solo history into the
reveal (e.g. weighting through-line naming) is a v2 sketch, gated on a careful
design that never makes individual homework a prerequisite for the group result.

## Not published to the stores yet

App Store / Google Play submission has not happened. Build and run it yourself per
the [build & run guide](how-to/build-and-run.md).

## What it deliberately will *not* become

- A taste **scoreboard**. No global score, no leaderboard, no "better." This is a
  design invariant, not a missing feature — see [ADR-0005](adr/0005-pairwise-elo-discovery.md)
  and the [vision](../VISION.md).
- A **cloud** app. No BaaS, no analytics, no account-by-default. See
  [ADR-0004](adr/0004-ghost-mode-local-first.md).
