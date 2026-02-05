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
}
