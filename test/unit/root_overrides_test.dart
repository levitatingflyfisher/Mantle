// test/unit/root_overrides_test.dart
//
// Fleet PWAs share one browser origin, so on web Mantle's recovery words
// must live under Mantle's own key names, never the shared slot every other
// app reads.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/app/root_overrides.dart';
import 'package:sanctuary_auth_core/sanctuary_auth_core.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

void main() {
  test('on web the key store is scoped to Mantle', () {
    final container = ProviderContainer(overrides: mantleRootOverrides(web: true));
    addTearDown(container.dispose);

    expect(container.read(secureKeyStoreProvider), isA<AppScopedSecureKeyStore>());
    expect(container.read(sanctuaryBackupConfigProvider).appId, 'mantle');
    expect(container.read(sanctuaryAppDomainProvider), 'mantle');
  });

  test('on native the platform keychain is used as before', () {
    final container =
        ProviderContainer(overrides: mantleRootOverrides(web: false));
    addTearDown(container.dispose);

    expect(container.read(secureKeyStoreProvider),
        isNot(isA<AppScopedSecureKeyStore>()));
  });
}
