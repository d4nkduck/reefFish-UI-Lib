-- reefFish UI Lib: Roblox Studio example
-- Place src/reefFish.luau as a ModuleScript named ReefFish in ReplicatedStorage.
-- Run this from StarterPlayerScripts as a LocalScript.
local ReefFish = require(game:GetService("ReplicatedStorage"):WaitForChild("ReefFish"))
local window = ReefFish:CreateWindow({Title="humuhumunukunukuāpuaʻaHub",Theme="MatrixInverse"})
local main=window:CreateTab({Name="MAIN"})
main:CreateSection("DEMO")
main:CreateLabel({Text="reefFish is ready_"})
main:CreateButton({Name="Ping",Callback=function()window:Notify("Pong!","OK")end})
main:CreateToggle({Name="Show markers",Flag="markers",Default=false,Callback=function(v)print("Markers:",v)end})
main:CreateSlider({Name="Test delay",Flag="delay",Min=0,Max=2,Increment=.05,Default=.4,Callback=function(v)print("Delay:",v)end})
main:CreateDropdown({Name="Mode",Flag="mode",Options={"Off","Visual","Detailed"},Default="Visual",Callback=function(v)print("Mode:",v)end})
local preset=main:CreateInput({Name="Profile name",Default="default"})
main:CreateButton({Name="Save profile",Callback=function()
 local ok,msg=window.Config:Save(preset:Get())
 window:Notify(ok and "Saved" or msg,ok and "OK" or "ERROR")
end})
