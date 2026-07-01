# Mantle — White Paper

*Discovering a household's shared aesthetic from revealed preference, and keeping
it local.*

**Status:** conceptual overview. For the invariants see [VISION.md](../VISION.md);
for the mechanics, [architecture/OVERVIEW.md](architecture/OVERVIEW.md); for the
reveal semantics, the [yellow paper](spec/yellow-paper.md). This document is honest
about the line between what is built and what is aspirational — see §7.

---

## Abstract

Every household has an aesthetic — a way it wants its rooms, its clothes, its
spaces to *feel* — that its members share more than they realize and can name less
than they'd like. Existing tools miss it from both sides: single-user style quizzes
hand *one* person a label, and "family values" templates capture no aesthetic
dimension at all. Mantle discovers the shared aesthetic the only way that actually
works — from the family's own choices, not their self-descriptions — by having
everyone make a stream of two-second pairwise judgments and then merging those
judgments so that *agreement*, not enthusiasm, decides what counts as shared. The
result is a self-authored, printable **House Charter**. It runs entirely on one
device, with no account and no network, because a family's aesthetic identity is an
intimate heirloom, not profile data.

## 1. The problem

Ask a household "what's your style?" and three things go wrong at once. The
question invites *self-description*, which is defensive and aspirational rather than
honest. It's answered by *one* person, so it produces a label the household never
agreed to. And it treats aesthetic identity as something you already know and can
articulate — when in fact it's mostly tacit, felt in the moment of choosing rather
than stated in the abstract.

So the felt-but-unspoken aesthetic stays unspoken. Families can't name it, can't
agree on it out loud, and can't pass it down. What's missing is not another quiz.
It's a way to *surface* the thing that's already there.

## 2. The idea

**Discover the aesthetic from revealed preference.** Don't ask people to describe
their taste; watch what they choose. Replace "what's your style?" with "which of
these is more *us*, right now?" — a forced choice between two images, answered in
two seconds. One choice says little. Thirty-six choices each, across three domains,
from everyone in the house, say a great deal.

Two design commitments make the output trustworthy:

- **Agreement, not enthusiasm.** A *shared* favourite is one that ranked high for
  *everyone*, not one that one person loved and another tolerated. Mantle merges
  each person's ranking with a harmonic mean, which penalizes disagreement, and it
  admits an item to the family "Spine" only when it has both high agreement *and* a
  genuinely-high combined score. (The second condition matters: high agreement
  alone would also admit an item everyone *dis*likes. The [yellow
  paper](spec/yellow-paper.md) proves the combined rule can't be fooled that way.)
- **The app describes; the family decides.** Mantle supplies neutral reference
  material and does the merging arithmetic. Every value judgment — *this* is us, we
  are a House that loves the charged gap — is a family output. The app never
  declares a household's aesthetic on its behalf.

## 3. Why coherence, not connoisseurship

Mantle has no global taste score, no leaderboard, and no notion of "better." This
is a stance, not an omission. The thing worth surfacing is *coherence* — "this is
recognizably us" — and coherence is domain-neutral: a warm farmhouse House is
exactly as coherent, and exactly as legitimate, as an austere Brutalist one. The
moment an app ranks taste, it stops being a mirror and becomes a judge, and a
family stops answering honestly. So the common reading is always valid, the "closer
read" in the reference vocabulary is a *particular* lens and never a superior one,
and the only distinction Mantle draws is *authorship*: is this thread recognizably
yours?

## 4. The through-line: the "aha"

The payoff is cross-domain. When the same idea — *material honesty*, say, or *the
charged gap* — turns up in the family's shared favourites in **both** how they build
*and* how they dress, Mantle names it. That's the moment a household sees its
aesthetic as a real signature rather than a set of unrelated likes: a thread that
runs across domains is not a mood, it's an identity. Naming a through-line requires
it to be expressed by at least two Spine items spanning at least two domains —
precise enough that the "aha" is earned, not manufactured.

## 5. Why local-first, here

A family's aesthetic identity is about *belonging* — it's for them, not a signal to
outsiders. That is precisely the kind of data that should never sit on someone
else's server by default. Mantle is therefore **Ghost mode**: no account, no
network client for app data, no analytics, everything in a local database. Privacy
isn't a promise bolted on; it's architectural — there is nothing in the app that
*can* send your data anywhere (see [privacy-model.md](privacy-model.md)). The
Charter is an heirloom you print and keep, not a record we hold.

This also shapes the roadmap honestly: cross-device sync, when it comes, has to
preserve the property — encrypted blobs through a dumb relay, never plaintext,
never a backend that can read the family's taste.

## 6. How it's different

| Approach | What it does | What it misses |
|---|---|---|
| Interior "find your style" funnels | Single-user style quiz → a label | Solo; label-dispensing; no household coordination |
| Pinterest / mood boards | Self-curated image collections | Individual; no shared reveal; no vocabulary |
| Family "mission statement" templates | Values-only worksheets | No aesthetic axis at all |
| DailyArt / Slow Art / VTS | Art appreciation, "how to look" | Strong prior art on *looking* — but no collective reveal |

Mantle's combination is the differentiator: **collective** (a household, not a
person) + **revealed-preference** (choices, not self-report) + **image and
vocabulary** together + a **self-authored, printable heirloom** + **local-first /
account-free**. No existing tool sits at that intersection.

