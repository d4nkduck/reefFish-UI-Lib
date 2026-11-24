-- Example for environments that provide loadstring and game:HttpGet.
-- This is NOT a normal Roblox Studio LocalScript loading mechanism.
local ReefFish=loadstring(game:HttpGet(
 "https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/dist/reefFish.lua"
))()
local window=ReefFish:CreateWindow({Title="reefFish Console"})
local tab=window:CreateTab({Name="TOOLS"})
tab:CreateButton({Name="Hello",Callback=function()window:Notify("Hello from reefFish","OK")end})
