# reefFish

A single-file UI library for Roblox/Luau. Mostly intended for script hubs, debug menus and small client-side tools.

Current version: **0.5.0-alpha**  
License: MIT

It has the usual controls, profiles, themes and a few extra utilities. The Matrix border is optional and disabled by default. The UI should still look fine without it.

This is an alpha build. Some things still need testing in Roblox, particularly mobile input and the newer search/dialog features.

## Installation

### Roblox Studio

Put `src/reefFish.luau` in a ModuleScript named `ReefFish` under `ReplicatedStorage`. Then require it from a LocalScript.

```lua
local ReefFish = require(game.ReplicatedStorage.ReefFish)
```

There's a working example in [`examples/basic.luau`](examples/basic.luau). You can put that in `StarterPlayerScripts` to see the components.

### Single-file loader

For environments that support `game:HttpGet` and `loadstring`:

```lua
local ReefFish = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/dist/reefFish.lua"
))()
```

The URL always points to the latest build on `main`. Normal Studio LocalScripts should use the ModuleScript approach instead.

## Example

Create a window, add a tab and put your controls in it.

```lua
local win = ReefFish:CreateWindow({
    Title = "My Hub",
    Theme = "MatrixInverse",
    Rain = false,
})

local main = win:CreateTab({Name = "Main"})
main:CreateSection("General")

main:CreateToggle({
    Name = "Show Markers",
    Flag = "showMarkers",
    Default = false,
    Callback = function(enabled)
        print("Markers:", enabled)
    end,
})

main:CreateSlider({
    Name = "Speed",
    Flag = "speed",
    Min = 0,
    Max = 100,
    Default = 25,
    Callback = function(value)
        print("Speed:", value)
    end,
})

main:CreateButton({
    Name = "Test Notification",
    Callback = function()
        win:Notify("Working", "OK")
    end,
})
```

Callbacks run when the user changes a control. Add a unique `Flag` if you want a value included in saved profiles.

## Components

| Component | Example |
| --- | --- |
| Tab | `win:CreateTab({Name="Main"})` |
| Section | `tab:CreateSection("General")` |
| Collapsible section | `tab:CreateCollapsibleSection({Name="Advanced", Expanded=false})` |
| Label | `tab:CreateLabel({Text="Ready"})` |
| Button | `tab:CreateButton({Name="Run", Callback=fn})` |
| Toggle | `tab:CreateToggle({Name="Enabled", Default=false, Callback=fn})` |
| Slider | `tab:CreateSlider({Name="Amount", Min=0, Max=100, Default=20})` |
| Dropdown | `tab:CreateDropdown({Name="Mode", Options={"A","B"}, Default="A"})` |
| Multi-dropdown | `tab:CreateMultiDropdown({Name="Filters", Options={"A","B"}, Default={"A"}})` |
| Input | `tab:CreateInput({Name="Value", Default=""})` |
| Paragraph | `tab:CreateParagraph({Title="Info", Content="Some details."})` |
| Colour picker | `tab:CreateColorPicker({Name="Accent", Default=Color3.fromRGB(80,200,130)})` |
| Keybind | `tab:CreateKeybind({Name="Hotkey", Default="F6", Mode="Toggle"})` |
| Text area | `tab:CreateTextArea({Name="JSON", Height=120})` |
| Progress bar | `tab:CreateProgressBar({Name="Loading", Min=0, Max=100, Default=0})` |
| Status | `tab:CreateStatus({Name="Connection", Value="Ready", Level="success"})` |

Most interactive controls return a handle. Use `:Get()` to read their value or `:Set(value)` to change it. Depending on the control, there are also methods like `:SetVisible(bool)`, `:SetDisabled(bool)` and `:Destroy()`.

A few options worth knowing:

- Buttons accept `Variant="Primary"`, `"Secondary"` or `"Danger"`. Buttons and toggles can also have a `Description`.
- Collapsible sections return `:SetExpanded(bool)`, `:GetExpanded()` and `:Toggle()`. Controls created afterward are placed in that section until you add another one.
- Progress bars use `:Set(value, animate)`. Status rows use `:Set(value, level)`, where the level can be `success`, `error` or `info`.
- Colour pickers start collapsed. Pass `Expanded=true` if you want the editor open immediately.

## Window methods

The window can be resized, hidden, minimised or restyled after creation.

```lua
win:SetSize(640, 440)
win:SetTheme("Monochrome")
win:SetRain(false)
win:SetHidden(false)

win:Notify("Loaded", "OK")
```

There is a search button in the header. You can also press **Ctrl+K**, or open it through code:

```lua
win:OpenSearch("speed")
```

Search looks through tab names and registered controls. Selecting a result switches to the right tab and scrolls to it.

For actions that need confirmation:

```lua
win:Confirm({
    Title = "Delete profile?",
    Content = "This cannot be undone.",
    Danger = true,
    OnConfirm = function()
        print("Confirmed")
    end,
})
```

`win:GetDiagnostics()` returns basic UI information such as the number of tabs, controls and event connections. It does not run a background profiler.

Other methods include `SetAccentColor`, `SetBorderThickness`, `SetMinimized`, `SelectTab`, `Toast` and `Destroy`.

## Icon

The fish icon is in [`assets/reefFish-icon.png`](assets/reefFish-icon.png).

Roblox won't load a GitHub PNG directly into an `ImageLabel`. Upload the image through Roblox first, then pass its Roblox image asset ID:

```lua
local win = ReefFish:CreateWindow({
    Title = "My Hub",
    Icon = "rbxassetid://YOUR_IMAGE_ASSET_ID",
})
```

You can also call `win:SetIcon(assetId)`, set `ReefFish.DefaultIconAsset` before making a window, or use `Icon` on individual tabs. No ID is included by default.

## Profiles

Only controls with a `Flag` are saved. Game profiles and appearance profiles are separate.

```lua
win.Config:Save("default")
win.Config:Load("default")

-- Normally, loading a profile does not call your callbacks.
win.Config:Load("default", {FireCallbacks=true})

local json = win.Config:Export()
win.Config:Import(json)

win.Appearance:Save("dark")
win.Appearance:Load("dark")
```

Game profiles are separated by `game.GameId`. If compatible file APIs are available, files are stored under `reefFishUI/games/<game.GameId>/` and `reefFishUI/appearance/`.

Without file APIs, profiles only last for the current session. Check `win.StorageMode` to see whether it's using `"file"` or `"memory"`.

Imported profiles are JSON values, not executable Lua.

## Notes

- Default size is 600×420. Smaller windows use horizontal tabs.
- Matrix rain is optional and only creates its glyph objects when enabled.
- Dropdowns reuse visible option rows rather than creating hundreds at once.
- The profile format is still schema v1. Old pinned builds are left alone.
- `src/reefFish.luau` is the editable source; `dist/reefFish.lua` is the current release.
- The example covers the newer controls, resizing and a few cleanup checks. Mobile controls, repeated loading and popup behaviour still need more live testing.

If something breaks, include the client, game/place, steps to reproduce and the first console error. That makes it much easier to track down.

## License

MIT. See [LICENSE](LICENSE). Previous changes are listed in [CHANGELOG.md](CHANGELOG.md).
