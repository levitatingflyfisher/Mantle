# PRD: Mantle
**App:** Mantle
**Package:** `mantle` (OpenHearth portfolio)
**License:** MIT
**Status:** v1 built and tested
**Owner:** OpenHearth
**Contact:** open an issue on GitHub

---

## 1. Problem

Families have a felt-but-unspoken aesthetic — a way they want their home, their clothes, and their spaces to *feel* — that they can't name, can't agree on out loud, and can't pass down. Existing tools are single-user style quizzes that hand one person a label, or values-only "family mission statement" templates with no aesthetic dimension. Nothing helps a *household* discover the thread that runs through everything they love and turn it into something they can keep.

The actual failure mode is frame: asking "what's your style?" invites defensive self-description. Asking "which of these is more *us*, right now?" produces an answer in two seconds. Do it enough times, across three domains, with everyone in the household, and a genuine shared aesthetic surfaces — not from a quiz, but from the family's own choices.

### Non-goals (v1)
- Cloud AI, BYO API keys, generated text
- Cross-device sync (v2)
- Hair and Art domains
- Mood-board/canvas editor
- Numeric taste scores or leaderboards
- Analytics or usage telemetry

---

## 2. Goals

- **G1 — Discovery.** Help a family discover and name its shared aesthetic identity — "what is House X?" — across home, dress, and space.
- **G2 — The Charter.** Produce a self-authored, printable House Charter: the Spine (where the family converges), where they lovingly differ, and the named through-lines that run across domains.
- **G3 — First sitting.** The reveal is reachable in the first joint sitting (~≤15 min for 2–3 members), not gated behind long solo work.
- **G4 — Honest depth.** Offer genuine, optional taste-conversancy — a real vocabulary (Read) and a real eye-for-features (Spot) — never dressed up as more than it is.
- **G5 — Warmth.** Frame distinctiveness as coherence and authorship ("this is recognizably us"), never as superior taste. A warm farmhouse House is exactly as legitimate as an austere Brutalist one.

---

## 3. Users

**Primary:** A household (couple, or parents + older kids) doing this together on one device, passed around. The reveal is for *them*, about belonging — not signaling to outsiders.

**Secondary:** One curious adult exploring Read / Spot / Map solo, any time. A solo user does not get the House reveal or Charter — the Spine/Contested reveal is mathematically meaningful only with ≥2 rankers. This is stated, not implied.

**Accessibility floor:** Must delight a normal family with no design background. The on-ramp is fast, visual, and judgement-free.

---

## 4. Auth Tier

**v1 — Ghost only.** Zero network, no accounts ever required for core function. All state in a local Drift/SQLite database. Theme preference via `flutter_secure_storage`. No analytics, no telemetry, no network client for app data.

**v2 — Sync (shaped for, not yet built).** Shared BIP39 seed + encrypted blob relay via a seed-phrase-based shared-key scheme; the data model is additive (EloSession already carries dormant sync fields).

---

## 5. Content & Data

Hand-authored content ships as bundled JSON assets. MIT-licensed alongside the code (no CC BY-SA split).

### 5.1 The Canon (`assets/data/canon.json`)
20 items across three domains: **Architecture, Tailoring, Interiors**. Each item:

```
CanonItem {
  id          — slug ("waist-suppression")
  domain      — "architecture" | "tailoring" | "interiors"
  term        — concept name
  gloss       — plain one-line definition
  principle   — the mechanism, neutral voice
  quickRead   — the common first take (fully valid, never penalized)
  closerRead  — a more particular lens (NOT "better")
  echo        — { toId: CanonItem.id, note: string }
  plate       — SVG plate key (one of 20)
  throughlines — through-line keys this item expresses
}
```

Voice: neutral, warm. No second-person taste assertion. The common reading is valid.

### 5.2 Through-lines (`assets/data/throughlines.json`)
Four cross-domain threads:

| Key | Label |
|---|---|
| `interval` | the charged gap |
| `figure-void` | mass & emptiness on purpose |
| `material-honesty` | say only what the structure needs |
| `expressed-structure` | the celebrated joint |

### 5.3 Drawn Plates (`assets/plates/`)
20 hand-drawn SVG plates in the app's warm theme colors. Keys: `xline, armhole, drape, sack, shoulder, gorge, aline, collar, betonbrut, tectonic, poche, enfilade, ma, pilotis, japandi, wabisabi, shibui, biophilic, patina, truth`. Additional contrast-pair variants for Spot mode (e.g. `gorge-high`, `poche-filled`).

