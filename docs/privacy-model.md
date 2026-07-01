# Privacy model

Mantle is **Ghost mode only**: nothing about your family leaves the device,
because there is nothing in the app that can send it. This page says exactly what
that means and how you can check it yourself.

## What leaves the device

**Nothing.** There is no network client for app data in Mantle. No accounts, no
sync, no analytics, no telemetry, no crash reporting, no ad SDKs. Every member,
every ranking decision, every Charter lives in a local SQLite database on the
device and never travels.

The only data that persists *at all* is:

| Data | Where it lives | Leaves device? |
|---|---|---|
| Members, rounds, ranking decisions, charters, solo progress | Local Drift/SQLite database (app-private storage) | No |
| Theme preference (Daytime / Evening / Late night) | `flutter_secure_storage` (OS keystore) | No |
| The affinity deck, canon, plates, Spot questions | Bundled read-only assets shipped in the app | N/A (never uploaded) |

A **PDF Charter** leaves the device only if *you* export/share it, through the OS
share sheet, to a destination you choose. Mantle initiates no transfer on its own.

## Threat model

Mantle's privacy posture is deliberately simple because the attack surface is
small:

- **No server** means no breach of a Mantle backend is possible — there isn't one.
- **No account** means no credential to phish and no identity to correlate.
- **No network client for app data** means a compromised or malicious build change
  that *tried* to exfiltrate would have to add networking from scratch — a visible,
  reviewable diff, not a config flip.
- The residual surface is the **device itself**: anyone with unlocked access to the
  phone can open the app and see the family's data. Mantle is a shared-household
  tool and treats the device as trusted; it is not a secrets vault.

## How to verify (don't trust — check)

The claim "no network client" is checkable from source. Start with the
dependency list — it's short, auditable, and contains no networking or analytics
package:

```bash
# Inspect declared runtime dependencies:
sed -n '/^dependencies:/,/^dev_dependencies:/p' pubspec.yaml
```

Then confirm the source imports no HTTP / socket / analytics client. This prints
**nothing** (word boundaries keep it from matching, e.g., the theme *radio*
buttons):

```bash
grep -rniE '\b(https?|websocket|dio|firebase|supabase|analytics|telemetry)\b' lib/
```

The dependency list is short and auditable: Flutter, Riverpod, Drift + SQLite,
`path`/`path_provider`, `flutter_svg`, `pdf`/`printing`, `flutter_secure_storage`,
and two local sibling packages (`elo_engine`, `openhearth_design`). None of them is
a network or analytics client. On Android you can further confirm the app declares
no `INTERNET`-dependent networking behaviour for its own data by inspecting the
manifest.

## v2 sync — if it is ever built

Cross-device sync is **not implemented** (see [limitations.md](limitations.md)).
The *intended* design, recorded so it can't drift into a weaker one, is:
**encrypted blobs through a dumb relay** — members derive a shared key from a BIP39
seed phrase, ranking sessions sync as ciphertext the relay cannot read, and merge
identically on each device. No plaintext, no BaaS, no account that can read your
data. Until that ships, Mantle is single-device and this page describes the whole
story.
