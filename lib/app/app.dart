import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openhearth_design/openhearth_design.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';
import 'package:sanctuary_backup_ui/sanctuary_backup_ui.dart';

class MantleApp extends ConsumerStatefulWidget {
  const MantleApp({super.key});

  @override
  ConsumerState<MantleApp> createState() => _MantleAppState();
}

class _MantleAppState extends ConsumerState<MantleApp> {
  @override
  void initState() {
    super.initState();
    // Silent freshness snapshot (BACKUP_RETENTION_SPEC §3): if a backup key
    // exists and the newest vault snapshot is older than the configured age,
    // take one. Post-frame + fire-and-forget — never blocks boot, never
    // surfaces errors (the Sundial precedent).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(backupControllerProvider.notifier).runStartupMaintenance();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pref = ref.watch(themePreferenceProvider).valueOrNull ??
        ThemePreference.system;
    // Each screen caps its own content with OhPage, so the bars still span
    // a tablet or browser window while the phone layout stays phone-shaped.
    return MaterialApp(
      title: 'Mantle',
      theme: OhTheme.light(),
      darkTheme: pref.darkTheme(),
      themeMode: pref.themeMode,
      home: const HomeScreen(),
    );
  }
}
