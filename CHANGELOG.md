# changelog

Short version: what changed, what broke, what's still untested.

## 0.5.0-alpha

- Added global setting search. Header button or Ctrl+K; picks a tab and scrolls to the control.
- Added proper confirm/cancel dialogs. Profile deletion uses one now instead of the double-click thing.
- Added collapsible sections, progress bars, status rows and `GetDiagnostics()`.
- Tabs can have Roblox image icons now.
- Put the new pixel fish in `assets/reefFish-icon.png` and removed the placeholder dot. Needs a Roblox image asset ID before it'll render in-game.
- Kept the same config format and dist URL.
- Search, dialogs and mobile layout still need hands-on testing in Roblox.

## 0.4.4-alpha

- Changed section groups to use a measured height instead of nesting automatic sizing inside a scrolling canvas.
- Stopped building Matrix-rain labels on startup when rain is disabled.
- Added startup checkpoints to the HumuHub loader to narrow down crashes.
- These are crash mitigations, not a confirmed fix for every client crash.

## 0.4.3-alpha

- Redid the window styling: flatter graphite shell, cleaner header, less noisy accent use.
- Grouped related controls instead of stacking a separate card for everything.
- Added shared spacing/type tokens and primary/secondary/danger button variants.
- Buttons and toggles can show descriptions.
- Rain is off by default. Default window moved to 600×420.

## 0.4.2-alpha

- Fixed the title-bar drag jump.
- Window keeps its requested size when the viewport shrinks and restores it when space comes back.
- Added horizontal tabs for small windows.
- Virtualized dropdown rows. The old 50-result cutoff is gone.
- Improved touch tracking and cleaned up control listeners, flags and theme bindings on destroy.

## 0.4.1-alpha

- Added window resize grip and `SetSize`.
- Improved viewport fit, dropdown positioning, numeric input validation and paragraph auto-height.
- Stopped rain updates while hidden/minimized; added columns when resizing.
- Added more cases to the Studio demo.

## 0.4.0-alpha

- Cut the thick border down to 5px.
- Reworked sidebar/content proportions and typography.
- Switched toggles to proper switches and tightened up sliders and dropdowns.
- Colour picker starts folded instead of filling the panel.

## 0.3.0-alpha

- Colour picker (HSV/HEX/RGB), keybind modes, multi-dropdowns and paragraph cards.
- Added toasts and custom accent colours.
- Configs started saving Color3 and string arrays. Profile schema stayed at v1.
- Kept the pinned `dist/reefFish-v0.3.lua` build.

## 0.2.0-alpha

- Improved the rain animation and control hover/focus states.
- Added appearance controls and named profile management.
- Added basic filesystem detection with in-memory fallback.

## 0.1.x

- First window, tabs and standard controls.
- Built the inverted Matrix border and later switched it to a single vertical masked rain field.
- Searchable dropdowns, initial config storage and cleanup work.

---

`src/reefFish.luau` is the editable source; `dist/reefFish.lua` is the current single-file build. Old pinned builds are kept separate. Syntax/static checks aren't a substitute for testing in Roblox.
