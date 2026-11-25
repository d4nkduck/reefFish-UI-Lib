# Changelog

## 0.4.2-alpha — Stabilization and lifecycle fixes

- Correct title dragging so scaled initial window coordinates no longer cause a jump.
- Keep requested window dimensions separate from temporary viewport fit; restore on viewport expansion.
- Add horizontal scrollable tabs for narrow windows and responsive RGB colour picker inputs.
- Replace the 50-option dropdown cutoff with a virtualized row pool and full-list scrolling.
- Track touch identities for sliders and colour picker; ignore unrelated fingers.
- Explicitly disconnect viewport watchers on destroy, and clean control-owned input events, flags, keybinds and theme bindings when removed.
- Hide the status bar while minimized; adapt toast placement to smaller viewports.
- Refresh the Studio smoke test with 120 options, control deletion and theme switching.
- Preserve the same stable `dist/reefFish.lua` loader and existing public component APIs.
- Static structural validation passed. Real Roblox Studio/mobile rendering and input tests are still outstanding.

## 0.4.1-alpha — Usability and reliability pass

- Add draggable bottom-right resize grip, public `SetSize`, viewport clamping and adaptive sidebar widths.
- Make dragging and resizing handle mouse and touch input while preventing title-bar action clicks from moving the window.
- Constrain dropdown popups to the viewport, cap rendered search results at 50, and retain multi-select scroll position.
- Improve numeric input validation, focused/disabled feedback and avoid duplicate unchanged-value callbacks.
- Auto-size paragraph text when `Height` is not explicitly set.
- Expand Matrix rain columns when resizing and pause background rendering while the UI is hidden or minimized.
- Preserve existing component, profile and loader APIs. The stable distribution remains `dist/reefFish.lua`.
- Update Studio smoke demo. Static syntax checks passed; live Roblox runtime testing is still pending.

## 0.4.0-alpha — Refinement before differentiation

- Slimmed the default inverse-Matrix bezel from 12 px to 5 px (range now 3–16 px) and softened the default rain density and speed.
- Rebalanced the window into a cleaner title bar, less dominant sidebar, and wider content area, with a visible selected-tab marker.
- Replaced heavy console-only typography with readable Gotham UI labels and compact sections, cards, and actions.
- Redesigned toggles as animated switches; gave sliders separate value readouts and a larger invisible drag target.
- Refined dropdowns, including multi-select highlighting, shorter inputs, and more consistent toasts.
- Made the colour picker **collapsed by default**, with title/swatch click-to-expand and optional `Expanded=true` / `:SetExpanded(bool)` support.
- Kept existing control method names, profile flag persistence, themes, keybind handling and inverse-Matrix renderer.
- Continued shipping through stable `dist/reefFish.lua`; older pinned v0.3 distribution remains unchanged.
- Static syntax/balance and compatibility checks passed. Live Roblox rendering must be tested in a compatible client.

## 0.3.0-alpha — Advanced components and interaction layer

- Implemented original colour picker with HSV square, hue bar, hexadecimal input, live swatch and Color3 API.
- Implemented keyboard capture and keybinds with Press/Toggle/Hold modes, one shared input dispatcher and show/hide hotkey.
- Added searchable multi-select dropdowns with array return values.
- Added title-and-body paragraphs, more consistent component visibility and disabled methods.
- Added capped animated toast notifications, timed dismissal and integration with status messages.
- Added custom accent colour editing to Appearance tab; preserved existing themes and vertical inverse Matrix border.
- Extended JSON config serialization for Color3 values and arrays of selected options; kept schema v1 compatibility.
- Added `examples/components-v0.3.luau` demonstration/smoke-test and unique `dist/reefFish-v0.3.lua` distribution.

## 0.2.0-alpha — Interaction polish and named profile manager

- Smoothed inverse-Matrix fading: near-black head at the bottom of each falling stream, lighter characters trailing into the green border.
- Reduced whole-stream character flicker by changing fewer glyphs per update.
- Added centralized hover/pressed interactions, slider thumb, rounded tracks, and input focus outlines.
- Added live border thickness adjustment, rain density/speed sliders and a complete builtin Appearance controls panel.
- Added profile browsing, save/load, rename, delete with confirmation, JSON text-area import/export and optional clipboard export.
- Added 1-second debounced autosave while the window is open; explicit loading remains manual.
- Added read/write/list/delete filesystem capability detection, graceful memory fallback, schema and game-ID validation.
- Kept source and distribution as a single-file Lua module; pinned loader also published as `dist/reefFish-v0.2.lua`.
- Still alpha: not yet verified in every Roblox client/Xeno version.

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