### 5.4 Affinity Deck (`assets/images/deck/` + `manifest.json`)
24 real CC0/Public-Domain images for the family round — 8 per domain, spanning a warm-traditional → austere-modern range. Sourced and license-verified from the **Cleveland Museum of Art** (CC0) and the **Metropolitan Museum of Art** (Open Access / Public Domain), per the verified playbook in `docs/cc0-image-sourcing.md`. Per-image provenance in `manifest.json`; the content-validation test enforces a complete CC0/PD provenance block on every record. Architecture = Cleveland ruins/buildings; tailoring = Cleveland costume/garment works; interiors = Met + Cleveland room paintings (Vermeer, Vuillard, de Witte, Panini, Gwen John…).

### 5.5 Spot Questions (`assets/data/spot.json`)
~6–8 feature-discrimination questions per domain. Each: `{ id, domain, featureId, promptText, plateA, plateB, correctSide, explanation }`.

---

## 6. Core Experience

The loop is collective and front-loaded:

1. **Gather.** "Who's playing?" — add 2–5 members (label + color; no accounts). One device, passed around.
2. **The round (per member, per domain, no peeking).** Each member ranks the same fixed 24-image deck via quick head-to-head "which is more *us*?" pairs, run per domain (3 domains × 12 decisions per domain = 36 decisions per member). Forced choice; skip allowed. Between members, a hand-off interstitial appears; no individual results are shown during the sitting.
3. **The reveal** (after all non-removed members are complete): per domain, `EloMerge.combine(sessions, strategy: MergeStrategy.harmonicMean)` yields per-item `combinedScore` and `agreement`. Partition into Spine and Contested (§6.3). Named through-lines surfaced if ≥2 Spine items from ≥2 domains share a through-line key.
4. **The Charter.** A single-page, hand-editable House Charter: family names their House and writes an optional motto; the app fills in Spine images and named through-lines. Export/print to PDF.
5. **Optional depth (solo, any time).** Read (vocabulary), Spot (eye training), Map (through-lines + qualitative coherence reading). Informational only — does not alter the reveal in v1.

### 6.1 The "thread" framing
The aesthetic thread is a coherence/authorship motif, never a scoring system. There is no global taste score and no penalty for the common reading. Map's coherence reading is qualitative; it names which through-lines recur in the member's discovered set. It never produces a leaderboard.

### 6.2 Session construction
Per member per domain: an `EloEngine` with `EloConfig(allowTies: false, enabledAlgorithms: {AlgorithmId.elo})`. The round is fixed-length: 12 recorded decisions per domain. A domain session is complete when its recorded-decision count reaches 12; a member is complete when all 3 domain sessions are complete. Mantle does not rely on `isConverged`.

### 6.3 Spine / Contested partition
- **Spine candidates** = items with `agreement ≥ 0.75` AND `combinedScore` above the domain midpoint. Both conditions required: agreement alone admits mutually-disliked items.
- **House Spine** = top Spine candidates by `combinedScore` across all domains, capped at 8. Fallback: if fewer than 3 family-wide, top-3 by `combinedScore` overall + warm copy ("you're still finding your common ground").
- **Contested** = items with `agreement ≤ 0.25`, the 5 lowest-agreement shown. If none, the section is hidden.

### 6.4 Same-device mode & no-peek guarantee
Three guards: (a) no individual-result screen is reachable during a sitting; (b) a hand-off interstitial between members; (c) the merged reveal route is gated until all non-removed members are complete.

---

## 7. Family Same-Device Mode

Per member, per domain: an `EloSession` with independent history. Matches stored as outcome rows and replayed. Between members, a hand-off interstitial. The reveal route is gated (default-locked) until all non-removed members are complete.

`EloMerge.combine(sessions, strategy: MergeStrategy.harmonicMean)` — harmonic mean penalizes disagreement, so the Spine is a genuine shared core.

---

## 8. Sync Mode (v2 — out of scope, shaped for)

Members would rank on separate devices; `EloSession`s sync as encrypted blobs (shared BIP39 seed, a seed-phrase-based shared-key scheme, dumb relay) and merge identically. `EloSession` already carries dormant `sessionCode`/`hostParticipantId`/`expiresAt` fields, so this is additive when the time comes.

---

## 9. Data Model

**Bundled (read-only):** `canon.json`, `throughlines.json`, `spot.json`, plate SVGs, `deck/manifest.json` + images.

