import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mantle/app/app.dart';
import 'package:mantle/app/root_overrides.dart';

void main() => runApp(
      ProviderScope(
        overrides: mantleRootOverrides(),
        child: const MantleApp(),
      ),
    );
