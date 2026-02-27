import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

class HoldBoostButton extends StatefulWidget {
  const HoldBoostButton({
    required this.palette,
    super.key,
  });

  final List<Color> palette;

  @override
  State<HoldBoostButton> createState() => _HoldBoostButtonState();
}

class _HoldBoostButtonState extends State<HoldBoostButton> {
  bool _isPressed = false;

  void _setPressed(final bool value) {
    if (_isPressed == value) {
      return;
    }
    setState(() {
      _isPressed = value;
    });
  }

  @override
  Widget build(final BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedGradientBorder(
          holdBoostMode: _isPressed,
          glowEffect: _isPressed,
          holdBoostTurnsPerSecond: 0.9,
          borderRadius: BorderRadius.circular(16),
          borderWidth: 1.8,
          colors: widget.palette,
          child: SizedBox(
            height: 52,
            child: Center(
              child: Text(
                _isPressed ? 'Hold: Boost active' : 'Hold: Boost mode',
                style: const TextStyle(
                  color: Color(0xFFB5542B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      );
}
