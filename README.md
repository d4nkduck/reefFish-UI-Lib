# reefFish UI Lib 🐟

**Version:** 0.3.0-alpha  
**License:** MIT  
**Status:** Feature alpha — new controls, keybinds and notifications

A lightweight Roblox Luau UI library with an intentionally distinctive look: dark console panels framed by thick phosphor-green borders containing inverse Matrix rain (dark glyphs on green). Built for game debug tooling; reusable in client-side Roblox Studio projects.

This is an **early alpha**, not a production-hardened full-featured library. No external requests or third-party modules are needed to display its UI. Both the source and single-file build are included.

## What works today

- Draggable console window, minimize and close buttons, status line, notification banner
- Slim (12 px default, configurable 9–16 px) inverse-Matrix bezel revealing a single vertical falling-code field that slowly scrolls right, up to ~10 Hz
- Five colour themes: MatrixInverse, ClassicCRT, AmberTerminal, IceConsole and Monochrome
- UI controls: tabs, sections, labels, buttons, toggles, sliders with handles, searchable single/multi-select dropdowns, colour picker (HSV/HEX), keybinds (Press/Toggle/Hold), paragraphs and text inputs
- Built-in Appearance and Config tabs with named profile management, editable accent colour and JSON import/export (unless disabled)
- Hover/pressed button feedback, focused text input outlines, and themed slider handles
- Appearance editor: theme, rain toggle, density, speed and live border thickness (9–16px)
- Profile browsing, named save/load, rename/delete with confirmation, JSON import/export and optional debounced autosave
- Capped, animated on-screen toast notifications, built-in status line and safe component callback dispatch with `pcall`
- Show/hide hotkey (RightShift default, configurable via `ToggleKey`) with a shared input dispatcher
- Game configuration profiles and independently stored appearance profiles. Flags now persist Color3 and string-array values in addition to primitive values
- Best-effort storage adapter for environments with `writefile`/`readfile`/`makefolder`; in-memory fallback in normal clients
- Namespaced profiles by Roblox `game.GameId`, JSON-encoded with HttpService
- Config loading **does not run user callbacks by default**
- Cleanup of event connections when the window closes

## What is planned, not implemented

RGB numeric fields in the colour picker, graphs, richer console drawer, notification actions, automated tests across client builds, responsive small-screen design, multi-window support, cross-session auto-load, theme import/export beyond the built-in presets, and a resizable main window.

## Installation (Roblox Studio)

1. Copy `src/reefFish.luau` into a **ModuleScript** named `ReefFish` inside `ReplicatedStorage`.
2. Create a **LocalScript** inside `StarterPlayer > StarterPlayerScripts`.
3. Paste `examples/basic.luau` into that LocalScript.
4. Run Play mode. The sample window will appear.

The library should run on the **client**, not as a Script inside `ServerScriptService`.

## Installation (compatible Lua loader)

After uploading the repository to GitHub, use `examples/loader-compatible.luau` and replace the placeholder username. **The standard Roblox Studio LocalScript environment does not support the remote loadstring example directly.** Use `require()` for Studio.

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
- `tab:CreateButton({Name="NAME", Callback=function() end})` → `:SetDisabled(bool)`
- `tab:CreateToggle({Name="NAME", Flag="unique-id", Default=false, Callback=function(bool) end})` → `:Get()`, `:Set(bool, fireCallback)`
- `tab:CreateSlider({Name="NAME", Flag="unique-id", Min=0, Max=100, Increment=1, Default=25, Callback=function(number) end})` → `:Get()`, `:Set(number, fireCallback)`
- `tab:CreateDropdown({Name="NAME", Flag="unique-id", Options={"A","B"}, Default="A", Callback=function(string) end})` → `:Get()`, `:Set(value, fireCallback)`
- `tab:CreateInput({Name="NAME", Flag="unique-id", Default="text", Numeric=false, Callback=function(string) end})` → `:Get()`, `:Set(value, fireCallback)`
- `tab:CreateParagraph({Title="Help", Content="Long explanation", Height=96})` → `:Set(title,content)`
- `tab:CreateColorPicker({Name="Tint", Flag="tint", Default=Color3.fromRGB(0,255,120), Callback=function(color3) end})` → `:Get()`, `:GetHex()`, `:Set(Color3 or "#RRGGBB", fireCallback)`
- `tab:CreateMultiDropdown({Name="Filters", Flag="filters", Options={"A","B"}, Default={"A"}, Callback=function(array) end})` → `:Get()`, `:Set(array, fireCallback)`
- `tab:CreateKeybind({Name="Overlay key", Flag="overlay.key", Default="F6", Mode="Toggle", Callback=function(active,keyName) end})` → `:Get()`, `:Set(keyName, fireChangeCallback)`
- `tab:CreateTextArea({Name="JSON", Height=120})` → `:Get()`, `:Set(text)`

