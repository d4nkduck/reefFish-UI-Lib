-- reefFish UI Lib v0.3.0-alpha
-- MIT License | Console-style Roblox Luau UI
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local TweenService=game:GetService("TweenService")
local Lib={Version="0.3.0-alpha"}
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

local function colorHex(color)
 return string.format("#%02X%02X%02X",
  math.floor(color.R*255+.5),math.floor(color.G*255+.5),math.floor(color.B*255+.5))
end
local function parseColor(value)
 if typeof(value)=="Color3" then return value end
 if type(value)=="string" then
  local h=value:gsub("#","")
  if #h==6 and h:match("^[0-9a-fA-F]+$") then
   return Color3.fromRGB(tonumber(h:sub(1,2),16),tonumber(h:sub(3,4),16),tonumber(h:sub(5,6),16))
  end
 end
 return nil
end
local function packValue(v)
 if typeof(v)=="Color3" then
  return {__reefFishType="Color3",R=v.R,G=v.G,B=v.B}
 end
 if type(v)=="boolean" or type(v)=="string" or type(v)=="number" then return v end
 if type(v)=="table" then
  local out={}
  if #v>100 then return nil end
  for i,item in ipairs(v) do
   if type(item)~="string" then return nil end
   out[i]=item
  end
  return out
 end
 return nil
end
local function unpackValue(v)
 if type(v)=="table" then
  if v.__reefFishType=="Color3" then
   if type(v.R)~="number" or type(v.G)~="number" or type(v.B)~="number" then return nil end
   if v.R~=v.R or v.G~=v.G or v.B~=v.B then return nil end
   return Color3.new(math.clamp(v.R,0,1),math.clamp(v.G,0,1),math.clamp(v.B,0,1))
  end
  if v.__reefFishType~=nil or #v>100 then return nil end
  local out={}
  for i,item in ipairs(v) do
   if type(item)~="string" then return nil end
   out[i]=item
  end
  return out
 end
 if type(v)=="boolean" or type(v)=="string" or type(v)=="number" then return v end
 return nil
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
 self.themeName=name self.colors=table.clone(palettes[name])
 for _,bound in ipairs(self._bound) do if bound[1].Parent then bound[1][bound[2]]=self.colors[bound[3]] end end
 for _,refresh in ipairs(self._feedbackRefresh) do refresh() end
 if self.active then self:SelectTab(self.active) end
 if self._repaintRain then self._repaintRain() end
 self:_markChanged("appearance")
 return true
end

function Window:SetAccentColor(value)
 local color=parseColor(value)
 if not color then return false end
 self.colors.accent=color
 for _,bound in ipairs(self._bound) do
  if bound[3]=="accent" and bound[1].Parent then bound[1][bound[2]]=color end
 end
 for _,refresh in ipairs(self._feedbackRefresh) do refresh() end
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
-- Small capped toast queue with a timed dismissal.
function Window:Toast(info)
 info=type(info)=="table" and info or {Content=tostring(info)}
 if self.destroyed or not self._toastLayer then return nil end
 local title=tostring(info.Title or "REEFFISH")
 local content=tostring(info.Content or info.Message or "")
 local duration=math.clamp(tonumber(info.Duration) or 4,1,15)
 if #self._toasts>=4 then
  local oldest=table.remove(self._toasts,1)
  if oldest and oldest.Parent then oldest:Destroy() end
 end
 local frame=make("Frame",{
  Size=UDim2.new(1,0,0,58),BackgroundColor3=self.colors.panel,
  BackgroundTransparency=1,BorderSizePixel=0,ZIndex=180
 },self._toastLayer)
 round(frame,4)
 make("UIStroke",{Color=self.colors.border,Thickness=1,Transparency=.2},frame)
 local heading=make("TextLabel",{
  Text="> "..title,TextColor3=self.colors.accent,BackgroundTransparency=1,
  Position=UDim2.fromOffset(8,3),Size=UDim2.new(1,-26,0,22),
  TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Code,TextSize=13,
  TextTransparency=1,ZIndex=181
 },frame)
 local body=make("TextLabel",{
  Text=content,TextColor3=self.colors.text,BackgroundTransparency=1,
  Position=UDim2.fromOffset(8,23),Size=UDim2.new(1,-16,0,31),
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
  TextWrapped=true,Font=Enum.Font.Code,TextSize=12,TextTransparency=1,ZIndex=181
 },frame)
 local close=make("TextButton",{
  Text="×",TextColor3=self.colors.muted,BackgroundTransparency=1,
  Position=UDim2.new(1,-25,0,1),Size=UDim2.fromOffset(23,22),
  Font=Enum.Font.Code,TextSize=16,ZIndex=182
 },frame)
 table.insert(self._toasts,frame)
 local function dismiss()
  if not frame.Parent then return end
  for i=#self._toasts,1,-1 do if self._toasts[i]==frame then table.remove(self._toasts,i) end end
  TweenService:Create(frame,TweenInfo.new(.16),{BackgroundTransparency=1}):Play()
  TweenService:Create(heading,TweenInfo.new(.16),{TextTransparency=1}):Play()
  TweenService:Create(body,TweenInfo.new(.16),{TextTransparency=1}):Play()
  task.delay(.18,function()if frame.Parent then frame:Destroy() end end)
 end
 close.MouseButton1Click:Connect(dismiss)
 TweenService:Create(frame,TweenInfo.new(.2),{BackgroundTransparency=.05}):Play()
 TweenService:Create(heading,TweenInfo.new(.2),{TextTransparency=0}):Play()
 TweenService:Create(body,TweenInfo.new(.2),{TextTransparency=.05}):Play()
 task.delay(duration,dismiss)
 return {Dismiss=dismiss}