**Drift tables (local, mutable):**

| Table | Key columns |
|---|---|
| `members` | `id, label, color, createdAt` |
| `rounds` | `id, deckVersion, createdAt` |
| `ranking_sessions` | `id, roundId, memberId, domain, isComplete, resultsLocked (default true), createdAt` |
| `ranking_matches` | `id, sessionId, idA, idB, outcome ('aWins'\|'bWins'), decidedAt` |
| `charters` | `id, roundId, houseName, motto, createdAt, spineItemIds, throughlines, contestedItemIds, bodyOverrides` |
| `spot_progress` | `memberId, questionId, seenCount, correctCount` |
| `read_progress` | `memberId, itemId, knewIt` |
| `discovered_throughlines` | `memberId, throughlineId, firstSeenAt` |

Theme preference: `flutter_secure_storage`, not Drift.

---

## 10. Screen Inventory

| Screen | Purpose |
|---|---|
| **Home / Hearth** | Start a round, open last Charter, enter solo depth (Explore). Settings icon in AppBar. |
| **Members** | Add/label/color 2–5 members. |
| **Round** | Full-bleed head-to-head pair ("which is more *us*?"), per-domain progress, hand-off interstitial. |
| **Reveal** | Spine, Where-the-House-Argues, named through-lines. Empty-state handling. |
| **Charter** | Editable houseName/motto/body; Spine grid + through-line list; export/print to PDF. |
| **Solo Hub (Explore)** | Member-selector + activity cards for Read, Spot, Map. |
| **Read** | Plate + term → gloss → principle → quickRead/closerRead → cross-domain echo. Self-report ("Knew it" / "New to me"). |
| **Spot** | Drawn contrast pair, "which shows X?", explanation after. |
| **Map** | Discovered through-lines + qualitative coherence reading (no score, no ranking). |
| **Settings** | Theme picker (Daytime / Evening / Late night), About Mantle, data-reset affordance. |

---

## 11. Design Principles

1. **Coherence, not connoisseurship.** Distinctiveness = "recognizably *us*", never "better taste." No global score.
2. **The common reading is valid.** Liking the popular take (quickRead) is never penalized.
3. **The app describes; the family decides.** Reference content is neutral; every value judgment is a family output.
4. **Heraldry is self-authored metaphor.** "House"/"Charter" = the family's self-made heirloom. The app never declares aesthetic identity on their behalf.
5. **Warm OpenHearth surfaces.** Use `OhTheme.light` / `hearthDark` / `night` with no accent override. No inlined hex values. `google_fonts` banned; bundled Lora + Nunito.
6. **Ghost mode is the product.** No account, no network, no analytics — architecturally enforced.
7. **Beautiful and simple.** Warm, home-cooked, never sterile or gatekeeping.

---

## 12. Notifications

None in v1. Mantle is a sit-down-together tool — no push, no reminders, no background workers.

---

## 13. Metrics

No analytics collected (Ghost tier). Success criteria judged by intent:
- A 2-person family reaches a printed Charter in one sitting (<~15 min)
- The reveal yields at least one "that *is* us" moment (informal testing)
- Kids complete the affinity round unaided
- No screen reads as judging taste

---

## 14. Competitive Landscape

| Product | Model | Gap vs. Mantle |
|---|---|---|
| Indyx / interior "find your style" funnels | Single-user style quiz | Solo, label-dispensing; no household coordination |
| Pinterest / mood boards | Self-curated image collections | Individual, no shared reveal, no vocabulary |
| Family mission statement tools | Values-only templates | No aesthetic axis |
| DailyArt / Slow Art / VTS | Art appreciation | Strong "how to look" prior art; no collective reveal |

**Differentiator:** collective + image-and-vocabulary based + a self-authored printable heirloom + local-first / account-free.

---

## 15. Dependencies

| Package | Use |
|---|---|
| `elo_engine` (path: `OpenHearth/eloEngine`) | Family pairwise ranking + `EloMerge.combine` / `agreement` |
| `openhearth_design` (path: `OpenHearth/ohStyle/openhearth_design`) | `OhTheme` / `OhColors` / `OhTypography` / spacing |
| `drift` + `drift_dev` + `sqlite3_flutter_libs` | Local SQLite persistence |
| `flutter_riverpod` | State management |
| `flutter_svg` | SVG plate rendering |
| `flutter_secure_storage` | Theme preference persistence |
| `pdf` + `printing` | Charter export / print |
| `path_provider` + `path` | Database file location |
| `bip39_mnemonic` (pinned exact) | v2 seed phrase (dormant in v1) |

