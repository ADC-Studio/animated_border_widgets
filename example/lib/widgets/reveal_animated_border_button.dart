import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

class RevealAnimatedBorderButton extends StatefulWidget {
  const RevealAnimatedBorderButton({
    required this.palette,
    super.key,
  });

  final List<Color> palette;

  @override
  State<RevealAnimatedBorderButton> createState() =>
      _RevealAnimatedBorderButtonState();
}

class _RevealAnimatedBorderButtonState extends State<RevealAnimatedBorderButton> {
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
        child: SizedBox(
          height: 52,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  opacity: _isPressed ? 0 : 1,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFFBDBDBD),
                        width: 1.8,
                      ),
                    ),
                  ),
                ),
              ),
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  opacity: _isPressed ? 1 : 0,
                  child: AnimatedGradientBorder(
                    holdBoostMode: _isPressed,
                    holdBoostTurnsPerSecond: 1.0,
                    borderRadius: BorderRadius.circular(16),
                    borderWidth: 1.8,
                    innerColor: Colors.white,
                    colors: widget.palette,
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              Center(
                child: Text(
                  _isPressed
                      ? 'Hold: Animated border'
                      : 'Hold: Reveal animated border',
                  style: TextStyle(
                    color: _isPressed
                        ? const Color(0xFF4A2A1A)
                        : const Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