Window methods: `:SetTheme(name)`, `:SetAccentColor(Color3 or hex)`, `:SetRain(enabled, density, speed)`, `:Notify(text, kind)`, `:Toast({Title,Content,Duration})`, `:SetMinimized(bool)`, `:SetHidden(bool)`, `:SelectTab(tab)`, `:Destroy()`. Most interactive component handles expose `:SetVisible(bool)`, `:SetDisabled(bool)` and `:Destroy()`.

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
## GitHub alpha implementation notes

The GitHub implementation has evolved since the first downloadable prototype. Dropdowns now open searchable scrollable menus; the interface is draggable but not yet resizable; and file-backed profiles require the environment's optional filesystem functions. Some items described above remain roadmap goals. Run the included example in Roblox Studio before depending on this in a published project.

Source: `src/reefFish.luau`. Standalone loader distribution: `dist/reefFish.lua`. Both currently contain the same alpha code.

## v0.1.1-alpha changes

- The border uses a 12px default instead of 18px (configure with `BorderThickness`, constrained to 9–16px).
- The inverse Matrix border now renders reusable streams with a moving head, fading trailing glyphs, digits, and katakana. Vertical trails run on the side bezels, with horizontally adapted trails on top/bottom.
- Dropdown controls open a searchable, scrolling option list. Use `Dropdown:SetOptions({...})` to refresh choices.
- Reloading a window attempts to clean up the previous tracked instance before constructing a new one.
- As with earlier alpha versions, test with your own client version; this release is not verified against every third-party execution environment.

## v0.1.2-alpha Matrix background update

- A **single full-window Matrix field** replaces separate animations for each border side. All code trails fall vertically; no streams run around the window edges.
- The opaque inner content panel masks the background, exposing it only through the green border.
- The entire field drifts slowly to the **right** while individual columns fall independently, wrapping seamlessly across the full-width field.
- Each trail includes changing digits/katakana, a darker leading character, and fading tail; the animation uses pooled labels and a capped 10 Hz update loop.
- Searchable dropdowns and other controls remain available.
- This release has not been visually validated in Roblox/Xeno; please test the updated loader.



## v0.3.0-alpha — Original advanced controls and interactions

This version builds upon the v0.2 profile manager. It is an **independent implementation** informed by feature-completeness goals from established Roblox libraries, not a copy of their source.

- **Colour picker:** An embedded HSV square, rainbow hue bar, HEX input, and a colour preview. Use `Get()` for a `Color3` value, `GetHex()` for a hex string, or `Set(value)` with either. The Appearance tab includes a live accent colour picker.
- **Keybinds:** A click-to-capture key selector, three modes (`Press`, `Toggle`, `Hold`), callback state, and a shared window-level input handler. Textbox focus and Roblox-processed input are ignored. The show/hide key is reserved.
- **Multi-select dropdowns:** Popup search, click to toggle several options, and `Get()`/`Set()` returning/accepting arrays of strings.
- **Paragraphs:** A compact title+body control with multiline content.
- **Notifications:** Animated toasts with a maximum of four active items, timed dismissal, and a close button. `Window:Notify` also continues to update the bottom status line.
- **Window keyboard shortcut:** RightShift by default; customize through `CreateWindow({ToggleKey=Enum.KeyCode.F8})`. Press it again to show the window after hiding.
- **Config persistence:** Color3 values are JSON objects tagged `__reefFishType="Color3"`; multi-select values are stored as string arrays. Config schema version remains 1. Existing number/string/boolean profiles are compatible.
- **Lightweight runtime:** The Matrix renderer remains the same vertical falling-wallpaper effect visible only through the thin border; notifications use short tasks, not new polling loops.

### Studio smoke test

Copy `src/reefFish.luau` into ReplicatedStorage as a ModuleScript named ReefFish, then run `examples/components-v0.3.luau` in a StarterPlayerScripts LocalScript. It includes a round-trip test for colour and multi-select profile saving.

