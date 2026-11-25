# reefFish UI Lib 🐟

**Version:** 0.4.3-alpha  
**License:** MIT  
**Status:** Visual system alpha — existing component APIs remain compatible

A modern Roblox Luau UI library with grouped settings, deliberate typography and an optional inverse-Matrix border. Built for game debug tooling and reusable in client-side Roblox Studio projects.

This is an **early alpha**, not a production-hardened full-featured library. No external requests or third-party modules are needed to display its UI. Both the source and single-file build are included.

## Refinement priorities

The interface must look complete without visual effects. Shared design tokens govern spacing, typography, corners and control sizes. Matrix rain is optional and off by default; the five themes remain available.

## What works today

- Draggable/resizable window with tracked mouse/touch gestures, restore-on-grow sizing, horizontal mobile tabs, minimize/close, status line and toasts
- Slim (4 px default, configurable 3–16 px) matte frame. Inverse-Matrix border rain is available with `Rain=true` or via the Appearance tab, up to ~10 Hz
- Five colour themes: MatrixInverse, ClassicCRT, AmberTerminal, IceConsole and Monochrome
- UI controls: tabs, sections, labels, buttons, toggles, sliders with handles, searchable single/multi-select dropdowns, colour picker (HSV/HEX), keybinds (Press/Toggle/Hold), paragraphs and text inputs
- Built-in Appearance and Profiles tabs with named profile management, editable accent colour and JSON import/export (unless disabled)
- Grouped settings surfaces, button variants, optional descriptions, focused inputs, restrained hover feedback and themed slider handles
- Appearance editor: theme, rain toggle, density, speed and live border thickness (3–16px)
- Profile browsing, named save/load, rename/delete with confirmation, JSON import/export and optional debounced autosave
- Capped, animated on-screen toast notifications, built-in status line and safe component callback dispatch with `pcall`
- Show/hide hotkey (RightShift default, configurable via `ToggleKey`) with a shared input dispatcher
- Game configuration profiles and independently stored appearance profiles. Flags now persist Color3 and string-array values in addition to primitive values
- Best-effort storage adapter for environments with `writefile`/`readfile`/`makefolder`; in-memory fallback in normal clients
- Namespaced profiles by Roblox `game.GameId`, JSON-encoded with HttpService
- Config loading **does not run user callbacks by default**
- Cleanup of input listeners, keybinds, saved flags and theme references when controls or the window close

## What is planned, not implemented

Still planned: full phone/tablet usability validation, accessibility and keyboard navigation for all controls, graphs, richer log drawer, notification actions, automated tests across Roblox clients, multi-window support, cross-session auto-load and custom theme import/export. The window now also restores its requested size after temporary viewport shrinkage, but real mobile testing is still outstanding.

## Installation (Roblox Studio)

1. Copy `src/reefFish.luau` into a **ModuleScript** named `ReefFish` inside `ReplicatedStorage`.
2. Create a **LocalScript** inside `StarterPlayer > StarterPlayerScripts`.
3. Paste `examples/basic.luau` into that LocalScript.
4. Run Play mode. The sample window will appear.

The library should run on the **client**, not as a Script inside `ServerScriptService`.

## Installation (compatible Lua loader)

Use the stable distribution URL below in a compatible Lua environment. **Normal Roblox Studio LocalScripts do not support this remote loadstring mechanism**; use `require()` for Studio.

```lua
local ReefFish = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/dist/reefFish.lua"
))()
```

The `dist/reefFish.lua` URL stays the same for future updates. Old version-pinned releases remain separate for compatibility.

## Minimal usage

```lua
local ReefFish = require(game.ReplicatedStorage.ReefFish)
local win = ReefFish:CreateWindow({Title = "My Game Tools", Theme = "MatrixInverse"})
local tab = win:CreateTab({Name = "DEBUG"})

tab:CreateToggle({
    Name = "Show markers", Flag = "markers.enabled", Default = false,
    Callback = function(enabled)
        print("Markers:", enabled)
    end
})

local ok, reason = win.Config:Save("my-profile")
print(ok, reason)
```

## Controls API

