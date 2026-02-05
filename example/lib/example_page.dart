import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

import 'widgets/demo_bottom_bar_card.dart';
import 'widgets/hold_boost_button.dart';
import 'widgets/reveal_animated_border_button.dart';
import 'widgets/tap_boost_button.dart';

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  final AnimatedGradientBorderController _barController =
      AnimatedGradientBorderController();
  final AnimatedGradientBorderController _tapButtonController =
      AnimatedGradientBorderController();

  int _selectedDemoTab = 0;

  static const List<Color> _barPalette = [
    Color(0xFFFF6B35),
    Color(0xFFFFA451),
    Color(0xFFFFD77A),
    Color(0xFFFFF1C8),
    Color(0xFFFFC58F),
    Color(0xFFFF7E63),
    Color(0xFFFF6B35),
  ];

  static const List<Color> _tapPalette = [
    Color(0xFFEF476F),
    Color(0xFFFF7B9C),
    Color(0xFFFFC2D3),
    Color(0xFFFFE7EE),
    Color(0xFFFFA2B8),
    Color(0xFFF45B8A),
    Color(0xFFEF476F),
  ];

  static const List<Color> _holdPalette = [
    Color(0xFF118AB2),
    Color(0xFF39A9DB),
    Color(0xFF7FD0F5),
    Color(0xFFB3D5E8),
    Color(0xFF6EC6E8),
    Color(0xFF1A97C4),
    Color(0xFF118AB2),
  ];

  static const List<Color> _revealPalette = [
    Color(0xFF6A4C93),
    Color(0xFF8A6FB5),
    Color(0xFFB8A0DD),
    Color(0xFFC8B2EC),
    Color(0xFFA98ED1),
    Color(0xFF7C62A8),
    Color(0xFF6A4C93),
  ];

  @override
  void dispose() {
    _barController.dispose();
    _tapButtonController.dispose();
    super.dispose();
  }

  void _onDemoTabPressed(final int index) {
    if (_selectedDemoTab != index) {
      setState(() {
        _selectedDemoTab = index;
      });
    }
    _barController.triggerBoost();
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFF7F3EE),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DemoBottomBarCard(
                    controller: _barController,
                    selectedIndex: _selectedDemoTab,
                    onTabPressed: _onDemoTabPressed,
                    palette: _barPalette,
                  ),
                  const SizedBox(height: 20),
                  TapBoostButton(
                    controller: _tapButtonController,
                    palette: _tapPalette,
                  ),
                  const SizedBox(height: 12),
                  const HoldBoostButton(
                    palette: _holdPalette,
                  ),
                  const SizedBox(height: 12),
                  const RevealAnimatedBorderButton(
                    palette: _revealPalette,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
