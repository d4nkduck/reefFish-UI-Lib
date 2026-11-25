-- reefFish UI Lib v0.5.0-alpha
-- MIT License | Console-style Roblox Luau UI
local Players=game:GetService("Players")
local UIS=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local HttpService=game:GetService("HttpService")
local TweenService=game:GetService("TweenService")
local Lib={Version="0.5.0-alpha"}
-- Public artwork source. Roblox UI requires a Roblox image asset ID at runtime.
Lib.IconSource="https://raw.githubusercontent.com/d4nkduck/reefFish-UI-Lib/main/assets/reefFish-icon.png"
Lib.DefaultIconAsset=nil
-- Foundation tokens: neutral surfaces and a separate optional accent/rain layer.
local Design={
 space={xs=4,sm=8,md=12,lg=16,xl=20},
 radius={small=5,control=7,surface=10,window=13},
 type={caption=10,label=12,body=13,section=11,title=17},
 height={header=52,footer=25,button=40,toggle=44,slider=60,dropdown=70,input=68}
}
Lib.Design=Design
local palettes={
 MatrixInverse={
  bg=Color3.fromRGB(13,17,21),panel=Color3.fromRGB(22,28,33),
  raised=Color3.fromRGB(31,39,45),stroke=Color3.fromRGB(49,61,68),
  border=Color3.fromRGB(31,179,111),ink=Color3.fromRGB(8,62,40),
  accent=Color3.fromRGB(115,224,162),text=Color3.fromRGB(231,238,240),
  muted=Color3.fromRGB(148,166,171),danger=Color3.fromRGB(235,132,126)
 },
 ClassicCRT={
  bg=Color3.fromRGB(12,18,15),panel=Color3.fromRGB(20,29,23),
  raised=Color3.fromRGB(28,42,32),stroke=Color3.fromRGB(48,68,53),
  border=Color3.fromRGB(26,151,83),ink=Color3.fromRGB(9,55,29),
  accent=Color3.fromRGB(111,224,147),text=Color3.fromRGB(228,240,230),
  muted=Color3.fromRGB(147,173,151),danger=Color3.fromRGB(235,132,126)
 },
 AmberTerminal={
  bg=Color3.fromRGB(21,19,17),panel=Color3.fromRGB(32,28,24),
  raised=Color3.fromRGB(43,38,31),stroke=Color3.fromRGB(73,60,43),
  border=Color3.fromRGB(198,144,61),ink=Color3.fromRGB(80,54,20),
  accent=Color3.fromRGB(238,190,114),text=Color3.fromRGB(242,234,220),
  muted=Color3.fromRGB(175,157,131),danger=Color3.fromRGB(235,132,126)
 },
 IceConsole={
  bg=Color3.fromRGB(13,19,25),panel=Color3.fromRGB(20,29,38),
  raised=Color3.fromRGB(29,42,53),stroke=Color3.fromRGB(50,69,82),
  border=Color3.fromRGB(62,149,196),ink=Color3.fromRGB(23,58,80),
  accent=Color3.fromRGB(145,214,242),text=Color3.fromRGB(230,238,244),
  muted=Color3.fromRGB(152,175,187),danger=Color3.fromRGB(235,132,126)
 },
 Monochrome={
  bg=Color3.fromRGB(17,18,20),panel=Color3.fromRGB(27,29,32),
  raised=Color3.fromRGB(39,42,46),stroke=Color3.fromRGB(65,70,76),
  border=Color3.fromRGB(150,155,161),ink=Color3.fromRGB(51,55,60),
  accent=Color3.fromRGB(236,238,241),text=Color3.fromRGB(232,233,236),
  muted=Color3.fromRGB(163,169,176),danger=Color3.fromRGB(235,132,126)
 }
}
Lib.Themes=palettes
local function make(class,props,parent)
 local x=Instance.new(class)
 for k,v in pairs(props or {}) do x[k]=v end
 x.Parent=parent
 return x
end
local function round(x,n) make("UICorner",{CornerRadius=UDim.new(0,n or Design.radius.control)},x) end
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
local function imageAsset(value)
 local id=value
 if type(id)=="number" and id>0 then id=tostring(math.floor(id)) end
 if type(id)=="string" and id:match("^%d+$") then id="rbxassetid://"..id end
 if type(id)=="string" and (
  id:match("^rbxassetid://%d+$")
  or id:match("^rbxasset://[%w_/%-%.]+$")
 ) then return id end
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
function Window:_feedback(hitbox,surface,baseToken)
 local state="normal"
 local currentTween
 local transparentIdle=surface.BackgroundTransparency>.95
 local function refresh(animate)
  if not surface.Parent then return end
  local base=self.colors[baseToken or "panel"] or self.colors.panel
  local target=base
  local highlight=(baseToken=="accent" or baseToken=="danger") and self.colors.text or self.colors.accent
  if state=="hover" then
   target=base:Lerp(highlight,(baseToken=="accent" or baseToken=="danger") and .13 or .055)
  elseif state=="pressed" then
   target=base:Lerp(highlight,(baseToken=="accent" or baseToken=="danger") and .22 or .12)
  end
  if currentTween then currentTween:Cancel() currentTween=nil end
  local transparency=transparentIdle and (state=="normal" and 1 or (state=="pressed" and .58 or .75)) or 0
  if animate then
   currentTween=TweenService:Create(surface,TweenInfo.new(.14,Enum.EasingStyle.Quad,Enum.EasingDirection.Out),{
    BackgroundColor3=target,BackgroundTransparency=transparency
   })
   currentTween:Play()
  else
   surface.BackgroundColor3=target
   surface.BackgroundTransparency=transparency
  end
 end
 self:_trackFeedback(surface,function()refresh(false)end)
 local function add(signal,fn)
  return self:_connectControl(surface,signal,fn)
 end
 add(hitbox.MouseEnter,function()state="hover" refresh(true)end)
 add(hitbox.MouseLeave,function()state="normal" refresh(true)end)
 add(hitbox.MouseButton1Down,function()state="pressed" refresh(true)end)
 add(hitbox.MouseButton1Up,function()state="hover" refresh(true)end)
 refresh(false)
