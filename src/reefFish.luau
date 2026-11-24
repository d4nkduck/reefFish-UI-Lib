-- reefFish UI Lib v0.2.0-alpha
-- MIT License | Console-style Roblox Luau UI
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local Lib={Version="0.2.0-alpha"}
local palettes={
 MatrixInverse={bg=Color3.fromRGB(11,17,14),panel=Color3.fromRGB(16,26,20),raised=Color3.fromRGB(23,35,28),border=Color3.fromRGB(19,185,108),ink=Color3.fromRGB(6,59,35),accent=Color3.fromRGB(96,255,169),text=Color3.fromRGB(213,233,220),muted=Color3.fromRGB(129,161,140)},
 ClassicCRT={bg=Color3.fromRGB(8,13,9),panel=Color3.fromRGB(12,23,14),raised=Color3.fromRGB(19,42,25),border=Color3.fromRGB(19,135,72),ink=Color3.fromRGB(6,53,26),accent=Color3.fromRGB(86,237,134),text=Color3.fromRGB(215,242,215),muted=Color3.fromRGB(126,164,130)},
 AmberTerminal={bg=Color3.fromRGB(23,18,11),panel=Color3.fromRGB(35,27,17),raised=Color3.fromRGB(48,35,20),border=Color3.fromRGB(214,156,48),ink=Color3.fromRGB(83,54,9),accent=Color3.fromRGB(255,214,138),text=Color3.fromRGB(240,226,202),muted=Color3.fromRGB(170,148,110)},
 IceConsole={bg=Color3.fromRGB(11,18,24),panel=Color3.fromRGB(15,27,35),raised=Color3.fromRGB(24,42,52),border=Color3.fromRGB(70,159,201),ink=Color3.fromRGB(22,60,80),accent=Color3.fromRGB(140,229,255),text=Color3.fromRGB(214,231,238),muted=Color3.fromRGB(130,164,176)},
 Monochrome={bg=Color3.fromRGB(17,17,17),panel=Color3.fromRGB(26,26,26),raised=Color3.fromRGB(39,39,39),border=Color3.fromRGB(148,148,148),ink=Color3.fromRGB(51,51,51),accent=Color3.fromRGB(240,240,240),text=Color3.fromRGB(220,220,220),muted=Color3.fromRGB(159,159,159)}
}
Lib.Themes=palettes
local function make(class,props,parent)
 local x=Instance.new(class)
 for k,v in pairs(props or {}) do x[k]=v end
 x.Parent=parent
 return x
end
local function round(x,n) make("UICorner",{CornerRadius=UDim.new(0,n or 4)},x) end
local function fire(fn,...)
 if type(fn)=="function" then local ok,err=pcall(fn,...) if not ok then warn("[reefFish]",err) end end
end
local function validName(n)
 return type(n)=="string" and #n>0 and #n<=48 and n:match("^[%w_%-]+$")~=nil
end
local function storage()
 local funcs={read=readfile,write=writefile,mkdir=makefolder,exists=isfile,dir=isfolder,list=listfiles,delete=delfile}
 if type(funcs.read)=="function" and type(funcs.write)=="function" and type(funcs.mkdir)=="function" then return funcs end
 return nil
end
local function ensureDir(fs,path)
 local p=""
 for component in string.gmatch(path,"[^/]+") do
  p=(p=="" and component or p.."/"..component)
  local exists=false
  if type(fs.dir)=="function" then local ok,b=pcall(fs.dir,p) exists=ok and b end
  if not exists then pcall(fs.mkdir,p) end
 end
