# reefFish

small UI lib for Luau. one file, no extra dependencies.

**0.5.0-alpha** · MIT

Made for script hubs, debug panels and other client-side tools. Dark UI, grouped settings, optional Matrix border. Rain is off by default because it shouldn't be carrying the design.

Still alpha. Static checks are done before pushing builds, but not every update has been tested in a live Roblox client.

## load it

**Studio:** put `src/reefFish.luau` in a ModuleScript named `ReefFish` under `ReplicatedStorage`. Run `examples/basic.luau` from a LocalScript in `StarterPlayerScripts`.

```lua
local ReefFish = require(game.ReplicatedStorage.ReefFish)
```

**Compatible Lua environments:** the single-file build lives at one URL.

```lua
local ReefFish = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/dist/reefFish.lua"
))()
```

Regular Studio LocalScripts don't support that remote `loadstring` setup. Use `require` there.

## basic setup

```lua
local win = ReefFish:CreateWindow({
    Title = "my hub",
    Theme = "MatrixInverse",
    Rain = false,
})

local tab = win:CreateTab({Name = "Main"})
tab:CreateSection("Main")

tab:CreateToggle({
    Name = "Markers",
    Flag = "markers",
    Default = false,
    Callback = function(on)
        print("markers:", on)
    end,
})

tab:CreateSlider({
    Name = "Speed",
    Flag = "speed",
    Min = 0,
    Max = 100,
    Default = 25,
    Callback = function(value)
        print(value)
    end,
})
```

## controls

Most controls return a handle with `Get`, `Set`, `SetVisible`, `SetDisabled` or `Destroy` where applicable.

| Control | Call |
| --- | --- |
| Tab | `win:CreateTab({Name="Main"})` |
| Group | `tab:CreateSection("General")` |
| Foldable group | `tab:CreateCollapsibleSection({Name="Extra", Expanded=false})` |
| Label | `tab:CreateLabel({Text="ready"})` |
| Button | `tab:CreateButton({Name="Run", Callback=fn})` |
| Toggle | `tab:CreateToggle({Name="Enabled", Default=false, Callback=fn})` |
| Slider | `tab:CreateSlider({Name="Amount", Min=0, Max=100, Default=20})` |
| Dropdown | `tab:CreateDropdown({Name="Mode", Options={"A","B"}, Default="A"})` |
| Multi dropdown | `tab:CreateMultiDropdown({Name="Flags", Options={"A","B"}, Default={"A"}})` |
| Input | `tab:CreateInput({Name="Value", Default="", Numeric=false})` |
| Paragraph | `tab:CreateParagraph({Title="Info", Content="..."})` |
| Colour | `tab:CreateColorPicker({Name="Accent", Default=Color3.fromRGB(80,200,130)})` |
| Keybind | `tab:CreateKeybind({Name="Hotkey", Default="F6", Mode="Toggle"})` |
| Text area | `tab:CreateTextArea({Name="JSON", Height=120})` |
| Progress | `tab:CreateProgressBar({Name="Task", Min=0, Max=100, Default=0})` |
| Status | `tab:CreateStatus({Name="Connection", Value="Ready", Level="success"})` |

`CreateButton` supports `Variant="Primary"`, `"Secondary"` or `"Danger"`. Buttons and toggles also accept `Description`.

`CreateCollapsibleSection` returns `SetExpanded(bool)`, `GetExpanded()` and `Toggle()`. Controls created after it go inside that group until you add another section.

A progress handle supports `Set(value, animate)` and `SetLabel(text)`. Status rows support `Set(value, level)` with `success`, `error` or `info`.

## window stuff

```lua
win:SetSize(640, 440)
win:SetTheme("Monochrome")
win:SetRain(false)
win:Notify("loaded", "OK")

-- search all tabs/controls, or press Ctrl+K
win:OpenSearch("speed")

win:Confirm({
    Title = "Delete profile?",
    Content = "This can't be undone.",
    Danger = true,
    OnConfirm = function()
        print("confirmed")
    end,
})

local stats = win:GetDiagnostics()
print(stats.counts.controls, stats.counts.controlEvents)
```

The header search button works on touch too. Search matches tab names and registered control labels, then jumps to the matching control. `Escape` closes search/dialogs on keyboard.

Other window methods: `SetAccentColor`, `SetBorderThickness`, `SetHidden`, `SetMinimized`, `SelectTab`, `Toast` and `Destroy`.

### icon

The fish PNG is in [`assets/reefFish-icon.png`](assets/reefFish-icon.png). That file is the source image, not a Roblox asset.

Upload it to Roblox first, then use its **image asset ID**:

```lua
local win = ReefFish:CreateWindow({
    Title = "my hub",
    Icon = "rbxassetid://YOUR_IMAGE_ASSET_ID",
})

-- or set the ID later
win:SetIcon("rbxassetid://YOUR_IMAGE_ASSET_ID")
```

You can also set `ReefFish.DefaultIconAsset` before creating the window, or pass an `Icon` to a tab. The old dot placeholder is gone. No asset ID is hardcoded.

## configs

Only controls with a `Flag` are saved.

```lua
win.Config:Save("default")
win.Config:Load("default")
win.Config:Load("default", {FireCallbacks=true}) -- opt-in

local json = win.Config:Export()
win.Config:Import(json)

win.Appearance:Save("dark")
win.Appearance:Load("dark")
```

Game profiles are separated by `game.GameId`. Appearance profiles are stored separately. JSON is values only; importing a profile doesn't execute Lua. Loading doesn't fire your callbacks unless you explicitly ask it to.

If the environment has compatible file APIs, profiles go under:

```text
reefFishUI/
  appearance/
  games/<game.GameId>/
```

Otherwise it's in-memory for the current session. Check `win.StorageMode` to see which is active.

## notes

- Default window is 600×420. It resizes, clamps to the viewport and uses horizontal tabs when narrow.
- Matrix rain is optional. It doesn't create its glyph labels until enabled.
- Dropdowns reuse visible rows instead of spawning every option.
- Existing profile format is still schema v1. The main distribution path stays `dist/reefFish.lua`.
- Studio demo: `examples/basic.luau`. It covers the newer components, resizing and some cleanup checks.
- Needs more real client testing, especially mobile input, modal/search layering and repeated open/close. A static check isn't a playtest.

Bug reports are more useful with the client, game/place, steps to reproduce and the first error in the console.

## license

MIT. See [LICENSE](LICENSE).

Release history is in [CHANGELOG.md](CHANGELOG.md).
