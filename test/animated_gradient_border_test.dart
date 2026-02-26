import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders child widget', (final tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedGradientBorder(
          colors: [Colors.orange, Colors.yellow],
          child: SizedBox(
            key: Key('child'),
            width: 100,
            height: 40,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('child')), findsOneWidget);
  });

  testWidgets('controller triggerBoost does not throw', (final tester) async {
    final controller = AnimatedGradientBorderController();

    await tester.pumpWidget(
      MaterialApp(
        home: AnimatedGradientBorder(
          controller: controller,
          colors: const [Colors.purple, Colors.deepPurpleAccent],
          child: const SizedBox(width: 120, height: 48),
        ),
      ),
    );

    controller.triggerBoost();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(AnimatedGradientBorder), findsOneWidget);
  });

  testWidgets('holdBoostMode true animates without errors',
      (final tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedGradientBorder(
          holdBoostMode: true,
          holdBoostTurnsPerSecond: 1,
          colors: [Colors.blue, Colors.cyan],
          child: SizedBox(width: 120, height: 48),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byType(AnimatedGradientBorder), findsOneWidget);
  });

  testWidgets('glowEffect true renders without errors', (final tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedGradientBorder(
          glowEffect: true,
          glow: AnimatedGradientBorderGlow(
            opacity: 0.4,
            outerStrokeWidth: 10,
            innerStrokeWidth: 5,
          ),
          colors: [Colors.green, Colors.lightGreen],
          child: SizedBox(width: 120, height: 48),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 120));

    expect(find.byType(AnimatedGradientBorder), findsOneWidget);
  });

  testWidgets('enabled false supports disabled border rendering',
      (final tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedGradientBorder(
          enabled: false,
          showBorderWhenDisabled: true,
          disabledBorderWidth: 2.4,
          colors: [Colors.indigo, Colors.blue],
          child: SizedBox(width: 140, height: 50),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 320));

    expect(find.byType(AnimatedGradientBorder), findsOneWidget);
  });

  testWidgets('clipChild true renders child widget', (final tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: AnimatedGradientBorder(
          clipChild: true,
          colors: [Colors.teal, Colors.cyan],
          child: SizedBox(
            key: Key('clipped-child'),
            width: 100,
            height: 40,
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('clipped-child')), findsOneWidget);
  });
}
