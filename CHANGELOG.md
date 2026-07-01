# Changelog

All notable changes to Mantle will be documented in this file.

## [Unreleased]

### Added
- First CI workflow (`.github/workflows/ci.yml`): analyze + test, debug-APK
  and web-release smoke builds, Flutter pinned to the fleet's 3.38.7, all
  five sibling path deps cloned alongside the checkout.
- Fleet conformance suite (`test/fleet_conformance_test.dart` on
  `oh_fleet_conformance`): style canon, backup spec, size budgets
  (`budgets.json` baselines: 1,147,222 gz-bytes web JS / 24,673,766 bytes
  arm64 APK), the zero-permission claim, and the shared test/CI harness —
  all enforced as tests.
- Encrypted backup & restore (`.ohbk`), the fleet's sanctuary stack:
  12-word recovery phrase (BIP39) with re-entry confirmation, encrypted
  export via the system share sheet, and restore-by-phrase on a fresh
  install (typing the words adopts them as this device's identity).
- Snapshot vault ("Previous backups" in Settings): every encrypted
  export and every restore leaves a stamped on-device snapshot
  (keep-10, pinnable) you can restore, pin or delete.
- Mandatory pre-restore snapshot: a restore refuses to run unless the
  current data was snapshotted (and the snapshot verified) first —
  restoring is reversible from day one.
- Preview before restore: the confirm dialog shows the backup's age and
  per-table row counts next to what's on the device now.
- Encrypted exports verify themselves by read-back before reporting
  success.
- Silent freshness snapshot on app open when the newest one is older
  than 7 days.
- Plain-JSON export (honestly labeled as unencrypted) — your data in a
  file any program can read.

### Fixed
- Restore now rejects a backup that is missing any of the eight table
  keys (naming the missing one) instead of silently emptying that table:
  restore wipes every table before re-inserting, so an absent key used to
  read as "empty" and destroy that table's data while reporting success.
  Preview (describe) applies the same gate. A legitimately empty table —
  key present, empty list — still restores.

### Notes
- Backups cover all household data: members, rounds, ranking sessions,
  match history, charters, and solo/tutor progress. The bundled deck,
  canon, and menswear content ships with the app and is never backed up.
- Mantle's blobs are bound to its own key domain and AEAD context
  (`mantle` / `mantle-backup/v1`): a backup from another OpenHearth app
  can never restore here, nor vice versa.
