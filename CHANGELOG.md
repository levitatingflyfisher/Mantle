# Changelog

All notable changes to Mantle will be documented in this file.

## [Unreleased]

### Changed (fleet rollout, September 2026)
- Builds on openhearth_design 0.7.0, sanctuary_backup_ui 0.3.0 and
  oh_fleet_conformance 0.8.0. Conformance now also runs C10 (no raw
  exception on screen), C11 (named app-bar commands), C12 (accent vs error)
  and the 360dp x 1.3 primary-action sweep for Home, the member list and
  the round.
- Every failure state is `OhErrorState` inside its screen's app bar, with
  Try again. The reveal's error says the round's choices are saved and
  retries the same round; it no longer tells a household to play it again.
  The local `ErrorView` is gone.
- Clear all data takes a safety copy into Previous backups first, clears at
  once and offers an Undo that does not expire. Without backup it asks
  first and says there is no copy. It is no longer "cannot be undone".
- Theme: follow the phone by default, with Light / Dark (and "Auto") in the
  app bar of every primary screen; Night stays in Settings. The old
  Daytime / Evening / Late night choice migrates (Daytime follows the
  phone, Evening is Dark, Late night is Night).
- Each screen's content is capped at 640dp and centred on tablets and in
  the browser; the app bars span the window.
- Settings and Print are labelled in their app bars.
- Home shows a dismissable Finish setup line while backup is not set up.
  On web the recovery words are stored under Mantle's own key names.
- Copy: no spaced em dashes and typographic apostrophes, in the app and in
  the bundled content.
- The round prints "Architecture · 4 of 12" beside the domain name.
- Members show their initial inside their colour dot everywhere, and the
  swatches have names ("Colour: Sage").
- A tap on a member renames, recolours or removes them; remove has an Undo.
- A removed member stays under "Recently removed" with Restore (and a
  confirmed delete forever). The database is now schema 2 (`members.deletedAt`);
  a backup from this version is refused as "newer" by older builds.
- Bundled content no longer uses characters the fonts cannot draw ("Noh
  Costume"; "Ma" without the kanji), and a test keeps it that way.
- Spot shows the correct plate on the left or right per member and
  question, with no A/B letters (the answer used to be the left plate
  every time). The menswear quiz does the same.
- The printed House Charter carries the Spine and Contested plates with
  their titles, a "Made on" date, and is set in Lora.

### Fixed
- The reveal rebuilds each session under its saved id, so it never mints
  one; minting was the dart2js `1 << 32` crash that broke every reveal on
  web. CI now compiles the reveal path with dart2js and runs one whole
  round under node.

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