end
function Window:Notify(msg,kind)
 self._status.Text="["..string.upper(tostring(kind or "INFO")).."] "..tostring(msg)
 if self.enableToasts then
  self:Toast({Title=kind or "INFO",Content=tostring(msg),Duration=3.5})
 end
end
function Window:SetHidden(value)
 self.hidden=value==true
 if self._closeDropdown then self._closeDropdown() end
 self.screen.Enabled=not self.hidden
 return self.hidden
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
 self._bindingCapture=nil
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
 return {
  SetText=function(_,v)l.Text=tostring(v)end,
  Get=function()return l.Text end,
  SetVisible=function(_,v)f.Visible=v~=false end,
  Destroy=function()f:Destroy()end
 }
end
function Tab:CreateButton(o)
 local w=self.window
 local f=self:_base(36)
 local b=make("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,Text="[ "..tostring(o.Name or "Button").." ]",Font=Enum.Font.Code,TextSize=15},f)
 w:_theme(b,"TextColor3","accent")
 w:_feedback(b,f)
 local disabled=false
 w._connections[#w._connections+1]=b.MouseButton1Click:Connect(function()if not disabled then fire(o.Callback)end end)
 return {
  SetDisabled=function(_,v)disabled=v==true b.TextTransparency=disabled and .5 or 0 end,
  SetVisible=function(_,v)f.Visible=v~=false end,
  Destroy=function()f:Destroy()end
 }
end
function Tab:CreateToggle(o)
 local w=self.window
 local f=self:_base(37)
 local value=o.Default==true
 local b=make("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},f)
 w:_theme(b,"TextColor3","text")
 w:_feedback(b,f)
 local disabled=false
 local function render()b.Text="  ["..(value and "X" or " ").."] "..tostring(o.Name or "Toggle")end
 local handle={}
 function handle:SetDisabled(v)disabled=v==true b.TextTransparency=disabled and .5 or 0 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 function handle:Get()return value end
 function handle:Set(v,notify)
  if type(v)~="boolean" then return false end
  value=v
  render()
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,value)
  end
  return true
 end
 w:_register(o.Flag,handle)
 w._connections[#w._connections+1]=b.MouseButton1Click:Connect(function()
  if not disabled then handle:Set(not value,true) end
 end)
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
 local disabled=false
 function handle:SetDisabled(v)disabled=v==true f.BackgroundTransparency=disabled and .5 or 0 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
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
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,value)
  end
 end
 local dragging=false
 w._connections[#w._connections+1]=bar.InputBegan:Connect(function(i)
  if not disabled and (i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch) then dragging=true end
 end)
 w._connections[#w._connections+1]=UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
 end)
 w._connections[#w._connections+1]=UIS.InputChanged:Connect(function(i)
  if not disabled and dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
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
 local multi=o.Multi==true
 local value
 if multi then
  value={}
  if type(o.Default)=="table" then
   for _,entry in ipairs(o.Default) do
    if table.find(opts,entry) and not table.find(value,entry) then table.insert(value,entry) end
   end
  end
 else
  value=table.find(opts,o.Default) and o.Default or opts[1]
 end
 local lab=make("TextLabel",{Text=tostring(o.Name or "Dropdown"),BackgroundTransparency=1,Size=UDim2.new(1,-12,0,25),Position=UDim2.fromOffset(6,0),Font=Enum.Font.Code,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},f)
 w:_theme(lab,"TextColor3","text")
 local b=make("TextButton",{Size=UDim2.new(1,-14,0,31),Position=UDim2.fromOffset(7,30),Font=Enum.Font.Code,TextSize=13,BorderSizePixel=0,AutoButtonColor=false},f)
 w:_theme(b,"TextColor3","accent")
 w:_theme(b,"BackgroundColor3","panel")
 w:_feedback(b,f)
 local handle={}
 local disabled=false
 function handle:SetDisabled(v)disabled=v==true b.TextTransparency=disabled and .5 or 0 end
 function handle:SetVisible(v)
  f.Visible=v~=false
  if not f.Visible and w._dropdownOwner==b and w._closeDropdown then w._closeDropdown() end
 end
 function handle:Destroy()
  if w._dropdownOwner==b and w._closeDropdown then w._closeDropdown() end
  f:Destroy()
 end
 local function render()
  if multi then b.Text=(#value==0 and "Select..." or table.concat(value,", ")).."  ▾"
  else b.Text=tostring(value or "Select...").."  ▾" end
 end
 function handle:Get()
  if not multi then return value end
  return table.clone(value)
 end
 function handle:Set(v,notify)
  if multi then
   if type(v)~="table" or #v>100 then return false end
   local selected={}
   for _,entry in ipairs(v) do
    if type(entry)~="string" or not table.find(opts,entry) then return false end
    if not table.find(selected,entry) then table.insert(selected,entry) end
   end
   value=selected
  else
   if not table.find(opts,v) then return false end
   value=v
  end
  render()
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,handle:Get())
  end
  return true
 end
 function handle:SetOptions(nextOptions)
  if type(nextOptions)~="table" then return end
  opts=nextOptions
  if multi then
   local selected={}
   for _,entry in ipairs(value) do
    if table.find(opts,entry) then table.insert(selected,entry) end
   end
   value=selected
  elseif not table.find(opts,value) then value=opts[1] end
  render()
  if w._closeDropdown then w._closeDropdown() end
 end
 w._connections[#w._connections+1]=b.MouseButton1Click:Connect(function()
  if w.destroyed or disabled then return end
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
      Text=((multi and table.find(value,chosen)~=nil or chosen==value) and "✓  " or "   ")..label,
      Size=UDim2.new(1,-4,0,28),BackgroundColor3=w.colors.raised,
      TextColor3=chosen==value and w.colors.accent or w.colors.text,
      BorderSizePixel=0,Font=Enum.Font.Code,TextSize=13,
      TextXAlignment=Enum.TextXAlignment.Left,ZIndex=105
     },list)
     round(item,3)
     optionButtons[#optionButtons+1]=item
     item.MouseButton1Click:Connect(function()
      if multi then
       local nextValue=table.clone(value)
       local index=table.find(nextValue,chosen)
       if index then table.remove(nextValue,index) else table.insert(nextValue,chosen) end
       handle:Set(nextValue,true)
       updateList()
      else
       handle:Set(chosen,true)
       if w._closeDropdown then w._closeDropdown() end
      end
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
function Tab:CreateMultiDropdown(o)
 o=o or {}
 o.Multi=true
 return self:CreateDropdown(o)
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
 function handle:SetDisabled(v)box.TextEditable=v~=true end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
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
-- A readable paragraph card for long help or diagnostic descriptions.
function Tab:CreateParagraph(o)
 o=o or {}
 local w=self.window
 local f=self:_base(math.clamp(tonumber(o.Height) or 82,56,220))
 local heading=make("TextLabel",{
  Position=UDim2.fromOffset(9,5),Size=UDim2.new(1,-18,0,23),
  BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
  Font=Enum.Font.Code,TextSize=15,Text=tostring(o.Title or "INFORMATION")
 },f)
 w:_theme(heading,"TextColor3","accent")
 local content=make("TextLabel",{
  Position=UDim2.fromOffset(9,30),Size=UDim2.new(1,-18,1,-36),
  BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
  TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,
  Font=Enum.Font.Code,TextSize=13,Text=tostring(o.Content or "")
 },f)
 w:_theme(content,"TextColor3","text")
 local handle={}
 function handle:Set(title,body)
  if type(title)=="table" then
   heading.Text=tostring(title.Title or heading.Text)
   content.Text=tostring(title.Content or content.Text)
  else
   heading.Text=tostring(title or heading.Text)
   if body~=nil then content.Text=tostring(body) end
  end
 end
 function handle:Get()return {Title=heading.Text,Content=content.Text}end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 return handle
end

-- Original, self-contained HSV colour picker; no external UI assets.
-- Supports Color3 or #RRGGBB input, a hue strip, and an SV square.
function Tab:CreateColorPicker(o)
 o=o or {}
 local w=self.window
 local f=self:_base(230)
 local initial=parseColor(o.Default or o.Color) or w.colors.accent
 local hue,saturation,value=initial:ToHSV()
 local disabled=false
 local heading=make("TextLabel",{
  Text=tostring(o.Name or "Colour picker"),Font=Enum.Font.Code,TextSize=14,
  TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
  Position=UDim2.fromOffset(9,4),Size=UDim2.new(1,-82,0,22)
 },f)
 w:_theme(heading,"TextColor3","text")
 local swatch=make("Frame",{
  Position=UDim2.new(1,-43,0,7),Size=UDim2.fromOffset(30,18),
  BackgroundColor3=initial,BorderSizePixel=0
 },f)
 round(swatch,3)
 local picker=make("Frame",{
  Position=UDim2.fromOffset(9,33),Size=UDim2.new(1,-18,0,98),
  Active=true,ClipsDescendants=true,BackgroundColor3=Color3.fromHSV(hue,1,1),
  BorderSizePixel=0
 },f)
 round(picker,3)
 local white=make("Frame",{
  Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(1,1,1),
  BorderSizePixel=0,Active=false
 },picker)
 make("UIGradient",{
  Transparency=NumberSequence.new({
   NumberSequenceKeypoint.new(0,0),
   NumberSequenceKeypoint.new(1,1)
  })
 },white)
 local dark=make("Frame",{
  Size=UDim2.fromScale(1,1),BackgroundColor3=Color3.new(0,0,0),
  BorderSizePixel=0,Active=false
 },picker)
 make("UIGradient",{
  Rotation=90,Transparency=NumberSequence.new({
   NumberSequenceKeypoint.new(0,1),
   NumberSequenceKeypoint.new(1,0)
  })
 },dark)
 local target=make("Frame",{
  AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(9,9),
  BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Active=false
 },picker)
 round(target,5)
 make("UIStroke",{Color=Color3.new(0,0,0),Thickness=1},target)
 local hueBar=make("Frame",{
  Position=UDim2.fromOffset(9,139),Size=UDim2.new(1,-18,0,12),
  BackgroundColor3=Color3.fromRGB(255,0,0),BorderSizePixel=0,Active=true
 },f)
 round(hueBar,3)
 make("UIGradient",{
  Color=ColorSequence.new({
   ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),
   ColorSequenceKeypoint.new(.17,Color3.fromRGB(255,255,0)),
   ColorSequenceKeypoint.new(.33,Color3.fromRGB(0,255,0)),
   ColorSequenceKeypoint.new(.5,Color3.fromRGB(0,255,255)),
   ColorSequenceKeypoint.new(.67,Color3.fromRGB(0,0,255)),
   ColorSequenceKeypoint.new(.83,Color3.fromRGB(255,0,255)),
   ColorSequenceKeypoint.new(1,Color3.fromRGB(255,0,0))
  })
 },hueBar)
 local hueMarker=make("Frame",{
  AnchorPoint=Vector2.new(.5,.5),Size=UDim2.fromOffset(4,17),
  BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Active=false
 },hueBar)
 local hex=make("TextBox",{
  Position=UDim2.fromOffset(9,159),Size=UDim2.new(1,-18,0,25),
  Text=colorHex(initial),Font=Enum.Font.Code,TextSize=13,
  ClearTextOnFocus=false,BorderSizePixel=0,
  BackgroundColor3=w.colors.panel,TextColor3=w.colors.accent
 },f)
 round(hex,3)
 local outline=make("UIStroke",{Color=w.colors.muted,Thickness=1,Transparency=.5},hex)
 local rgbFields={}
 for channel,name in ipairs({"R","G","B"}) do
  local x=9+(channel-1)*76
  local caption=make("TextLabel",{
   Position=UDim2.fromOffset(x,191),Size=UDim2.fromOffset(16,25),
   BackgroundTransparency=1,Text=name,TextColor3=w.colors.muted,
   Font=Enum.Font.Code,TextSize=12
  },f)
  local field=make("TextBox",{
   Position=UDim2.fromOffset(x+18,191),Size=UDim2.fromOffset(50,25),
   BackgroundColor3=w.colors.panel,TextColor3=w.colors.accent,
   Font=Enum.Font.Code,TextSize=12,BorderSizePixel=0,
   ClearTextOnFocus=false,Text="0"
  },f)
  round(field,3)
  rgbFields[channel]=field
 end
 local function repaint()
  local c=Color3.fromHSV(hue,saturation,value)
  picker.BackgroundColor3=Color3.fromHSV(hue,1,1)
  swatch.BackgroundColor3=c
  target.Position=UDim2.fromScale(saturation,1-value)
  hueMarker.Position=UDim2.fromScale(hue,.5)
  if not hex:IsFocused() then hex.Text=colorHex(c) end
  local channels={c.R,c.G,c.B}
  for i,field in ipairs(rgbFields) do
   if not field:IsFocused() then field.Text=tostring(math.floor(channels[i]*255+.5)) end
  end
 end
 local handle={}
 function handle:Get()return Color3.fromHSV(hue,saturation,value)end
 function handle:GetHex()return colorHex(handle:Get())end
 function handle:GetRGB()
  local c=handle:Get()
  return math.floor(c.R*255+.5),math.floor(c.G*255+.5),math.floor(c.B*255+.5)
 end
 function handle:SetRGB(r,g,b,notify)
  if type(r)~="number" or type(g)~="number" or type(b)~="number" then return false end
  return handle:Set(Color3.fromRGB(math.clamp(math.floor(r+.5),0,255),
   math.clamp(math.floor(g+.5),0,255),math.clamp(math.floor(b+.5),0,255)),notify)
 end
 function handle:Set(c,notify)
  local parsed=parseColor(c)
  if not parsed then return false end
  hue,saturation,value=parsed:ToHSV()
  repaint()
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,handle:Get())
  end
  return true
 end
 function handle:SetDisabled(v)
  disabled=v==true
  f.BackgroundTransparency=disabled and .45 or 0
 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 local dragging=nil
 local function applyInput(which,pos)
  if disabled then return end
  if which=="sv" then
   saturation=math.clamp((pos.X-picker.AbsolutePosition.X)/math.max(1,picker.AbsoluteSize.X),0,1)
   value=1-math.clamp((pos.Y-picker.AbsolutePosition.Y)/math.max(1,picker.AbsoluteSize.Y),0,1)
  else
   hue=math.clamp((pos.X-hueBar.AbsolutePosition.X)/math.max(1,hueBar.AbsoluteSize.X),0,1)
  end
  repaint()
  if o.Flag then w:_markChanged("game") end
  fire(o.Callback,handle:Get())
 end
 w._connections[#w._connections+1]=picker.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   dragging="sv" applyInput(dragging,i.Position)
  end
 end)
 w._connections[#w._connections+1]=hueBar.InputBegan:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   dragging="hue" applyInput(dragging,i.Position)
  end
 end)
 w._connections[#w._connections+1]=UIS.InputChanged:Connect(function(i)
  if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
   applyInput(dragging,i.Position)
  end
 end)
 w._connections[#w._connections+1]=UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   dragging=nil
  end
 end)
 w._connections[#w._connections+1]=hex.Focused:Connect(function()outline.Color=w.colors.accent outline.Transparency=0 end)
 w._connections[#w._connections+1]=hex.FocusLost:Connect(function()
  outline.Color=w.colors.muted outline.Transparency=.5
  if not handle:Set(hex.Text,true) then hex.Text=handle:GetHex() end
 end)
 for _,field in ipairs(rgbFields) do
  w._connections[#w._connections+1]=field.FocusLost:Connect(function()
   local rgb={}
   for i,box in ipairs(rgbFields) do rgb[i]=tonumber(box.Text) end
   if rgb[1] and rgb[2] and rgb[3] then
    handle:SetRGB(rgb[1],rgb[2],rgb[3],true)
   else
    repaint()
   end
  end)
 end
 w:_register(o.Flag,handle)
 repaint()
 return handle
end

-- Keybinds use the window's shared input dispatcher rather than one
-- global InputBegan/InputEnded listener for every keybind.
function Tab:CreateKeybind(o)
 o=o or {}
 local w=self.window
 local f=self:_base(43)
 local mode=o.Mode or "Toggle"
 if mode~="Hold" and mode~="Toggle" and mode~="Press" then mode="Toggle" end
 local label=make("TextLabel",{
  Text=tostring(o.Name or "Keybind"),Font=Enum.Font.Code,
  TextSize=14,BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,
  Position=UDim2.fromOffset(8,0),Size=UDim2.new(.56,-8,1,0)
 },f)
 w:_theme(label,"TextColor3","text")
 local button=make("TextButton",{
  Size=UDim2.new(.42,-8,0,30),Position=UDim2.new(.58,0,0,7),
  BackgroundColor3=w.colors.panel,TextColor3=w.colors.accent,
  Text="[ NONE ]",Font=Enum.Font.Code,TextSize=13,BorderSizePixel=0
 },f)
 round(button,3)
 local selected=nil
 local active=false
 local disabled=false
 local handle={}
 local function redraw()
  button.Text="["..(selected or "NONE").."]"
 end
 function handle:Get()return selected or "None"end
 function handle:Set(candidate,notify)
  local name=typeof(candidate)=="EnumItem" and candidate.Name or candidate
  if type(name)~="string" then return false end
  if name=="None" or name=="" then selected=nil
  else
   local okKey,key=pcall(function()return Enum.KeyCode[name]end)
   if not okKey or not key or name=="Unknown" or name==w.toggleKey.Name then return false end
   selected=name
  end
  active=false
  redraw()
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.OnChanged,selected)
  end
  return true
 end
 function handle:SetDisabled(v)disabled=v==true button.TextTransparency=disabled and .6 or 0 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()
  if w._bindingCapture==handle then w._bindingCapture=nil end
  for i=#w._keybinds,1,-1 do if w._keybinds[i]==handle then table.remove(w._keybinds,i) end end
  f:Destroy()
 end
 function handle:_input(down)
  if disabled or not f.Parent then return end
  if mode=="Hold" then
   if active~=down then active=down fire(o.Callback,active,selected) end
  elseif down and mode=="Press" then
   fire(o.Callback,true,selected)
  elseif down then
   active=not active
   fire(o.Callback,active,selected)
  end
 end
 w._connections[#w._connections+1]=button.MouseButton1Click:Connect(function()
  if disabled then return end
  w._bindingCapture=handle
  button.Text="[ PRESS KEY ]"
 end)
 handle:Set(o.Default or "None")
 table.insert(w._keybinds,handle)
 w:_register(o.Flag,handle)
 redraw()
 return handle
end

function Tab:CreateTextArea(o)
 o=o or {}
 local w=self.window
 local height=math.clamp(tonumber(o.Height) or 120,80,240)
 local f=self:_base(height)
 local label=make("TextLabel",{
  Text=tostring(o.Name or "JSON"),BackgroundTransparency=1,
  Position=UDim2.fromOffset(6,3),Size=UDim2.new(1,-12,0,22),
  Font=Enum.Font.Code,TextSize=13,TextXAlignment=Enum.TextXAlignment.Left
 },f)
 w:_theme(label,"TextColor3","accent")
 local box=make("TextBox",{
  Size=UDim2.new(1,-12,1,-30),Position=UDim2.fromOffset(6,26),
  BackgroundColor3=w.colors.panel,TextColor3=w.colors.text,
  PlaceholderColor3=w.colors.muted,Text=tostring(o.Default or ""),
  PlaceholderText=tostring(o.Placeholder or "Paste JSON here..."),
  ClearTextOnFocus=false,MultiLine=true,TextWrapped=true,
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
  Font=Enum.Font.Code,TextSize=12,BorderSizePixel=0
 },f)
 round(box,3)
 local outline=make("UIStroke",{Color=w.colors.muted,Transparency=.55,Thickness=1},box)
 w._connections[#w._connections+1]=box.Focused:Connect(function()
  outline.Color=w.colors.accent outline.Transparency=0
 end)
 w._connections[#w._connections+1]=box.FocusLost:Connect(function()
  outline.Color=w.colors.muted outline.Transparency=.55
 end)
 local handle={}
 function handle:Get()return box.Text end
 function handle:Set(v)box.Text=tostring(v or "")end
 function handle:SetDisabled(v)box.TextEditable=v~=true end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 return handle
end
function Window:_register(flag,handle)
 if type(flag)=="string" and #flag>0 then self.flags[flag]=handle end
end
local memory={}
local function configObject(win,kind)
 local obj={}
 local folder="reefFishUI/"..(kind=="appearance" and "appearance" or ("games/"..tostring(game.GameId)))
 local function path(name)return folder.."/"..name..".json"end

 local function readRaw(name)
  if not validName(name) then return nil,"Invalid profile name" end
  local file=path(name)
  if win.fs then
   local ok,value=pcall(win.fs.read,file)
   if ok and type(value)=="string" then return value end
  end
  return memory[file],"Profile not found"
 end
 local function writeRaw(name,content)
  if not validName(name) then return false,"Invalid profile name" end
  if type(content)~="string" then return false,"Profile data must be text" end
  local file=path(name)
  if win.fs then
   local ok,err=pcall(function()
    ensureDir(win.fs,folder)
    win.fs.write(file,content)
   end)
   if not ok then return false,tostring(err) end
   memory[file]=content
   return true,"file"
  end
  memory[file]=content
  return true,"memory"
 end
 function obj:List()
  local names={}
  local found={}
  local function add(name)
   if validName(name) and not found[name] then
    found[name]=true
    names[#names+1]=name
   end
  end
  for p in pairs(memory) do
   if p:sub(1,#folder+1)==folder.."/" then
    add(p:sub(#folder+2):match("^([^/]+)%.json$"))
   end
  end
  if win.fs and type(win.fs.list)=="function" then
   local ok,paths=pcall(win.fs.list,folder)
   if ok and type(paths)=="table" then
    for _,filename in ipairs(paths) do
     if type(filename)=="string" then
      local normalized=filename:gsub("\\","/")
      add(normalized:match("([^/]+)%.json$"))
     end
    end
   end
  end
  table.sort(names)
  return names
 end
 function obj:Export()
  if kind=="appearance" then
   return HttpService:JSONEncode({
    version=1,theme=win.themeName,rain=win.rainEnabled,
    density=win.rainDensity,speed=win.rainSpeed,
    borderThickness=win.borderThickness,
    accent=packValue(win.colors.accent)
   })
  end
  local flags={}
  for name,control in pairs(win.flags) do
   local value=packValue(control:Get())
   if value~=nil then flags[name]=value end
  end
  return HttpService:JSONEncode({version=1,gameId=game.GameId,flags=flags})
 end
 function obj:Import(source,options)
  if type(source)~="string" then return false,"Expected JSON text" end
  local ok,data=pcall(HttpService.JSONDecode,HttpService,source)
  if not ok or type(data)~="table" then return false,"Invalid JSON" end
  if data.version~=1 then return false,"Unsupported profile schema" end
  if kind=="game" then
   if data.gameId~=nil and data.gameId~=game.GameId then
    return false,"This profile belongs to another game"
   end
   if type(data.flags)~="table" then return false,"Missing flags" end
  end
  win._importing=true
  local applied,err=pcall(function()
   if kind=="appearance" then
    if type(data.theme)=="string" then win:SetTheme(data.theme) end
    if type(data.borderThickness)=="number" then win:SetBorderThickness(data.borderThickness) end
    if data.accent then win:SetAccentColor(unpackValue(data.accent)) end
    if type(data.rain)=="boolean" then
     win:SetRain(data.rain,data.density,data.speed)
    elseif type(data.density)=="number" or type(data.speed)=="number" then
     win:SetRain(win.rainEnabled,data.density,data.speed)
    end
   else
    for flag,value in pairs(data.flags) do
     local ctl=win.flags[flag]
     if ctl then
      local decoded=unpackValue(value)
      if decoded~=nil then ctl:Set(decoded,options and options.FireCallbacks==true) end
     end
    end
   end
  end)
  win._importing=false
  if not applied then return false,tostring(err) end
  return true
 end
 function obj:Save(name)
  local ok,data=pcall(function()return self:Export()end)
  if not ok then return false,tostring(data) end
  return writeRaw(name,data)
 end
 function obj:Load(name,options)
  local raw,err=readRaw(name)
  if not raw then return false,err end
  return self:Import(raw,options)
 end
 function obj:Delete(name)
  if not validName(name) then return false,"Invalid profile name" end
  local file=path(name)
  if win.fs then
   if type(win.fs.delete)~="function" then
    return false,"Deletion not supported by the filesystem"
   end
   local ok,err=pcall(win.fs.delete,file)
   if not ok then return false,tostring(err) end
  end
  memory[file]=nil
  return true
 end
 function obj:Rename(oldName,newName)
  if not validName(oldName) or not validName(newName) then return false,"Invalid profile name" end
  if oldName==newName then return true end
  local raw,err=readRaw(oldName)
  if not raw then return false,err end
  local existing=readRaw(newName)
  if existing then return false,"Destination profile already exists" end
  if win.fs and type(win.fs.delete)~="function" then
   return false,"Renaming requires filesystem deletion support"
  end
  local saved,why=writeRaw(newName,raw)
  if not saved then return false,why end
  local deleted,message=self:Delete(oldName)
  if not deleted then return false,message end
  return true
 end
 return obj
end
function Window:_profileManager(tab,kind,store,onImported)
 local title=kind=="appearance" and "APPEARANCE PROFILES" or "GAME PROFILES"
 tab:CreateSection(title)
 local storageLabel=tab:CreateLabel({Text="Storage: "..(self.StorageMode=="file" and "local files" or "session memory only")})
 local profile=tab:CreateInput({Name="Profile name",Default="default",Placeholder="Letters, numbers, - and _"})
 local picker=tab:CreateDropdown({
  Name="Saved profiles",Options=store:List(),
  Callback=function(name)profile:Set(name)end
 })
 local w=self
 local function report(action,ok,detail)
  w:Notify(ok and (action.." succeeded") or (action..": "..tostring(detail)),ok and "OK" or "ERROR")
 end
 local function refresh(selected)
  picker:SetOptions(store:List())
  if selected then picker:Set(selected) end
 end
 tab:CreateButton({Name="Save named profile",Callback=function()
  local name=profile:Get()
  local ok,why=store:Save(name)
  if ok then
   refresh(name)
   if w._autosaveTargets[kind] then w._autosaveTargets[kind]=name end
  end
  report("Save",ok,why)
 end})
 tab:CreateButton({Name="Load named profile",Callback=function()
  local name=profile:Get()
  -- Import applies control values without running user callbacks.
  local ok,why=store:Load(name)
  if ok and onImported then onImported() end
  report("Load",ok,why)
 end})
 tab:CreateButton({Name="Rename selected profile",Callback=function()
  local source=picker:Get()
  if not source then w:Notify("Select a saved profile first","WARN") return end
  local dest=profile:Get()
  local ok,why=store:Rename(source,dest)
  if ok then
   refresh(dest)
   if w._autosaveTargets[kind]==source then w._autosaveTargets[kind]=dest end
  end
  report("Rename",ok,why)
 end})
 local confirmName,confirmUntil
 tab:CreateButton({Name="Delete selected profile (confirm twice)",Callback=function()
  local target=picker:Get()
  if not target then w:Notify("No saved profile selected","WARN") return end
  if confirmName~=target or os.clock()>(confirmUntil or 0) then
   confirmName=target
   confirmUntil=os.clock()+5
   w:Notify("Click Delete again within 5 seconds to remove "..target,"WARN")
   return
  end
  confirmName=nil
  local ok,why=store:Delete(target)
  if ok then
   refresh()
   if w._autosaveTargets[kind]==target then w._autosaveTargets[kind]=nil end
  end
  report("Delete",ok,why)
 end})
 tab:CreateToggle({Name="Auto-save selected profile (this session)",Default=false,Callback=function(enabled)
  local name=profile:Get()
  if enabled and not validName(name) then
   w:Notify("Enter a valid profile name first","WARN")
   return
  end
  w._autosaveTargets[kind]=enabled and name or nil
  w._autosaveDue[kind]=nil
  w:Notify(enabled and ("Auto-save to "..name.." enabled") or "Auto-save disabled","INFO")
 end})
 tab:CreateSection("JSON IMPORT / EXPORT")
 local payload=tab:CreateTextArea({Name="Profile JSON",Height=125,Placeholder="Exported JSON appears here. Paste JSON here to import."})
 tab:CreateButton({Name="Export values to JSON",Callback=function()
  local ok,value=pcall(function()return store:Export()end)
  if not ok then w:Notify("Export failed: "..tostring(value),"ERROR") return end
  payload:Set(value)
  if type(setclipboard)=="function" then
   local copied=pcall(setclipboard,value)
   w:Notify(copied and "JSON exported and copied" or "JSON exported into text field",copied and "OK" or "INFO")
  else
   w:Notify("JSON exported into text field","OK")
  end
 end})
 tab:CreateButton({Name="Import values from JSON",Callback=function()
  local ok,why=store:Import(payload:Get())
  if ok and onImported then onImported() end
  report("Import",ok,why)
 end})
 return {Refresh=refresh,Selected=picker,Name=profile}
end
function Lib:CreateWindow(o)
 o=o or {}
 local player=Players.LocalPlayer
 assert(player,"reefFish must run in a client LocalScript")
 local colors=table.clone(palettes[o.Theme] or palettes.MatrixInverse)
 local w=setmetatable({
  width=math.max(330,o.Size and o.Size.X.Offset or 560),height=math.max(250,o.Size and o.Size.Y.Offset or 370),
  colors=colors,themeName=palettes[o.Theme] and o.Theme or "MatrixInverse",
  rainEnabled=true,rainDensity=.82,rainSpeed=.4,minimized=false,destroyed=false,
  flags={},tabs={},_bound={},_connections={},_feedbackRefresh={},
  _autosaveTargets={},_autosaveDue={},_importing=false,
  _keybinds={},_toasts={},enableToasts=o.Notifications~=false,hidden=false,
  fs=storage(),borderThickness=math.clamp(tonumber(o.BorderThickness) or 12,9,16)
 },Window)
 local requestedKey=o.ToggleKey or "RightShift"
 if typeof(requestedKey)=="EnumItem" then requestedKey=requestedKey.Name end
 local okKey,enumKey=pcall(function()return Enum.KeyCode[requestedKey]end)
 w.toggleKey=okKey and enumKey or Enum.KeyCode.RightShift
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
 local caption=make("TextLabel",{Text="reefFish // "..tostring(o.Title or "CONSOLE").."  ["..Lib.Version.."]",Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-90,1,0),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Code,TextSize=16,ZIndex=7},top)
 w:_theme(caption,"TextColor3","accent")
 local min=make("TextButton",{Text="_",Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-72,0,6),BorderSizePixel=0,ZIndex=7},top)
 local close=make("TextButton",{Text="X",Size=UDim2.fromOffset(32,30),Position=UDim2.new(1,-37,0,6),BorderSizePixel=0,ZIndex=7},top)
 for _,b in ipairs({min,close}) do w:_theme(b,"BackgroundColor3","raised") w:_theme(b,"TextColor3","accent") end
 w.body=make("Frame",{Position=UDim2.fromOffset(0,42),Size=UDim2.new(1,0,1,-66),BackgroundTransparency=1,ZIndex=6},inner)
 w.nav=make("ScrollingFrame",{Size=UDim2.new(.3,0,1,0),ScrollBarThickness=0,BackgroundTransparency=1,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=6},w.body)
 make("UIListLayout",{Padding=UDim.new(0,4)},w.nav)
 w.content=make("Frame",{Size=UDim2.new(.7,-5,1,0),Position=UDim2.new(.3,5,0,0),BackgroundTransparency=1,ZIndex=6},w.body)
 w._status=make("TextLabel",{Text="> reefFish "..Lib.Version.." | PROFILES | ready_",Position=UDim2.new(0,8,1,-24),Size=UDim2.new(1,-16,0,22),BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Code,TextSize=12,ZIndex=6},inner)
 w:_theme(w._status,"TextColor3","muted")
 w._toastLayer=make("Frame",{
  Position=UDim2.new(1,-299,1,-250),Size=UDim2.fromOffset(280,225),
  BackgroundTransparency=1,BorderSizePixel=0,ZIndex=175
 },w.screen)
 make("UIListLayout",{
  SortOrder=Enum.SortOrder.LayoutOrder,VerticalAlignment=Enum.VerticalAlignment.Bottom,
  Padding=UDim.new(0,5)
 },w._toastLayer)
 -- One window-level key dispatcher.
 w._connections[#w._connections+1]=UIS.InputBegan:Connect(function(i,processed)
  if i.UserInputType~=Enum.UserInputType.Keyboard then return end
  if w._bindingCapture then
   if processed or UIS:GetFocusedTextBox() then return end
   local captured=w._bindingCapture
   w._bindingCapture=nil
   if i.KeyCode~=Enum.KeyCode.Escape then
    if not captured:Set(i.KeyCode.Name,true) then
     captured:Set(captured:Get())
     w:Notify("Invalid or reserved key","WARN")
    end
   else
    captured:Set(captured:Get())
    w:Notify("Keybind capture cancelled","INFO")
   end
   return
  end
  if processed or UIS:GetFocusedTextBox() then return end
  if i.KeyCode==w.toggleKey then w:SetHidden(not w.hidden) return end
  if w.hidden then return end
  for _,bind in ipairs(w._keybinds) do
   if bind:Get()==i.KeyCode.Name then bind:_input(true) end
  end
 end)
 w._connections[#w._connections+1]=UIS.InputEnded:Connect(function(i)
  if i.UserInputType~=Enum.UserInputType.Keyboard then return end
  for _,bind in ipairs(w._keybinds) do
   if bind:Get()==i.KeyCode.Name then bind:_input(false) end
  end
 end)
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
 -- Centralized 1-second debounce. No new tasks on each slider change.
 w._connections[#w._connections+1]=RunService.Heartbeat:Connect(function()
  if w.destroyed then return end
  local now=os.clock()
  for kind,due in pairs(w._autosaveDue) do
   if due and now>=due then
    w._autosaveDue[kind]=nil
    local name=w._autosaveTargets[kind]
    if name then
     local manager=kind=="appearance" and w.Appearance or w.Config
     local ok,err=manager:Save(name)
     if not ok then w:Notify("Auto-save failed: "..tostring(err),"ERROR") end
    end
   end
  end
 end)
 if not o.HideBuiltins then
  local appearance=w:CreateTab({Name="APPEARANCE"})
  appearance:CreateSection("CONSOLE STYLE")
  local theme=appearance:CreateDropdown({
   Name="Theme",Options={"MatrixInverse","ClassicCRT","AmberTerminal","IceConsole","Monochrome"},
   Default=w.themeName,Callback=function(value)w:SetTheme(value)end
  })
  local accentPicker=appearance:CreateColorPicker({
   Name="Accent colour",Default=w.colors.accent,
   Callback=function(c)w:SetAccentColor(c)end
  })
  local rain=appearance:CreateToggle({
   Name="Matrix rain",Default=w.rainEnabled,
   Callback=function(value)w:SetRain(value)end
  })
  local density=appearance:CreateSlider({
   Name="Rain density (%)",Min=0,Max=100,Increment=5,
   Default=math.floor(w.rainDensity*100+.5),
   Callback=function(value)w:SetRain(w.rainEnabled,value/100,w.rainSpeed)end
  })
  local speed=appearance:CreateSlider({
   Name="Rain speed (%)",Min=0,Max=100,Increment=5,
   Default=math.floor(w.rainSpeed*100+.5),
   Callback=function(value)w:SetRain(w.rainEnabled,w.rainDensity,value/100)end
  })
  local border=appearance:CreateSlider({
   Name="Border thickness",Min=9,Max=16,Increment=1,Default=w.borderThickness,
   Callback=function(value)w:SetBorderThickness(value)end
  })
  local function syncAppearance()
   theme:Set(w.themeName)
   accentPicker:Set(w.colors.accent)
   rain:Set(w.rainEnabled)
   density:Set(math.floor(w.rainDensity*100+.5))
   speed:Set(math.floor(w.rainSpeed*100+.5))
   border:Set(w.borderThickness)
  end
  w:_profileManager(appearance,"appearance",w.Appearance,syncAppearance)
  local config=w:CreateTab({Name="CONFIG"})
  config:CreateLabel({Text="Profiles are isolated by game.GameId. Loading restores values, not callbacks."})
  w:_profileManager(config,"game",w.Config)
 end
 return w
end
return Lib
