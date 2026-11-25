# Changelog

Changes are listed here by version. The current build is still alpha, so some client-specific issues may remain.

## 0.5.0-alpha

- Added search across tabs and controls. Open it from the header or with Ctrl+K.
- Added confirmation dialogs. Profile deletion now uses a proper confirmation instead of requiring two clicks.
- Added collapsible sections, progress bars, status rows and `GetDiagnostics()`.
- Added support for Roblox image IDs on window and tab icons.
- Added the fish image to `assets/reefFish-icon.png` and removed the old placeholder. It still needs a Roblox asset ID to display in-game.
- Kept the existing profile format and distribution URL.

Search, dialogs and mobile behaviour still need live testing.

## 0.4.4-alpha

- Replaced nested automatic section sizing with measured group heights to reduce unnecessary layout updates.
- Stopped creating Matrix-rain labels during startup when rain is disabled.
- Added startup logging to the HumuHub loader to help locate crashes.

These changes address possible causes of startup issues. They haven't been confirmed as a complete crash fix.

## 0.4.3-alpha

- Reworked the window styling, title bar and navigation.
- Added grouped settings, consistent spacing and less prominent accent colours.
- Added primary, secondary and danger button variants.
- Added optional descriptions to buttons and toggles.
- Made Matrix rain opt-in and increased the default window size to 600×420.

## 0.4.2-alpha

- Fixed the window jumping when dragging from a scaled position.
- Made the window remember its requested size after the viewport changes.
- Added horizontal tab navigation for narrow screens.
- Changed dropdowns to use virtual scrolling instead of cutting off after 50 options.
- Improved touch handling and cleanup of listeners, flags and theme references.

## 0.4.1-alpha

- Added a resize grip and `SetSize`.
- Improved dropdown positioning and smaller-screen handling.
- Added numeric input validation and automatically sized paragraphs.
- Paused rain rendering while the window is hidden or minimised.

## 0.4.0-alpha

- Reduced the default border thickness to 5px.
- Adjusted the sidebar layout and typography.
- Reworked toggles, sliders and dropdown styling.
- Made colour pickers collapsed by default.

## 0.3.0-alpha

- Added the HSV/HEX/RGB colour picker, keybind modes, multi-dropdowns and paragraphs.
- Added toasts and custom accent colours.
- Expanded profile serialization to support Color3 values and string arrays.
- Kept a pinned build at `dist/reefFish-v0.3.lua`.

## 0.2.0-alpha

- Improved the rain animation, hover states and input focus outlines.
- Added named profiles and appearance settings.
- Added basic filesystem detection with an in-memory fallback.

## 0.1.x

- Initial window, tabs and standard controls.
- Built and revised the inverse-Matrix border effect.
- Added searchable dropdowns and early configuration support.

---

`src/reefFish.luau` is the source file. `dist/reefFish.lua` is the single-file build. Static checks don't replace testing inside Roblox.
