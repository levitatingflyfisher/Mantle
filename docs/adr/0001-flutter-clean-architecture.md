# 0001 — Flutter + Clean Architecture (domain / data / presentation)

**Status:** Accepted

## Context

Mantle targets phones and tablets (a family passing one device around) and should
also run on web and desktop for development and future reach. The reveal logic —
the ranking round, the merge partition, the through-line naming — is the part most
likely to grow subtle bugs, and it must be unit-testable without spinning up a UI
or a database.

## Decision

Build in **Flutter**, structured as **Clean Architecture** with each feature split
into three layers:

- **domain** — pure Dart. No Flutter imports, no Drift. Business rules
  (`RoundService`, `SessionBuilder`, `RevealService`, `ThroughlineNamer`) and
  plain DTOs (`MatchRow`).
- **data** — Drift DAOs and the `ContentRepository`. Persistence and asset loading.
- **presentation** — Riverpod controllers and widgets.

The domain layer must not depend on the data or presentation layers.

## Consequences

- The reveal and round logic is tested directly, no widget pump required — the
  bulk of the suite's value lives there.
- One codebase covers mobile, web, and desktop; the only platform-specific code is
  the Drift connection (`connection/native.dart` vs `web.dart`).
- The discipline costs a little ceremony (DTOs like `MatchRow` that mirror a Drift
  row) — accepted deliberately to keep the domain pure.
- This mirrors every other OpenHearth Flutter app, so contributors move between
  them without relearning the layout.
