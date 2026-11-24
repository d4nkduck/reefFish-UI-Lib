-- reefFish v0.3.0-alpha: standalone component demonstration
-- Roblox Studio: put src/reefFish.luau in ReplicatedStorage as a ModuleScript
-- named ReefFish, then run this file as a StarterPlayerScripts LocalScript.
local ReefFish=require(game:GetService("ReplicatedStorage"):WaitForChild("ReefFish"))
assert(ReefFish.Version=="0.3.0-alpha","Unexpected reefFish version")

local win=ReefFish:CreateWindow({
 Title="reefFish COMPONENT LAB",
 Theme="MatrixInverse",
 BorderThickness=11,
 ToggleKey=Enum.KeyCode.RightShift
})

local demo=win:CreateTab({Name="CONTROLS"})
demo:CreateParagraph({
 Title="SYSTEM // ACTIVE",
 Content="This test covers color selection, multi-select dropdowns, keybinds, and local profile serialization. Right Shift hides and shows the window.",
 Height=102
})
local colour=demo:CreateColorPicker({
 Name="Debug highlight color",
 Flag="demo.highlightColor",
 Default=Color3.fromRGB(80,255,150),
 Callback=function(c)print("Color changed",c)end
})
local targets=demo:CreateMultiDropdown({
 Name="Target filters",
 Flag="demo.filters",
 Options={"Dummies","NPCs","Props","Players","Triggers"},
 Default={"Dummies","Props"},
 Callback=function(selected)print("Filters selected",table.concat(selected,", "))end
})
demo:CreateKeybind({
 Name="Toggle debug overlay",
 Flag="demo.overlayBind",
 Default="F6",
 Mode="Toggle",
 Callback=function(enabled,key)print("Debug overlay",enabled,key)end
})

local advanced=win:CreateTab({Name="TEST"})
advanced:CreateButton({
 Name="Validate saved profile",
 Callback=function()
  local ok,msg=win.Config:Save("v03_smoke")
  if not ok then win:Notify("Save failed: "..tostring(msg),"ERROR")return end
  local encoded=game:GetService("HttpService"):JSONDecode(win.Config:Export())
  assert(encoded.flags["demo.highlightColor"].__reefFishType=="Color3")
  assert(type(encoded.flags["demo.filters"])=="table")
  local original=colour:GetHex()
  colour:Set("#AABBCC")
  targets:Set({"NPCs"})
  local loaded,err=win.Config:Load("v03_smoke")
  assert(loaded,"Load failed: "..tostring(err))
  assert(colour:GetHex()==original,"Color did not restore")
  assert(table.find(targets:Get(),"Dummies")~=nil,"Multi-select did not restore")
  win:Toast({Title="SMOKE TEST",Content="Color and multi-select profiles restored.",Duration=4})
 end
})
advanced:CreateButton({
 Name="Show sample notification",
 Callback=function()
  win:Toast({Title="REEFFISH ONLINE",Content="Toast system is ready.",Duration=4})
 end
})
