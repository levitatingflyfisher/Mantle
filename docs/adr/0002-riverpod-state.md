# 0002 — Riverpod for state management

**Status:** Accepted

## Context

Mantle's screens need to read async data (the bundled deck, the local database,
the persisted theme) and hold flow state (the current pair, which member is
ranking, whether all members are done). That state must be testable and easy to
override in widget tests with fakes (an in-memory database, a deterministic deck).

## Decision

Use **`flutter_riverpod`**. Dependencies (database, DAOs, `ContentRepository`,
theme) are exposed as providers in `lib/core/providers.dart`; screen flow lives in
`StateNotifier`s (`RoundController`, `RevealController`) behind
`StateNotifierProvider.autoDispose.family`.

## Consequences

- Widget tests override providers with fakes cleanly — e.g. `no_peek_test.dart`
  swaps in an in-memory `MantleDatabase` and a fake `ContentRepository` with a
  deterministic 24-image deck, with no network and no asset bundle.
- The no-peek gate is expressed as controller state (`allMembersComplete`) that
  the router reads, which keeps the gate testable in isolation.
- Riverpod is the OpenHearth-wide default, so the pattern is familiar across apps.
- `autoDispose` controllers reset per navigation; anything that must survive is a
  keep-alive provider or persisted to Drift.