end
function Window:_connectControl(owner,signal,callback)
 local connection=signal:Connect(callback)
 local bucket=self._controlConnections[owner]
 if not bucket then
  bucket={}
  self._controlConnections[owner]=bucket
  owner.Destroying:Connect(function()
   for _,c in ipairs(bucket) do c:Disconnect() end
   self._controlConnections[owner]=nil
  end)
 end
 bucket[#bucket+1]=connection
 return connection
end
function Window:_trackFeedback(owner,refresh)
 local entry={owner=owner,refresh=refresh}
 self._feedbackRefresh[#self._feedbackRefresh+1]=entry
 owner.Destroying:Connect(function()
  for i=#self._feedbackRefresh,1,-1 do
   if self._feedbackRefresh[i]==entry then
    table.remove(self._feedbackRefresh,i)
    break
   end
  end
 end)
end
function Window:_refreshFeedback()
 for i=#self._feedbackRefresh,1,-1 do
  local item=self._feedbackRefresh[i]
  if item.owner.Parent then item.refresh() else table.remove(self._feedbackRefresh,i) end
 end
end
function Window:_markChanged(kind)
 if self._importing then return end
 local name=self._autosaveTargets[kind]
 if name then self._autosaveDue[kind]=os.clock()+1 end
end
function Window:SetBorderThickness(value)
 local n=math.clamp(math.floor(tonumber(value) or self.borderThickness),3,16)
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
 if not self._boundOwners[obj] then
  self._boundOwners[obj]=true
  obj.Destroying:Connect(function()
   self._boundOwners[obj]=nil
   for i=#self._bound,1,-1 do
    if self._bound[i][1]==obj then table.remove(self._bound,i) end
   end
  end)
 end
 obj[property]=self.colors[token]
end
function Window:_refreshChrome()
 if self.root and self.root.Parent then
  self.root.BackgroundColor3=self.rainEnabled and self.colors.border or self.colors.stroke
 end
end
function Window:SetTheme(name)
 if not palettes[name] then return false end
 if self._closeDropdown then self._closeDropdown() end
 self.themeName=name self.colors=table.clone(palettes[name])
 for i=#self._bound,1,-1 do
  local bound=self._bound[i]
  if bound[1].Parent then bound[1][bound[2]]=self.colors[bound[3]]
  else table.remove(self._bound,i) end
 end
 self:_refreshFeedback()
 self:_refreshChrome()
 if self.active then self:SelectTab(self.active) end
 if self._repaintRain then self._repaintRain() end
 self:_markChanged("appearance")
 return true
end

function Window:SetAccentColor(value)
 local color=parseColor(value)
 if not color then return false end
 self.colors.accent=color
 for i=#self._bound,1,-1 do
  local bound=self._bound[i]
  if not bound[1].Parent then table.remove(self._bound,i)
  elseif bound[3]=="accent" then bound[1][bound[2]]=color end
 end
 self:_refreshFeedback()
 if self.active then self:SelectTab(self.active) end
 self:_markChanged("appearance")
 return true
end
function Window:SetRain(enabled,density,speed)
 self.rainEnabled=enabled~=false
 if type(density)=="number" then self.rainDensity=math.clamp(density,0,1) end
 if type(speed)=="number" then self.rainSpeed=math.clamp(speed,0,1) end
 if self._rainLayer then self._rainLayer.Visible=self.rainEnabled end
 if self.rainEnabled and self._ensureRainColumns then
  self._ensureRainColumns(self.width)
 end
 self:_refreshChrome()
 if self._rainColumns and self._repaintRain then self._repaintRain() end
 self:_markChanged("appearance")
end
-- Small capped toast queue with a timed dismissal.
-- Lightweight, non-blocking confirmation modal. No continuous render loops.
function Window:Confirm(options)
 options=options or {}
 if self.destroyed or not self.screen then return nil end
 if self._dialog then self._dialog:Dismiss(true) end
 if self._searchOverlay then self:CloseSearch() end
 local viewport=self:_viewport()
 local panelWidth=math.min(420,math.max(230,viewport.X-28))
 local panelHeight=math.min(238,math.max(170,viewport.Y-28))
 local overlay=make("Frame",{
  Name="ReefFishConfirm",Size=UDim2.fromScale(1,1),
  BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.45,
  BorderSizePixel=0,ZIndex=225
 },self.screen)
 local panel=make("Frame",{
  AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
  Size=UDim2.fromOffset(panelWidth,panelHeight),
  BorderSizePixel=0,ZIndex=226
 },overlay)
 round(panel,Design.radius.surface)
 self:_theme(panel,"BackgroundColor3","panel")
 local edge=make("UIStroke",{Thickness=1,Transparency=.3},panel)
 self:_theme(edge,"Color","stroke")
 local title=make("TextLabel",{
  Text=tostring(options.Title or "Are you sure?"),Position=UDim2.fromOffset(18,13),
  Size=UDim2.new(1,-36,0,30),BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
  Font=Enum.Font.GothamBold,TextSize=16,ZIndex=227
 },panel)
 self:_theme(title,"TextColor3","text")
 local body=make("TextLabel",{
  Text=tostring(options.Content or options.Message or ""),
  Position=UDim2.fromOffset(18,48),Size=UDim2.new(1,-36,1,-105),
  TextWrapped=true,TextYAlignment=Enum.TextYAlignment.Top,
  TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
  Font=Enum.Font.Gotham,TextSize=Design.type.body,ZIndex=227
 },panel)
 self:_theme(body,"TextColor3","muted")
 local cancel=make("TextButton",{
  Text=tostring(options.CancelText or "Cancel"),
  Position=UDim2.new(.5,-126,1,-48),Size=UDim2.fromOffset(118,34),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  BorderSizePixel=0,AutoButtonColor=false,ZIndex=227
 },panel)
 round(cancel,Design.radius.control)
 self:_theme(cancel,"TextColor3","text")
 self:_theme(cancel,"BackgroundColor3","raised")
 local confirm=make("TextButton",{
  Text=tostring(options.ConfirmText or "Confirm"),
  Position=UDim2.new(.5,8,1,-48),Size=UDim2.fromOffset(118,34),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  BorderSizePixel=0,AutoButtonColor=false,ZIndex=227
 },panel)
 round(confirm,Design.radius.control)
 self:_theme(confirm,"BackgroundColor3",options.Danger==true and "danger" or "accent")
 self:_theme(confirm,"TextColor3","bg")
 local handle={}
 local selfWindow=self
 local closed=false
 function handle:Dismiss(silent)
  if closed then return end
  closed=true
  if self==handle and overlay.Parent then overlay:Destroy() end
  if self==handle and selfWindow._dialog==handle then selfWindow._dialog=nil end
  if not silent then
   fire(options.OnCancel)
   if not options.OnConfirm then fire(options.Callback,false) end
  end
 end
 function handle:Cancel()self:Dismiss(false)end
 function handle:Confirm()
  if closed then return end
  self:Dismiss(true)
  fire(options.OnConfirm or options.Callback,true)
 end
 self._dialog=handle
 cancel.MouseButton1Click:Connect(function()handle:Cancel()end)
 confirm.MouseButton1Click:Connect(function()handle:Confirm()end)
 return handle
end
function Window:Dialog(options)
 return self:Confirm(options)
end

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
 round(frame,Design.radius.surface)
 self:_theme(frame,"BackgroundColor3","panel")
 local toastStroke=make("UIStroke",{Thickness=1,Transparency=.5},frame)
 self:_theme(toastStroke,"Color","stroke")
 local accentBar=make("Frame",{
  Position=UDim2.fromOffset(0,11),Size=UDim2.fromOffset(3,36),
  BorderSizePixel=0,ZIndex=181
 },frame)
 round(accentBar,2)
 self:_theme(accentBar,"BackgroundColor3","accent")
 local heading=make("TextLabel",{
  Text=title,TextColor3=self.colors.text,BackgroundTransparency=1,
  Position=UDim2.fromOffset(14,4),Size=UDim2.new(1,-42,0,22),
  TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,TextSize=Design.type.label,
  TextTransparency=1,ZIndex=181
 },frame)
 local body=make("TextLabel",{
  Text=content,TextColor3=self.colors.muted,BackgroundTransparency=1,
  Position=UDim2.fromOffset(14,24),Size=UDim2.new(1,-28,0,31),
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
  TextWrapped=true,Font=Enum.Font.Gotham,TextSize=Design.type.caption,TextTransparency=1,ZIndex=181
 },frame)
 local close=make("TextButton",{
  Text="×",TextColor3=self.colors.muted,BackgroundTransparency=1,
  Position=UDim2.new(1,-25,0,1),Size=UDim2.fromOffset(23,22),
  Font=Enum.Font.Gotham,TextSize=18,ZIndex=182
 },frame)
 self:_theme(heading,"TextColor3","text")
 self:_theme(body,"TextColor3","muted")
 self:_theme(close,"TextColor3","muted")
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
 self._status.Text=string.upper(tostring(kind or "INFO")).."  •  "..tostring(msg)
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
function Window:_viewport()
 local camera=workspace.CurrentCamera
 return camera and camera.ViewportSize or Vector2.new(1280,720)
end
function Window:_clampPosition()
 if self.destroyed or not self.root then return end
 local viewport=self:_viewport()
 local size=self.root.Size
 local x=self.root.Position.X.Scale*viewport.X+self.root.Position.X.Offset
 local y=self.root.Position.Y.Scale*viewport.Y+self.root.Position.Y.Offset
 local margin=8
 local maxX=math.max(margin,viewport.X-size.X.Offset-margin)
 local maxY=math.max(margin,viewport.Y-size.Y.Offset-margin)
 self.root.Position=UDim2.fromOffset(
  math.floor(math.clamp(x,margin,maxX)+.5),
  math.floor(math.clamp(y,margin,maxY)+.5)
 )
end
function Window:_layout()
 if self.destroyed or not self.root then return end
 local viewport=self:_viewport()
 local maxWidth=math.max(140,math.floor(viewport.X-16))
 local maxHeight=math.max(130,math.floor(viewport.Y-16))
 -- Preserve intended dimensions when the viewport temporarily gets smaller.
 self.width=math.clamp(self.requestedWidth,math.min(330,maxWidth),maxWidth)
 self.height=math.clamp(self.requestedHeight,math.min(250,maxHeight),maxHeight)
 local shownHeight=self.minimized and (Design.height.header+self.borderThickness*2) or self.height
 self.root.Size=UDim2.fromOffset(self.width,shownHeight)
 if self.nav and self.content then
  local compact=self.width<420
  self._compactNav=compact
  if compact then
   -- Mobile: horizontal, scrollable tab rail rather than a narrow sidebar.
   self.nav.Position=UDim2.fromOffset(0,0)
   self.nav.Size=UDim2.new(1,0,0,46)
   self.nav.ScrollingDirection=Enum.ScrollingDirection.X
   self.nav.AutomaticCanvasSize=Enum.AutomaticSize.X
   if self._navLayout then self._navLayout.FillDirection=Enum.FillDirection.Horizontal end
   if self._navPadding then
    self._navPadding.PaddingTop=UDim.new(0,5)
    self._navPadding.PaddingBottom=UDim.new(0,4)
    self._navPadding.PaddingLeft=UDim.new(0,8)
   end
   self.content.Position=UDim2.fromOffset(0,47)
   self.content.Size=UDim2.new(1,0,1,-47)
   if self._navDivider then
    self._navDivider.Position=UDim2.fromOffset(0,46)
    self._navDivider.Size=UDim2.new(1,0,0,1)
   end
  else
   local navWidth=math.clamp(math.floor(self.width*.245),118,162)
   self.nav.Position=UDim2.fromOffset(0,0)
   self.nav.Size=UDim2.new(0,navWidth,1,0)
   self.nav.ScrollingDirection=Enum.ScrollingDirection.Y
   self.nav.AutomaticCanvasSize=Enum.AutomaticSize.Y
   if self._navLayout then self._navLayout.FillDirection=Enum.FillDirection.Vertical end
   if self._navPadding then
    self._navPadding.PaddingTop=UDim.new(0,12)
    self._navPadding.PaddingBottom=UDim.new(0,8)
    self._navPadding.PaddingLeft=UDim.new(0,8)
   end
   self.content.Position=UDim2.fromOffset(navWidth+3,0)
   self.content.Size=UDim2.new(1,-navWidth-3,1,0)
   if self._navDivider then
    self._navDivider.Position=UDim2.fromOffset(navWidth,0)
    self._navDivider.Size=UDim2.new(0,1,1,0)
   end
  end
  for _,tab in ipairs(self.tabs) do
   tab.button.Size=compact and UDim2.fromOffset(124,36) or UDim2.new(1,-10,0,36)
  end
 end
 if self._resizeGrip then self._resizeGrip.Visible=not self.minimized end
 if self._status then self._status.Visible=not self.minimized end
 if self._toastLayer then
  local toastWidth=math.min(280,math.max(120,viewport.X-20))
  local toastHeight=math.min(225,math.max(70,viewport.Y-26))
  self._toastLayer.Size=UDim2.fromOffset(toastWidth,toastHeight)
  self._toastLayer.Position=UDim2.new(1,-toastWidth-10,1,-toastHeight-12)
 end
 if self.rainEnabled and self._ensureRainColumns then self._ensureRainColumns(self.width) end
 self:_clampPosition()
end
function Window:SetSize(width,height)
 if self.destroyed then return Vector2.new(self.width,self.height) end
 if self._closeDropdown then self._closeDropdown() end
 if typeof(width)=="Vector2" then height=width.Y width=width.X end
 if type(width)=="number" and width==width and width>0 and width<10000 then
  self.requestedWidth=math.floor(width+.5)
 end
 if type(height)=="number" and height==height and height>0 and height<10000 then
  self.requestedHeight=math.floor(height+.5)
 end
 self:_layout()
 return Vector2.new(self.width,self.height)
end
function Window:SetMinimized(value)
 self.minimized=value==true
 if self._closeDropdown then self._closeDropdown() end
 self.body.Visible=not self.minimized
 self:_layout()
end
function Window:SelectTab(tab)
 if not tab then return end
 if self._closeDropdown then self._closeDropdown() end
 for _,t in ipairs(self.tabs) do
  local selected=t==tab
  t.page.Visible=selected
  t.button.BackgroundColor3=selected and self.colors.raised or self.colors.bg
  t.button.TextColor3=selected and self.colors.text or self.colors.muted
  t.button.Font=selected and Enum.Font.GothamBold or Enum.Font.GothamMedium
  if t.indicator then t.indicator.Visible=selected end
 end
 self.active=tab
end
function Window:Destroy()
 if self.destroyed then return end
 self.destroyed=true
 if self._closeDropdown then self._closeDropdown() end
 if self._dialog then self._dialog:Dismiss(true) end
 if self._searchOverlay then self:CloseSearch() end
 self._bindingCapture=nil
 if self._viewportConnection then
  self._viewportConnection:Disconnect()
  self._viewportConnection=nil
 end
 -- Flush any queued autosaves before disconnecting.
 for kind,due in pairs(self._autosaveDue) do
  local name=self._autosaveTargets[kind]
  if due and name then
   local obj=kind=="appearance" and self.Appearance or self.Config
   if obj then pcall(function()obj:Save(name)end) end
  end
 end
 for _,c in ipairs(self._connections) do c:Disconnect() end
 if self._controlConnections then
  for _,bucket in pairs(self._controlConnections) do
   for _,connection in ipairs(bucket) do connection:Disconnect() end
  end
  table.clear(self._controlConnections)
 end
 table.clear(self.flags)
 self.screen:Destroy()
 table.clear(self._bound)
 table.clear(self._boundOwners)
 table.clear(self._feedbackRefresh)
 table.clear(self._keybinds)
 table.clear(self._searchItems)
 table.clear(self._connections)
 if self._registry and self._registry.__reefFishWindow==self then
  self._registry.__reefFishWindow=nil
 end
end
function Window:_indexControl(tab,frame,title)
 local label=tostring(title or "")
 if #label>100 then label=label:sub(1,100) end
 if label=="" then return end
 self._searchItems[#self._searchItems+1]={
  tab=tab,frame=frame,title=label,
  key=string.lower(tostring(tab.name or "").." "..label)
 }
end
function Window:GetDiagnostics()
 local counts={windowEvents=#self._connections,controlEvents=0,tabs=#self.tabs,controls=0,flags=0}
 for _,bucket in pairs(self._controlConnections or {}) do
  counts.controlEvents+=#bucket
 end
 for _,entry in ipairs(self._searchItems or {}) do
  if entry.frame.Parent then counts.controls+=1 end
 end
 for _ in pairs(self.flags or {}) do counts.flags+=1 end
 return {
  version=Lib.Version,theme=self.themeName,hidden=self.hidden,
  minimized=self.minimized,destroyed=self.destroyed,
  rain=self.rainEnabled,storage=self.StorageMode,
  size=Vector2.new(self.width,self.height),counts=counts
 }
end
function Window:FindControls(query,limit)
 local needle=string.lower(tostring(query or ""))
 local results={}
 limit=math.clamp(math.floor(tonumber(limit) or 20),1,100)
 for i=#self._searchItems,1,-1 do
  local entry=self._searchItems[i]
  if not entry.frame.Parent then table.remove(self._searchItems,i) end
 end
 for _,entry in ipairs(self._searchItems) do
  if needle=="" or string.find(entry.key,needle,1,true) then
   results[#results+1]=entry
   if #results>=limit then break end
  end
 end
 return results
end
function Window:CloseSearch()
 if self._searchOverlay then
  self._searchOverlay:Destroy()
  self._searchOverlay=nil
 end
end
function Window:_jumpToSearchResult(entry)
 if self.destroyed or not entry or not entry.frame.Parent then return false end
 local tab=entry.tab
 local parent=entry.frame.Parent
 local expand=tab._collapsibleGroups and tab._collapsibleGroups[parent]
 if expand then expand(true) end
 self:SelectTab(tab)
 self:CloseSearch()
 task.defer(function()
  if self.destroyed or not entry.frame.Parent or not tab.page.Parent then return end
  local y=entry.frame.AbsolutePosition.Y-tab.page.AbsolutePosition.Y
    +tab.page.CanvasPosition.Y-14
  tab.page.CanvasPosition=Vector2.new(0,math.max(0,y))
 end)
 return true
end
function Window:OpenSearch(initial)
 if self.destroyed or not self.screen then return nil end
 if self._dialog then self._dialog:Dismiss(true) end
 self:CloseSearch()
 if self._closeDropdown then self._closeDropdown() end
 local viewport=self:_viewport()
 local width=math.min(440,math.max(220,viewport.X-24))
 local height=math.min(392,math.max(180,viewport.Y-24))
 local overlay=make("Frame",{
  Name="ReefFishSearch",Size=UDim2.fromScale(1,1),
  BackgroundColor3=Color3.new(0,0,0),BackgroundTransparency=.42,
  BorderSizePixel=0,ZIndex=200
 },self.screen)
 self._searchOverlay=overlay
 local dismiss=make("TextButton",{
  Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
  Text="",BorderSizePixel=0,ZIndex=201,AutoButtonColor=false
 },overlay)
 local panel=make("Frame",{
  AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(.5,.5),
  Size=UDim2.fromOffset(width,height),BorderSizePixel=0,ZIndex=202
 },overlay)
 round(panel,Design.radius.surface)
 self:_theme(panel,"BackgroundColor3","panel")
 local outline=make("UIStroke",{Thickness=1,Transparency=.3},panel)
 self:_theme(outline,"Color","stroke")
 local heading=make("TextLabel",{
  Text="Find a setting",Position=UDim2.fromOffset(16,12),
  Size=UDim2.new(1,-32,0,25),BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamBold,
  TextSize=15,ZIndex=203
 },panel)
 self:_theme(heading,"TextColor3","text")
 local field=make("TextBox",{
  Position=UDim2.fromOffset(14,45),Size=UDim2.new(1,-28,0,36),
  BackgroundColor3=self.colors.raised,TextColor3=self.colors.text,
  PlaceholderColor3=self.colors.muted,PlaceholderText="Search tabs and settings...",
  Text=tostring(initial or ""),ClearTextOnFocus=false,
  Font=Enum.Font.Gotham,TextSize=Design.type.body,
  TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0,ZIndex=203
 },panel)
 round(field,Design.radius.control)
 make("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},field)
 local resultList=make("ScrollingFrame",{
  Position=UDim2.fromOffset(14,91),Size=UDim2.new(1,-28,1,-105),
  BackgroundTransparency=1,BorderSizePixel=0,
  AutomaticCanvasSize=Enum.AutomaticSize.Y,
  CanvasSize=UDim2.new(),ScrollBarThickness=3,ZIndex=203
 },panel)
 make("UIListLayout",{Padding=UDim.new(0,4),SortOrder=Enum.SortOrder.LayoutOrder},resultList)
 local shown={}
 local function refresh()
  if not overlay.Parent then return end
  for _,child in ipairs(resultList:GetChildren()) do
   if child:IsA("TextButton") or child:IsA("TextLabel") then child:Destroy() end
  end
  table.clear(shown)
  local hits=self:FindControls(field.Text,12)
  for i,entry in ipairs(hits) do
   shown[i]=entry
   local row=make("TextButton",{
    Text="  "..entry.title.."  ·  "..tostring(entry.tab.name or "Tab"),
    Size=UDim2.new(1,-3,0,35),BackgroundColor3=self.colors.raised,
    TextColor3=self.colors.text,BorderSizePixel=0,
    Font=Enum.Font.Gotham,TextSize=Design.type.body,
    TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd,
    AutoButtonColor=false,ZIndex=204,LayoutOrder=i
   },resultList)
   round(row,Design.radius.small)
   local choice=entry
   row.MouseButton1Click:Connect(function()self:_jumpToSearchResult(choice)end)
  end
  if #hits==0 then
   local none=make("TextLabel",{
    Text="No matching settings",
    Size=UDim2.new(1,0,0,38),BackgroundTransparency=1,
    TextColor3=self.colors.muted,Font=Enum.Font.Gotham,
    TextSize=Design.type.body,ZIndex=204
   },resultList)
  end
  resultList.CanvasPosition=Vector2.zero
 end
 local selfWindow=self
 local handle={}
 function handle:Dismiss()selfWindow:CloseSearch()end
 dismiss.MouseButton1Click:Connect(function()self:CloseSearch()end)
 field:GetPropertyChangedSignal("Text"):Connect(refresh)
 field.FocusLost:Connect(function(enterPressed)
  if enterPressed and shown[1] then self:_jumpToSearchResult(shown[1]) end
 end)
 refresh()
 task.defer(function()
  if overlay.Parent then field:CaptureFocus() end
 end)
 return handle
end
function Window:ToggleSearch()
 if self._searchOverlay then self:CloseSearch() else self:OpenSearch() end
end
function Window:CreateTab(opts)
 local name=type(opts)=="table" and (opts.Name or opts.Title) or opts or "TAB"
 local iconId=imageAsset(type(opts)=="table" and opts.Icon or nil)
 local button=make("TextButton",{
  Text=(iconId and "       " or "  ")..tostring(name),LayoutOrder=#self.tabs+1,
  Size=self._compactNav and UDim2.fromOffset(124,36) or UDim2.new(1,-10,0,36),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,
  BorderSizePixel=0,AutoButtonColor=false
 },self.nav)
 round(button,Design.radius.control)
 local iconLabel
 if iconId then
  iconLabel=make("ImageLabel",{
   Name="TabIcon",BackgroundTransparency=1,Image=iconId,
   Size=UDim2.fromOffset(19,19),Position=UDim2.fromOffset(10,8),
   ScaleType=Enum.ScaleType.Fit,BorderSizePixel=0,ZIndex=7
  },button)
  pcall(function()iconLabel.ResampleMode=Enum.ResamplerMode.Pixelated end)
 end
 local indicator=make("Frame",{
  Position=UDim2.fromOffset(0,8),Size=UDim2.fromOffset(3,20),
  BorderSizePixel=0,Visible=false,Active=false
 },button)
 round(indicator,2)
 self:_theme(indicator,"BackgroundColor3","accent")
 local page=make("ScrollingFrame",{
  Size=UDim2.fromScale(1,1),BackgroundTransparency=1,
  ScrollBarThickness=3,ScrollBarImageColor3=self.colors.muted,
  AutomaticCanvasSize=Enum.AutomaticSize.Y,CanvasSize=UDim2.new(),
  Visible=false,BorderSizePixel=0
 },self.content)
 make("UIPadding",{
  PaddingTop=UDim.new(0,Design.space.md),PaddingBottom=UDim.new(0,Design.space.lg),
  PaddingLeft=UDim.new(0,Design.space.md),PaddingRight=UDim.new(0,Design.space.md)
 },page)
 make("UIListLayout",{Padding=UDim.new(0,Design.space.sm),SortOrder=Enum.SortOrder.LayoutOrder},page)
 local t=setmetatable({window=self,button=button,page=page,indicator=indicator,name=tostring(name)},Tab)
 function t:SetIcon(asset)
  local id=imageAsset(asset)
  if not id then
   if iconLabel then iconLabel:Destroy() iconLabel=nil end
   button.Text="  "..self.name
   return false
  end
  if not iconLabel then
   iconLabel=make("ImageLabel",{
    Name="TabIcon",BackgroundTransparency=1,BorderSizePixel=0,
    Size=UDim2.fromOffset(19,19),Position=UDim2.fromOffset(10,8),
    ScaleType=Enum.ScaleType.Fit,ZIndex=7
   },button)
   pcall(function()iconLabel.ResampleMode=Enum.ResamplerMode.Pixelated end)
  end
  iconLabel.Image=id
  button.Text="       "..self.name
  return true
 end
 self:_theme(button,"TextColor3","muted")
 self:_theme(button,"BackgroundColor3","bg")
 self.tabs[#self.tabs+1]=t
 self._connections[#self._connections+1]=button.MouseButton1Click:Connect(function()self:SelectTab(t)end)
 self._connections[#self._connections+1]=button.MouseEnter:Connect(function()
  if self.active~=t then
   TweenService:Create(button,TweenInfo.new(.13),{BackgroundColor3=self.colors.panel}):Play()
  end
 end)
 self._connections[#self._connections+1]=button.MouseLeave:Connect(function()
  if self.active~=t then
   TweenService:Create(button,TweenInfo.new(.13),{BackgroundColor3=self.colors.bg}):Play()
  end
 end)
 if #self.tabs==1 then self:SelectTab(t) end
 return t
end
function Tab:_base(height,searchLabel)
 local w=self.window
 local grouped=self._group~=nil and self._group.Parent~=nil
 local order
 if grouped then
  self._groupOrder=(self._groupOrder or 0)+1
  order=self._groupOrder
 else
  self._layoutOrder=(self._layoutOrder or 0)+1
  order=self._layoutOrder
 end
 local frame=make("Frame",{
  Size=UDim2.new(1,grouped and 0 or -4,0,height),
  BackgroundTransparency=grouped and 1 or 0,
  BorderSizePixel=0,LayoutOrder=order
 },grouped and self._group or self.page)
 if not grouped then
  round(frame,Design.radius.surface)
  w:_theme(frame,"BackgroundColor3","panel")
  local edge=make("UIStroke",{Thickness=1,Transparency=.65},frame)
  w:_theme(edge,"Color","stroke")
 else
  -- A single section surface holds related settings, with quiet row separators.
  local separator=make("Frame",{
   Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),
   BorderSizePixel=0,BackgroundTransparency=.68,Active=false
  },frame)
  w:_theme(separator,"BackgroundColor3","stroke")
 end
 if searchLabel~=nil then
  w:_indexControl(self,frame,tostring(searchLabel))
 end
 return frame
end
function Tab:CreateSection(name)
 local w=self.window
 local opts=type(name)=="table" and name or nil
 local title=tostring(opts and (opts.Name or opts.Title) or name or "Section")
 local collapsible=opts~=nil and opts.Collapsible==true
 self._layoutOrder=(self._layoutOrder or 0)+1
 local f=make("Frame",{
  Size=UDim2.new(1,-4,0,30),BackgroundTransparency=1,
  BorderSizePixel=0,LayoutOrder=self._layoutOrder
 },self.page)
 local label=make(collapsible and "TextButton" or "TextLabel",{
  BackgroundTransparency=1,Size=UDim2.new(1,-18,1,0),
  Position=UDim2.fromOffset(7,0),
  Text=title,Font=Enum.Font.GothamBold,TextSize=Design.type.section,
  TextXAlignment=Enum.TextXAlignment.Left,
  TextTruncate=Enum.TextTruncate.AtEnd,
  BorderSizePixel=0
 },f)
 w:_theme(label,"TextColor3","muted")
 local chevron
 if collapsible then
  label.Size=UDim2.new(1,-46,1,0)
  chevron=make("TextLabel",{
   Position=UDim2.new(1,-28,0,0),Size=UDim2.fromOffset(20,30),
   BackgroundTransparency=1,Font=Enum.Font.GothamBold,
   TextSize=14,ZIndex=7
  },f)
  w:_theme(chevron,"TextColor3","muted")
 end
 self._layoutOrder+=1
 -- Explicit height avoids nested AutomaticSize cycles.
 local group=make("Frame",{
  Size=UDim2.new(1,-4,0,8),
  AutomaticSize=Enum.AutomaticSize.None,
  BackgroundTransparency=0,BorderSizePixel=0,
  LayoutOrder=self._layoutOrder
 },self.page)
 round(group,Design.radius.surface)
 w:_theme(group,"BackgroundColor3","panel")
 local border=make("UIStroke",{Thickness=1,Transparency=.62},group)
 w:_theme(border,"Color","stroke")
 make("UIPadding",{
  PaddingLeft=UDim.new(0,8),PaddingRight=UDim.new(0,8),
  PaddingTop=UDim.new(0,4),PaddingBottom=UDim.new(0,4)
 },group)
 local groupLayout=make("UIListLayout",{
  Padding=UDim.new(0,0),SortOrder=Enum.SortOrder.LayoutOrder
 },group)
 local function updateGroupHeight()
  if not group.Parent then return end
  local required=math.max(8,math.ceil(groupLayout.AbsoluteContentSize.Y)+8)
  if group.Size.Y.Offset~=required then
   group.Size=UDim2.new(1,-4,0,required)
  end
 end
 w:_connectControl(group,groupLayout:GetPropertyChangedSignal("AbsoluteContentSize"),updateGroupHeight)
 task.defer(updateGroupHeight)
 self._group=group
 self._groupOrder=0
 w:_indexControl(self,f,title)
 if not collapsible then return f end
 self._collapsibleGroups=self._collapsibleGroups or {}
 local expanded=opts.Expanded~=false
 local function setExpanded(v)
  expanded=v==true
  if group.Parent then group.Visible=expanded end
  if chevron.Parent then chevron.Text=expanded and "⌄" or "›" end
 end
 self._collapsibleGroups[group]=setExpanded
 group.Destroying:Connect(function()
  self._collapsibleGroups[group]=nil
 end)
 w:_connectControl(f,label.MouseButton1Click,function()
  setExpanded(not expanded)
 end)
 setExpanded(expanded)
 local handle={}
 function handle:SetExpanded(v)setExpanded(v)end
 function handle:GetExpanded()return expanded end
 function handle:Toggle()setExpanded(not expanded)end
 function handle:SetVisible(v)
  f.Visible=v~=false
  group.Visible=f.Visible and expanded
 end
 function handle:Destroy()
  if group.Parent then group:Destroy() end
  if f.Parent then f:Destroy() end
 end
 return handle
end
function Tab:CreateCollapsibleSection(o)
 o=type(o)=="table" and table.clone(o) or {Name=tostring(o)}
 o.Collapsible=true
 return self:CreateSection(o)
end
function Tab:CreateLabel(o)
 o=type(o)=="table" and o or {Text=o}
 local f=self:_base(32,o.Text or "Label")
 local l=make("TextLabel",{
  BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.new(1,-20,1,0),
  Text=tostring(o.Text or ""),TextXAlignment=Enum.TextXAlignment.Left,
  Font=Enum.Font.Gotham,TextSize=Design.type.body,TextWrapped=true
 },f)
 self.window:_theme(l,"TextColor3","text")
 return {
  SetText=function(_,v)l.Text=tostring(v)end,
  Get=function()return l.Text end,
  SetVisible=function(_,v)f.Visible=v~=false end,
  Destroy=function()f:Destroy()end
 }
end
function Tab:CreateButton(o)
 o=o or {}
 local w=self.window
 local hasDescription=type(o.Description)=="string" and o.Description~=""
 local f=self:_base(hasDescription and 59 or Design.height.button,o.Name or "Button")
 local variant=string.lower(tostring(o.Variant or o.Style or "secondary"))
 if variant~="primary" and variant~="danger" then variant="secondary" end
 local colored=variant~="secondary"
 if colored then
  f.BackgroundTransparency=0
  round(f,Design.radius.control)
  w:_theme(f,"BackgroundColor3",variant=="primary" and "accent" or "danger")
 end
 local b=make("TextButton",{
  Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,
  Text="",BorderSizePixel=0
 },f)
 local name=make("TextLabel",{
  Text=tostring(o.Name or "Button"),BackgroundTransparency=1,
  Size=UDim2.new(1,-60,0,24),Position=UDim2.fromOffset(13,hasDescription and 7 or 8),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
 },f)
 local detail
 if hasDescription then
  detail=make("TextLabel",{
   Text=o.Description,BackgroundTransparency=1,
   Size=UDim2.new(1,-65,0,19),Position=UDim2.fromOffset(13,30),
   Font=Enum.Font.Gotham,TextSize=Design.type.caption,
   TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
  },f)
 end
 local arrow=make("TextLabel",{
  Text="→",BackgroundTransparency=1,
  Size=UDim2.fromOffset(19,28),Position=UDim2.new(1,-31,.5,-14),
  Font=Enum.Font.GothamMedium,TextSize=17
 },f)
 w:_theme(name,"TextColor3",colored and "bg" or "text")
 w:_theme(arrow,"TextColor3",colored and "bg" or "muted")
 if detail then w:_theme(detail,"TextColor3",colored and "bg" or "muted") end
 w:_feedback(b,f,colored and variant=="danger" and "danger" or (colored and "accent" or "panel"))
 local disabled=false
 w:_connectControl(f,b.MouseButton1Click,function()
  if not disabled then fire(o.Callback) end
 end)
 return {
  SetDisabled=function(_,v)
   disabled=v==true
   name.TextTransparency=disabled and .55 or 0
   arrow.TextTransparency=disabled and .55 or 0
   if detail then detail.TextTransparency=disabled and .6 or 0 end
  end,
  SetVisible=function(_,v)f.Visible=v~=false end,
  Destroy=function()f:Destroy()end
 }
end
function Tab:CreateToggle(o)
 o=o or {}
 local w=self.window
 local hasDescription=type(o.Description)=="string" and o.Description~=""
 local f=self:_base(hasDescription and 62 or Design.height.toggle,o.Name or "Toggle")
 local value=o.Default==true
 local b=make("TextButton",{
  Size=UDim2.fromScale(1,1),BackgroundTransparency=1,AutoButtonColor=false,
  Text="",BorderSizePixel=0
 },f)
 local name=make("TextLabel",{
  Text=tostring(o.Name or "Toggle"),BackgroundTransparency=1,
  Position=UDim2.fromOffset(13,hasDescription and 8 or 10),
  Size=UDim2.new(1,-82,0,25),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
 },f)
 w:_theme(name,"TextColor3","text")
 local detail
 if hasDescription then
  detail=make("TextLabel",{
   Text=o.Description,BackgroundTransparency=1,
   Position=UDim2.fromOffset(13,34),Size=UDim2.new(1,-85,0,18),
   Font=Enum.Font.Gotham,TextSize=Design.type.caption,
   TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
  },f)
  w:_theme(detail,"TextColor3","muted")
 end
 local track=make("Frame",{
  Size=UDim2.fromOffset(40,22),Position=UDim2.new(1,-54,.5,-11),
  BorderSizePixel=0,BackgroundColor3=w.colors.raised,Active=false
 },f)
 round(track,11)
 local knob=make("Frame",{
  Size=UDim2.fromOffset(16,16),Position=UDim2.fromOffset(3,3),
  BorderSizePixel=0,BackgroundColor3=w.colors.muted,Active=false
 },track)
 round(knob,8)
 w:_feedback(b,f)
 local disabled=false
 local function render(animate)
  local targetColor=value and w.colors.accent or w.colors.raised
  local knobColor=value and w.colors.bg or w.colors.muted
  local targetPosition=UDim2.fromOffset(value and 21 or 3,3)
  if animate then
   TweenService:Create(track,TweenInfo.new(.16),{BackgroundColor3=targetColor}):Play()
   TweenService:Create(knob,TweenInfo.new(.16),{Position=targetPosition,BackgroundColor3=knobColor}):Play()
  else
   track.BackgroundColor3=targetColor
   knob.Position=targetPosition
   knob.BackgroundColor3=knobColor
  end
 end
 w:_trackFeedback(f,function()render(false)end)
 local handle={}
 function handle:SetDisabled(v)
  disabled=v==true
  name.TextTransparency=disabled and .55 or 0
  if detail then detail.TextTransparency=disabled and .55 or 0 end
  track.BackgroundTransparency=disabled and .45 or 0
 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 function handle:Get()return value end
 function handle:Set(v,notify)
  if type(v)~="boolean" then return false end
  value=v
  render(true)
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,value)
  end
  return true
 end
 w:_register(o.Flag,handle,f)
 w:_connectControl(f,b.MouseButton1Click,function()
  if not disabled then handle:Set(not value,true) end
 end)
 render(false)
 return handle
end
function Tab:CreateSlider(o)
 o=o or {}
 local w=self.window
 local f=self:_base(Design.height.slider,o.Name or "Slider")
 local min,max=tonumber(o.Min) or 0,tonumber(o.Max) or 100
 if max<=min then max=min+1 end
 local inc=math.max(tonumber(o.Increment) or 1,0.000001)
 local value=math.clamp(tonumber(o.Default) or min,min,max)
 local label=make("TextLabel",{
  Text=tostring(o.Name or "Slider"),BackgroundTransparency=1,
  Size=UDim2.new(1,-98,0,26),Position=UDim2.fromOffset(11,4),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,TextXAlignment=Enum.TextXAlignment.Left
 },f)
 w:_theme(label,"TextColor3","text")
 local valueLabel=make("TextLabel",{
  BackgroundTransparency=1,Size=UDim2.fromOffset(77,26),
  Position=UDim2.new(1,-87,0,4),Font=Enum.Font.GothamMedium,
  TextSize=Design.type.label,TextXAlignment=Enum.TextXAlignment.Right
 },f)
 w:_theme(valueLabel,"TextColor3","muted")
 local bar=make("TextButton",{
  Size=UDim2.new(1,-24,0,18),Position=UDim2.fromOffset(12,36),
  BackgroundTransparency=1,BorderSizePixel=0,Text="",AutoButtonColor=false
 },f)
 local track=make("Frame",{
  Position=UDim2.fromOffset(0,6),Size=UDim2.new(1,0,0,6),
  BorderSizePixel=0,Active=false
 },bar)
 w:_theme(track,"BackgroundColor3","raised")
 round(track,3)
 local fill=make("Frame",{Size=UDim2.fromScale(0,1),BorderSizePixel=0},track)
 w:_theme(fill,"BackgroundColor3","accent")
 round(fill,3)
 local thumb=make("Frame",{
  AnchorPoint=Vector2.new(.5,.5),Position=UDim2.fromScale(0,.5),
  Size=UDim2.fromOffset(12,12),BorderSizePixel=0,Active=false
 },track)
 w:_theme(thumb,"BackgroundColor3","accent")
 round(thumb,6)
 local handle={}
 local disabled=false
 function handle:SetDisabled(v)
  disabled=v==true
  f.BackgroundTransparency=disabled and .45 or 0
 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 local function render()
  valueLabel.Text=tostring(value)
  local progress=(value-min)/(max-min)
  fill.Size=UDim2.fromScale(progress,1)
  thumb.Position=UDim2.fromScale(progress,.5)
 end
 function handle:Get()return value end
 function handle:Set(v,notify)
  if type(v)~="number" then return false end
  value=math.clamp(min+math.floor(((v-min)/inc)+.5)*inc,min,max)
  render()
  if notify then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,value)
  end
  return true
 end
 local dragging=false
 local dragTouch=nil
 local function updateFromPosition(pos)
  if disabled or not f.Parent then return end
  local fraction=math.clamp((pos.X-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)
  handle:Set(min+fraction*(max-min),true)
 end
 w:_connectControl(f,bar.InputBegan,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   if not disabled then
    if not dragging then
     dragging=true
     dragTouch=i.UserInputType==Enum.UserInputType.Touch and i or nil
     updateFromPosition(i.Position)
    end
   end
  end
 end)
 w:_connectControl(f,UIS.InputEnded,function(i)
  if (dragTouch==nil and i.UserInputType==Enum.UserInputType.MouseButton1)
   or (dragTouch~=nil and i==dragTouch) then
   dragging=false
   dragTouch=nil
  end
 end)
 w:_connectControl(f,UIS.InputChanged,function(i)
  if not f.Parent then dragging=false dragTouch=nil return end
  local mouseMove=i.UserInputType==Enum.UserInputType.MouseMovement
  if dragging and (mouseMove and dragTouch==nil or i==dragTouch) then
   updateFromPosition(i.Position)
  end
 end)
 w:_register(o.Flag,handle,f)
 render()
 return handle
end
-- Read-only progress component for loading, tasks and diagnostic work.
function Tab:CreateProgressBar(o)
 o=o or {}
 local w=self.window
 local f=self:_base(58,o.Name or "Progress")
 local low=tonumber(o.Min) or 0
 local high=tonumber(o.Max) or 100
 if high<=low then high=low+1 end
 local value=math.clamp(tonumber(o.Default) or low,low,high)
 local label=make("TextLabel",{
  Text=tostring(o.Name or "Progress"),BackgroundTransparency=1,
  Position=UDim2.fromOffset(11,4),Size=UDim2.new(1,-112,0,25),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  TextXAlignment=Enum.TextXAlignment.Left,TextTruncate=Enum.TextTruncate.AtEnd
 },f)
 w:_theme(label,"TextColor3","text")
 local valueLabel=make("TextLabel",{
  BackgroundTransparency=1,
  Position=UDim2.new(1,-94,0,4),Size=UDim2.fromOffset(80,25),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.label,
  TextXAlignment=Enum.TextXAlignment.Right
 },f)
 w:_theme(valueLabel,"TextColor3","muted")
 local track=make("Frame",{
  Position=UDim2.fromOffset(12,38),Size=UDim2.new(1,-24,0,7),
  BorderSizePixel=0
 },f)
 round(track,4)
 w:_theme(track,"BackgroundColor3","raised")
 local fill=make("Frame",{
  Size=UDim2.fromScale(0,1),BorderSizePixel=0
 },track)
 round(fill,4)
 w:_theme(fill,"BackgroundColor3","accent")
 local function paint(animate)
  local ratio=math.clamp((value-low)/(high-low),0,1)
  local pct=math.floor(ratio*100+.5)
  valueLabel.Text=tostring(pct).."%"
  local target=UDim2.fromScale(ratio,1)
  if animate then
   TweenService:Create(fill,TweenInfo.new(.18,Enum.EasingStyle.Quad),{Size=target}):Play()
  else fill.Size=target end
 end
 local handle={}
 function handle:Set(v,animate)
  local nextValue=tonumber(v)
  if not nextValue or nextValue~=nextValue then return false end
  value=math.clamp(nextValue,low,high)
  paint(animate==true)
  return true
 end
 function handle:Get()return value end
 function handle:SetLabel(v)label.Text=tostring(v)end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 paint(false)
 return handle
end
-- Compact live status row with standard semantic colour categories.
function Tab:CreateStatus(o)
 o=o or {}
 local w=self.window
 local f=self:_base(40,o.Name or "Status")
 local label=make("TextLabel",{
  Position=UDim2.fromOffset(12,5),Size=UDim2.new(.58,-12,1,-10),
  Text=tostring(o.Name or "Status"),BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.GothamMedium,
  TextSize=Design.type.body,TextTruncate=Enum.TextTruncate.AtEnd
 },f)
 w:_theme(label,"TextColor3","text")
 local indicator=make("Frame",{
  Position=UDim2.new(.62,0,.5,-4),Size=UDim2.fromOffset(8,8),
  BorderSizePixel=0,BackgroundTransparency=0
 },f)
 round(indicator,4)
 local valueLabel=make("TextLabel",{
  Position=UDim2.new(.65,0,0,5),Size=UDim2.new(.35,-12,1,-10),
  Text=tostring(o.Value or "Ready"),BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Right,Font=Enum.Font.GothamMedium,
  TextSize=Design.type.label,TextTruncate=Enum.TextTruncate.AtEnd
 },f)
 local level="info"
 local function paint()
  local token=level=="success" and "accent" or (level=="error" and "danger" or "muted")
  indicator.BackgroundColor3=w.colors[token]
  valueLabel.TextColor3=w.colors[token]
 end
 w:_trackFeedback(f,paint)
 local handle={}
 function handle:Set(v,nextLevel)
  valueLabel.Text=tostring(v or "")
  if nextLevel~=nil then level=string.lower(tostring(nextLevel)) end
  paint()
 end
 function handle:Get()return valueLabel.Text,level end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 handle:Set(o.Value or "Ready",o.Level or "info")
 return handle
end

function Tab:CreateDropdown(o)
 -- Searchable popup, rendered at ScreenGui level to escape scrolling-frame clipping.
 o=o or {}
 local w=self.window
 local f=self:_base(Design.height.dropdown,o.Name or "Dropdown")

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
 local lab=make("TextLabel",{
  Text=tostring(o.Name or "Dropdown"),BackgroundTransparency=1,
  Size=UDim2.new(1,-20,0,25),Position=UDim2.fromOffset(11,2),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.label,TextXAlignment=Enum.TextXAlignment.Left
 },f)
 w:_theme(lab,"TextColor3","muted")
 local b=make("TextButton",{
  Size=UDim2.new(1,-22,0,32),Position=UDim2.fromOffset(11,29),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.body,TextXAlignment=Enum.TextXAlignment.Left,
  TextTruncate=Enum.TextTruncate.AtEnd,
  BorderSizePixel=0,AutoButtonColor=false
 },f)
 round(b,Design.radius.control)
 w:_theme(b,"TextColor3","text")
 w:_theme(b,"BackgroundColor3","raised")
 local fieldStroke=make("UIStroke",{Thickness=1,Transparency=.55},b)
 w:_theme(fieldStroke,"Color","stroke")
 local chevron=make("TextLabel",{
  Text="⌄",BackgroundTransparency=1,Size=UDim2.fromOffset(18,28),
  Position=UDim2.new(1,-37,0,32),Font=Enum.Font.GothamBold,TextSize=15
 },f)
 w:_theme(chevron,"TextColor3","muted")
 local handle={}
 local disabled=false
 function handle:SetDisabled(v)
  disabled=v==true
  b.TextTransparency=disabled and .55 or 0
  chevron.TextTransparency=disabled and .55 or 0
  if disabled and w._dropdownOwner==b and w._closeDropdown then w._closeDropdown() end
 end
 function handle:SetVisible(v)
  f.Visible=v~=false
  if not f.Visible and w._dropdownOwner==b and w._closeDropdown then w._closeDropdown() end
 end
 function handle:Destroy()
  if w._dropdownOwner==b and w._closeDropdown then w._closeDropdown() end
  f:Destroy()
 end
 local function render()
  if multi then b.Text="  "..(#value==0 and "Select..." or table.concat(value,", "))
  else b.Text="  "..tostring(value or "Select...") end
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
  if w._dropdownOwner==b and w._closeDropdown then w._closeDropdown() end
 end
 w:_connectControl(f,b.MouseButton1Click,function()
  if w.destroyed or disabled then return end
  if w._dropdownOwner==b and w._closeDropdown then
   w._closeDropdown()
   return
  end
  if w._closeDropdown then w._closeDropdown() end
  local overlay=make("Frame",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ZIndex=100},w.screen)
  local dismiss=make("TextButton",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,Text="",AutoButtonColor=false,ZIndex=101},overlay)
  local viewport=w:_viewport()
  local rows=math.min(#opts,6)
  local panelHeight=math.min(math.max(82,math.min(246,rows*29+46)),math.max(68,viewport.Y-16))
  local panelWidth=math.min(math.max(155,b.AbsoluteSize.X),math.max(110,viewport.X-16))
  local panel=make("Frame",{Size=UDim2.fromOffset(panelWidth,panelHeight),BorderSizePixel=0,ZIndex=102},overlay)
  panel.BackgroundColor3=w.colors.panel
  round(panel,5)
  make("UIStroke",{Color=w.colors.muted,Thickness=1,Transparency=.55},panel)
  local function positionPanel()
   local viewport=w:_viewport()
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
   Text="",ClearTextOnFocus=false,Font=Enum.Font.Gotham,TextSize=12,
   BorderSizePixel=0,ZIndex=104
  },panel)
  round(search,3)
  local list=make("ScrollingFrame",{
   Position=UDim2.fromOffset(6,41),Size=UDim2.new(1,-12,1,-47),
   BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,
   ScrollBarImageColor3=w.colors.muted,AutomaticCanvasSize=Enum.AutomaticSize.None,
   CanvasSize=UDim2.new(),ZIndex=103
  },panel)

  -- Virtual scrolling: all options remain reachable without instantiating
  -- one Roblox TextButton per option.
  local ROW_HEIGHT=30
  local visibleCount=math.max(3,math.ceil((panelHeight-47)/ROW_HEIGHT)+2)
  local filtered={}
  local rowButtons={}
  local rowIndexes={}
  local empty=make("TextLabel",{
   Text="No matching options",
   Size=UDim2.new(1,-8,0,30),Position=UDim2.fromOffset(4,0),
   BackgroundTransparency=1,Font=Enum.Font.Gotham,
   TextSize=12,TextColor3=w.colors.muted,ZIndex=105,Visible=false
  },list)
  local function refreshVisible()
   if not overlay or not overlay.Parent then return end
   local first=math.max(1,math.floor(list.CanvasPosition.Y/ROW_HEIGHT)+1)
   for slot,row in ipairs(rowButtons) do
    local index=first+slot-1
    local choice=filtered[index]
    rowIndexes[slot]=index
    if choice~=nil then
     local chosen=multi and table.find(value,choice)~=nil or choice==value
     row.Text=(chosen and "✓  " or "   ")..tostring(choice)
     row.TextColor3=chosen and w.colors.accent or w.colors.text
     row.BackgroundColor3=w.colors.raised
     row.Position=UDim2.fromOffset(2,(index-1)*ROW_HEIGHT)
     row.Visible=true
    else
     row.Visible=false
    end
   end
   empty.Visible=#filtered==0
  end
  for slot=1,visibleCount do
   local row=make("TextButton",{
    Text="",Size=UDim2.new(1,-8,0,28),
    BackgroundColor3=w.colors.raised,BorderSizePixel=0,
    Font=Enum.Font.Gotham,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left,
    AutoButtonColor=false,TextTruncate=Enum.TextTruncate.AtEnd,
    ZIndex=105,Visible=false
   },list)
   round(row,4)
   rowButtons[slot]=row
   row.MouseEnter:Connect(function()
    if row.Parent then row.BackgroundColor3=w.colors.raised:Lerp(w.colors.accent,.10) end
   end)
   row.MouseLeave:Connect(function()
    if row.Parent then row.BackgroundColor3=w.colors.raised end
   end)
   row.MouseButton1Click:Connect(function()
    local choice=filtered[rowIndexes[slot]]
    if choice==nil then return end
    if multi then
     local nextValue=table.clone(value)
     local index=table.find(nextValue,choice)
     if index then table.remove(nextValue,index) else table.insert(nextValue,choice) end
     handle:Set(nextValue,true)
     refreshVisible()
    else
     handle:Set(choice,true)
     if w._closeDropdown then w._closeDropdown() end
    end
   end)
  end
  local function updateList()
   table.clear(filtered)
   local query=string.lower(search.Text)
   for _,option in ipairs(opts) do
    if query=="" or string.find(string.lower(tostring(option)),query,1,true) then
     filtered[#filtered+1]=option
    end
   end
   list.CanvasSize=UDim2.new(0,0,0,#filtered*ROW_HEIGHT)
   list.CanvasPosition=Vector2.zero
   refreshVisible()
  end
  list:GetPropertyChangedSignal("CanvasPosition"):Connect(refreshVisible)
  search.FocusLost:Connect(function(enterPressed)
   if enterPressed and not multi and filtered[1]~=nil and overlay and overlay.Parent then
    handle:Set(filtered[1],true)
    if w._closeDropdown then w._closeDropdown() end
   end
  end)
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
 w:_register(o.Flag,handle,f)
 render()
 return handle
end
function Tab:CreateMultiDropdown(o)
 o=o or {}
 o.Multi=true
 return self:CreateDropdown(o)
end
function Tab:CreateInput(o)
 o=o or {}
 local w=self.window
 local f=self:_base(Design.height.input,o.Name or "Input")
 local name=make("TextLabel",{
  Text=tostring(o.Name or "Input"),BackgroundTransparency=1,
  Size=UDim2.new(1,-20,0,25),Position=UDim2.fromOffset(11,2),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.label,TextXAlignment=Enum.TextXAlignment.Left
 },f)
 w:_theme(name,"TextColor3","muted")
 local box=make("TextBox",{
  Text=tostring(o.Default or ""),PlaceholderText=tostring(o.Placeholder or ""),
  ClearTextOnFocus=false,Size=UDim2.new(1,-22,0,32),
  Position=UDim2.fromOffset(11,29),Font=Enum.Font.Gotham,TextSize=Design.type.body,
  TextXAlignment=Enum.TextXAlignment.Left,BorderSizePixel=0
 },f)
 round(box,Design.radius.control)
 make("UIPadding",{PaddingLeft=UDim.new(0,10),PaddingRight=UDim.new(0,10)},box)
 w:_theme(box,"TextColor3","text")
 w:_theme(box,"BackgroundColor3","raised")
 w:_theme(box,"PlaceholderColor3","muted")
 local outline=make("UIStroke",{Thickness=1,Color=w.colors.stroke,Transparency=.42},box)
 local disabled=false
 local lastCommitted=box.Text
 local function refreshOutline()
  if not box.Parent then return end
  outline.Color=box:IsFocused() and w.colors.accent or w.colors.stroke
  outline.Transparency=box:IsFocused() and 0 or .42
 end
 w:_trackFeedback(f,refreshOutline)
 w:_connectControl(f,box.Focused,refreshOutline)
 local handle={}
 function handle:SetDisabled(v)
  disabled=v==true
  box.TextEditable=not disabled
  box.TextTransparency=disabled and .55 or 0
  name.TextTransparency=disabled and .5 or 0
  if disabled and box:IsFocused() then box:ReleaseFocus() end
 end
 function handle:SetVisible(v)f.Visible=v~=false end
 function handle:Destroy()f:Destroy()end
 function handle:Get()return box.Text end
 function handle:Focus()
  if not disabled and box.Parent then box:CaptureFocus() end
 end
 function handle:Set(v,notify)
  if o.Numeric and tonumber(v)==nil then return false end
  local nextValue=tostring(v)
  local changed=nextValue~=lastCommitted
  box.Text=nextValue
  lastCommitted=nextValue
  if notify and changed then
   if o.Flag then w:_markChanged("game") end
   fire(o.Callback,nextValue)
  end
  return true
 end
 w:_connectControl(f,box.FocusLost,function()
  refreshOutline()
  if disabled then return end
  if o.Numeric and tonumber(box.Text)==nil then
   box.Text=lastCommitted
   outline.Color=w.colors.danger
   outline.Transparency=0
   w:Notify("Enter a valid number for "..tostring(o.Name or "Input"),"WARN")
   return
  end
  handle:Set(box.Text,true)
 end)
 w:_register(o.Flag,handle,f)
 return handle
end
-- A readable paragraph card for long help or diagnostic descriptions.
function Tab:CreateParagraph(o)
 o=o or {}
 local w=self.window
 local fixedHeight=tonumber(o.Height)
 local autoHeight=fixedHeight==nil
 local f=self:_base(fixedHeight and math.clamp(fixedHeight,56,220) or 56,o.Title or "Information")
 local heading=make("TextLabel",{
  Position=UDim2.fromOffset(10,5),Size=UDim2.new(1,-20,0,23),
  BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
  Font=Enum.Font.GothamBold,TextSize=Design.type.body,Text=tostring(o.Title or "INFORMATION")
 },f)
 w:_theme(heading,"TextColor3","text")
 local content=make("TextLabel",{
  Position=UDim2.fromOffset(10,30),
  Size=autoHeight and UDim2.new(1,-20,0,0) or UDim2.new(1,-20,1,-36),
  AutomaticSize=autoHeight and Enum.AutomaticSize.Y or Enum.AutomaticSize.None,
  BackgroundTransparency=1,TextXAlignment=Enum.TextXAlignment.Left,
  TextYAlignment=Enum.TextYAlignment.Top,TextWrapped=true,
  Font=Enum.Font.Gotham,TextSize=Design.type.label,Text=tostring(o.Content or "")
 },f)
 w:_theme(content,"TextColor3","muted")
 local function updateHeight()
  if autoHeight and f.Parent then
   f.Size=UDim2.new(1,f.Parent==self.page and -4 or 0,0,math.max(56,math.min(1200,content.AbsoluteSize.Y+38)))
  end
 end
 if autoHeight then
  w:_connectControl(f,content:GetPropertyChangedSignal("AbsoluteSize"),updateHeight)
  task.defer(updateHeight)
 end
 local handle={}
 function handle:Set(title,body)
  if type(title)=="table" then
   heading.Text=tostring(title.Title or heading.Text)
   content.Text=tostring(title.Content or content.Text)
  else
   heading.Text=tostring(title or heading.Text)
   if body~=nil then content.Text=tostring(body) end
  end
  if autoHeight then task.defer(updateHeight) end
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
 local expanded=o.Expanded==true
 local f=self:_base(expanded and 230 or Design.height.toggle,o.Name or "Colour picker")
 local initial=parseColor(o.Default or o.Color) or w.colors.accent
 local hue,saturation,value=initial:ToHSV()
 local disabled=false
 local heading=make("TextButton",{
  Text=tostring(o.Name or "Colour picker"),Font=Enum.Font.GothamMedium,TextSize=Design.type.body,AutoButtonColor=false,
  TextXAlignment=Enum.TextXAlignment.Left,BackgroundTransparency=1,
  Position=UDim2.fromOffset(11,6),Size=UDim2.new(1,-85,0,28)
 },f)
 w:_theme(heading,"TextColor3","text")
 local swatch=make("TextButton",{
  Position=UDim2.new(1,-43,0,10),Size=UDim2.fromOffset(28,23),
  BackgroundColor3=initial,BorderSizePixel=0,Text="",AutoButtonColor=false
 },f)
 round(swatch,Design.radius.small)
 local swatchOutline=make("UIStroke",{Thickness=1,Transparency=.4},swatch)
 w:_theme(swatchOutline,"Color","stroke")
 local picker=make("Frame",{
  Position=UDim2.fromOffset(9,33),Size=UDim2.new(1,-18,0,98),
  Active=true,ClipsDescendants=true,BackgroundColor3=Color3.fromHSV(hue,1,1),
  BorderSizePixel=0
 },f)
 round(picker,Design.radius.small)
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
 round(target,Design.radius.small)
 make("UIStroke",{Color=Color3.new(0,0,0),Thickness=1},target)
 local hueBar=make("Frame",{
  Position=UDim2.fromOffset(9,139),Size=UDim2.new(1,-18,0,12),
  BackgroundColor3=Color3.fromRGB(255,0,0),BorderSizePixel=0,Active=true
 },f)
 round(hueBar,Design.radius.small)
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
  Position=UDim2.fromOffset(9,159),Size=UDim2.new(1,-18,0,27),
  Text=colorHex(initial),Font=Enum.Font.GothamMedium,TextSize=Design.type.body,
  ClearTextOnFocus=false,BorderSizePixel=0,
  BackgroundColor3=w.colors.panel,TextColor3=w.colors.accent
 },f)
 round(hex,Design.radius.control)
 w:_theme(hex,"BackgroundColor3","raised")
 w:_theme(hex,"TextColor3","text")
 local outline=make("UIStroke",{Color=w.colors.muted,Thickness=1,Transparency=.5},hex)
 local rgbFields={}
 local rgbCaptions={}
 for channel,name in ipairs({"R","G","B"}) do
  local fraction=(channel-1)/3
  local caption=make("TextLabel",{
   Position=UDim2.new(fraction,10,0,192),Size=UDim2.fromOffset(16,25),
   BackgroundTransparency=1,Text=name,TextColor3=w.colors.muted,
   Font=Enum.Font.Gotham,TextSize=12
  },f)
  w:_theme(caption,"TextColor3","muted")
  rgbCaptions[channel]=caption
  local field=make("TextBox",{
   Position=UDim2.new(fraction,28,0,192),Size=UDim2.new(1/3,-34,0,27),
   BackgroundColor3=w.colors.panel,TextColor3=w.colors.accent,
   Font=Enum.Font.Gotham,TextSize=12,BorderSizePixel=0,
   ClearTextOnFocus=false,Text="0"
  },f)
  round(field,Design.radius.small)
  w:_theme(field,"BackgroundColor3","raised")
  w:_theme(field,"TextColor3","text")
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
 local function setExpanded(v)
  expanded=v==true
  f.Size=UDim2.new(1,f.Parent==self.page and -4 or 0,0,expanded and 230 or Design.height.toggle)
  heading.Text=tostring(o.Name or "Colour picker")..(expanded and "  ▴" or "  ▾")
  picker.Visible=expanded
  hueBar.Visible=expanded
  hex.Visible=expanded
  for _,caption in ipairs(rgbCaptions) do caption.Visible=expanded end
  for _,field in ipairs(rgbFields) do field.Visible=expanded end
 end
 function handle:SetExpanded(v)setExpanded(v)end
 function handle:GetExpanded()return expanded end
 w:_connectControl(f,heading.MouseButton1Click,function()
  if not disabled then setExpanded(not expanded) end
 end)
 w:_connectControl(f,swatch.MouseButton1Click,function()
  if not disabled then setExpanded(not expanded) end
 end)
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
 local dragTouch=nil
 local function applyInput(which,pos)
  if disabled or not expanded or not f.Parent then return end
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
 w:_connectControl(f,picker.InputBegan,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   if not dragging then
    dragging="sv"
    dragTouch=i.UserInputType==Enum.UserInputType.Touch and i or nil
    applyInput(dragging,i.Position)
   end
  end
 end)
 w:_connectControl(f,hueBar.InputBegan,function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
   if not dragging then
    dragging="hue"
    dragTouch=i.UserInputType==Enum.UserInputType.Touch and i or nil
    applyInput(dragging,i.Position)
   end
  end
 end)
 w:_connectControl(f,UIS.InputChanged,function(i)
  if not f.Parent then dragging=nil dragTouch=nil return end
  local mouseMove=i.UserInputType==Enum.UserInputType.MouseMovement
  if dragging and (mouseMove and dragTouch==nil or i==dragTouch) then
   applyInput(dragging,i.Position)
  end
 end)
 w:_connectControl(f,UIS.InputEnded,function(i)
  if (dragTouch==nil and i.UserInputType==Enum.UserInputType.MouseButton1)
   or (dragTouch~=nil and i==dragTouch) then
   dragging=nil
   dragTouch=nil
  end
 end)
 w:_connectControl(f,hex.Focused,function()outline.Color=w.colors.accent outline.Transparency=0 end)
 w:_connectControl(f,hex.FocusLost,function()
  outline.Color=w.colors.muted outline.Transparency=.5
  if not handle:Set(hex.Text,true) then hex.Text=handle:GetHex() end
 end)
 for _,field in ipairs(rgbFields) do
  w:_connectControl(f,field.FocusLost,function()
   local rgb={}
   for i,box in ipairs(rgbFields) do rgb[i]=tonumber(box.Text) end
   if rgb[1] and rgb[2] and rgb[3] then
    handle:SetRGB(rgb[1],rgb[2],rgb[3],true)
   else
    repaint()
   end
  end)
 end
 w:_register(o.Flag,handle,f)
 repaint()
 setExpanded(expanded)
 return handle
end

-- Keybinds use the window's shared input dispatcher rather than one
-- global InputBegan/InputEnded listener for every keybind.
function Tab:CreateKeybind(o)
 o=o or {}
 local w=self.window
 local f=self:_base(Design.height.toggle,o.Name or "Keybind")
 local mode=o.Mode or "Toggle"
 if mode~="Hold" and mode~="Toggle" and mode~="Press" then mode="Toggle" end
 local label=make("TextLabel",{
  Text=tostring(o.Name or "Keybind"),Font=Enum.Font.GothamMedium,
  TextSize=Design.type.body,BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,
  Position=UDim2.fromOffset(11,0),Size=UDim2.new(.56,-12,1,0)
 },f)
 w:_theme(label,"TextColor3","text")
 local button=make("TextButton",{
  Size=UDim2.new(.42,-12,0,30),Position=UDim2.new(.58,0,0,7),
  BackgroundColor3=w.colors.raised,TextColor3=w.colors.accent,
  Text="None",Font=Enum.Font.GothamMedium,TextSize=Design.type.label,BorderSizePixel=0
 },f)
 round(button,Design.radius.control)
 local keyStroke=make("UIStroke",{Thickness=1,Transparency=.58},button)
 w:_theme(keyStroke,"Color","stroke")
 w:_theme(button,"BackgroundColor3","raised")
 w:_theme(button,"TextColor3","text")
 local selected=nil
 local active=false
 local disabled=false
 local handle={}
 local function redraw()
  button.Text=selected or "None"
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
 local function releaseKeybind()
  if w._bindingCapture==handle then w._bindingCapture=nil end
  for i=#w._keybinds,1,-1 do
   if w._keybinds[i]==handle then table.remove(w._keybinds,i) end
  end
 end
 f.Destroying:Connect(releaseKeybind)
 function handle:Destroy()
  releaseKeybind()
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
 w:_connectControl(f,button.MouseButton1Click,function()
  if disabled then return end
  w._bindingCapture=handle
  button.Text="Press a key..."
 end)
 handle:Set(o.Default or "None")
 table.insert(w._keybinds,handle)
 w:_register(o.Flag,handle,f)
 redraw()
 return handle
end

function Tab:CreateTextArea(o)
 o=o or {}
 local w=self.window
 local height=math.clamp(tonumber(o.Height) or 120,80,240)
 local f=self:_base(height,o.Name or "Text")
 local label=make("TextLabel",{
  Text=tostring(o.Name or "JSON"),BackgroundTransparency=1,
  Position=UDim2.fromOffset(6,3),Size=UDim2.new(1,-12,0,22),
  Font=Enum.Font.GothamMedium,TextSize=Design.type.label,TextXAlignment=Enum.TextXAlignment.Left
 },f)
 w:_theme(label,"TextColor3","muted")
 local box=make("TextBox",{
  Size=UDim2.new(1,-12,1,-30),Position=UDim2.fromOffset(6,26),
  BackgroundColor3=w.colors.raised,TextColor3=w.colors.text,
  PlaceholderColor3=w.colors.muted,Text=tostring(o.Default or ""),
  PlaceholderText=tostring(o.Placeholder or "Paste JSON here..."),
  ClearTextOnFocus=false,MultiLine=true,TextWrapped=true,
  TextXAlignment=Enum.TextXAlignment.Left,TextYAlignment=Enum.TextYAlignment.Top,
  Font=Enum.Font.Code,TextSize=12,BorderSizePixel=0
 },f)
 round(box,Design.radius.control)
 w:_theme(box,"BackgroundColor3","raised")
 w:_theme(box,"TextColor3","text")
 w:_theme(box,"PlaceholderColor3","muted")
 local outline=make("UIStroke",{Color=w.colors.muted,Transparency=.55,Thickness=1},box)
 w:_connectControl(f,box.Focused,function()
  outline.Color=w.colors.accent outline.Transparency=0
 end)
 w:_connectControl(f,box.FocusLost,function()
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
function Window:_register(flag,handle,owner)
 if type(flag)=="string" and #flag>0 then
  self.flags[flag]=handle
  if owner then
   owner.Destroying:Connect(function()
    if self.flags[flag]==handle then self.flags[flag]=nil end
   end)
  end
 end
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
 local title=kind=="appearance" and "Saved appearance" or "Game profiles"
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
 tab:CreateButton({
  Name="Delete selected profile",Variant="Danger",
  Description="Confirm before removing a saved profile",
  Callback=function()
   local target=picker:Get()
   if not target then w:Notify("No saved profile selected","WARN") return end
   w:Confirm({
    Title="Delete profile?",
    Content="Permanently delete '"..tostring(target).."'? This cannot be undone.",
    ConfirmText="Delete",Danger=true,
    OnConfirm=function()
     local ok,why=store:Delete(target)
     if ok then
      refresh()
      if w._autosaveTargets[kind]==target then w._autosaveTargets[kind]=nil end
     end
     report("Delete",ok,why)
    end
   })
  end
 })
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
 tab:CreateSection("Import & export")
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
 local initialWidth=math.max(330,o.Size and o.Size.X.Offset or 600)
 local initialHeight=math.max(250,o.Size and o.Size.Y.Offset or 420)
 local w=setmetatable({
  width=initialWidth,height=initialHeight,
  requestedWidth=initialWidth,requestedHeight=initialHeight,
  colors=colors,themeName=palettes[o.Theme] and o.Theme or "MatrixInverse",
  rainEnabled=o.Rain==true,rainDensity=.43,rainSpeed=.25,minimized=false,destroyed=false,
  flags={},tabs={},_bound={},_boundOwners={},_connections={},_feedbackRefresh={},
  _autosaveTargets={},_autosaveDue={},_importing=false,
  _keybinds={},_toasts={},enableToasts=o.Notifications~=false,hidden=false,
  fs=storage(),borderThickness=math.clamp(tonumber(o.BorderThickness) or 4,3,16),
  _controlConnections={},_searchItems={}
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
 w:_theme(w.root,"BackgroundColor3","stroke")
 round(w.root,Design.radius.window)
 local pad=w.borderThickness
 local inner=make("Frame",{Size=UDim2.new(1,-2*pad,1,-2*pad),Position=UDim2.fromOffset(pad,pad),BorderSizePixel=0,ZIndex=5},w.root)
 w:_theme(inner,"BackgroundColor3","bg")
 round(inner,Design.radius.surface)
 w.inner=inner
 local top=make("Frame",{Size=UDim2.new(1,0,0,Design.height.header),BorderSizePixel=0,ZIndex=6},inner)
 local headerLine=make("Frame",{
  Position=UDim2.new(0,0,1,-1),Size=UDim2.new(1,0,0,1),BorderSizePixel=0,
  BackgroundTransparency=.3,ZIndex=7
 },top)
 w:_theme(headerLine,"BackgroundColor3","stroke")
 w:_theme(top,"BackgroundColor3","panel")
 -- No substitute dot logo. A Roblox-hosted image asset can show the fish artwork.
 local fish=make("ImageLabel",{
  Name="ReefFishIcon",BackgroundTransparency=1,BorderSizePixel=0,
  Size=UDim2.fromOffset(34,34),Position=UDim2.fromOffset(9,9),
  ScaleType=Enum.ScaleType.Fit,Image="",Visible=false,ZIndex=7
 },top)
 pcall(function()fish.ResampleMode=Enum.ResamplerMode.Pixelated end)
 w._fishIcon=fish
 function w:SetIcon(asset)
  local id=imageAsset(asset)
  fish.Image=id or ""
  fish.Visible=id~=nil
  local left=fish.Visible and 44 or 14
  if w._title then w._title.Position=UDim2.fromOffset(left,6) end
  if w._subtitle then w._subtitle.Position=UDim2.fromOffset(left,30) end
  return id~=nil
 end
 w:SetIcon(o.Icon or o.IconAsset or Lib.DefaultIconAsset)
 local caption=make("TextLabel",{
  Text=tostring(o.Title or "reefFish"),Position=UDim2.fromOffset(44,6),
  Size=UDim2.new(1,-152,0,25),BackgroundTransparency=1,
  TextTruncate=Enum.TextTruncate.AtEnd,TextXAlignment=Enum.TextXAlignment.Left,
  Font=Enum.Font.GothamBold,TextSize=Design.type.title,ZIndex=7
 },top)
 w:_theme(caption,"TextColor3","text")
 local subtitle=make("TextLabel",{
  Text="reefFish UI  ·  "..Lib.Version,Position=UDim2.fromOffset(44,30),
  Size=UDim2.new(1,-152,0,14),BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,
  Font=Enum.Font.Gotham,TextSize=Design.type.caption,ZIndex=7
 },top)
 w:_theme(subtitle,"TextColor3","muted")
 w._title=caption
 w._subtitle=subtitle
 w:SetIcon(o.Icon or o.IconAsset or Lib.DefaultIconAsset)
 local searchBtn=make("TextButton",{
  Name="SearchSettings",Text="⌕",Size=UDim2.fromOffset(30,28),
  Position=UDim2.new(1,-111,0,11),BorderSizePixel=0,
  Font=Enum.Font.GothamBold,TextSize=19,ZIndex=7,AutoButtonColor=false
 },top)
 w._searchBtn=searchBtn
 local min=make("TextButton",{
  Text="−",Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,-76,0,11),
  BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=18,ZIndex=7,AutoButtonColor=false
 },top)
 local close=make("TextButton",{
  Text="×",Size=UDim2.fromOffset(30,28),Position=UDim2.new(1,-41,0,11),
  BorderSizePixel=0,Font=Enum.Font.GothamBold,TextSize=18,ZIndex=7,AutoButtonColor=false
 },top)
 for _,b in ipairs({searchBtn,min,close}) do
  round(b,Design.radius.control)
  w:_theme(b,"BackgroundColor3","raised")
  w:_theme(b,"TextColor3","text")
  w:_feedback(b,b,"raised")
 end
 w.body=make("Frame",{Position=UDim2.fromOffset(0,Design.height.header),Size=UDim2.new(1,0,1,-(Design.height.header+Design.height.footer)),BackgroundTransparency=1,ZIndex=6},inner)
 w.nav=make("ScrollingFrame",{
  Size=UDim2.new(.26,0,1,0),ScrollBarThickness=0,
  BackgroundTransparency=0,CanvasSize=UDim2.new(),
  AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=6
 },w.body)
 w:_theme(w.nav,"BackgroundColor3","bg")
 w._navPadding=make("UIPadding",{
  PaddingTop=UDim.new(0,12),PaddingLeft=UDim.new(0,8),
  PaddingRight=UDim.new(0,5),PaddingBottom=UDim.new(0,8)
 },w.nav)
 w._navLayout=make("UIListLayout",{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},w.nav)
 local navDivider=make("Frame",{
  Size=UDim2.new(0,1,1,0),Position=UDim2.new(.26,0,0,0),
  BorderSizePixel=0,ZIndex=7,Active=false
 },w.body)
 w._navDivider=navDivider
 w:_theme(navDivider,"BackgroundColor3","raised")
 w.content=make("Frame",{
  Size=UDim2.new(.74,-3,1,0),Position=UDim2.new(.26,3,0,0),
  BackgroundTransparency=1,ZIndex=6
 },w.body)
 w._status=make("TextLabel",{
  Text="Ready",Position=UDim2.new(0,14,1,-25),
  Size=UDim2.new(1,-28,0,23),BackgroundTransparency=1,
  TextXAlignment=Enum.TextXAlignment.Left,Font=Enum.Font.Gotham,
  TextSize=Design.type.caption,ZIndex=6
 },inner)
 w:_theme(w._status,"TextColor3","muted")
 w._resizeGrip=make("TextButton",{
  Name="ResizeGrip",Size=UDim2.fromOffset(24,24),
  Position=UDim2.new(1,-24,1,-24),
  BackgroundTransparency=1,Text="◢",
  Font=Enum.Font.Gotham,TextSize=15,
  TextColor3=w.colors.muted,AutoButtonColor=false,
  BorderSizePixel=0,ZIndex=20
 },inner)
 w:_theme(w._resizeGrip,"TextColor3","muted")
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
  if i.KeyCode==Enum.KeyCode.Escape then
   if w._dialog then w._dialog:Cancel() return end
   if w._searchOverlay then w:CloseSearch() return end
  end
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
  if i.KeyCode==Enum.KeyCode.K
    and (UIS:IsKeyDown(Enum.KeyCode.LeftControl) or UIS:IsKeyDown(Enum.KeyCode.RightControl))
    and not w.hidden then
   w:ToggleSearch()
   return
  end
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
 w._connections[#w._connections+1]=searchBtn.MouseButton1Click:Connect(function()
  w:ToggleSearch()
 end)
 w._connections[#w._connections+1]=min.MouseButton1Click:Connect(function()w:SetMinimized(not w.minimized)end)
 w._connections[#w._connections+1]=close.MouseButton1Click:Connect(function()w:Destroy()end)
 -- Touch and mouse dragging share a single tracked gesture.
 local dragStart,startPos,resizeStart,startWidth,startHeight
 local dragTouch,resizeTouch
 local dragging,resizing=false,false
 local function isPointer(i)
  return i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch
 end
 w._connections[#w._connections+1]=top.InputBegan:Connect(function(i)
  if not isPointer(i) or resizing or w.destroyed then return end
  -- Title-bar actions shouldn't initiate dragging.
  local pos=i.Position
  local minX=min.AbsolutePosition.X
  local closeX=close.AbsolutePosition.X
  local searchX=searchBtn.AbsolutePosition.X
  if (pos.X>=searchX and pos.X<=searchX+searchBtn.AbsoluteSize.X)
   or (pos.X>=minX and pos.X<=minX+min.AbsoluteSize.X)
   or (pos.X>=closeX and pos.X<=closeX+close.AbsoluteSize.X) then return end
  dragging=true
  dragTouch=i.UserInputType==Enum.UserInputType.Touch and i or nil
  dragStart=i.Position
  startPos=w.root.AbsolutePosition
 end)
 w._connections[#w._connections+1]=w._resizeGrip.InputBegan:Connect(function(i)
  if not isPointer(i) or w.minimized or dragging or w.destroyed then return end
  resizing=true
  resizeTouch=i.UserInputType==Enum.UserInputType.Touch and i or nil
  resizeStart=i.Position
  startWidth,startHeight=w.width,w.height
 end)
 w._connections[#w._connections+1]=UIS.InputEnded:Connect(function(i)
  if i.UserInputType==Enum.UserInputType.MouseButton1 then
   dragging=false resizing=false dragTouch=nil resizeTouch=nil
  elseif i.UserInputType==Enum.UserInputType.Touch then
   if i==dragTouch then dragging=false dragTouch=nil end
   if i==resizeTouch then resizing=false resizeTouch=nil end
  end
 end)
 w._connections[#w._connections+1]=UIS.InputChanged:Connect(function(i)
  local mouseMove=i.UserInputType==Enum.UserInputType.MouseMovement
  if dragging and (mouseMove and dragTouch==nil or i==dragTouch) then
   local diff=i.Position-dragStart
   w.root.Position=UDim2.fromOffset(startPos.X+diff.X,startPos.Y+diff.Y)
   w:_clampPosition()
  elseif resizing and (mouseMove and resizeTouch==nil or i==resizeTouch) then
   local diff=i.Position-resizeStart
   w:SetSize(startWidth+diff.X,startHeight+diff.Y)
  end
 end)
 -- Fit the window to the viewport initially and on display rotation/resize.
 local function connectViewport(camera)
  if w._viewportConnection then w._viewportConnection:Disconnect() end
  w._viewportConnection=nil
  if camera then
   w._viewportConnection=camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    w:_layout()
   end)
  end
  w:_layout()
 end
 w._connections[#w._connections+1]=workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
  connectViewport(workspace.CurrentCamera)
 end)
 w._connections[#w._connections+1]=w.screen.Destroying:Connect(function()
  if w._viewportConnection then w._viewportConnection:Disconnect() w._viewportConnection=nil end
 end)
 connectViewport(workspace.CurrentCamera)
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
 local count=0
 local fieldPeriod=spacing
 local streams={}
 local rainLayer=make("Frame",{
  Name="MatrixWallpaper",
  Size=UDim2.fromScale(1,1),
  BackgroundTransparency=1,BorderSizePixel=0,
  ClipsDescendants=true,Active=false,ZIndex=2
 },w.root)
 w._rainLayer=rainLayer
  rainLayer.Visible=w.rainEnabled
  w:_refreshChrome()
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
 local function ensureRainColumns(width)
  local required=math.ceil(width/spacing)+4
  for col=count+1,required do
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
  count=math.max(count,required)
  fieldPeriod=count*spacing
 end
 w._ensureRainColumns=ensureRainColumns
 if w.rainEnabled then ensureRainColumns(w.width) end
 w._rainColumns=streams
 w._repaintRain=function()
  for _,stream in ipairs(streams) do updateText(stream) end
 end
 local elapsedBuffer=0
 local drift=0
 w._connections[#w._connections+1]=RunService.Heartbeat:Connect(function(dt)
  if w.destroyed or not w.rainEnabled or w.minimized or w.hidden or not w.screen.Enabled then
   elapsedBuffer=0
   return
  end
  elapsedBuffer+=dt
  if elapsedBuffer<.10 then return end -- at most 10 updates/second
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
    if stream.label.Visible then updateText(stream) end
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
  local appearance=w:CreateTab({Name="Appearance"})
  appearance:CreateSection("Theme & display")
  local theme=appearance:CreateDropdown({
   Name="Theme",Options={"MatrixInverse","ClassicCRT","AmberTerminal","IceConsole","Monochrome"},
   Default=w.themeName,Callback=function(value)w:SetTheme(value)end
  })
  local accentPicker=appearance:CreateColorPicker({
   Name="Accent colour",Default=w.colors.accent,
   Callback=function(c)w:SetAccentColor(c)end
  })
  local rain=appearance:CreateToggle({
   Name="Matrix rain",Description="Optional animated border effect",Default=w.rainEnabled,
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
   Name="Border thickness",Min=3,Max=16,Increment=1,Default=w.borderThickness,
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
  local config=w:CreateTab({Name="Profiles"})
  config:CreateLabel({Text="Save settings for this game. Loading a profile restores values without running actions."})
  w:_profileManager(config,"game",w.Config)
 end
 return w
end
return Lib
