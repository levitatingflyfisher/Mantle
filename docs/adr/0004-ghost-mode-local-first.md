# 0004 — Ghost mode: local-first, no accounts, no BaaS

**Status:** Accepted

## Context

Mantle's output is intimate — a family's aesthetic identity, a self-authored
heirloom. That data is exactly the kind that should never sit on someone else's
server by default, never feed an ad profile, and never require an account to use.
The OpenHearth ethos is local-first and privacy-by-default; this app is a clean fit
for the strictest version of it.

## Decision

Ship **Ghost mode only** for v1:

- **No account, ever, for core function.** Zero identity, zero server contact.
- **No network client for app data.** There is no HTTP/socket client in the app;
  all state is a local Drift/SQLite database. The only non-Drift persistence is
  the theme preference, in `flutter_secure_storage`.
- **No analytics, no telemetry, no ad SDKs.**
- **No BaaS** (Firebase / Supabase / Auth0). If cross-device sync is built (v2),
  it will be **encrypted blobs through a dumb relay** using a shared BIP39 seed —
  never plaintext, never a backend that can read the data.

## Consequences

- Privacy is *architectural*, not a promise: with no network client, there is
  nothing that can exfiltrate data. This is checkable — see
  [privacy-model.md](../privacy-model.md).
- No login screen, no onboarding friction; a family starts a sitting immediately.
- Sync and multi-device are therefore **not free** — the data model is *shaped*
  for them (`EloSession` carries dormant `sessionCode` / `hostParticipantId` /
  `expiresAt` fields; persistence records mergeable decision logs) but nothing is
  built, and a real "user lost their phone" recovery story is deferred to a future
  Named tier.
- Any future contribution that adds a network client, an account, or an analytics
  SDK contradicts this ADR and the [vision](../VISION.md) — reopen this record
  first.