`window:CreateTab({Name="NAME"})` → tab

- `tab:CreateSection("TEXT")`
- `tab:CreateLabel({Text="TEXT"})` → `:SetText(text)`
- `tab:CreateButton({Name="NAME", Variant="Secondary", Description="Optional detail", Callback=function() end})` → `:SetDisabled(bool)`. Variants: `Primary`, `Secondary` (default), `Danger`.
- `tab:CreateToggle({Name="NAME", Description="Optional detail", Flag="unique-id", Default=false, Callback=function(bool) end})` → `:Get()`, `:Set(bool, fireCallback)`
- `tab:CreateSlider({Name="NAME", Flag="unique-id", Min=0, Max=100, Increment=1, Default=25, Callback=function(number) end})` → `:Get()`, `:Set(number, fireCallback)`
- `tab:CreateDropdown({Name="NAME", Flag="unique-id", Options={"A","B"}, Default="A", Callback=function(string) end})` → `:Get()`, `:Set(value, fireCallback)`
- `tab:CreateInput({Name="NAME", Flag="unique-id", Default="text", Numeric=false, Callback=function(string) end})` → `:Get()`, `:Set(value, fireCallback)`
- `tab:CreateParagraph({Title="Help", Content="Long explanation"})` → `:Set(title,content)`; auto-height is the default, and `Height=96` opts into a fixed-height card
- `tab:CreateColorPicker({Name="Tint", Flag="tint", Default=Color3.fromRGB(0,255,120), Callback=function(color3) end})` → `:Get()`, `:GetHex()`, `:GetRGB()`, `:Set(Color3 or "#RRGGBB", fireCallback)`, `:SetRGB(r,g,b,fireCallback)`, `:SetExpanded(bool)`. The editor is collapsed by default; use `Expanded=true` to open it initially.
- `tab:CreateMultiDropdown({Name="Filters", Flag="filters", Options={"A","B"}, Default={"A"}, Callback=function(array) end})` → `:Get()`, `:Set(array, fireCallback)`
- `tab:CreateKeybind({Name="Overlay key", Flag="overlay.key", Default="F6", Mode="Toggle", Callback=function(active,keyName) end})` → `:Get()`, `:Set(keyName, fireChangeCallback)`
- `tab:CreateTextArea({Name="JSON", Height=120})` → `:Get()`, `:Set(text)`

Window methods: `:SetSize(width,height)` or `:SetSize(Vector2)`, `:SetTheme(name)`, `:SetAccentColor(Color3 or hex)`, `:SetRain(enabled, density, speed)`, `:Notify(text, kind)`, `:Toast({Title,Content,Duration})`, `:SetMinimized(bool)`, `:SetHidden(bool)`, `:SelectTab(tab)`, `:Destroy()`. Most interactive component handles expose `:SetVisible(bool)`, `:SetDisabled(bool)` and `:Destroy()`.

## Configuration API

| Action | Method |
|---|---|
| Save game values | `win.Config:Save("name")` |
| Load game values | `win.Config:Load("name")` |
| Load and explicitly fire callbacks | `win.Config:Load("name", {FireCallbacks=true})` |
| Export game values as JSON | `win.Config:Export()` |
| Import JSON | `win.Config:Import(json)` |
| Save appearance | `win.Appearance:Save("name")` |
| Load appearance | `win.Appearance:Load("name")` |

**Important:** auto-execution of actions is off on load. Only controls with a `Flag` are persisted. Script authors should not treat saved JSON as trusted code: ReefFish only decodes JSON values and never executes them.

Profiles are stored in the following relative paths when compatible file APIs are available:

```text
reefFishUI/
├── appearance/
│   └── default.json
└── games/
    └── <game.GameId>/
        └── default.json
```

When filesystem functions aren't available, saves work only inside the current window session, and `win.StorageMode` reports `"memory"`. This behavior is intentional and avoids dependency on executor-specific APIs.

**Executor compatibility is best effort:** Some hosts provide filesystem functions with different restrictions. Filesystem writes are protected with `pcall`; not every device or executor version has been tested.

## Performance design

