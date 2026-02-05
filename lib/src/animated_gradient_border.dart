import 'dart:math' as math;

import 'package:flutter/material.dart';

class AnimatedGradientBorderController extends ChangeNotifier {
  void triggerBoost() {
    notifyListeners();
  }
}

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
  });

  final Widget child;
  final List<Color> colors;
  final BorderRadius borderRadius;
  final double borderWidth;
  final Duration turnDuration;
  final Duration boostDuration;
  final double boostTurns;
  final Color innerColor;
  final List<BoxShadow>? boxShadow;
  final AnimatedGradientBorderController? controller;

  @override
  State<AnimatedGradientBorder> createState() =>
      _AnimatedGradientBorderState();
}

class _AnimatedGradientBorderState extends State<AnimatedGradientBorder>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _boostController;
  late Animation<double> _boostAnimation;
  double _phaseShift = 0;

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

    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onControllerEvent);
      widget.controller?.addListener(_onControllerEvent);
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onControllerEvent);
    _boostController.dispose();
    _rotationController.dispose();
    super.dispose();
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
