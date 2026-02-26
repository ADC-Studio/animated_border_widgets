import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

class TapBoostButton extends StatelessWidget {
  const TapBoostButton({
    required this.controller,
    required this.palette,
    super.key,
  });

  final AnimatedGradientBorderController controller;
  final List<Color> palette;

  @override
  Widget build(final BuildContext context) => AnimatedGradientBorder(
        controller: controller,
        borderRadius: BorderRadius.circular(16),
        borderWidth: 1.8,
        glowEffect: true,
        colors: palette,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFFB5542B),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: controller.triggerBoost,
            child: const Text('Tap: Trigger Boost'),
          ),
        ),
      );
}
