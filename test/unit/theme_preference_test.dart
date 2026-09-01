// test/unit/theme_preference_test.dart
//
// The theme follows the phone by default, light and dark are one tap away,
// and Night stays an explicit extra choice. Installs that stored the old
// Daytime / Evening / Late night picker are migrated on read.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:openhearth_design/openhearth_design.dart';

Future<ThemePreference> _read(Map<String, String> stored) async {
  FlutterSecureStorage.setMockInitialValues(stored);
  final container = ProviderContainer();
  addTearDown(container.dispose);
  return container.read(themePreferenceProvider.future);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('default and migration', () {
    test('nothing stored follows the phone', () async {
      expect(await _read({}), ThemePreference.system);
    });

    test('legacy Daytime (the old default) follows the phone', () async {
      expect(await _read({'mantle.themePreference': 'light'}),
          ThemePreference.system);
    });

    test('legacy Evening becomes Dark', () async {
      expect(await _read({'mantle.themePreference': 'hearthDark'}),
          ThemePreference.dark);
    });

    test('legacy Late night stays Night', () async {
      expect(await _read({'mantle.themePreference': 'night'}),
          ThemePreference.night);
    });

    test('a choice under the new key wins over the legacy one', () async {
      expect(
          await _read({
            'mantle.themePreference': 'hearthDark',
            'mantle.themeMode': 'light',
          }),
          ThemePreference.light);
    });

    test('a saved choice reads back', () async {
      FlutterSecureStorage.setMockInitialValues({});
      await setThemePreference(ThemePreference.dark);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(await container.read(themePreferenceProvider.future),
          ThemePreference.dark);
    });
  });

  group('what each choice renders', () {
    test('follow phone, light, dark and night map to a ThemeMode', () {
      expect(ThemePreference.system.themeMode, ThemeMode.system);
      expect(ThemePreference.light.themeMode, ThemeMode.light);
      expect(ThemePreference.dark.themeMode, ThemeMode.dark);
      expect(ThemePreference.night.themeMode, ThemeMode.dark);
    });

    test('dark is the warm hearth dark; night is the neutral night theme', () {
      expect(ThemePreference.dark.darkTheme().colorScheme.primary,
          OhTheme.hearthDark().colorScheme.primary);
      expect(ThemePreference.night.darkTheme().colorScheme.primary,
          OhTheme.night().colorScheme.primary);
    });

    test('the app-bar toggle shows Night as Dark, and a pick clears Night', () {
      expect(ThemePreference.night.toggleValue, OhThemeModePreference.dark);
      expect(ThemePreference.fromToggle(OhThemeModePreference.dark),
          ThemePreference.dark);
      expect(ThemePreference.fromToggle(OhThemeModePreference.system),
          ThemePreference.system);
    });
  });
}
