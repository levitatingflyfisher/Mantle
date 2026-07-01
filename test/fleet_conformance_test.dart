import 'package:oh_fleet_conformance/oh_fleet_conformance.dart';

void main() => runFleetConformance(const FleetAppConfig(
      appId: 'mantle',
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
