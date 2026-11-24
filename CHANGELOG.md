# Changelog

## 0.1.3-alpha — Vertical rain field and uncached diagnostic build

- Replaced per-glyph position updates with one multiline rich-text label per falling column.
- Full-window vertical code streams are masked by the central panel and exposed in the bezel only.
- Global background drift is extremely slow, moving right at 0.18–0.48 pixels/second; the main movement is always down.
- Added persistent visible version markers and the distinct `dist/reefFish-v0.1.3.lua` entry point.
- Reduced the per-frame UI-object update overhead and preserved searching dropdowns.

## 0.1.2-alpha — Unified vertical Matrix rain

- Replaced edge-specific motion with a single masked falling-code backdrop.
- All trails fall vertically, with a slow, continuous rightward drift across the full window.
- Kept the slim bezel, dark-on-green inverse style, katakana/digits and fading head-and-tail streams.
- Capped updates at ~10 Hz, reusing existing TextLabel instances.
- Preserved searchable dropdowns, appearance settings and configuration APIs.

## 0.1.1-alpha — Bezel and dropdown refinement

- Reduced default border from 18px to 12px; supports `BorderThickness` (9–16px).
- Replaced independent drifting characters with directional streams, heads and fading trails.
- Added a larger katakana and digit glyph set for the inverse Matrix effect.
- Replaced cycling dropdowns with a searchable popup and scrollable option list.
- Added `Dropdown:SetOptions()` and improved window re-execution cleanup.
- Kept animations throttled with no per-frame object creation.

## 0.1.0-alpha — Initial prototype

- Inverse Matrix console frame and 5 themes
- Draggable/minimizable window, tabs, labels, buttons, toggles, sliders, dropdowns, text inputs
- Appearance and game profile persistence adapters with JSON validation
- Cleanup and throttled animation architecture
- Roblox Studio and loader-compatible usage examples

This release is a foundation, not a feature-complete alternative to established Roblox UI libraries.