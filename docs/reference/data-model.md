# Reference — data model & feature status

Precise lookup material. Schema is authoritative in
[`lib/core/db/database.dart`](../../lib/core/db/database.dart); this page mirrors
it. `schemaVersion = 2`: create-all on a fresh install; upgrading from 1 adds
`members.deletedAt`.

## Drift tables (local, mutable)

| Table | Key / notable columns | Purpose |
|---|---|---|
| **Members** | `id` (PK), `label`, `color` (int ARGB), `createdAt`, `deletedAt` (nullable) | The 2–5 people in a sitting. No accounts. A removed member keeps their row with `deletedAt` set and is listed under Recently removed until restored or deleted for good. |
| **Rounds** | `id` (PK), `deckVersion`, `createdAt` | One family sitting, tied to a deck version. |
| **RankingSessions** | `id` (PK), `roundId`, `memberId`, `domain`, `isComplete` (default false), `resultsLocked` (default **true**), `createdAt` | One member's ranking of one domain. `resultsLocked` backs the no-peek guarantee. |
| **RankingMatches** | `id` (PK), `sessionId` (indexed), `idA`, `idB`, `outcome` (`'aWins'`\|`'bWins'`), `decidedAt` | One recorded head-to-head decision. Persistence stores **decisions**, not ratings — the ranking is replayed from these. |
| **Charters** | `id` (PK), `roundId`, `houseName` (default `''`), `motto` (default `''`), `createdAt`, `spineItemIds`, `throughlines`, `contestedItemIds`, `bodyOverrides` (default `'{}'`) | The self-authored House Charter for a round. |
| **SpotProgress** | (`memberId`, `questionId`) PK, `seenCount`, `correctCount` | Per-member Spot practice tallies. |
| **ReadProgress** | (`memberId`, `itemId`) PK, `knewIt` | Per-member Read self-report. |
| **DiscoveredThroughlines** | (`memberId`, `throughlineId`) PK, `firstSeenAt` | Which through-lines a member has met in solo depth. |

DAOs live in `lib/features/*/data/*_dao.dart` (`MembersDao`, `RoundsDao`,
`SessionsDao`, `MatchesDao`, `ChartersDao`, `ReadProgressDao`, `SpotProgressDao`,
`DiscoveredThroughlinesDao`).

Theme preference is **not** in Drift — it's a single key in
`flutter_secure_storage`: `mantle.themeMode` (`system` / `light` / `dark` /
`night`, default `system`). The old `mantle.themePreference` key from the
Daytime / Evening / Late night picker is only read, as a migration: Daytime
becomes follow-the-phone, Evening becomes Dark, Late night stays Night.

### Dormant sync fields

`EloSession` (in the `elo_engine` package) already carries `sessionCode`,
`hostParticipantId`, and `expiresAt`. These are **unused in v1** and reserved for a
future encrypted-blob sync (see [ADR-0004](../adr/0004-ghost-mode-local-first.md)).

## Bundled content (read-only assets)

Loaded via `ContentRepository`; shipped in the app, never uploaded.

| Asset | Shape | Notes |
|---|---|---|
| `assets/data/canon.json` | 20 `CanonItem`s | `id`, `domain`, `term`, `gloss`, `principle`, `quickRead`, `closerRead`, `echo{toId,note}`, `plate`, `throughlines[]`. Neutral voice; the common reading is valid. |
| `assets/data/throughlines.json` | 4 `Throughline`s | `key` → `label` (e.g. `interval` → "the charged gap"). |
| `assets/data/spot.json` | ~6–8 `SpotQuestion`s / domain | `id`, `domain`, `featureId`, `promptText`, `plateA`, `plateB`, `correctSide`, `explanation`. |
| `assets/images/deck/` + `manifest.json` | 24 `DeckImage`s (8/domain) | Real CC0/PD images; each record carries full provenance (`license`, `institution`, `accessionId`, `sourceUrl`, `creator`, `title`) and its `throughlines[]`. Validated by test. |
| `assets/plates/` | 20 SVG plates (+ Spot contrast variants) | Hand-drawn in the warm theme; keys like `xline`, `poche`, `japandi`, `betonbrut`. |

### The four through-lines

| Key | Label |
|---|---|
| `interval` | the charged gap |
| `figure-void` | mass & emptiness on purpose |
| `material-honesty` | say only what the structure needs |
| `expressed-structure` | the celebrated joint |

## Reveal constants

From [`lib/features/reveal/domain/reveal.dart`](../../lib/features/reveal/domain/reveal.dart):

| Constant | Value | Meaning |
|---|---|---|
| `kSpineAgreementMin` | `0.75` | Min agreement (inclusive) for a Spine candidate. |
| `kContestedAgreementMax` | `0.25` | Max agreement (inclusive) for a Contested item. |
| `kSpineCap` | `8` | Max items in the House Spine. |
| `kContestedCap` | `5` | Max items in the Contested list. |
| `kMinSpineCandidates` | `3` | Below this many candidates, fall back. |
| `kFallbackSpineSize` | `3` | Items taken from the top-by-score fallback. |
| `kDecisionsPerDomain` | `12` | Recorded (non-skip) decisions to complete a domain. |

The full decision procedure and its soundness property are in the
[yellow paper](../spec/yellow-paper.md).

## Feature status (v1)

| Area | Status |
|---|---|
| Gather → round → reveal → Charter (PDF) | **Shipped, tested** |
| No-peek guarantee (gated route, hand-off, no mid-sitting results) | **Shipped, regression-tested** |
| Solo depth (Read / Spot / Map) | **Shipped, tested** |
| CC0/PD affinity deck (24 images, provenance-validated) | **Shipped** |
| Ghost mode (no network / accounts / analytics) | **Shipped, architectural** |
| Cross-device sync | **Not built** — data model shaped only |
| Named / account-recovery tier | **Not built** |
| Art domain | **Not built** |
| N > 2 threshold recalibration | **Not done** — tuned for 2 |
| App Store / Play release | **Not done** |