## 7. What is built, and what is not

A white paper that overclaims is marketing. Honestly, as of v1:

**Built, tested, load-bearing** (132 tests passing, `flutter analyze` clean): the
whole spine — gather → per-domain fixed-length round → persisted decisions →
replayed sessions → harmonic-mean merge → Spine/Contested partition → named
through-lines → editable Charter → PDF export; the no-peek guarantee (gated reveal
route, hand-off interstitial, no mid-sitting results), regression-tested; the solo
depth (Read / Spot / Map, never scored); a real, license-verified CC0/PD affinity
deck with provenance enforced by a test; and Ghost mode as an architectural fact,
not a promise.

**Aspirational — documented, not built:** cross-device **sync** (the data model is
*shaped* for it — dormant session fields, mergeable decision logs — but the crypto
and relay do not exist; Mantle is single-device today); the **N > 2 threshold
calibration** (the 0.75 / 0.25 partition constants are tuned for two rankers, and a
single outlier collapses agreement at larger sizes); an **Art** domain; **solo
depth feeding the reveal**; a **Named** account-recovery tier; and app-store
release. Each is a sketch with nothing shipped toward it.

The honest boundary: the reveal's soundness is a genuine, checkable property *for
two rankers* (§ the yellow paper), the thresholds above two are *tuned* not proved,
and the "≥ 2 rankers" requirement is enforced by the routing gate, not the merge
math. Everything with "sync," "account," or "v2" attached is still a hope.

## 8. Why it's worth doing

Because the alternative — a household's shared aesthetic staying tacit, ungraspable,
and un-passed-down, or else reduced to one person's quiz result on a company's
server — is the status quo, and it's a small quiet loss repeated in every home. The
contribution is not a new algorithm; it's the framing (discover from choice, merge
for agreement, describe don't judge) and the insistence that this intimate thing
stay on the family's own device, in a form they authored and can keep.

---

## References

- Elo, A. (1978). *The Rating of Chessplayers, Past and Present* — the pairwise
  rating method the ranking round builds on (via the `elo_engine` package).
- Diátaxis (Procida, D.) — the documentation framework this project's
  [docs](README.md) follow.
- Prior art on "how to look": DailyArt, Slow Art Day, and Visual Thinking
  Strategies (VTS); Charlotte Mason picture study.

*The code and comments referenced here were authored by an AI assistant and
describe what currently exists — take them with gratitude and a grain of salt, and
verify before relying.*
