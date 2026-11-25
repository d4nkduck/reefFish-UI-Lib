-- reefFish UI Lib: Roblox Studio example
-- Place src/reefFish.luau as a ModuleScript named ReefFish in ReplicatedStorage.
-- Run this from StarterPlayerScripts as a LocalScript.
local ReefFish = require(game:GetService("ReplicatedStorage"):WaitForChild("ReefFish"))
-- Upload assets/reefFish-icon.png to Roblox, then optionally supply its image asset ID:
-- Icon="rbxassetid://YOUR_ROBLOX_IMAGE_ASSET_ID"
local window = ReefFish:CreateWindow({Title="reefFish Playground",Theme="MatrixInverse"})
local main=window:CreateTab({Name="Overview"})
main:CreateSection("Quick actions")
main:CreateLabel({Text="reefFish v0.5.0  •  Search, dialogs and rich controls"})
main:CreateButton({
 Name="Run quick check",Variant="Primary",Description="Verify notifications and actions",
 Callback=function()window:Notify("Interface is responding","OK")end
})
main:CreateButton({Name="Show information",Variant="Secondary",
 Description="Preview a standard action row",
 Callback=function()window:Notify("Grouped actions look cleaner","INFO")end
})
main:CreateSection("Preferences")
main:CreateToggle({
 Name="Show markers",Description="Example feature toggle",
 Flag="markers",Default=false,Callback=function(v)print("Markers:",v)end
})
main:CreateSlider({Name="Test delay",Flag="delay",Min=0,Max=2,Increment=.05,Default=.4,Callback=function(v)print("Delay:",v)end})
main:CreateDropdown({Name="Mode",Flag="mode",Options={"Off","Visual","Detailed"},Default="Visual",Callback=function(v)print("Mode:",v)end})
local colour=main:CreateColorPicker({
 Name="Highlight colour",Default=Color3.fromRGB(96,255,169),
 Callback=function(value)print("Accent:",value)end
})
assert(colour:GetExpanded()==false,"Colour picker should start compact")
main:CreateSection("New in v0.5")
local progress=main:CreateProgressBar({Name="Example task",Min=0,Max=100,Default=20})
local liveStatus=main:CreateStatus({Name="UI health",Value="Ready",Level="success"})
assert(progress:Get()==20,"Progress initialization failed")
main:CreateButton({Name="Advance progress",Callback=function()
 progress:Set(math.min(100,progress:Get()+20),true)
 liveStatus:Set(progress:Get()>=100 and "Complete" or "Working","success")
end})
main:CreateButton({Name="Open confirmation dialog",Variant="Secondary",
 Callback=function()
  window:Confirm({
   Title="Confirm action",Content="This is the native reefFish confirmation dialog.",
   ConfirmText="Continue",OnConfirm=function()
    window:Notify("Confirmed","OK")
   end
  })
 end
})
main:CreateButton({Name="Search all settings",Callback=function()
 window:OpenSearch()
end})
main:CreateButton({Name="UI diagnostics",Callback=function()
 local info=window:GetDiagnostics()
 window:Notify(tostring(info.counts.controls).." controls | "..tostring(info.counts.tabs).." tabs","INFO")
end})
local advanced=main:CreateCollapsibleSection({Name="Advanced options",Expanded=false})
assert(advanced:GetExpanded()==false,"Collapsible section should start folded")
main:CreateToggle({Name="Advanced debug toggle",Default=false})
main:CreateButton({Name="Advanced test action",Callback=function()
 window:Notify("Advanced action works","OK")
end})
main:CreateSection("Layout & stress tests")
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
for i=1,120 do manyOptions[i]="Option "..i end
local longDropdown=main:CreateDropdown({
 Name="120-option scroll test",Options=manyOptions,Default="Option 1",
 Callback=function(choice)print("Selected:",choice)end
})
main:CreateButton({Name="Select final dropdown option",Callback=function()
 assert(longDropdown:Set("Option 120",true),"Dropdown rejected last option")
 window:Notify("Option 120 selected — scroll to verify it can be reached","OK")
end})
main:CreateButton({Name="Test destroyed-control cleanup",Callback=function()
 local testFlag="smoke.temporary"
 local probe=main:CreateToggle({Name="Temporary control",Flag=testFlag})
 assert(window.flags[testFlag]==probe,"Temporary flag missing")
 probe:Destroy()
 -- Destroying signal behaviour may be deferred in some Roblox environments.
 task.delay(.1,function()
  if window.destroyed then return end
  assert(window.flags[testFlag]==nil,"Destroyed flag still registered")
  window:Notify("Control cleanup passed","OK")
 end)
end})
main:CreateButton({Name="Test theme changes",Callback=function()
 local initial=window.themeName
 assert(window:SetTheme("AmberTerminal"),"Theme change failed")
 assert(window:SetTheme(initial),"Theme restoration failed")
 window:Notify("Theme refresh passed","OK")
end})
assert(#window:FindControls("Test delay")>0,"Global control indexing failed")
local preset=main:CreateInput({Name="Profile name",Default="default"})
main:CreateButton({Name="Save profile",Callback=function()
 local ok,msg=window.Config:Save(preset:Get())
 window:Notify(ok and "Saved" or msg,ok and "OK" or "ERROR")
end})
