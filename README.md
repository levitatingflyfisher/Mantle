# Mantle

*Discover your family's shared aesthetic — and keep it.*

> **Vision:** A household has a felt-but-unspoken aesthetic — a way it wants its
> home, its clothes, its spaces to *feel* — that no one can quite name. Mantle
> surfaces it from the family's own choices (not a quiz), and turns it into a
> printable **House Charter** you can keep. Local-first, account-free, no taste
> scores. See **[VISION.md](VISION.md)**.

Mantle is a free, local-first Flutter app for households. Everyone sits down
together around one device and answers a stream of two-second questions —
*"which of these is more **us**?"* — across three domains (architecture,
tailoring, interiors). When everyone's done, Mantle merges the choices and
reveals:

- **The Spine** — where the family genuinely converges: your shared favourites.
- **Where the House argues** — the items you lovingly disagree on.
- **Named through-lines** — the cross-domain threads that run through what you
  love (e.g. *the charged gap*, *material honesty*).

From there you name your House, write an optional motto, and export a one-page
**Charter** to PDF. The reveal is an heirloom the family authors — the app never
declares your taste for you.

## How a sitting goes

1. **Gather** — add 2–5 members (a label and a colour; no accounts).
2. **The round** — pass the device around. Each person ranks the same fixed deck
   of 24 images via quick head-to-head pairs, per domain. No peeking at anyone's
   results mid-sitting.
3. **The reveal** — after everyone's finished, the merged Spine / Contested /
   through-lines appear.
4. **The Charter** — name your House, add a motto, print it.
5. **Explore (solo, any time)** — optional depth: **Read** (a real vocabulary),
   **Spot** (train your eye), **Map** (see your through-lines). Never scored.

A solo user can Read / Spot / Map any time, but the House reveal needs **≥ 2
rankers** to mean anything — that's stated, not implied.

## Quickstart

```bash
flutter pub get
flutter run           # a device or emulator; also builds for web/desktop
flutter test          # the full suite
flutter analyze lib test
```

Flutter SDK `>=3.5.0 <4.0.0`. Mantle depends on two sibling packages in the
OpenHearth workspace — `elo_engine` (pairwise ranking + merge) and
`openhearth_design` (the shared theme) — checked out next to this repo. Drift
code generation, when needed:

```bash
dart run build_runner build --delete-conflicting-outputs --force-jit
```

## Privacy in one line

Ghost mode is the whole product: **zero network for app data, no accounts, no
analytics, no telemetry.** Everything lives in a local SQLite database on the
device. There is no network client in the app. See
**[docs/privacy-model.md](docs/privacy-model.md)** — and you can check it
yourself.

## Documentation

Start at **[docs/README.md](docs/README.md)** (organized
[Diátaxis](https://diataxis.fr/)-style). The map:

- **[VISION.md](VISION.md)** — the one idea, the invariants, the honest scorecard.
- **[AGENTS.md](AGENTS.md)** — guide for agents and humans working in this repo.
- **[docs/architecture/OVERVIEW.md](docs/architecture/OVERVIEW.md)** — how it fits together.
- **[docs/concepts.md](docs/concepts.md)** — the domain model in prose.
- **[docs/spec/yellow-paper.md](docs/spec/yellow-paper.md)** — the reveal semantics, specified.

## License

MIT. Bundled content (the affinity deck) is CC0 / Public-Domain, verified
per-object — see [docs/cc0-image-sourcing.md](docs/cc0-image-sourcing.md).
