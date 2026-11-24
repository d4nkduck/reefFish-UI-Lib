-- reefFish v0.2.0-alpha manual smoke test
-- Studio: copy src/reefFish.luau into ReplicatedStorage as a ModuleScript named ReefFish.
-- Run this file in a StarterPlayerScripts LocalScript.
-- Compatible loadstring environments may replace the require() line with the
-- versioned GitHub loader shown in README.md.
local ReefFish = require(game:GetService("ReplicatedStorage"):WaitForChild("ReefFish"))
assert(ReefFish.Version == "0.2.0-alpha", "Unexpected reefFish version: "..tostring(ReefFish.Version))

local win = ReefFish:CreateWindow({
    Title = "reefFish profile smoke test",
    Theme = "MatrixInverse",
    BorderThickness = 10,
})

local tab = win:CreateTab({Name = "SMOKE"})
tab:CreateSection("CONTROLS")

local toggle = tab:CreateToggle({
    Name = "Visual Debug",
    Flag = "smoke.visual",
    Default = false,
    Callback = function(v) print("Visual Debug:", v) end,
})

local speed = tab:CreateSlider({
    Name = "Delay",
    Flag = "smoke.delay",
    Min = 0,
    Max = 2,
    Increment = 0.1,
    Default = 0.4,
})

local target = tab:CreateDropdown({
    Name = "Target",
    Flag = "smoke.target",
    Options = {"Dummy A", "Dummy B", "Dummy C"},
    Default = "Dummy A",
})

tab:CreateButton({
    Name = "Run profile round trip",
    Callback = function()
        toggle:Set(true)
        speed:Set(0.8)
        target:Set("Dummy B")

        local saved, reason = win.Config:Save("reefFish_smoke")
        if not saved then win:Notify("Save failed: "..tostring(reason), "ERROR") return end

        toggle:Set(false)
        speed:Set(0.2)
        target:Set("Dummy C")

        local loaded, err = win.Config:Load("reefFish_smoke")
        local passed = loaded and toggle:Get() == true
            and math.abs(speed:Get() - 0.8) < 0.001
            and target:Get() == "Dummy B"

        assert(passed, "Profile round trip failed: "..tostring(err))
        print("reefFish profile smoke test passed", win.StorageMode)
        win:Notify("PROFILE ROUND TRIP PASSED", "OK")
    end,
})

tab:CreateButton({
    Name = "Run appearance round trip",
    Callback = function()
        win:SetTheme("MatrixInverse")
        win:SetRain(true, 0.75, 0.35)
        win:SetBorderThickness(10)

        local saved, err = win.Appearance:Save("reefFish_look")
        if not saved then win:Notify("Appearance save failed: "..tostring(err), "ERROR") return end

        win:SetTheme("AmberTerminal")
        win:SetBorderThickness(14)
        local loaded, reason = win.Appearance:Load("reefFish_look")
        assert(loaded and win.themeName == "MatrixInverse" and win.borderThickness == 10,
            "Appearance round trip failed: "..tostring(reason))
        win:Notify("APPEARANCE ROUND TRIP PASSED", "OK")
    end,
})
