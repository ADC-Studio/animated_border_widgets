import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Controller for [AnimatedGradientBorder].
///
/// Use [triggerBoost] to request a one-shot temporary acceleration.
class AnimatedGradientBorderController extends ChangeNotifier {
  /// Starts a one-shot boost animation in the attached border widget.
  void triggerBoost() {
    notifyListeners();
  }
}

/// Fine-tuning configuration for [AnimatedGradientBorder.glowEffect].
@immutable
class AnimatedGradientBorderGlow {
  const AnimatedGradientBorderGlow({
    this.opacity = 0.55,
    this.outerBlurSigma = 18,
    this.innerBlurSigma = 8,
    this.outerStrokeWidth = 14,
    this.innerStrokeWidth = 8,
    this.spread = 4,
    this.blendMode = BlendMode.srcOver,
    this.fadeDuration = const Duration(milliseconds: 220),
    this.fadeCurve = Curves.easeOut,
  })  : assert(opacity >= 0 && opacity <= 1, 'opacity must be in [0..1].'),
        assert(outerBlurSigma >= 0, 'outerBlurSigma must be >= 0.'),
        assert(innerBlurSigma >= 0, 'innerBlurSigma must be >= 0.'),
        assert(outerStrokeWidth >= 0, 'outerStrokeWidth must be >= 0.'),
        assert(innerStrokeWidth >= 0, 'innerStrokeWidth must be >= 0.'),
        assert(spread >= 0, 'spread must be >= 0.');

  /// Overall glow strength multiplier.
  final double opacity;

  /// Blur sigma of the soft outer halo layer.
  final double outerBlurSigma;

  /// Blur sigma of the sharper inner halo layer.
  final double innerBlurSigma;

  /// Stroke width of the soft outer halo layer.
  final double outerStrokeWidth;

  /// Stroke width of the sharper inner halo layer.
  final double innerStrokeWidth;

  /// Additional outside expansion for glow drawing.
  final double spread;

  /// Blend mode used by glow paint.
  final BlendMode blendMode;

  /// Duration of glow fade-in and fade-out when [glowEffect] changes.
  final Duration fadeDuration;

  /// Curve used for glow fade transitions.
  final Curve fadeCurve;
}

/// A container-like widget that paints an animated sweep-gradient border.
///
/// The border rotates continuously. You can accelerate it briefly with
/// [AnimatedGradientBorderController.triggerBoost] or keep it accelerated while
/// pressed with [holdBoostMode].
class AnimatedGradientBorder extends StatefulWidget {
  const AnimatedGradientBorder({
    required this.child,
    required this.colors,
    super.key,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.borderWidth = 1.8,
    this.turnDuration = const Duration(seconds: 7),
    this.boostDuration = const Duration(milliseconds: 700),
    this.boostTurns = 0.24,
    this.innerColor = Colors.white,
    this.boxShadow,
    this.controller,
    this.holdBoostMode = false,
    this.holdBoostTurnsPerSecond = 0.35,
    this.enabled = true,
    this.fadeDuration = const Duration(milliseconds: 300),
    this.showBorderWhenDisabled = true,
    this.disabledBorderColor = const Color(0x33000000),
    this.disabledBorderWidth,
    this.clipChild = false,
    this.autoCloseGradientLoop = true,
    this.glowEffect = false,
    this.glow = const AnimatedGradientBorderGlow(),
  });

  /// The content placed inside the bordered area.
  final Widget child;

  /// Colors used to build the sweep gradient.
  ///
  /// Must contain at least 2 colors.
  final List<Color> colors;

  /// Outer border radius.
  final BorderRadius borderRadius;

  /// Border thickness.
  final double borderWidth;

  /// Duration of one full baseline rotation.
  final Duration turnDuration;

  /// Duration of the one-shot boost phase.
  final Duration boostDuration;

  /// Extra rotation amount (in turns) applied during one-shot boost.
  final double boostTurns;

  /// Fill color of the inner content container.
  final Color innerColor;

  /// Optional outer shadows for the whole bordered widget.
  final List<BoxShadow>? boxShadow;

  /// Optional controller to trigger one-shot boost externally.
  final AnimatedGradientBorderController? controller;

  /// Enables accelerated rotation while this flag is true.
  final bool holdBoostMode;

