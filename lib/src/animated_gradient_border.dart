import 'dart:math' as math;

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

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _boostController;
  late final Ticker _holdBoostTicker;
  late Animation<double> _boostAnimation;

  double _phaseShift = 0;
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

    _boostController.addStatusListener((final status) {
      if (status == AnimationStatus.completed) {
        _phaseShift = (_phaseShift + widget.boostTurns) % 1;
        _boostController.value = 0;
      }
    });

    _holdBoostTicker = createTicker(_onHoldBoostTick);
    if (widget.holdBoostMode) {
      _startHoldBoost();
    }

    widget.controller?.addListener(_onControllerEvent);
  }

  @override
  void didUpdateWidget(final AnimatedGradientBorder oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.turnDuration != widget.turnDuration) {
      _rotationController.duration = widget.turnDuration;
      if (!_rotationController.isAnimating) {
        _rotationController.repeat();
      }
    }

    if (oldWidget.boostDuration != widget.boostDuration) {
      _boostController.duration = widget.boostDuration;
    }

    if (oldWidget.holdBoostMode != widget.holdBoostMode) {
      if (widget.holdBoostMode) {
        _startHoldBoost();
      } else {
        _stopHoldBoost();
      }
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
    if (!widget.holdBoostMode) {
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
    _phaseShift =
        (_phaseShift + deltaSeconds * widget.holdBoostTurnsPerSecond) % 1;
    if (mounted) {
      setState(() {});
    }
  }

  void _onControllerEvent() {
    _triggerBoost();
  }

  void _triggerBoost() {
    if (_boostController.isAnimating) {
      _phaseShift =
          (_phaseShift + _boostAnimation.value * widget.boostTurns) % 1;
      _boostController.stop();
      _boostController.value = 0;
    }

    _boostController.forward(from: 0);
  }

  @override
  Widget build(final BuildContext context) {
    assert(widget.colors.length >= 2,
        'AnimatedGradientBorder requires at least 2 colors.');
    assert(widget.holdBoostTurnsPerSecond >= 0,
        'holdBoostTurnsPerSecond must be >= 0.');

    final innerRadius = BorderRadius.only(
      topLeft: Radius.circular(
        math.max(0, widget.borderRadius.topLeft.x - widget.borderWidth),
      ),
      topRight: Radius.circular(
        math.max(0, widget.borderRadius.topRight.x - widget.borderWidth),
      ),
      bottomLeft: Radius.circular(
        math.max(0, widget.borderRadius.bottomLeft.x - widget.borderWidth),
      ),
      bottomRight: Radius.circular(
        math.max(0, widget.borderRadius.bottomRight.x - widget.borderWidth),
      ),
    );

    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _boostController]),
      builder: (final context, final child) {
        final turns = (_rotationController.value +
                _phaseShift +
                _boostAnimation.value * widget.boostTurns) %
            1;

        return Container(
          padding: EdgeInsets.all(widget.borderWidth),
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: SweepGradient(
              colors: widget.colors,
              transform: GradientRotation(turns * math.pi * 2),
            ),
            boxShadow: widget.boxShadow,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.innerColor,
              borderRadius: innerRadius,
            ),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
