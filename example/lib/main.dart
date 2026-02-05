import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const _ExampleApp());
}

class _ExampleApp extends StatelessWidget {
  const _ExampleApp();

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: AnimatedGradientBorder(
              borderRadius: BorderRadius.circular(20),
              borderWidth: 1.8,
              colors: const [
                Color(0xFFED7203),
                Color(0xFFFFA726),
                Color(0xFFFFD54F),
                Color(0xFFFFE0B2),
                Color(0xFFFFB74D),
                Color(0xFFFF8A65),
                Color(0xFFED7203),
              ],
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
              child: const SizedBox(
                height: 64,
                child: Center(
                  child: Text('Animated Border Widget'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
