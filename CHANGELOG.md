## 0.2.1

- Repaint animated borders and glow directly without rebuilding or laying out their widget trees on every animation frame.
- Isolate child content from border repaints with a dedicated repaint boundary.
- Reuse the sweep-gradient shader across both glow layers and reuse glow paint configuration between frames.
- Keep the existing two-layer glow, animation controls, fade transitions, and public API.
- Restore compatibility with the declared Flutter 3.22 minimum by using compatible color APIs.
- Add regression coverage for animation repaint behavior and lifecycle transitions.
- Add CI checks on current stable Flutter and Flutter 3.22.3, plus a publication dry run.

## 0.2.0

- Added configurable `glowEffect` with `AnimatedGradientBorderGlow`.
- Added `enabled` + `fadeDuration` for fadeable border visibility.
- Added disabled-state border options:
  - `showBorderWhenDisabled`
  - `disabledBorderColor`
  - `disabledBorderWidth`
- Added `clipChild` to clip inner content by border radius.
- Added `autoCloseGradientLoop` for seamless sweep-gradient loops.
- Refactored border rendering to `CustomPaint` for glow and fade support.
- Expanded tests for glow, disabled mode, and clipping.
- Raised minimum environment to Dart `>=3.3.0` and Flutter `>=3.22.0`.

## 0.1.0

- Initial release with `AnimatedGradientBorder` and boost-capable controller.
- Added hold boost mode via `holdBoostMode` and `holdBoostTurnsPerSecond`.
- Updated example with tap boost, hold boost, and opacity-based animated border reveal.
