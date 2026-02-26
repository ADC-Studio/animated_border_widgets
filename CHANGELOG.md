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
