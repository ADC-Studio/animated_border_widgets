import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaintCount {
  int value = 0;
}

class _PaintProbe extends SingleChildRenderObjectWidget {
  const _PaintProbe({required this.count, required super.child});

  final _PaintCount count;

  @override
  RenderObject createRenderObject(final BuildContext context) =>
      _PaintProbeRenderObject(count);
}

class _PaintProbeRenderObject extends RenderProxyBox {
  _PaintProbeRenderObject(this.count);

  final _PaintCount count;

  @override
  void paint(final PaintingContext context, final Offset offset) {
    count.value += 1;
    super.paint(context, offset);
  }
}

Widget _host({
  required final Widget child,
  final bool enabled = true,
  final bool holdBoostMode = false,
  final bool tickerEnabled = true,
  final bool glowEffect = true,
  final AnimatedGradientBorderController? controller,
  final Curve glowCurve = Curves.easeOut,
}) =>
    Directionality(
      textDirection: TextDirection.ltr,
      child: TickerMode(
        enabled: tickerEnabled,
        child: Center(
          child: AnimatedGradientBorder(
            enabled: enabled,
            glowEffect: glowEffect,
            glow: AnimatedGradientBorderGlow(fadeCurve: glowCurve),
            holdBoostMode: holdBoostMode,
            controller: controller,
            colors: const [Colors.pink, Colors.cyan],
            child: child,
          ),
        ),
      ),
    );

Future<void> _pumpFrames(final WidgetTester tester) async {
  for (var frame = 0; frame < 12; frame += 1) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

Future<Uint8List> _pixels(
  final WidgetTester tester,
  final GlobalKey key,
) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage();
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      return Uint8List.fromList(data!.buffer.asUint8List());
    } finally {
      image.dispose();
    }
  });
  return bytes!;
}

Widget _visualBorder(
  final GlobalKey key, {
  final AnimatedGradientBorderController? controller,
  final bool holdBoostMode = false,
}) =>
    RepaintBoundary(
      key: key,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: AnimatedGradientBorder(
          controller: controller,
          holdBoostMode: holdBoostMode,
          glowEffect: true,
          colors: const [Colors.pink, Colors.cyan],
          child: const SizedBox(width: 160, height: 60),
        ),
      ),
    );

