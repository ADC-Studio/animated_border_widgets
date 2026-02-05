import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

class DemoBottomBarCard extends StatelessWidget {
  const DemoBottomBarCard({
    required this.controller,
    required this.selectedIndex,
    required this.onTabPressed,
    required this.palette,
    super.key,
  });

  final AnimatedGradientBorderController controller;
  final int selectedIndex;
  final ValueChanged<int> onTabPressed;
  final List<Color> palette;

  static const List<IconData> _outlinedIcons = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.person_outline,
  ];

  static const List<IconData> _filledIcons = [
    Icons.home,
    Icons.search,
    Icons.person,
  ];

  static const List<String> _tabLabels = [
    'Home',
    'Search',
    'Account',
  ];

  @override
  Widget build(final BuildContext context) => AnimatedGradientBorder(
        controller: controller,
        borderRadius: BorderRadius.circular(20),
        borderWidth: 1.8,
        colors: palette,
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_tabLabels.length, (final index) {
              final isSelected = index == selectedIndex;
              final color =
                  isSelected ? const Color(0xFFED7203) : const Color(0xFF777498);
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTabPressed(index),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? _filledIcons[index] : _outlinedIcons[index],
                        size: 22,
                        color: color,
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.only(top: 3),
                          child: Text(
                            _tabLabels[index],
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFED7203),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      );
}