---

## 16. Open Questions

**Real CC0 image curation — DONE.** The affinity deck now ships 24 real, license-verified CC0/Public-Domain images (8/domain), sourced via a 5-angle adversarially-verified research pass and a visual curation pass (downloaded thumbnails → contact sheets → hand-picked for relevance + the warm→austere spread + no recognizable people/logos). Sources: Cleveland Museum of Art (CC0) and the Met (Public Domain), both verified per-object. Full playbook retained in `docs/cc0-image-sourcing.md`. *(Deferred follow-up: if a larger/rotating deck is wanted later, the same playbook scales — Smithsonian/NGA/Rijksmuseum need API keys; AIC's IIIF image server blocks automated download.)*

**Art domain.** DailyArt / Charlotte Mason picture study is strong prior art. A fourth domain (Art) is a natural v2 addition requiring 8 new deck images, ~3 new canon items, and ~2 Spot questions per new feature.

**N > 2 thresholds.** The Spine / Contested partition constants (`agreement ≥ 0.75` for Spine, `≤ 0.25` for Contested) are tuned for 2 members. With 3+ members a single outlier collapses agreement. Threshold recalibration for larger households is flagged but not blocking for v1 (max 5 members; <15 min budget assumes 2–3).

**Map → Reveal coupling (v2).** In v1, discovered through-lines and Map readings are informational only and do not alter the reveal. A future version could weight the Spine's through-line naming by solo exploration history, but this requires careful design to avoid making individual solo depth a prerequisite for group results.

**Named tier (v2).** Account recovery, family sharing, and cross-device identity require a Named auth tier (an encrypted-backup auth module, not yet built across the portfolio). Blocking constraint: deferred until a real "user lost phone" story drives the need.

---

## 17. Delivery Checklist

**v1 — completed**
- [x] Canon (20 items), throughlines (4 keys), spot questions bundled as JSON assets
- [x] 20 drawn SVG plates + Spot contrast variants; `Plate` widget; content validation tests
- [x] Drift schema: members, rounds, ranking_sessions, ranking_matches, charters, spot_progress, read_progress, discovered_throughlines
- [x] `EloEngine` + `EloMerge` integration; round service; session builder; no-convergence fixed-length round (12 decisions/domain)
- [x] Spine / Contested partition (§6.3 constants, unit-tested)
- [x] Through-line naming (§6.4, unit-tested)
- [x] No-peek guarantee: no individual results during sitting; hand-off interstitial; gated reveal route (regression-tested)
- [x] Members screen (add / label / color, 2–5)
- [x] Round screen (head-to-head pair, domain progress, hand-off)
- [x] Reveal screen (Spine grid, Contested, through-lines, empty-state handling)
- [x] Charter screen (editable houseName/motto, Spine grid, PDF export)
- [x] Read screen (vocabulary, quickRead/closerRead, echo, self-report)
- [x] Spot screen (contrast pair, grade, explanation, progress tracking)
- [x] Map screen (discovered through-lines, qualitative reading, warm empty state; no score/ranking)
- [x] Solo Hub (Explore) screen (member selector, Read/Spot/Map entry cards)
- [x] Settings screen (theme picker, About, data-reset with confirmation)
- [x] Home / Hearth screen (Start a round, Open last Charter, Explore; Settings icon)
- [x] Navigation wired: Home → Members → Round → Reveal → Charter; Home → Solo Hub → Read/Spot/Map; Home → Settings
- [x] `ThemePreference` (light / hearthDark / night) + `setThemePreference` + `flutter_secure_storage`
- [x] Full test suite: 116 tests, all passing; `flutter analyze lib test` — no issues

**v1 — deferred (human follow-up)**
- [x] Real CC0/PD affinity deck images (24 images, 8/domain) — sourced + license-verified (Cleveland CC0 + Met Public Domain); see `docs/cc0-image-sourcing.md`
- [ ] App Store / Google Play submission

**v2 — not yet started**
- [ ] Cross-device sync (Sync tier, encrypted blob relay)
- [ ] Named auth tier (account recovery, family sharing)
- [ ] Art domain (8 deck images, canon items, Spot questions)
- [ ] Threshold recalibration for N > 2 members
- [ ] Map → Reveal coupling (optional depth feeds through-line weighting)