  /// Additional turns-per-second while [holdBoostMode] is active.
  final double holdBoostTurnsPerSecond;

  /// Enables or disables the animated border with fade transition.
  final bool enabled;

  /// Fade duration used when [enabled] changes.
  final Duration fadeDuration;

  /// Shows a static base border while animated border fades out.
  final bool showBorderWhenDisabled;

  /// Base border color used when [enabled] is false.
  final Color disabledBorderColor;

  /// Optional base border width when [enabled] is false.
  ///
  /// Defaults to [borderWidth] if null.
  final double? disabledBorderWidth;

  /// Clips [child] to the inner rounded shape.
  final bool clipChild;

  /// Auto-appends the first gradient color to the end when needed.
  ///
  /// Useful to remove visible seam in sweep gradients.
  final bool autoCloseGradientLoop;

  /// Enables animated glow halo around the border.
  final bool glowEffect;

  /// Fine-tuning config for [glowEffect].
  final AnimatedGradientBorderGlow glow;

  @override
  State<AnimatedGradientBorder> createState() => _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _boostController;
  late final AnimationController _visibilityController;
  late final AnimationController _glowVisibilityController;
  late final Ticker _holdBoostTicker;
  late final CurvedAnimation _boostAnimation;
  late final CurvedAnimation _visibilityAnimation;
  late final CurvedAnimation _glowVisibilityAnimation;
  late final Listenable _repaint;

