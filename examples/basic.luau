-- reefFish UI Lib: Roblox Studio example
-- Place src/reefFish.luau as a ModuleScript named ReefFish in ReplicatedStorage.
-- Run this from StarterPlayerScripts as a LocalScript.
local ReefFish = require(game:GetService("ReplicatedStorage"):WaitForChild("ReefFish"))
local window = ReefFish:CreateWindow({Title="reefFish UI demo",Theme="MatrixInverse"})
local main=window:CreateTab({Name="MAIN"})
main:CreateSection("DEMO")
main:CreateLabel({Text="reefFish v0.4.1 resizing + input test"})
main:CreateButton({Name="Ping",Callback=function()window:Notify("Pong!","OK")end})
main:CreateToggle({Name="Show markers",Flag="markers",Default=false,Callback=function(v)print("Markers:",v)end})
main:CreateSlider({Name="Test delay",Flag="delay",Min=0,Max=2,Increment=.05,Default=.4,Callback=function(v)print("Delay:",v)end})
main:CreateDropdown({Name="Mode",Flag="mode",Options={"Off","Visual","Detailed"},Default="Visual",Callback=function(v)print("Mode:",v)end})
local colour=main:CreateColorPicker({
 Name="Highlight colour",Default=Color3.fromRGB(96,255,169),
 Callback=function(value)print("Accent:",value)end
})
assert(colour:GetExpanded()==false,"Colour picker should start compact")
local wide=false
main:CreateButton({Name="Toggle window size",Callback=function()
 wide=not wide
 local size=window:SetSize(wide and 700 or 560,wide and 440 or 380)
 window:Notify("Window: "..size.X.." × "..size.Y,"INFO")
end})
local numeric=main:CreateInput({Name="Numeric input",Default="10",Numeric=true,
 Callback=function(v)print("Numeric input:",v)end
})
assert(numeric:Set("not a number")==false,"Numeric validation failed")
main:CreateParagraph({
 Title="Automatic paragraph height",
 Content="This paragraph should wrap and expand when the content area gets narrower. Try dragging the bottom-right corner, resizing the window and rotating the device to test the responsive layout."
})
local manyOptions={}
for i=1,100 do manyOptions[i]="Option "..i end
main:CreateDropdown({Name="100-option dropdown",Options=manyOptions,Default="Option 1"})
local preset=main:CreateInput({Name="Profile name",Default="default"})
main:CreateButton({Name="Save profile",Callback=function()
 local ok,msg=window.Config:Save(preset:Get())
 window:Notify(ok and "Saved" or msg,ok and "OK" or "ERROR")
end})