void main() {
  testWidgets('rotation, boost and hold remain visibly animated',
      (final tester) async {
    final baselineKey = GlobalKey();
    final boostedKey = GlobalKey();
    final heldKey = GlobalKey();
    final controller = AnimatedGradientBorderController();
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _visualBorder(baselineKey),
              _visualBorder(boostedKey, controller: controller),
              _visualBorder(heldKey, holdBoostMode: true),
            ],
          ),
        ),
      ),
    );
    final initial = await _pixels(tester, baselineKey);
    expect(await _pixels(tester, boostedKey), equals(initial));
    expect(await _pixels(tester, heldKey), equals(initial));
    controller.triggerBoost();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));
    final rotating = await _pixels(tester, baselineKey);
    final boosted = await _pixels(tester, boostedKey);
    final held = await _pixels(tester, heldKey);
    expect(rotating, isNot(equals(initial)));
    expect(boosted, isNot(equals(rotating)));
    expect(held, isNot(equals(rotating)));
    controller.triggerBoost();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(await _pixels(tester, boostedKey), isNot(equals(boosted)));
    await tester.pumpWidget(const SizedBox.shrink());
    controller.dispose();
    expect(tester.takeException(), isNull);
  });

  for (final holdBoostMode in [false, true]) {
    testWidgets(
      'retains content painting while glow rotates (hold=$holdBoostMode)',
      (final tester) async {
        final count = _PaintCount();
        final controller = AnimatedGradientBorderController();
        await tester.pumpWidget(
          _host(
            holdBoostMode: holdBoostMode,
            controller: controller,
            child: _PaintProbe(
              count: count,
              child: const SizedBox(width: 120, height: 48),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));
        final initialPaints = count.value;
        expect(initialPaints, greaterThan(0));

        await _pumpFrames(tester);
        expect(count.value, initialPaints);

        controller.triggerBoost();
        await _pumpFrames(tester);
        expect(count.value, initialPaints);

        await tester.pumpWidget(const SizedBox.shrink());
        controller.dispose();
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('glow visibility preserves pointer handling at rounded corners',
      (final tester) async {
    var glowEnabled = false;
    var backgroundTaps = 0;
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (final context, final setState) {
          update = setState;
          return Stack(
            alignment: Alignment.topLeft,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => backgroundTaps += 1,
                ),
              ),
              _host(
                glowEffect: glowEnabled,
                child: const SizedBox(width: 120, height: 48),
              ),
            ],
          );
        },
      ),
    );
    final corner = tester.getTopLeft(find.byType(AnimatedGradientBorder)) +
        const Offset(0.5, 0.5);
    await tester.tapAt(corner);
    expect(backgroundTaps, 1);
    update(() => glowEnabled = true);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tapAt(corner);
    expect(backgroundTaps, 1);
    update(() => glowEnabled = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    await tester.tapAt(corner);
    expect(backgroundTaps, 2);
  });

  testWidgets('reuses paint delegates across animation frames',
      (final tester) async {
    await tester.pumpWidget(
      _host(
        holdBoostMode: true,
        child: const SizedBox(width: 120, height: 48),
      ),
    );
    final paintFinder = find.descendant(
      of: find.byType(AnimatedGradientBorder),
      matching: find.byType(CustomPaint),
    );
    final initial = tester.widget<CustomPaint>(paintFinder);
    await _pumpFrames(tester);
    final animated = tester.widget<CustomPaint>(paintFinder);
    expect(animated.painter, same(initial.painter));
    expect(animated.foregroundPainter, same(initial.foregroundPainter));
  });

  testWidgets('retained content still paints updates from its parent',
      (final tester) async {
    final count = _PaintCount();
    var color = Colors.red;
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (final context, final setState) {
          update = setState;
          return _host(
            child: _PaintProbe(
              count: count,
              child: SizedBox(
                width: 120,
                height: 48,
                child: ColoredBox(color: color),
              ),
            ),
          );
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    final initialPaints = count.value;
    update(() => color = Colors.blue);
    await tester.pump();
    expect(count.value, greaterThan(initialPaints));
    expect(
        tester.widget<ColoredBox>(find.byType(ColoredBox)).color, Colors.blue);
    final updatedPaints = count.value;
    await _pumpFrames(tester);
    expect(count.value, updatedPaints);
  });

  testWidgets('TickerMode mutes all repeating frame callbacks',
      (final tester) async {
    var tickerEnabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (final context, final setState) {
          update = setState;
          return _host(
            tickerEnabled: tickerEnabled,
            holdBoostMode: true,
            child: const SizedBox(width: 120, height: 48),
          );
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.binding.hasScheduledFrame, isTrue);
    update(() => tickerEnabled = false);
    await tester.pump();
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    update(() => tickerEnabled = true);
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isTrue);
  });

  testWidgets('disabling the border settles after its fade',
      (final tester) async {
    var enabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (final context, final setState) {
          update = setState;
          return _host(
            enabled: enabled,
            holdBoostMode: true,
            child: const SizedBox(width: 120, height: 48),
          );
        },
      ),
    );
    await tester.pump(const Duration(milliseconds: 16));
    update(() => enabled = false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('controller and glow curve updates dispose cleanly',
      (final tester) async {
    final first = AnimatedGradientBorderController();
    final second = AnimatedGradientBorderController();
    var useFirst = true;
    var glowEnabled = true;
    late StateSetter update;
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (final context, final setState) {
          update = setState;
          return _host(
            controller: useFirst ? first : second,
            glowEffect: glowEnabled,
            glowCurve: useFirst ? Curves.easeOut : Curves.easeIn,
            child: const SizedBox(width: 120, height: 48),
          );
        },
      ),
    );
    first.triggerBoost();
    await _pumpFrames(tester);
    update(() {
      useFirst = false;
      glowEnabled = false;
    });
    await tester.pump();
    first.dispose();
    second.triggerBoost();
    await _pumpFrames(tester);
    update(() => glowEnabled = true);
    await tester.pump();
    await _pumpFrames(tester);
    await tester.pumpWidget(const SizedBox.shrink());
    second.triggerBoost();
    second.dispose();
    expect(tester.takeException(), isNull);
    expect(tester.binding.transientCallbackCount, 0);
  });
}