  final ValueNotifier<double> _phaseShift = ValueNotifier(0);
  Duration? _lastHoldTickElapsed;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: widget.turnDuration,
    )..repeat();

    _boostController = AnimationController(
      vsync: this,
      duration: widget.boostDuration,
    );

    _boostAnimation = CurvedAnimation(
      parent: _boostController,
      curve: Curves.easeInOutQuint,
    );

    _visibilityController = AnimationController(
      vsync: this,
      duration: widget.fadeDuration,
      value: widget.enabled ? 1 : 0,
    );

    _visibilityAnimation = CurvedAnimation(
      parent: _visibilityController,
      curve: Curves.easeInOut,
    );

    _glowVisibilityController = AnimationController(
      vsync: this,
      duration: widget.glow.fadeDuration,
      value: widget.glowEffect ? 1 : 0,
    );

    _glowVisibilityAnimation = CurvedAnimation(
      parent: _glowVisibilityController,
      curve: widget.glow.fadeCurve,
    );

    _repaint = Listenable.merge([
      _rotationController,
      _boostController,
      _visibilityController,
      _glowVisibilityController,
      _phaseShift,
    ]);

    _boostController.addStatusListener((final status) {
      if (status == AnimationStatus.completed) {
        _phaseShift.value = (_phaseShift.value + widget.boostTurns) % 1;
        _boostController.value = 0;
      }
    });

    _holdBoostTicker = createTicker(_onHoldBoostTick);
    widget.controller?.addListener(_onControllerEvent);
    _applyEnabledState(animate: false);
  }

  @override
  void didUpdateWidget(final AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.turnDuration != widget.turnDuration) {
      _rotationController.duration = widget.turnDuration;
      if (widget.enabled && !_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    }

    if (oldWidget.boostDuration != widget.boostDuration) {
      _boostController.duration = widget.boostDuration;
    }

    if (oldWidget.enabled != widget.enabled) {
      _applyEnabledState(animate: true);
    } else {
      if (widget.enabled && !_rotationController.isAnimating) {
        _rotationController.repeat();
      }
      if (!widget.enabled) {
        if (_rotationController.isAnimating) {
          _rotationController.stop();
        }
        _stopHoldBoost();
      } else if (oldWidget.holdBoostMode != widget.holdBoostMode) {
        if (widget.holdBoostMode) {
          _startHoldBoost();
        } else {
          _stopHoldBoost();
        }
      }
    }

    if (oldWidget.fadeDuration != widget.fadeDuration) {
      _visibilityController.duration = widget.fadeDuration;
    }

    if (oldWidget.glow.fadeDuration != widget.glow.fadeDuration) {
      _glowVisibilityController.duration = widget.glow.fadeDuration;
    }

    if (oldWidget.glow.fadeCurve != widget.glow.fadeCurve) {
      _glowVisibilityAnimation.curve = widget.glow.fadeCurve;
    }

    if (oldWidget.glowEffect != widget.glowEffect) {
      _applyGlowEffectState(animate: true);
    } else if (!widget.glowEffect && _glowVisibilityController.value != 0) {
      _applyGlowEffectState(animate: false);
    }

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerEvent);
      widget.controller?.addListener(_onControllerEvent);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerEvent);
    _holdBoostTicker.dispose();
    _glowVisibilityAnimation.dispose();
    _visibilityAnimation.dispose();
    _boostAnimation.dispose();
    _phaseShift.dispose();
    _glowVisibilityController.dispose();
    _visibilityController.dispose();
    _boostController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _startHoldBoost() {
    _lastHoldTickElapsed = null;
    if (!_holdBoostTicker.isActive) {
      _holdBoostTicker.start();
    }
  }

  void _stopHoldBoost() {
    _lastHoldTickElapsed = null;
    if (_holdBoostTicker.isActive) {
      _holdBoostTicker.stop();
    }
  }

  void _onHoldBoostTick(final Duration elapsed) {
    if (!widget.enabled || !widget.holdBoostMode) {
      _stopHoldBoost();
      return;
    }

    final previous = _lastHoldTickElapsed;
    _lastHoldTickElapsed = elapsed;
    if (previous == null) {
      return;
    }

    final deltaMicros = elapsed.inMicroseconds - previous.inMicroseconds;
    if (deltaMicros <= 0) {
      return;
    }

    final deltaSeconds = deltaMicros / 1000000;
    _phaseShift.value =
        (_phaseShift.value + deltaSeconds * widget.holdBoostTurnsPerSecond) % 1;
  }

  void _onControllerEvent() {
    _triggerBoost();
  }

  void _triggerBoost() {
    if (!widget.enabled) {
      return;
    }

    if (_boostController.isAnimating) {
      _phaseShift.value =
          (_phaseShift.value + _boostAnimation.value * widget.boostTurns) % 1;
      _boostController.stop();
      _boostController.value = 0;
    }

    _boostController.forward(from: 0);
  }

  void _applyEnabledState({required final bool animate}) {
    if (widget.enabled) {
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
      if (widget.holdBoostMode) {
        _startHoldBoost();
      } else {
        _stopHoldBoost();
      }

      if (animate) {
        _visibilityController.duration = widget.fadeDuration;
        _visibilityController.forward();
      } else {
        _visibilityController.value = 1;
      }
      return;
    }

    _stopHoldBoost();
    if (animate) {
      _visibilityController.duration = widget.fadeDuration;
      _visibilityController.reverse().whenComplete(() {
        if (mounted && !widget.enabled) {
          _rotationController.stop();
        }
      });
    } else {
      _visibilityController.value = 0;
      _rotationController.stop();
    }
  }

  void _applyGlowEffectState({required final bool animate}) {
    if (widget.glowEffect) {
      if (animate) {
        _glowVisibilityController.duration = widget.glow.fadeDuration;
        _glowVisibilityController.forward();
      } else {
        _glowVisibilityController.value = 1;
      }
      return;
    }

    if (animate) {
      _glowVisibilityController.duration = widget.glow.fadeDuration;
      _glowVisibilityController.reverse();
    } else {
      _glowVisibilityController.value = 0;
    }
  }

  @override
  Widget build(final BuildContext context) {
    assert(widget.colors.length >= 2,
        'AnimatedGradientBorder requires at least 2 colors.');
    assert(widget.holdBoostTurnsPerSecond >= 0,
        'holdBoostTurnsPerSecond must be >= 0.');
    assert(widget.borderWidth >= 0, 'borderWidth must be >= 0.');
    assert(
      !widget.glow.fadeDuration.isNegative,
      'glow.fadeDuration must be >= Duration.zero.',
    );
    assert(
        widget.disabledBorderWidth == null || widget.disabledBorderWidth! >= 0,
        'disabledBorderWidth must be >= 0.');

    final gradientColors =
        _resolveGradientColors(widget.colors, widget.autoCloseGradientLoop);
    final innerRadius =
        _deflateBorderRadius(widget.borderRadius, widget.borderWidth);

    Widget content = widget.child;
    if (widget.clipChild) {
      content = ClipRRect(
        borderRadius: innerRadius,
        child: content,
      );
    }
    content = DecoratedBox(
      decoration: BoxDecoration(
        color: widget.innerColor,
        borderRadius: innerRadius,
      ),
      child: content,
    );

    final animation = _BorderPaintState(
      repaint: _repaint,
      rotation: _rotationController,
      boost: _boostAnimation,
      phaseShift: _phaseShift,
      boostTurns: widget.boostTurns,
      visibility: _visibilityAnimation,
      glowVisibility: _glowVisibilityAnimation,
      colors: gradientColors,
    );

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: widget.borderRadius,
          boxShadow: widget.boxShadow,
        ),
        child: CustomPaint(
          painter: _AnimatedGradientGlowPainter(
            animation: animation,
            borderRadius: widget.borderRadius,
            glow: widget.glow,
          ),
          foregroundPainter: _AnimatedGradientBorderPainter(
            animation: animation,
            borderWidth: widget.borderWidth,
            borderRadius: widget.borderRadius,
            showBorderWhenDisabled: widget.showBorderWhenDisabled,
            disabledBorderColor: widget.disabledBorderColor,
            disabledBorderWidth:
                widget.disabledBorderWidth ?? widget.borderWidth,
          ),
          child: Padding(
            padding: EdgeInsets.all(widget.borderWidth),
            // Keep the content's display list while the surrounding halo and
            // foreground stroke repaint. Preserve their original paint order.
            child: RepaintBoundary(child: content),
          ),
        ),
      ),
    );
  }
}

