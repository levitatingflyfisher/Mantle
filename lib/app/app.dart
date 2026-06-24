import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mantle/core/theme/theme_preference.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';

class MantleApp extends ConsumerWidget {
  const MantleApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pref = ref.watch(themePreferenceProvider);
    return MaterialApp(
      title: 'Mantle',
      theme: (pref.valueOrNull ?? ThemePreference.light).build(),
      home: const HomeScreen(),
    );
  }
}
