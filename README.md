# reefFish UI Lib 🐟

**Version:** 0.1.0-alpha  
**License:** MIT  
**Status:** Phase 1 functional prototype

A lightweight Roblox Luau UI library with an intentionally distinctive look: dark console panels framed by thick phosphor-green borders containing inverse Matrix rain (dark glyphs on green). Built for game debug tooling; reusable in client-side Roblox Studio projects.

This is an **early alpha**, not a production-hardened full-featured library. No external requests or third-party modules are needed to display its UI. Both the source and single-file build are included.

## What works today

- Draggable console window, minimize and close buttons, status line, notification banner
- Thick inverse-Matrix border with a single throttled animation loop per window (5–15 updates/s)
- Five colour themes: MatrixInverse, ClassicCRT, AmberTerminal, IceConsole and Monochrome
- UI controls: tabs, sections, labels, buttons, toggles, sliders, dropdowns, text inputs
- Built-in Appearance and Config tabs (unless disabled)
- Session-safe component callback dispatch with `pcall`
- Game configuration profiles and independently stored appearance profiles
- Best-effort storage adapter for environments with `writefile`/`readfile`/`makefolder`; in-memory fallback in normal clients
- Namespaced profiles by Roblox `game.GameId`, JSON-encoded with HttpService
- Config loading **does not run user callbacks by default**
- Cleanup of event connections when the window closes

## What is planned, not implemented

Keybind selector, colour picker, searchable multi-select dropdown, graphs, richer console drawer, notifications queue, export UI, automated tests across client builds, responsive small-screen design, multi-window management, theme import/export, full persistence management (list/rename/delete).

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

Window methods: `:SetTheme(name)`, `:SetRain(enabled, density, speed)`, `:Notify(text, kind)`, `:SetMinimized(bool)`, `:SelectTab(tab)`, `:Destroy()`.

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