class _BorderPaintState {
  _BorderPaintState({
    required this.repaint,
    required this.rotation,
    required this.boost,
    required this.phaseShift,
    required this.boostTurns,
    required this.visibility,
    required this.glowVisibility,
    required this.colors,
  });

  final Listenable repaint;
  final Animation<double> rotation;
  final Animation<double> boost;
  final ValueListenable<double> phaseShift;
  final double boostTurns;
  final Animation<double> visibility;
  final Animation<double> glowVisibility;
  final List<Color> colors;

  Rect? _shaderRect;
  double? _shaderTurns;
  Shader? _shader;

  Shader shader(final Rect rect) {
    final turns =
        (rotation.value + phaseShift.value + boost.value * boostTurns) % 1;
    if (_shaderRect != rect || _shaderTurns != turns) {
      _shaderRect = rect;
      _shaderTurns = turns;
      _shader = SweepGradient(
        colors: colors,
        transform: GradientRotation(turns * math.pi * 2),
      ).createShader(rect);
    }
    return _shader!;
  }
}

class _AnimatedGradientBorderPainter extends CustomPainter {
  _AnimatedGradientBorderPainter({
    required this.animation,
    required this.borderWidth,
    required this.borderRadius,
    required this.showBorderWhenDisabled,
    required this.disabledBorderColor,
    required this.disabledBorderWidth,
  }) : super(repaint: animation.repaint);

  final _BorderPaintState animation;
  final double borderWidth;
  final BorderRadius borderRadius;
  final bool showBorderWhenDisabled;
  final Color disabledBorderColor;
  final double disabledBorderWidth;

  final Paint _stroke = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _baseStroke = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  @override
  void paint(final Canvas canvas, final Size size) {
    final rect = Offset.zero & size;
    final visibleOpacity =
        animation.visibility.value.clamp(0.0, 1.0).toDouble();

    if (showBorderWhenDisabled && disabledBorderWidth > 0) {
      final baseAlpha = (1 - visibleOpacity).clamp(0.0, 1.0).toDouble();
      if (baseAlpha > 0) {
        _baseStroke
          ..strokeWidth = disabledBorderWidth
          ..color = disabledBorderColor
          ..colorFilter = _opacityFilter(baseAlpha);

        final baseRRect = borderRadius.toRRect(
          rect.deflate(disabledBorderWidth * 0.5),
        );
        canvas.drawRRect(baseRRect, _baseStroke);
      }
    }

    if (visibleOpacity <= 0 || borderWidth <= 0) {
      return;
    }

    _stroke
      ..shader = animation.shader(rect)
      ..strokeWidth = borderWidth
      ..colorFilter = _opacityFilter(visibleOpacity);

    final rrect = borderRadius.toRRect(rect.deflate(borderWidth * 0.5));
    canvas.drawRRect(rrect, _stroke);
  }