end
local Window={} Window.__index=Window
local Tab={} Tab.__index=Tab
-- Small, central interaction-state engine: no per-control animation loops.
function Window:_feedback(hitbox,surface)
 local state="normal"
 local function refresh()
  if not surface.Parent then return end
  local base=self.colors.raised
  if state=="hover" then
   surface.BackgroundColor3=base:Lerp(self.colors.accent,.16)
  elseif state=="pressed" then
   surface.BackgroundColor3=base:Lerp(self.colors.accent,.32)
  else
   surface.BackgroundColor3=base
  end
 end
 self._feedbackRefresh[#self._feedbackRefresh+1]=refresh
 local function add(signal,fn)
  self._connections[#self._connections+1]=signal:Connect(fn)
 end
 add(hitbox.MouseEnter,function()state="hover" refresh()end)
 add(hitbox.MouseLeave,function()state="normal" refresh()end)
 add(hitbox.MouseButton1Down,function()state="pressed" refresh()end)
 add(hitbox.MouseButton1Up,function()state="hover" refresh()end)
 refresh()
end
function Window:_markChanged(kind)
 if self._importing then return end
 local name=self._autosaveTargets[kind]
 if name then self._autosaveDue[kind]=os.clock()+1 end
end
function Window:SetBorderThickness(value)
 local n=math.clamp(math.floor(tonumber(value) or self.borderThickness),9,16)
 self.borderThickness=n
 if self.inner then
  self.inner.Position=UDim2.fromOffset(n,n)
  self.inner.Size=UDim2.new(1,-2*n,1,-2*n)
  self:SetMinimized(self.minimized)
 end
 self:_markChanged("appearance")
 return n
end
function Window:_theme(obj,property,token)
 self._bound[#self._bound+1]={obj,property,token}
 obj[property]=self.colors[token]
end
function Window:SetTheme(name)
 if not palettes[name] then return false end
 if self._closeDropdown then self._closeDropdown() end
 self.themeName=name self.colors=palettes[name]
 for _,bound in ipairs(self._bound) do if bound[1].Parent then bound[1][bound[2]]=self.colors[bound[3]] end end
 for _,refresh in ipairs(self._feedbackRefresh) do refresh() end
 if self.active then self:SelectTab(self.active) end
 if self._repaintRain then self._repaintRain() end
 self:_markChanged("appearance")
 return true
end
function Window:SetRain(enabled,density,speed)
 self.rainEnabled=enabled~=false
 if type(density)=="number" then self.rainDensity=math.clamp(density,0,1) end
 if type(speed)=="number" then self.rainSpeed=math.clamp(speed,0,1) end
 if self._rainLayer then self._rainLayer.Visible=self.rainEnabled end
 if self._rainColumns and self._repaintRain then self._repaintRain() end
 self:_markChanged("appearance")
end
function Window:Notify(msg,kind)
 self._status.Text="["..string.upper(tostring(kind or "INFO")).."] "..tostring(msg)
end
function Window:SetMinimized(value)
 self.minimized=value==true
 if self._closeDropdown then self._closeDropdown() end
 self.body.Visible=not self.minimized
 self.root.Size=UDim2.fromOffset(self.width,self.minimized and (42+self.borderThickness*2) or self.height)
end
function Window:SelectTab(tab)
 for _,t in ipairs(self.tabs) do
  t.page.Visible=(t==tab)
  t.button.BackgroundColor3=(t==tab) and self.colors.raised or self.colors.panel
 end
 self.active=tab
end
function Window:Destroy()
 if self.destroyed then return end
 self.destroyed=true
 if self._closeDropdown then self._closeDropdown() end
 -- Flush any queued autosaves before disconnecting.
 for kind,due in pairs(self._autosaveDue) do
  local name=self._autosaveTargets[kind]
  if due and name then
   local obj=kind=="appearance" and self.Appearance or self.Config
   if obj then pcall(function()obj:Save(name)end) end
  end
 end
 for _,c in ipairs(self._connections) do c:Disconnect() end
 self.screen:Destroy()
 if self._registry and self._registry.__reefFishWindow==self then
  self._registry.__reefFishWindow=nil
 end
end
function Window:CreateTab(opts)
 local name=type(opts)=="table" and (opts.Name or opts.Title) or opts or "TAB"
 local button=make("TextButton",{Text="> "..tostring(name),Size=UDim2.new(1,-8,0,34),Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,AutoButtonColor=false},self.nav)
 local page=make("ScrollingFrame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ScrollBarThickness=4,AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),Visible=false,BorderSizePixel=0},self.content)
 make("UIPadding",{PaddingTop=UDim.new(0,8),PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8)},page)
 make("UIListLayout",{Padding=UDim.new(0,7),SortOrder=Enum.SortOrder.LayoutOrder},page)
 local t=setmetatable({window=self,button=button,page=page},Tab)
 self:_theme(button,"TextColor3","accent")
 self:_theme(button,"BackgroundColor3","panel")
 self.tabs[#self.tabs+1]=t
 self._connections[#self._connections+1]=button.MouseButton1Click:Connect(function()self:SelectTab(t)end)
 if #self.tabs==1 then self:SelectTab(t) end
 return t
end
function Tab:_base(height)
 local w=self.window
 local frame=make("Frame",{Size=UDim2.new(1,-4,0,height),BorderSizePixel=0},self.page)
 round(frame,4) w:_theme(frame,"BackgroundColor3","raised")
 return frame
end
function Tab:CreateSection(name)
 local f=self:_base(27)
 local l=make("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-12,1,0),Position=UDim2.fromOffset(6,0),Text=tostring(name),Font=Enum.Font.Code,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},f)
 self.window:_theme(l,"TextColor3","accent")
 return f
end
function Tab:CreateLabel(o)
 o=type(o)=="table" and o or {Text=o}
 local f=self:_base(32)
 local l=make("TextLabel",{BackgroundTransparency=1,Position=UDim2.fromOffset(8,0),Size=UDim2.new(1,-16,1,0),Text=tostring(o.Text or ""),TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Code,TextSize=14,TextWrapped=true},f)
 self.window:_theme(l,"TextColor3","text")
 return {SetText=function(_,v)l.Text=tostring(v)end}
end
function Tab:CreateButton(o)
 local w=self.window
 local f=self:_base(36)
 local b=make("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,Text="[ "..tostring(o.Name or "Button").." ]",Font=Enum.Font.Code,TextSize=15},f)
 w:_theme(b,"TextColor3","accent")
 w:_feedback(b,f)
 local disabled=false
 w._connections[#w._connections+1]=b.MouseButton1Click:Connect(function()if not disabled then fire(o.Callback)end end)
 return {SetDisabled=function(_,v)disabled=v==true b.TextTransparency=disabled and .5 or 0 end}
end
function Tab:CreateToggle(o)
 local w=self.window
 local f=self:_base(37)
 local value=o.Default==true
 local b=make("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},f)
 w:_theme(b,"TextColor3","text")
 w:_feedback(b,f)
 local function render()b.Text="  ["..(value and "X" or " ").."] "..tostring(o.Name or "Toggle")end
 local handle={}
 function handle:Get()return value end
 function handle:Set(v,notify)
  if type(v)~="boolean" then return false end
  value=v
  render()
  if notify then w:_markChanged("game") fire(o.Callback,value) end
  return true
 end
 w:_register(o.Flag,handle)
 w._connections[#w._connections+1]=b.MouseButton1Click:Connect(function()handle:Set(not value,true)end)
 render() return handle
end
function Tab:CreateSlider(o)
 local w=self.window
 local f=self:_base(55)
 local min,max=tonumber(o.Min) or 0,tonumber(o.Max) or 100
 if max<=min then max=min+1 end
 local inc=math.max(tonumber(o.Increment) or 1,0.000001)
 local value=math.clamp(tonumber(o.Default) or min,min,max)
 local name=make("TextLabel",{BackgroundTransparency=1,Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,0),Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},f)
 w:_theme(name,"TextColor3","text")
 local bar=make("TextButton",{Size=UDim2.new(1,-16,0,8),Position=UDim2.new(0,8,0,36),BorderSizePixel=0,Text="",AutoButtonColor=false},f)
 w:_theme(bar,"BackgroundColor3","panel")
 round(bar,4)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BorderSizePixel=0},bar)
 w:_theme(fill,"BackgroundColor3","accent")
 round(fill,4)
 local thumb=make("Frame",{
  AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),
  Size=UDim2.fromOffset(14,14),BorderSizePixel=0,Active=false
 },bar)
 w:_theme(thumb,"BackgroundColor3","accent")
 round(thumb,7)
 local handle={}
 local function render()
  name.Text=tostring(o.Name or "Slider").."  "..tostring(value)
  local progress=(value-min)/(max-min)
  fill.Size=UDim2.fromScale(progress,1)
  thumb.Position=UDim2.fromScale(progress,.5)
 end
 function handle:Get()return value end
 function handle:Set(v,notify)
  if type(v)~="number" then return end
  value=math.clamp(min+math.floor(((v-min)/inc)+.5)*inc,min,max)
  render()
  if notify then w:_markChanged("game") fire(o.Callback,value) end
 end
 local dragging=false
 w._connections[#w._connections+1]=bar.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true end
 end)
 w._connections[#w._connections+1]=UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
 end)
 w._connections[#w._connections+1]=UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   handle:Set(min+math.clamp((i.Position.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)*(max-min),true)
  end
 end)
 w:_register(o.Flag,handle) render() return handle
end
function Tab:CreateDropdown(o)
 -- Searchable popup, rendered at ScreenGui level to escape scrolling-frame clipping.
 o=o or {}
 local w=self.window
 local f=self:_base(70)
 local opts=o.Options or {}
 local value=table.find(opts,o.Default) and o.Default or opts[1]
 local lab=make("TextLabel",{Text=tostring(o.Name or "Dropdown"),BackgroundTransparency=1,Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,0),Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},f)
 w:_theme(lab,"TextColor3","text")
 local b=make("TextButton",{Size=UDim2.new(1,-14,0,31),Position=UDim2.fromOffset(7,30),Font=Enum.Font.Code,TextSize=13,BorderSizePixel=0,AutoButtonColor=false},f)
 w:_theme(b,"TextColor3","accent")
 w:_theme(b,"BackgroundColor3","panel")
 w:_feedback(b,f)
 local handle={}
 local function render() b.Text=tostring(value or "Select...").."  ▾" end
 function handle:Get() return value end
 function handle:Set(v,notify)
  if not table.find(opts,v) then return false end
  value=v
  render()
  if notify then w:_markChanged("game") fire(o.Callback,value) end
  return true
 end
 function handle:SetOptions(nextOptions)
  if type(nextOptions)~="table" then return end
  opts=nextOptions
  if not table.find(opts,value) then value=opts[1] end
  render()
  if w._closeDropdown then w._closeDropdown() end
 end
 w._connections[#w._connections+1]=b.MouseButton1Click:Connect(function()
  if w.destroyed then return end
  if w._dropdownOwner==b and w._closeDropdown then
   w._closeDropdown()
   return
  end
  if w._closeDropdown then w._closeDropdown() end
  local overlay=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=100},w.screen)
  local dismiss=make("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=101},overlay)
  local rows=math.min(#opts,6)
  local panelHeight=math.max(82,math.min(246,rows*29+46))
  local panelWidth=math.max(155,b.AbsoluteSize.X)
  local panel=make("Frame",{Size=UDim2.fromOffset(panelWidth,panelHeight),BorderSizePixel=0,ZIndex=102},overlay)
  panel.BackgroundColor3=w.colors.panel
  round(panel,5)
  make("UIStroke",{Color=w.colors.border,Thickness=1},panel)
  local function positionPanel()
   local viewport=workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize or Vector2.new(1280,720)
   local x=math.clamp(b.AbsolutePosition.X,6,math.max(6,viewport.X-panelWidth-6))
   local y=b.AbsolutePosition.Y+b.AbsoluteSize.Y+4
   if y+panelHeight>viewport.Y-8 then y=b.AbsolutePosition.Y-panelHeight-4 end
   y=math.clamp(y,6,math.max(6,viewport.Y-panelHeight-6))
   panel.Position=UDim2.fromOffset(x,y)
  end
  positionPanel()
  local search=make("TextBox",{
   Size=UDim2.new(1,-12,0,29),Position=UDim2.fromOffset(6,6),
   BackgroundColor3=w.colors.raised,TextColor3=w.colors.text,
   PlaceholderColor3=w.colors.muted,PlaceholderText="Search options...",
   Text="",ClearTextOnFocus=false,Font=Enum.Font.Code,TextSize=13,
   BorderSizePixel=0,ZIndex=104
  },panel)
  round(search,3)
  local list=make("ScrollingFrame",{
   Position=UDim2.fromOffset(6,41),Size=UDim2.new(1,-12,1,-47),
   BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,
   ScrollBarImageColor3=w.colors.border,AutomaticCanvasSize=Enum.AutomaticSize.Y,
   CanvasSize=UDim2.new(),ZIndex=103
  },panel)
  make("UIListLayout",{SortOrder=Enum.SortOrder.LayoutOrder,Padding=UDim.new(0,2)},list)
  local optionButtons={}
  local function updateList()
   for _,item in ipairs(optionButtons) do item:Destroy() end
   table.clear(optionButtons)
   local query=string.lower(search.Text)
   for _,option in ipairs(opts) do
    local label=tostring(option)
    if query=="" or string.find(string.lower(label),query,1,true) then
     local chosen=option
     local item=make("TextButton",{
      Text=(chosen==value and "✓  " or "   ")..label,
      Size=UDim2.new(1,-4,0,28),BackgroundColor3=w.colors.raised,
      TextColor3=chosen==value and w.colors.accent or w.colors.text,
      BorderSizePixel=0,Font=Enum.Font.Code,TextSize=13,
      TextXAlignment=Enum.TextXAlignment.Left,ZIndex=105
     },list)
     round(item,3)
     optionButtons[#optionButtons+1]=item
     item.MouseButton1Click:Connect(function()
      handle:Set(chosen,true)
      if w._closeDropdown then w._closeDropdown() end
     end)
    end
   end
   list.CanvasPosition=Vector2.zero
  end
  local positionConn=b:GetPropertyChangedSignal("AbsolutePosition"):Connect(positionPanel)
  local sizeConn=b:GetPropertyChangedSignal("AbsoluteSize"):Connect(positionPanel)
  w._dropdownOwner=b
  w._closeDropdown=function()
   if positionConn then positionConn:Disconnect() positionConn=nil end
   if sizeConn then sizeConn:Disconnect() sizeConn=nil end
   if overlay then overlay:Destroy() overlay=nil end
   w._closeDropdown=nil
   w._dropdownOwner=nil
  end
  dismiss.MouseButton1Click:Connect(function()
   if w._closeDropdown then w._closeDropdown() end
  end)
  search:GetPropertyChangedSignal("Text"):Connect(updateList)
  updateList()
 end)
 w:_register(o.Flag,handle)
 render()
 return handle
end
function Tab:CreateInput(o)
 local w=self.window
 local f=self:_base(64)
 local name=make("TextLabel",{Text=tostring(o.Name or "Input"),BackgroundTransparency=1,Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,0),Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},f)
 w:_theme(name,"TextColor3","text")
 local box=make("TextBox",{Text=tostring(o.Default or ""),PlaceholderText=tostring(o.Placeholder or ""),ClearTextOnFocus=false,Size=UDim2.new(1,-14,0,29),Position=UDim2.fromOffset(7,28),Font=Enum.Font.Code,TextSize=13,BorderSizePixel=0},f)
 w:_theme(box,"TextColor3","accent")w:_theme(box,"BackgroundColor3","panel")
 local outline=make("UIStroke",{Thickness=1,Color=w.colors.muted,Transparency=.45},box)
 w._connections[#w._connections+1]=box.Focused:Connect(function()
  outline.Color=w.colors.accent outline.Transparency=0
 end)
 local handle={}
 function handle:Get()return box.Text end
 function handle:Set(v,notify)
  if o.Numeric and tonumber(v)==nil then return end
  box.Text=tostring(v)
  if notify then w:_markChanged("game") fire(o.Callback,box.Text) end
 end
 w._connections[#w._connections+1]=box.FocusLost:Connect(function()
  outline.Color=w.colors.muted outline.Transparency=.45
  if not o.Numeric or tonumber(box.Text) then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,box.Text)
  end
 end)
 w:_register(o.Flag,handle) return handle
end
function Window:_register(flag,handle)
 if type(flag)=="string" and #flag>0 then self.flags[flag]=handle end
end
local memory={}
local function configObject(win,kind)
 local obj={}
 local function key(name)return "reefFishUI/"..(kind=="appearance" and "appearance/" or ("games/"..tostring(game.GameId).."/"))..name..".json" end
 function obj:Export()
  if kind=="appearance" then return HttpService:JSONEncode({version=1,theme=win.themeName,rain=win.rainEnabled,density=win.rainDensity,speed=win.rainSpeed}) end
  local flags={} for name,control in pairs(win.flags) do flags[name]=control:Get() end
  return HttpService:JSONEncode({version=1,gameId=game.GameId,flags=flags})
 end
 function obj:Import(source,options)
  local ok,data=pcall(HttpService.JSONDecode,HttpService,source)
  if not ok or type(data)~="table" then return false,"Invalid JSON" end
  if kind=="appearance" then
   if type(data.theme)=="string" then win:SetTheme(data.theme) end
   win:SetRain(data.rain,data.density,data.speed)
  else
   if type(data.flags)~="table" then return false,"Missing flags" end
   for flag,value in pairs(data.flags) do
    local ctl=win.flags[flag]
    if ctl and (type(value)=="boolean" or type(value)=="string" or type(value)=="number") then
     ctl:Set(value,options and options.FireCallbacks==true)
    end
   end
  end
  return true
 end
 function obj:Save(name)
  if not validName(name) then return false,"Invalid profile name" end
  local path=key(name) local data=self:Export()
  if not win.fs then memory[path]=data return true,"memory" end
  local ok,err=pcall(function()
   ensureDir(win.fs,path:match("^(.*)/[^/]+$"))
   win.fs.write(path,data)
  end)
  if not ok then return false,tostring(err) end
  return true,"file"
 end
 function obj:Load(name,options)
  if not validName(name) then return false,"Invalid profile name" end
  local path=key(name) local data=memory[path]
  if not data and win.fs then
   local ok,txt=pcall(win.fs.read,path)
   if ok then data=txt end
  end
  if not data then return false,"Profile not found" end
  return self:Import(data,options)
 end
 return obj
end
function Lib:CreateWindow(o)
 o=o or {}
 local player=Players.LocalPlayer
 assert(player,"reefFish must run in a client LocalScript")
 local colors=palettes[o.Theme] or palettes.MatrixInverse
 local w=setmetatable({
  width=math.max(330,o.Size and o.Size.X.Offset or 560),height=math.max(250,o.Size and o.Size.Y.Offset or 370),
  colors=colors,themeName=palettes[o.Theme] and o.Theme or "MatrixInverse",
  rainEnabled=true,rainDensity=.82,rainSpeed=.4,minimized=false,destroyed=false,
  flags={},tabs={},_bound={},_connections={},_feedbackRefresh={},
  _autosaveTargets={},_autosaveDue={},_importing=false,
  fs=storage(),borderThickness=math.clamp(tonumber(o.BorderThickness) or 12,9,16)
 },Window)
 w.StorageMode=w.fs and "file" or "memory"
 local parent=player:WaitForChild("PlayerGui")
 local registry=_G
 if type(getgenv)=="function" then
  local ok,env=pcall(getgenv)
  if ok and type(env)=="table" then registry=env end
 end
 local previous=registry.__reefFishWindow
 if previous and type(previous.Destroy)=="function" then
  pcall(function()previous:Destroy()end)
 end
 local old=parent:FindFirstChild("reefFishUI")
 if old then old:Destroy() end
 w._registry=registry
 registry.__reefFishWindow=w
 w.screen=make("ScreenGui",{Name="reefFishUI",ResetOnSpawn=false,IgnoreGuiInset=true,ZIndexBehavior=Enum.ZIndexBehavior.Sibling},parent)
 w.root=make("Frame",{Size=UDim2.fromOffset(w.width,w.height),Position=UDim2.new(.5,-w.width/2,.5,-w.height/2),BorderSizePixel=0,ClipsDescendants=true},w.screen)
 w:_theme(w.root,"BackgroundColor3","border")
 local pad=w.borderThickness
 local inner=make("Frame",{Size=UDim2.new(1,-2*pad,1,-2*pad),Position=UDim2.fromOffset(pad,pad),BorderSizePixel=0,ZIndex=5},w.root)
 w:_theme(inner,"BackgroundColor3","bg")
 w.inner=inner
 local top=make("Frame",{Size=UDim2.new(1,0,0,42),BorderSizePixel=0,ZIndex=6},inner)
 w:_theme(top,"BackgroundColor3","panel")
 local caption=make("TextLabel",{Text="reefFish // "..tostring(o.Title or "CONSOLE").."  [0.2.0]",Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-90,1,0),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Code,TextSize=16,ZIndex=7},top)
 w:_theme(caption,"TextColor3","accent")
 local min=make("TextButton",{Text="_",Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-72,0,6),BorderSizePixel=0,ZIndex=7},top)
 local close=make("TextButton",{Text="X",Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-37,0,6),BorderSizePixel=0,ZIndex=7},top)
 for _,b in ipairs({min,close}) do w:_theme(b,"BackgroundColor3","raised") w:_theme(b,"TextColor3","accent") end
 w.body=make("Frame",{Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,1,-66),BackgroundTransparency=1,ZIndex=6},inner)
 w.nav=make("ScrollingFrame",{Size=UDim2.new(.3,0,1,0),ScrollBarThickness=0,BackgroundTransparency=1,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=6},w.body)
 make("UIListLayout",{Padding=UDim.new(0,4)},w.nav)
 w.content=make("Frame",{Size=UDim2.new(.7,-5,1,0),Position=UDim2.new(.3,5,0,0),BackgroundTransparency=1,ZIndex=6},w.body)
 w._status=make("TextLabel",{Text="> reefFish 0.2.0 | PROFILES | ready_",Position=UDim2.new(0,8,1,-24),Size=UDim2.new(1,-16,0,22),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Code,TextSize=12,ZIndex=6},inner)
 w:_theme(w._status,"TextColor3","muted")
 w._connections[#w._connections+1]=min.MouseButton1Click:Connect(function()w:SetMinimized(not w.minimized)end)
 w._connections[#w._connections+1]=close.MouseButton1Click:Connect(function()w:Destroy()end)
 local drag=false local dragStart,startPos
 w._connections[#w._connections+1]=top.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=true dragStart=i.Position startPos=w.root.Position end
 end)
 w._connections[#w._connections+1]=UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
 end)
 w._connections[#w._connections+1]=UIS.InputChanged:Connect(function(i)
  if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   local diff=i.Position-dragStart
   w.root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+diff.X,startPos.Y.Scale,startPos.Y.Offset+diff.Y)
  end
 end)
 -- reefFish v0.1.3: full-window VERTICAL matrix rain, with a border mask.
 -- This intentionally looks like a conventional rain wallpaper:
 -- every column falls DOWN only, its tail fading from pale ink to near-black.
 -- The entire wallpaper drifts only 0.2-0.5 pixels RIGHT per second.
 -- The solid inner UI frame occludes the rain, leaving it visible in the bezel.
 --
 -- Rendering optimization: ONE multiline RichText TextLabel per column.
 -- No separate edge loops, sideways-moving letters, or per-frame object creation.
 local glyphs={"0","1","2","3","4","5","6","7","8","9",
  "ア","イ","ウ","エ","オ","カ","キ","ク","ケ","コ",
  "サ","シ","ス","セ","ソ","タ","チ","ツ","テ","ト",
  "ナ","ニ","ヌ","ネ","ノ","ハ","ヒ","フ","ヘ","ホ",
  "マ","ミ","ム","メ","モ","ヤ","ユ","ヨ","ラ","リ",
  "ル","レ","ロ","ワ","ヲ","ン"}
 local cell=10
 local spacing=9
 local count=math.ceil(w.width/spacing)+4
 local fieldPeriod=count*spacing
 local streams={}
 local rainLayer=make("Frame",{
  Name="MatrixWallpaper",
  Size=UDim2.fromScale(1,1),
  BackgroundTransparency=1,BorderSizePixel=0,
  ClipsDescendants=true,Active=false,ZIndex=2
 },w.root)
 w._rainLayer=rainLayer
 local function hex(c)
  return string.format("#%02X%02X%02X",
   math.floor(c.R*255+.5),
   math.floor(c.G*255+.5),
   math.floor(c.B*255+.5))
 end
 local function updateText(stream,initial)
  local lines={}
  local length=stream.length
  local visible=math.floor(length*w.rainDensity+.5)
  for n=1,length do
   local shown=visible>0 and n>length-visible
   -- Inverse Matrix: the falling HEAD at the bottom is near-black;
   -- the older tail above fades into the green border background.
   -- This is the inverse of green-on-black rain, NOT a flipped stream.
   if initial or stream.glyphs[n]==nil or n==length or math.random()<.15 then
    stream.glyphs[n]=glyphs[math.random(#glyphs)]
   end
   local distance=math.clamp((n-(length-visible))/math.max(visible,1),0,1)
   local contrast=distance*distance
   local color=w.colors.border:Lerp(w.colors.ink,contrast)
   local char=shown and stream.glyphs[n] or " "
   lines[n]='<font color="'..hex(color)..'">'..char..'</font>'
  end
  stream.label.Text=table.concat(lines,"\n")
 end
 for col=1,count do
  local length=math.random(8,14)
  local label=make("TextLabel",{
   Name="RainColumn",
   Size=UDim2.fromOffset(cell,length*cell+10),
   Position=UDim2.fromOffset((col-2)*spacing,-length*cell),
   BackgroundTransparency=1,BorderSizePixel=0,
   Font=Enum.Font.Code,TextSize=10,LineHeight=1,
   TextXAlignment=Enum.TextXAlignment.Center,
   TextYAlignment=Enum.TextYAlignment.Top,
   RichText=true,TextWrapped=false,TextScaled=false,
   Text="0",ZIndex=3
  },rainLayer)
  local stream={
   label=label,length=length,
   y=math.random(-w.height,w.height),
   x=(col-2)*spacing,
   speed=math.random(25,60),
   change=math.random(),
   seed=col,glyphs={}
  }
  streams[col]=stream
  updateText(stream,true)
 end
 w._rainColumns=streams
 w._repaintRain=function()
  for _,stream in ipairs(streams) do updateText(stream) end
 end
 local elapsedBuffer=0
 local drift=0
 w._connections[#w._connections+1]=RunService.Heartbeat:Connect(function(dt)
  if w.destroyed or not w.rainEnabled or w.minimized then return end
  elapsedBuffer+=dt
  if elapsedBuffer<.07 then return end -- at most 14 updates/second
  local elapsed=math.min(elapsedBuffer,.20)
  elapsedBuffer=0
  local width=w.root.AbsoluteSize.X
  local height=w.root.AbsoluteSize.Y
  if width<=0 or height<=0 then return end
  drift=(drift+elapsed*(.18+.30*w.rainSpeed))%fieldPeriod
  local velocityScale=.6+w.rainSpeed
  for _,stream in ipairs(streams) do
   -- Falling is the dominant motion. Never advance glyphs horizontally
   -- individually. Only the background-wide drift affects X.
   stream.y=stream.y+stream.speed*velocityScale*elapsed
   if stream.y>height+stream.length*cell then
    stream.y=-stream.length*cell-math.random(0,math.floor(height*.5))
    stream.speed=math.random(25,60)
   end
   stream.change=stream.change+elapsed
   if stream.change>=.26 then
    stream.change=stream.change-.26
    updateText(stream)
   end
   local x=((stream.x+drift+spacing)%fieldPeriod)-spacing
   stream.label.Position=UDim2.fromOffset(math.floor(x),math.floor(stream.y-stream.length*cell))
   stream.label.Visible=x<width and x+cell>0 and stream.y>-cell
     and stream.y-stream.length*cell<height
  end
 end)
 w.Config=configObject(w,"game")
 w.Appearance=configObject(w,"appearance")
 if not o.HideBuiltins then
  local appearance=w:CreateTab({Name="APPEARANCE"})
  appearance:CreateSection("CONSOLE STYLE")
  appearance:CreateDropdown({Name="Theme",Options={"MatrixInverse","ClassicCRT","AmberTerminal","IceConsole","Monochrome"},Default=w.themeName,Callback=function(v)w:SetTheme(v)end})
  appearance:CreateToggle({Name="Matrix rain",Default=true,Callback=function(v)w:SetRain(v)end})
  appearance:CreateButton({Name="Save appearance",Callback=function()local ok,why=w.Appearance:Save("default")w:Notify(why,ok and "ok" or "error")end})
  appearance:CreateButton({Name="Load appearance",Callback=function()local ok,why=w.Appearance:Load("default")w:Notify(ok and "Appearance loaded" or why,ok and "ok" or "error")end})
  local config=w:CreateTab({Name="CONFIG"})
  config:CreateSection("GAME SETTINGS")
  config:CreateButton({Name="Save default profile",Callback=function()local ok,why=w.Config:Save("default")w:Notify(why,ok and "ok" or "error")end})
  config:CreateButton({Name="Load default profile",Callback=function()local ok,why=w.Config:Load("default")w:Notify(ok and "Loaded" or why,ok and "ok" or "error")end})
 end
 return w
end
return Lib
