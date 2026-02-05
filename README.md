# animated_border_widgets

A small Flutter package with animated gradient border widgets.

## Features

- Animated sweep-gradient border
- Tap boost animation (temporary acceleration)
- Rounded corners, inner content, and shadow support

## Usage

```dart
import 'package:animated_border_widgets/animated_border_widgets.dart';

AnimatedGradientBorder(
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
  child: const SizedBox(height: 64),
)
```

Call `controller.triggerBoost()` to temporarily speed up rotation.
