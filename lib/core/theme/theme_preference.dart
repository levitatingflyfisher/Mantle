import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:openhearth_design/openhearth_design.dart';

/// How Mantle picks its theme.
///
/// Fleet ruling: follow the phone by default, with light and dark one tap
/// away in the app bar ([OhThemeToggle]). Night, the neutral high-contrast
/// dark with a sage accent, stays an explicit extra choice in Settings.
enum ThemePreference {
  /// Follow the phone: [OhTheme.light] by day, [OhTheme.hearthDark] when the
  /// phone is dark. The default.
  system,

  /// Always [OhTheme.light]: hearth on linen.
  light,

  /// Always [OhTheme.hearthDark]: warm brown-black, still hearth family.
  dark,

  /// Always [OhTheme.night]: neutral dark with a sage accent, for low light.
  night;

  ThemeMode get themeMode => switch (this) {
        ThemePreference.system => ThemeMode.system,
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark || ThemePreference.night => ThemeMode.dark,
      };

  /// The theme used whenever the app is dark.
  ThemeData darkTheme() =>
      this == ThemePreference.night ? OhTheme.night() : OhTheme.hearthDark();

  /// What the app-bar toggle shows. It has three choices, so Night reads as
  /// Dark there; picking any of them from the toggle leaves Night.
  OhThemeModePreference get toggleValue => switch (this) {
        ThemePreference.system => OhThemeModePreference.system,
        ThemePreference.light => OhThemeModePreference.light,
        ThemePreference.dark ||
        ThemePreference.night =>
          OhThemeModePreference.dark,
      };

  static ThemePreference fromToggle(OhThemeModePreference mode) =>
      switch (mode) {
        OhThemeModePreference.system => ThemePreference.system,
        OhThemeModePreference.light => ThemePreference.light,
        OhThemeModePreference.dark => ThemePreference.dark,
      };

  String get label => switch (this) {
        ThemePreference.system => 'Follow phone',
        ThemePreference.light => 'Light',
        ThemePreference.dark => 'Dark',
        ThemePreference.night => 'Night',
      };

  String get hint => switch (this) {
        ThemePreference.system => 'Light by day, dark when your phone is.',
        ThemePreference.light => 'Hearth on linen, for full daylight.',
        ThemePreference.dark => 'Warm dark, still hearth colours.',
        ThemePreference.night => 'Neutral dark with a sage accent, for low '
            'light.',
      };

  static ThemePreference? _fromName(String? id) {
    for (final v in ThemePreference.values) {
      if (v.name == id) return v;
    }
    return null;
  }

  /// The old Daytime / Evening / Late night picker. Daytime was also what an
  /// untouched install showed, so it cannot be told apart from "never
  /// chose" and follows the phone, per the fleet ruling.
  static ThemePreference _fromLegacy(String? id) => switch (id) {
        'hearthDark' => ThemePreference.dark,
        'night' => ThemePreference.night,
        _ => ThemePreference.system,
      };
}

const _themeKey = 'mantle.themeMode';
const _legacyThemeKey = 'mantle.themePreference';
const _storage = FlutterSecureStorage();

/// The user's theme choice. A choice saved under the current key wins;
/// otherwise the legacy picker's value is migrated on read (it is never
/// written back, so a later explicit Light is not mistaken for the old
/// default).
final themePreferenceProvider = FutureProvider<ThemePreference>((ref) async {
  final stored = ThemePreference._fromName(await _storage.read(key: _themeKey));
  if (stored != null) return stored;
  return ThemePreference._fromLegacy(await _storage.read(key: _legacyThemeKey));
});

/// Persist a new theme choice. Caller must invalidate
/// [themePreferenceProvider] after to trigger a rebuild.
Future<void> setThemePreference(ThemePreference pref) async {
  await _storage.write(key: _themeKey, value: pref.name);
}

/// The app-bar theme control: icon plus short label, three choices one menu
/// away. Put it in every primary screen's bar.
class MantleThemeToggle extends ConsumerWidget {
  const MantleThemeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    return OhThemeToggle(
      value: pref.toggleValue,
      onChanged: (mode) async {
        await setThemePreference(ThemePreference.fromToggle(mode));
        ref.invalidate(themePreferenceProvider);
      },
    );
  }
}
