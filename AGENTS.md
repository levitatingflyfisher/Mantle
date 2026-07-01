# AGENTS.md

Guidance for AI coding agents (and humans) working in this repo. This is the
top-level map for Mantle, the OpenHearth family-aesthetic app.

**Read these three, in order, before non-trivial work:**
1. [VISION.md](VISION.md) — what must stay true and why (the invariants).
2. [docs/architecture/OVERVIEW.md](docs/architecture/OVERVIEW.md) — how it fits together, with a diagram.
3. [docs/concepts.md](docs/concepts.md) — the domain model (deck, round, merge, reveal, Charter).

## Take the code as current-state, not gospel

Every line of source and every comment here was written by an AI assistant. Treat
it as **an accurate record of what currently exists, offered with gratitude and a
grain of salt** — not as a specification and not as guaranteed-correct. A comment
claiming an invariant is a *hypothesis to verify*, not a proof. If a comment and
the tests disagree, the tests win; if the tests and reality disagree, reality
wins. When you rely on a claim, confirm it (read the code, run the test) first.

## What this is

A local-first Flutter app for a household to **discover its shared aesthetic**.
Everyone ranks the same image deck head-to-head ("which is more *us*?") across
three domains; Mantle merges the choices (harmonic mean, so agreement beats
enthusiasm), partitions the result into a **Spine** (shared favourites) and
**Contested** items, names the cross-domain **through-lines**, and exports a
printable **House Charter**. Clean Architecture (domain / data / presentation),
Riverpod, Drift. Ghost mode only — no network, no accounts, no analytics.

## Non-negotiables (breaking one is a regression, not a feature)

- **Ghost mode is the product.** Do **not** add a network client for app data, an
  account system, analytics, or telemetry. All state is local Drift/SQLite; the
  only non-Drift persistence is the theme preference in `flutter_secure_storage`.
  No Firebase/Supabase/BaaS — v2 sync, if built, is *encrypted blobs through a
  dumb relay*, never plaintext.
- **No taste scores, ever.** No global score, no leaderboard, no "better"/
  "superior" language on any screen. The reveal is about coherence, not ranking
  people's taste. (There are tests that assert this — see `map_test.dart`.)
- **A shared favourite = agreement, not enthusiasm.** The Spine partition
  requires *both* high agreement *and* an above-midpoint score. Don't "simplify"
  it to agreement-only — that admits mutually-disliked items. See the
  [yellow paper](docs/spec/yellow-paper.md) for the proof.
- **Never break the no-peek guarantee.** No individual result screen during a
  sitting; hand-off interstitial between members; reveal route gated until all
  members are complete. `test/widget/no_peek_test.dart` is the regression guard.
- **The reveal needs ≥ 2 rankers.** `RevealService.compute` does *not* enforce
  this — a single session yields agreement 1.0 for every item and a spurious
  Spine. The guarantee lives in the **routing/presentation gate**
  (`allMembersComplete`), so keep the gate; don't hand a one-session reveal to
  the UI.
- **TDD, always.** Reproduce → failing test → fix → `flutter test` green →
  commit. Every bugfix ships with a regression test.
- **Atomic commits, one concern each.** Commit messages state the *why*. No
  AI-authorship or attribution trailers in commit messages — deliberate project
  policy.
- **Never commit local working artifacts.** The plans/specs under
  `docs/superpowers/` and the gitignored agent-instructions and editor-scratch
  files in the repo root are not shipped code — keep them out of commits. This repo
  ships `AGENTS.md` as its one committed guide.

## Where things are (progressive disclosure)

Start with the module map in
[OVERVIEW.md § module map](docs/architecture/OVERVIEW.md#module-map--where-to-look).
The short version, by concern:

| You're touching… | Go to |
|---|---|
| **The reveal math** (Spine/Contested, through-lines) | `lib/features/reveal/domain/reveal_service.dart`, `reveal.dart` (constants + types), `throughline_namer.dart` |
| **The ranking round** (pairing, completion) | `lib/features/ranking/domain/round_service.dart`, `session_builder.dart`, `round_models.dart` |
| **Merge / agreement math** (cross-package) | `EloMerge.combine` / `agreement` live in the sibling **`elo_engine`** package, not here — Mantle only *calls* them |
| **The no-peek gate & round flow** | `lib/features/ranking/presentation/round_controller.dart`, `round_screen.dart` |
| **The reveal → Charter flow** | `lib/features/reveal/presentation/` (`reveal_controller.dart`, `charter_screen.dart`, `charter_pdf.dart`) |
| **Persistence** (Drift schema + DAOs) | `lib/core/db/database.dart`, `lib/features/*/data/*_dao.dart` |
| **Bundled content** (canon, deck, spot, through-lines) | `lib/features/content/` + `assets/data/*.json`, `assets/images/deck/`, `assets/plates/` |
| **Solo depth** (Read / Spot / Map) | `lib/features/solo/` |
| **Theme / entry** | `lib/core/theme/theme_preference.dart`, `lib/app/app.dart`, `lib/main.dart` |

Docs are organized [Diátaxis](https://diataxis.fr/)-style — see
[docs/README.md](docs/README.md) for the tutorials / how-to / reference /
explanation split.

## How to work here

```bash
flutter pub get                                   # resolve deps (needs sibling packages)
flutter test                                      # the suite — must be green before you commit
flutter analyze lib test                          # static analysis — must be clean
dart run build_runner build \
  --delete-conflicting-outputs --force-jit        # regenerate Drift *.g.dart after schema edits
```

- Flutter `>=3.5.0 <4.0.0`. Mantle path-depends on two OpenHearth siblings:
  `elo_engine` (ranking + `EloMerge`) and `openhearth_design` (`OhTheme` /
  `OhColors` / `OhTypography`). They must be checked out next to this repo or
  `flutter pub get` fails.
- **Theme:** always use `OhTheme.light` / `hearthDark` / `night` with no accent
  override. **No inlined hex values.** `google_fonts` is banned — Lora + Nunito
  are bundled.
- **Drift is pinned** `<2.32.0` for the current Dart toolchain (see `pubspec.yaml`
  comment). Match it; don't bump blindly.
- **The domain layer is Drift-free** on purpose (`round_models.dart`'s `MatchRow`
  decouples ELO/reveal logic from persistence). Keep that boundary — reveal and
  round logic must stay pure Dart so it's unit-testable without a database.

## When you're unsure

Prefer a failing test to a plausible fix. Prefer matching the surrounding code to
introducing a new pattern. Prefer asking (or leaving a `TODO` with the open
question) to guessing on the reveal math or the no-peek gate — those are the two
places a subtle change quietly breaks the product's promise. When in doubt about
*why* a decision was made, grep [docs/adr/](docs/adr/) before reopening it — you
may be re-litigating a settled trade-off.
