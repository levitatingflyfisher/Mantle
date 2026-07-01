# Vision

> The north star for Mantle. If you (person or agent) are about to change
> something load-bearing, read this first — it says what must stay true and why.
> For *how it's built*, see [docs/architecture/OVERVIEW.md](docs/architecture/OVERVIEW.md);
> for *why each decision was made*, [docs/adr/](docs/adr/).

## The one idea

**A family's shared aesthetic is real, but you can't get it by asking.** Ask
"what's your style?" and you get defensive self-description — a label one person
picks that the household never agreed to. Ask "which of these is more *us*, right
now?" and you get an honest answer in two seconds. Do that enough times, across
three domains, with everyone in the house, and a genuine shared aesthetic
surfaces — **not from a quiz, but from the family's own choices.**

The move that makes this work:

> **Discover the aesthetic from revealed preference, then merge in a way that
> rewards agreement — not enthusiasm.** A shared favourite is one *both* people
> ranked high, not one person loved and the other tolerated.

Mantle then hands the family the result as something they *authored*: a printable
**House Charter**. The app describes; the family decides.

## What this is

A local-first Flutter app for a household, run on one shared device:

```
  gather members ─▶ each ranks the deck ─▶ merge ─▶ reveal ─▶ Charter
   (2–5, no        (24 images, head-to-    (harmonic  (Spine /   (name your
    accounts)       head, per domain)       mean)      Contested   House,
                                                       / through-  print PDF)
                                                       lines)
```

- **Discovery, not assessment.** There is no global taste score and no "better."
  The reveal is about *coherence* — "this is recognizably us" — never superiority.
- **Collective by construction.** The House Spine is mathematically meaningful
  only with **≥ 2 rankers**; a solo user gets the optional depth (Read / Spot /
  Map), not the House reveal.
- **An heirloom, not a signal.** The Charter is for the family, about belonging —
  not for showing outsiders.

## The invariants (do not break these)

These are the load-bearing beliefs. Breaking one is a design regression, not a
feature. They live in the code and the tests, and the load-bearing ones are
recorded as ADRs.

1. **Ghost mode is the product.** No account, no network client for app data, no
   analytics, no telemetry — architecturally enforced, not just promised. All
   state is a local Drift/SQLite database. ([ADR-0004](docs/adr/0004-ghost-mode-local-first.md))
2. **Coherence, not connoisseurship.** No global taste score, no leaderboard, no
   "better." Distinctiveness = "recognizably *us*." A warm farmhouse House is
   exactly as legitimate as an austere Brutalist one.
3. **The common reading is valid.** Liking the popular take is never penalized.
   Reference content (the vocabulary, the "closer read") offers a *particular*
   lens, never a superior one.
4. **The app describes; the family decides.** Every value judgment is a family
   *output*. The app supplies neutral reference material and merges choices — it
   never declares the family's aesthetic identity on their behalf.
5. **A shared favourite means agreement, not enthusiasm.** The merge penalizes
   disagreement (harmonic mean), and the Spine partition requires *both* high
   agreement *and* an above-midpoint score, so a mutually-*disliked* item can
   never masquerade as consensus. ([ADR-0005](docs/adr/0005-pairwise-elo-discovery.md),
   [yellow paper](docs/spec/yellow-paper.md))
6. **No peeking.** During a sitting no individual's results are reachable, a
   hand-off interstitial separates members, and the reveal route is gated until
   everyone is done. Belonging requires that no one games the mirror.

## Honest scorecard — built vs. aspirational

A guiding light has to tell the truth about where the light reaches. **Every line
of source and every comment in this repo was written by an AI assistant; treat it
as an accurate record of what currently exists, offered with gratitude and a
grain of salt — not as a specification and not as guaranteed-correct.** If a
comment and the tests disagree, the tests win; if the tests and reality disagree,
reality wins. As of v1:

**Real, tested, load-bearing** (132 tests passing; `flutter analyze` clean):
- The whole spine: gather → per-domain fixed-length round → persist decisions →
  rebuild sessions → merge → Spine/Contested partition → name through-lines →
  editable Charter → PDF export. This is the product and it holds.
- The no-peek guarantee (gated reveal route + hand-off interstitial + no
  mid-sitting result screen), regression-tested.
- The 24-image affinity deck is **real, license-verified CC0/PD** (Cleveland
  Museum of Art + the Met), with a content-validation test that refuses any deck
  record missing a complete provenance block.
- Ghost mode: no network client exists in the app; theme preference is the only
  thing outside Drift (in `flutter_secure_storage`).

**Aspirational — documented, not shipped:**
- **Cross-device sync (v2).** The data model is *shaped* for it — `EloSession`
  carries dormant `sessionCode` / `hostParticipantId` / `expiresAt` fields, and a
  BIP39-seed encrypted-blob relay is the intended design — but **none of it is
  built.** Today Mantle is single-device only.
- **The N > 2 calibration.** The partition thresholds (agreement ≥ 0.75 for
  Spine, ≤ 0.25 for Contested) are tuned for two rankers. With 3+, a single
  outlier collapses agreement. Flagged, not yet recalibrated.
- **The Art domain, Map → reveal coupling, and a Named (account-recovery) tier**
  are v2 sketches with nothing built toward them.
- **App Store / Play submission** has not happened.

The core is real and shipped. Anything with the word "sync," "account," or "v2"
attached is still a hope. Keep that line bright.

## Horizons (problems, not a feature list)

Framed as problems on purpose — a dated feature list self-destructs; the open
problem is what endures.

- **Near** — Recalibrate the Spine/Contested thresholds for households larger
  than two without letting one outlier erase the shared core. This is the one
  known soft spot in the reveal and the cheapest high-value fix.
- **Mid** — Cross-device sync as *encrypted blobs through a dumb relay*: members
  rank on their own phones, sessions sync and merge identically, and the relay
  never sees plaintext. The data model already leaves room; the crypto and the
  relay do not exist.
- **Far** — Let solo depth *inform* the reveal without making it a prerequisite:
  a family's Map history could weight which through-lines get named, but only if
  it never turns individual homework into a gate on the group result. The design
  tension (depth must stay optional) is the hard part, not the code.

## The name

**Mantle** — the thing a family wears and passes down; the warm surround of a
hearth; and the deep layer beneath the surface where a house's real character
lives. A mantle is inherited and it is worn in public without being *for* the
public — exactly what the House Charter is meant to be.
