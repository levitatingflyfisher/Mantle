# 0003 — Drift over sqflite for local persistence

**Status:** Accepted

## Context

All of Mantle's mutable state — members, rounds, per-domain ranking sessions,
recorded match decisions, charters, and solo progress — must persist locally, with
no server. The persistence model records *decisions* (match outcomes), not derived
ratings, so the ranking is always a reproducible replay. That means several
related tables with typed columns and relationships, queried from typed Dart.

## Decision

Use **Drift** (`drift` + `drift_dev` + `sqlite3_flutter_libs`) over raw `sqflite`.
Tables and DAOs are code-generated; the database is defined in
`lib/core/db/database.dart` with a native/web connection split.

## Consequences

- Compile-time-checked schema and queries; DAOs are typed, not stringly-typed SQL.
- Works across mobile, web (via `sqlite3.wasm`), and desktop from one schema.
- An in-memory `MantleDatabase.forTesting` constructor makes DAO and widget tests
  fast and hermetic.
- Codegen is a build step: after any schema change run
  `dart run build_runner build --delete-conflicting-outputs --force-jit`, and the
  `*.g.dart` files are committed.
- Drift is **pinned `<2.32.0`** for the current Dart toolchain (see the
  `pubspec.yaml` comment) — bump deliberately, with codegen re-run and tests green.
- Schema is at `schemaVersion = 1` with a create-all migration; adding a table or
  column for v2 (sync) needs a real migration step.
