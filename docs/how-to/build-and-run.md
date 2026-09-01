# How to build & run Mantle

Task-oriented setup. Assumes a working Flutter toolchain.

## Prerequisites

- **Flutter SDK** `>=3.5.0 <4.0.0` (`flutter --version` to check).
- **The two sibling packages** must be checked out *next to* this repo, because
  `pubspec.yaml` path-depends on them:

  ```
  OpenHearth/
  ├── Mantle/          ← this repo
  ├── eloEngine/       ← path dep: elo_engine (ranking + EloMerge)
  └── ohStyle/openhearth_design/  ← path dep: openhearth_design (theme)
  ```

  If either is missing, `flutter pub get` fails to resolve. (This is also why the
  test/analyze commands must be run from a normal checkout, not a detached copy.)

## Get dependencies

```bash
flutter pub get
```

## Run the app

```bash
flutter run                 # pick a connected device or emulator
flutter run -d chrome       # web
flutter run -d linux        # desktop (linux/macos/windows folders exist)
```

## Run the tests and analyzer

```bash
flutter test                # the full suite — keep it green before committing
flutter analyze lib test    # static analysis — keep it clean
```

The suite includes pure-domain unit tests (reveal partition, through-line naming,
session replay, Spot grading), DAO tests against an in-memory database, widget
tests (including the load-bearing `no_peek_test.dart`), golden tests for the SVG
plates, and content-validation tests that enforce deck provenance.

### Golden tests

Plate rendering is covered by golden images under `test/golden/goldens/`. If you
intentionally change a plate's appearance, regenerate them:

```bash
flutter test --update-goldens test/golden/plates_test.dart
```

Review the image diff before committing updated goldens.

### The reveal under dart2js

`flutter test` runs on the Dart VM, and the VM hid a crash that broke every
reveal on the web build (`1 << 32` is 0 under dart2js). A small check compiles
the reveal's pure-Dart path (`SessionBuilder` → `RevealService` →
`ThroughlineNamer`) to JavaScript and runs one whole two-member round through
it under node, with no browser:

```bash
dart compile js tool/web_reveal_check.dart -o build/web_reveal_check.js
node tool/run_js.cjs build/web_reveal_check.js   # exit 0 = the reveal assembled
```

CI runs it after the test suite. With the pre-fix `SessionBuilder` and
eloEngine it fails with the audit's `RangeError: max must be in range
0 < max ≤ 2^32, was 0`.

What it does **not** do: open the built web app. No CI step renders a Flutter
screen in a browser, so the web UI itself (layout, plugins, the reveal screen)
is still only checked by hand before a release.

## Drift code generation

The Drift database and DAOs are code-generated (`*.g.dart`). After changing a table
or DAO, regenerate:

```bash
dart run build_runner build --delete-conflicting-outputs --force-jit
```

The `--force-jit` flag and the `<2.32.0` Drift pin are required for the current
Dart toolchain (see the note in `pubspec.yaml`). Commit the regenerated `*.g.dart`
files.

## Build release artifacts

```bash
flutter build apk           # Android
flutter build appbundle     # Android (Play)
flutter build web           # PWA
flutter build linux         # desktop (or macos / windows)
```

Mantle is not yet published to the app stores; these produce local artifacts for
sideloading or self-hosting.
