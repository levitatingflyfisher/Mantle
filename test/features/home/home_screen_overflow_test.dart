import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mantle/features/home/presentation/home_screen.dart';

/// The Hearth's body was a rigid Column ending in a Spacer: on a short screen
/// (or at a large accessibility text scale) the wordmark + three ActivityCards
/// exceeded the viewport and Flutter threw a RenderFlex overflow. It is now a
/// SingleChildScrollView, so content scrolls instead of overflowing.
void main() {
  Future<void> pumpHome(WidgetTester tester, Size size, double textScale) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const HomeScreen(),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('does not overflow on a short screen', (tester) async {
    await pumpHome(tester, const Size(320, 480), 1.0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not overflow at large text scale on a narrow screen',
      (tester) async {
    await pumpHome(tester, const Size(320, 600), 2.0);
    expect(tester.takeException(), isNull);
  });
}
