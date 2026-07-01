import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Config-guard for the Android backup posture.
///
/// Mantle's DB holds the household's pairwise journaling — the app promises
/// "no data leaves without your say-so" (settings screen). Android Auto
/// Backup would silently upload the plaintext mantle.sqlite to the user's
/// Google account unless the manifest opts out. The encrypted .ohbk flow is
/// the sanctioned backup path; cloud Auto Backup must stay off.
///
/// This is a file-content guard (an Auto-Backup behavioral test is not
/// runnable under `flutter test`); it pins the manifest attributes and the
/// backup-rule XML resources that enforce the opt-out.
void main() {
  const manifestPath = 'android/app/src/main/AndroidManifest.xml';

  test('manifest opts out of Android Auto Backup', () {
    final manifest = File(manifestPath).readAsStringSync();

    expect(manifest, contains('android:allowBackup="false"'),
        reason: 'Auto Backup would upload the plaintext journaling DB '
            'to Google; the encrypted .ohbk flow is the only backup path.');
    expect(
      manifest,
      contains(
          'android:dataExtractionRules="@xml/data_extraction_rules"'),
      reason: 'Android 12+ reads dataExtractionRules, not allowBackup '
          'alone — both must deny extraction.',
    );
    expect(manifest, contains('android:fullBackupContent="@xml/backup_rules"'),
        reason: 'Pre-Android-12 devices read fullBackupContent; exclude '
            'everything there too.');
  });

  test('data_extraction_rules.xml disables cloud backup and device transfer',
      () {
    final file =
        File('android/app/src/main/res/xml/data_extraction_rules.xml');
    expect(file.existsSync(), isTrue,
        reason: 'The manifest references @xml/data_extraction_rules; '
            'the resource must exist or the build breaks.');
    final rules = file.readAsStringSync();
    expect(rules, contains('<cloud-backup'));
    expect(rules, contains('<device-transfer'));
    expect(rules, contains('<exclude domain="root" path="."'));
    expect(rules, isNot(contains('disableIfNoEncryptionCapabilities')),
        reason: 'Rules must exclude data outright, not conditionally on '
            'transport encryption.');
  });

  test('backup_rules.xml excludes everything for pre-Android-12', () {
    final file = File('android/app/src/main/res/xml/backup_rules.xml');
    expect(file.existsSync(), isTrue,
        reason: 'The manifest references @xml/backup_rules; '
            'the resource must exist or the build breaks.');
    final rules = file.readAsStringSync();
    expect(rules, contains('<full-backup-content'));
    expect(rules, contains('<exclude domain="root" path="."'));
  });
}
