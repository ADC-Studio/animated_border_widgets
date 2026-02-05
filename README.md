<!-- markdownlint-disable MD041 MD033 -->

<br>

<div align="center">
    <h1 align="center">Animated Border Widgets</h1>
    <p align="center">
        <strong>
        Animated gradient border widgets for Flutter, with smooth continuous rotation, one-shot boost on demand, and optional press-and-hold acceleration mode.
        </strong>
    </p>

<br>
  <p align="center">
  <a href="https://github.com/ADC-Studio/animated_border_widgets/releases">
    <img src="https://img.shields.io/pub/v/animated_border_widgets" alt="Release" />
  </a>
    <a href="https://flutter.dev">
      <img src="https://img.shields.io/badge/Platform-Flutter-02569B?logo=flutter"
        alt="Platform" />
    </a>
    <a href="https://opensource.org/licenses/MIT">
      <img src="https://img.shields.io/github/license/codenameakshay/flutter-floating-bottom-bar?color=red"
        alt="License: MIT" />
    </a>
  </p>

 <img src="https://raw.githubusercontent.com/ADC-Studio/animated_border_widgets/main/assets/animated_border_widgets_demo_1.gif" alt="Logo" />
</div>

## Features

- Animated sweep-gradient border
- One-shot boost via `controller.triggerBoost()`
- Press-and-hold boost via `holdBoostMode`
- Smooth phase continuity (no jump back after boost)
- Rounded corners, configurable border width, inner color, and shadows

## Bottom Bar Demo

![Bottom bar demo](https://raw.githubusercontent.com/ADC-Studio/animated_border_widgets/main/assets/animated_border_widgets_demo_2.gif)

## Installation

```yaml
dependencies:
  animated_border_widgets: ^0.1.0
```

## Quick Start

```dart
import 'package:animated_border_widgets/animated_border_widgets.dart';
import 'package:flutter/material.dart';

class Demo extends StatefulWidget {
  const Demo({super.key});

  @override
  State<Demo> createState() => _DemoState();
}

class _DemoState extends State<Demo> {
  final controller = AnimatedGradientBorderController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedGradientBorder(
      controller: controller,
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
      child: SizedBox(
        height: 56,
        child: ElevatedButton(
          onPressed: controller.triggerBoost,
          child: const Text('Boost'),
        ),
      ),
    );
  }
}
```

## Hold Boost Mode

Use `holdBoostMode` for press-and-hold interactions:

```dart
AnimatedGradientBorder(
  holdBoostMode: isPressed,
  holdBoostTurnsPerSecond: 0.9,
  colors: palette,
  child: const SizedBox(height: 52),
)
```

## API Overview

- `AnimatedGradientBorder`
  - `colors`
  - `borderRadius`
  - `borderWidth`
  - `turnDuration`
  - `boostDuration`
  - `boostTurns`
  - `holdBoostMode`
  - `holdBoostTurnsPerSecond`
  - `innerColor`
  - `boxShadow`
  - `controller`
- `AnimatedGradientBorderController`
  - `triggerBoost()`

This keeps images visible in pub.dev README while excluding local `assets/` files from the published package archive.

## Example

See the complete demo in `example/`:

- Demo bottom bar
- Tap boost button
- Hold boost button
- Gray border -> animated border reveal on hold

## License

MIT License. See [LICENSE](LICENSE).

## How to Contribute

To get started, read [CONTRIBUTING.md](CONTRIBUTING.md) to learn about the guidelines within this project.

## Changelog

[Refer to the Changelog to get all release notes.](/CHANGELOG.md)

## Maintainers

[ADC STUDIO](https://adc-web.ru)

[Valerij Shishov](https://github.com/MixKage)

This library is open for issues and pull requests. If you have ideas for improvements or bugs, the repository is open to contributions!
