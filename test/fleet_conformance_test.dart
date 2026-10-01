import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

void main() => runFleetConformance(const FleetAppConfig(
      appId: 'mantle',
      // Bundles its own type, so nothing falls back to a web font — a
      // character the bundled families cannot draw is a box on a
      // real phone. C7 sweeps lib/ for any.
      // C8: Mantle runs OhTheme directly, so its ambient iconTheme is live —
      // a bare IconButton.filled paints its glyph the color of its own
      // fill. Filled icon buttons must come from OhIconButton.
      checks: {
        // C13: the PWA loads nothing from Google's CDNs. web/flutter_bootstrap.js
        // points CanvasKit and the engine's fallback fonts at this origin.
        FleetCheck.c13WebSelfHosted,
        ...FleetAppConfig.withBundledFonts,
        FleetCheck.c8IconButtons,
        // C10: no raw exception text on screen. Failures go through
        // OhErrorState, which keeps the exception behind Details.
        FleetCheck.c10RawErrors,
        // C11: every app-bar command has a name; Mantle's show icon plus a
        // short visible label (fleet ruling on top bars).
        FleetCheck.c11IconLabels,
        // C12: the accent must not read as the error red (CIEDE2000 >= 12).
        FleetCheck.c12AccentVsError,
        // C5-primaryScreens: the screens below keep their primary action
        // reachable at 360dp x 1.3 (test/a11y/primary_action_sweep_test.dart).
        FleetCheck.c5PrimaryScreens,
        // C7-assetText: C7 over the bundled text assets too (the deck and
        // canon JSON, the Spot questions, the plates' <text>), which the
        // lib/ sweep never reads.
        FleetCheck.c7AssetText,
        // C9 (routes) is deliberately off: Mantle navigates with
        // Navigator.push and declares no GoRoute, so C9 has nothing to
        // check and would report exactly that.
      },
      primaryActionScreens: {
        'HomeScreen',
        'MembersScreen',
        'RoundScreen',
        'CharterScreen',
      },
      // Mantle consumes OhTheme.light()/hearthDark() directly
      // (lib/features/settings/.../theme_preference.dart) — the full tier.
      styleTier: StyleTier.full,
      // The zero-permission claim, enforced: Mantle's manifest declares no
      // <uses-permission> at all.
      androidPermissions: {},
      // C4 v2 — the release MERGED surface: source permissions plus
      // what plugins and the manifest merge inject. Bites when an APK
      // build has left a merged manifest under build/ (dev box).
      mergedAndroidPermissions: {
        'org.openhearth.mantle.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION',
      },
    ));