- One capped Heartbeat animation updater per window; no per-glyph render loops.
- Fixed pool of glyph labels in clipped border strips; no per-frame instance allocations.
- Effect pauses when disabled/minimized, and connections are disconnected on `:Destroy()`.
- Rain effect is cosmetic and never intercepts UI interaction.

## Contributing

Issues and pull requests are welcome when the GitHub repository is published. Keep changes dependency-free when feasible, add a short example for new public APIs, and avoid breaking existing component flags or profile formats without a schema migration.

## License

MIT. See `LICENSE`.
## v0.4.3 visual system

- Redesigned the workspace around a neutral matte frame, spacious header and more readable 600×420 default layout.
- Section headings now create **shared grouped settings surfaces** instead of stacking a separate card for every control.
- Standardised typography, spacing, corner radii, heights, field borders and subtler interactive states with `ReefFish.Design` tokens.
- Added action variants (`Primary`, `Secondary`, `Danger`) and optional `Description` text on buttons and toggles.
- Restyled sliders, dropdowns, inputs, colour picker, keybinds, notifications and navigation to share the same visual language.
- Rebalanced the five themes. Matrix rain is **off by default** and can be enabled with `Rain=true`; the border remains available without dominating the interface.
- Kept constructors, public component methods, existing saved profile formats and `dist/reefFish.lua` unchanged in structure. Roblox rendering still needs an in-game visual review.

## v0.4.2 stability pass

- **No jumping on drag:** title-bar dragging uses the actual pixel position.
- **Reversible resizing:** the window remembers the requested dimensions when a phone/tablet viewport temporarily shrinks.
- **Mobile navigation:** a horizontal, scrollable tab rail replaces the vertical sidebar at widths below 420px. The colour picker's RGB inputs also resize.
- **Large dropdowns:** virtual scrolling reuses visible option buttons, with no arbitrary 50-item cutoff. Search and multi-selection remain.
- **Touch handling:** slider and colour picker gestures track the originating touch instead of responding to unrelated fingers.
- **Cleanup:** destroyed controls remove their event listeners, profile flags, keybind registrations and theme-feedback references. Destroying a window explicitly disconnects the viewport watcher.
- **Polish:** the minimized status bar no longer overlaps the header; keybind, text-area and colour-picker fields follow the chosen theme.
- **Validation:** use `examples/basic.luau` to test 120-option scrolling, resizing, profile flags and theme changes. Static checks passed; **Roblox-runtime validation remains pending**.

## v0.4.1 usability pass

- **Resize:** drag the bottom-right grip, or call `window:SetSize(width,height)`.
- **Viewport:** the window clamps to available screen space and uses a narrower sidebar on small screens. Existing tab and component APIs are unchanged.
- **Dropdowns:** caps visible option controls at 50 per search, supports Enter to pick the first match and retains scrolling during multi-select.
- **Inputs:** numeric fields restore the last valid value when invalid and show an explanatory warning; disabled and focus feedback is clearer.
- **Paragraphs:** automatically expand with wrapped text unless `Height` is specified.
- **Matrix rendering:** pauses while hidden/minimized and grows its columns as the window is enlarged.
- **Testing:** `examples/basic.luau` includes a resize button, numeric-input assertions, auto-height paragraph and large-dropdown smoke test. Actual Roblox visual testing remains necessary.

## v0.4 visual refinement

- A thinner 5 px default bezel, with the original Matrix rain retained as a theme accent.
- Clean two-line title bar, slimmer sidebar, selected-tab indicator, and more room for controls.
- Gotham typography, compact section labels, flatter cards, lighter hover states, and smoother toggles.
- Slider values on the right with a larger invisible hit target; improved dropdown selection feedback.
- Colour picker collapsed by default. Click its title or colour swatch to expand the HSV/HEX/RGB editor.
- No breaking changes to tab constructors, control flags, profile data, configuration APIs, or HumuHub.

**Compatibility:** `src/reefFish.luau` and `dist/reefFish.lua` represent the current development build. Version-pinned legacy releases are retained separately and do not change.

**Testing:** Static source checks and source/distribution equality are verified before publishing. Roblox Studio and third-party client rendering still require a live in-game test.