### Direct loader (compatible Lua environments)

```lua
local ReefFish = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/dist/reefFish-v0.3.lua"
))()

assert(ReefFish.Version=="0.3.0-alpha", "Unexpected reefFish version")
local Window=ReefFish:CreateWindow({
    Title="reefFish COMPONENTS",
    Theme="MatrixInverse",
    ToggleKey=Enum.KeyCode.RightShift
})
```

**Testing status:** Source/loader consistency and static checks are performed before publishing. A real Roblox Studio and Xeno session remains necessary to validate rendering, keyboard events, local file compatibility and performance. Use the versioned file to avoid confusing older cached builds.

## v0.2.0-alpha — Named profiles and refined controls

**Appearance menu:** Pick a theme, toggle Matrix rain, edit rain density and speed, and adjust the border thickness in real time. The rain is still the **inverse** design: dark characters on green, with a dark head at the *bottom* of each falling trail and characters fading into the green background toward the top. Character changes are now less jittery.

**Profile manager:** Both the Appearance and Config tabs provide the same operations: browse existing profiles (when supported), enter a profile name, save/load, rename a selected profile, delete it with a two-click confirmation, and export/import JSON through a multiline text field. Export also attempts to copy JSON if `setclipboard` is available.

**File support:** Saving and loading require `writefile`, `readfile`, and `makefolder` in the current environment. Browsing existing files after a fresh session requires `listfiles`; deletion and renaming require `delfile`. When file I/O is unavailable, profiles are stored only in the library's **current session memory**. The UI explicitly reports this.

**Auto-save:** A checkbox can debounce changes for the selected profile by one second, **only while the window is open**. It does not auto-enable or auto-load profiles in subsequent sessions. Use **Load named profile** when you re-open the UI.

**Important:** Loading game profiles restores stored component values **without firing game-specific callbacks** by default. This prevents an arbitrary saved config from automatically starting an operation. Developers can explicitly request callback execution through `Config:Load(name, {FireCallbacks=true})` when appropriate.

### Programmatic configuration API

```lua
local ok, storageOrError = Window.Config:Save("npc_testing")
local savedNames = Window.Config:List()
local loaded, loadError = Window.Config:Load("npc_testing")
local renamed, renameError = Window.Config:Rename("npc_testing", "npc_visual")
local exportedJson = Window.Config:Export()
local imported, importError = Window.Config:Import(exportedJson)
local deleted, deleteError = Window.Config:Delete("npc_visual")

Window.Appearance:Save("green_console")
Window.Appearance:Load("green_console")
Window:SetBorderThickness(10)
Window:SetRain(true, 0.75, 0.35)
```

Profile names support letters, numbers, underscore and hyphen, up to 48 characters. Appearance profiles and game profiles live in separate folders. Game profiles are scoped by `game.GameId`. Unsupported profile schemas or profiles for another game are rejected.

### Testing

See `examples/profile-smoke.luau` for a small local test. This release is committed and statically reviewed, but not tested in your exact Xeno build until you try it. For a version-pinned loader, use `dist/reefFish-v0.2.lua`.

## v0.1.3-alpha — unmistakably vertical rain and cache diagnosis

- Uses one global full-window Matrix **wallpaper**, masked by the opaque console so **only the narrow border** reveals it.
- Every code column falls straight down; the whole wallpaper drifts right at just **0.18–0.48 pixels per second** (depending on rain speed).
- Each stream is now a **single multiline RichText label** with a shaded tail (instead of many independently moving glyph labels); Unicode katakana and digits are preserved.
- Visible version identifiers: the title includes **[0.1.3]** and the status bar includes **VERTICAL MATRIX**.
- New unique distribution path **`dist/reefFish-v0.1.3.lua`** avoids potential caching of the earlier `dist/reefFish.lua` URL.
- Temporary Xeno-compatible smoke-test launcher:

```lua
local UI = loadstring(game:HttpGet("https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/dist/reefFish-v0.1.3.lua"))()
assert(UI.Version == "0.1.3-alpha", "Outdated reefFish build loaded: " .. tostring(UI.Version))
local Window = UI:CreateWindow({Title="Matrix rain v0.1.3 test", Theme="MatrixInverse", BorderThickness=12})
```

The GitHub files have been verified, but this UI has **not yet been visually tested in Xeno**. If the version string is wrong, the environment is still loading old code; if the version is correct but animation appears wrong, report the version and a screenshot or short description.