  @override
  bool shouldRepaint(covariant final _AnimatedGradientBorderPainter old) {
    return old.animation != animation ||
        old.borderWidth != borderWidth ||
        old.borderRadius != borderRadius ||
        old.showBorderWhenDisabled != showBorderWhenDisabled ||
        old.disabledBorderColor != disabledBorderColor ||
        old.disabledBorderWidth != disabledBorderWidth;
  }
}

class _AnimatedGradientGlowPainter extends CustomPainter {
  _AnimatedGradientGlowPainter({
    required this.animation,
    required this.borderRadius,
    required this.glow,
  }) : super(repaint: animation.repaint) {
    _outerPaint
      ..strokeWidth = glow.outerStrokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.outerBlurSigma)
      ..blendMode = glow.blendMode;
    _innerPaint
      ..strokeWidth = glow.innerStrokeWidth
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, glow.innerBlurSigma)
      ..blendMode = glow.blendMode;
  }

  final _BorderPaintState animation;
  final BorderRadius borderRadius;
  final AnimatedGradientBorderGlow glow;

  final Paint _outerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;
  final Paint _innerPaint = Paint()
    ..style = PaintingStyle.stroke
    ..isAntiAlias = true;

  @override
  bool hitTest(final Offset position) => animation.glowVisibility.value > 0;

  @override
  void paint(final Canvas canvas, final Size size) {
    final visibleOpacity =
        (animation.visibility.value.clamp(0.0, 1.0).toDouble() *
                animation.glowVisibility.value.clamp(0.0, 1.0).toDouble() *
                glow.opacity)
            .clamp(0.0, 1.0)
            .toDouble();
    if (visibleOpacity <= 0 ||
        (glow.outerStrokeWidth <= 0 && glow.innerStrokeWidth <= 0)) {
      return;
    }

    final rect = Offset.zero & size;
    final glowRect = rect.inflate(glow.spread);
    final glowRRect = borderRadius.toRRect(glowRect);

    final shader = animation.shader(rect);

    if (glow.outerStrokeWidth > 0) {
      _outerPaint
        ..shader = shader
        ..colorFilter = _opacityFilter(visibleOpacity * 0.45);
      canvas.drawRRect(glowRRect, _outerPaint);
    }

    if (glow.innerStrokeWidth > 0) {
      _innerPaint
        ..shader = shader
        ..colorFilter = _opacityFilter(visibleOpacity);
      canvas.drawRRect(glowRRect, _innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant final _AnimatedGradientGlowPainter old) {
    return old.animation != animation ||
        old.borderRadius != borderRadius ||
        old.glow.opacity != glow.opacity ||
        old.glow.outerBlurSigma != glow.outerBlurSigma ||
        old.glow.innerBlurSigma != glow.innerBlurSigma ||
        old.glow.outerStrokeWidth != glow.outerStrokeWidth ||
        old.glow.innerStrokeWidth != glow.innerStrokeWidth ||
        old.glow.spread != glow.spread ||
        old.glow.blendMode != glow.blendMode ||
        old.glow.fadeDuration != glow.fadeDuration ||
        old.glow.fadeCurve != glow.fadeCurve;
  }
}

ColorFilter _opacityFilter(final double opacity) => ColorFilter.mode(
      // Color.lerp preserves fractional alpha on current Flutter versions and
      // is also available at the package's minimum supported Flutter version.
      Color.lerp(const Color(0x00FFFFFF), Colors.white, opacity)!,
      BlendMode.modulate,
    );

List<Color> _resolveGradientColors(
  final List<Color> colors,
  final bool autoCloseGradientLoop,
) {
  if (!autoCloseGradientLoop || colors.isEmpty) {
    return colors;
  }
  if (colors.first == colors.last) {
    return colors;
  }
  return <Color>[...colors, colors.first];
}

BorderRadius _deflateBorderRadius(
  final BorderRadius borderRadius,
  final double amount,
) {
  Radius deflateRadius(final Radius radius) {
    return Radius.elliptical(
      math.max(0, radius.x - amount),
      math.max(0, radius.y - amount),
    );
  }

  return BorderRadius.only(
    topLeft: deflateRadius(borderRadius.topLeft),
    topRight: deflateRadius(borderRadius.topRight),
    bottomLeft: deflateRadius(borderRadius.bottomLeft),
    bottomRight: deflateRadius(borderRadius.bottomRight),
  );
}
