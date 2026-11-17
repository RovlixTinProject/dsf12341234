local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

local Library = {}
Library.__index = Library

local THEME = {
    Background = Color3.fromRGB(12, 9, 11), Card = Color3.fromRGB(18, 13, 16),
    SidebarActive = Color3.fromRGB(27, 16, 19), Border = Color3.fromRGB(36, 24, 28),
    BorderActive = Color3.fromRGB(90, 36, 42), Accent = Color3.fromRGB(246, 92, 82),
    Text = Color3.fromRGB(235, 235, 235), Muted = Color3.fromRGB(120, 110, 115),
    Dim = Color3.fromRGB(72, 64, 68), ToggleOff = Color3.fromRGB(36, 28, 32),
    KnobOff = Color3.fromRGB(78, 68, 73), White = Color3.fromRGB(255, 255, 255),
}
local FAST = TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local function tween(obj, props) TweenService:Create(obj, FAST, props):Play() end
local function corner(obj, radius)
    local c = Instance.new("UICorner"); c.CornerRadius = UDim.new(0, radius or 7); c.Parent = obj; return c
end
local function stroke(obj, color)
    local s = Instance.new("UIStroke"); s.Color = color or THEME.Border; s.Thickness = 1; s.Parent = obj; return s
end
local function label(parent, text, size, color, font)
    local l = Instance.new("TextLabel"); l.BackgroundTransparency = 1; l.Text = text or "";
    l.Font = font or Enum.Font.GothamMedium; l.TextSize = size or 11; l.TextColor3 = color or THEME.Text;
    l.TextXAlignment = Enum.TextXAlignment.Left; l.Parent = parent; return l
end
local function make(class, props, parent)
    local o = Instance.new(class)
    for k,v in pairs(props or {}) do o[k] = v end
    o.Parent = parent
    return o
end

function Library:CreateWindow(options)
    options = options or {}
    local gui = make("ScreenGui", {Name = "PastaFluentUI", ResetOnSpawn = false, ZIndexBehavior = Enum.ZIndexBehavior.Sibling}, LocalPlayer:WaitForChild("PlayerGui"))
    local main = make("Frame", {Name="Main", Size=UDim2.fromOffset(790,490), Position=UDim2.new(.5,-395,.5,-245), BackgroundColor3=THEME.Background, BorderSizePixel=0}, gui)
    corner(main, 12); stroke(main)
    local top = make("Frame", {Size=UDim2.new(1,0,0,56), BackgroundTransparency=1}, main)
    local logo = label(top, options.Title or "pasta", 16, THEME.Accent, Enum.Font.GothamBold)
    logo.Position = UDim2.fromOffset(22, 0); logo.Size = UDim2.fromOffset(145, 56)
    local subtitle = label(top, options.SubTitle or "", 9, THEME.Muted)
    subtitle.Position = UDim2.fromOffset(22, 34); subtitle.Size = UDim2.fromOffset(145, 14)
    local searchBox = make("Frame", {Size=UDim2.fromOffset(250,26), Position=UDim2.fromOffset(185,15), BackgroundColor3=THEME.Card, BorderSizePixel=0}, top)
    corner(searchBox, 6); stroke(searchBox)
    local search = make("TextBox", {Size=UDim2.new(1,-16,1,0), Position=UDim2.fromOffset(9,0), BackgroundTransparency=1, PlaceholderText="Search something", PlaceholderColor3=THEME.Muted, Text="", TextColor3=THEME.Text, Font=Enum.Font.Gotham, TextSize=11, TextXAlignment=Enum.TextXAlignment.Left, ClearTextOnFocus=false}, searchBox)
    local sidebar = make("ScrollingFrame", {Size=UDim2.new(0,155,1,-68), Position=UDim2.fromOffset(14,58), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0, CanvasSize=UDim2.new()}, main)
    local sideLayout = make("UIListLayout", {Padding=UDim.new(0,3), SortOrder=Enum.SortOrder.LayoutOrder}, sidebar)
    sideLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() sidebar.CanvasSize = UDim2.fromOffset(0, sideLayout.AbsoluteContentSize.Y+8) end)
    local content = make("Frame", {Size=UDim2.new(1,-195,1,-68), Position=UDim2.fromOffset(182,58), BackgroundTransparency=1}, main)
    local window = {Gui=gui, Main=main, Sidebar=sidebar, Content=content, Search=search, Tabs={}, ActiveTab=nil, _rows={}}
    setmetatable(window, {__index = {
        AddTab = function(self, tabOptions) return self:_AddTab(tabOptions) end,
        Destroy = function(self) self.Gui:Destroy() end,
        SetVisible = function(self, visible) self.Main.Visible = visible end,
    }})

    function window:_AddTab(tabOptions)
        tabOptions = tabOptions or {}
        local title = tabOptions.Title or tabOptions.Name or ("Tab "..(#self.Tabs+1))
        local btn = make("TextButton", {Size=UDim2.new(1,-5,0,30), BackgroundColor3=THEME.Background, BackgroundTransparency=1, Text="", AutoButtonColor=false}, self.Sidebar)
        corner(btn,6)
        local iconText = label(btn, tabOptions.Icon or "", 12, THEME.Muted)
        iconText.Position=UDim2.fromOffset(10,0); iconText.Size=UDim2.fromOffset(18,30)
        local titleLabel = label(btn,title,11,THEME.Muted)
        titleLabel.Position=UDim2.fromOffset(34,0); titleLabel.Size=UDim2.new(1,-40,1,0)
        local page = make("ScrollingFrame", {Name=title, Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, BorderSizePixel=0, ScrollBarThickness=0, Visible=false, CanvasSize=UDim2.new()}, self.Content)
        local grid = make("UIGridLayout", {CellSize=UDim2.new(.485,0,0,150), CellPadding=UDim2.new(.03,0,0,12), SortOrder=Enum.SortOrder.LayoutOrder}, page)
        grid:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() page.CanvasSize=UDim2.fromOffset(0,grid.AbsoluteContentSize.Y+12) end)
        local tab = {Title=title, Button=btn, Page=page, Sections={}, Window=self}
        setmetatable(tab,{__index={AddSection=function(t,sectionOptions) return Library._AddTabSection(Library,t,sectionOptions) end, Select=function(t) t.Window:_SelectTab(t) end}})
        function self:_SelectTab(selected)
            if self.ActiveTab then
                self.ActiveTab.Page.Visible=false
                tween(self.ActiveTab.Button,{BackgroundTransparency=1})
                self.ActiveTab.TitleLabel.TextColor3=THEME.Muted
                self.ActiveTab.IconLabel.TextColor3=THEME.Muted
            end
            self.ActiveTab=selected; selected.Page.Visible=true
            tween(selected.Button,{BackgroundColor3=THEME.SidebarActive,BackgroundTransparency=0})
            selected.TitleLabel.TextColor3=THEME.Text; selected.IconLabel.TextColor3=THEME.Accent
            self:_ApplySearch()
        end
        tab.TitleLabel=titleLabel; tab.IconLabel=iconText
        btn.MouseButton1Click:Connect(function() self:_SelectTab(tab) end)
        table.insert(self.Tabs,tab)
        if #self.Tabs==1 or tabOptions.Default then self:_SelectTab(tab) end
        return tab
    end

    function window:_ApplySearch()
        local q=string.lower(self.Search.Text or "")
        for _,row in ipairs(self._rows) do
            local inActive = self.ActiveTab and row.Tab==self.ActiveTab
            local match = q=="" or string.find(string.lower(row.SearchText),q,1,true)~=nil
            row.Frame.Visible = inActive and match
        end
        for _,tab in ipairs(self.Tabs) do
            for _,section in ipairs(tab.Sections) do
                section.Frame.Visible = tab==self.ActiveTab
            end
        end
    end
    search:GetPropertyChangedSignal("Text"):Connect(function() window:_ApplySearch() end)

    -- Drag window by top bar.
    local dragging, dragInput, dragStart, startPos
    top.InputBegan:Connect(function(input)
        if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=true; dragStart=input.Position; startPos=main.Position end
    end)
    top.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement then dragInput=input end end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input==dragInput then local d=input.Position-dragStart; main.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y) end
    end)
    UIS.InputEnded:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseButton1 then dragging=false end end)
    local visible=true
    UIS.InputBegan:Connect(function(input,processed)
        if not processed and input.KeyCode==Enum.KeyCode.RightShift then visible=not visible; main.Visible=visible end
    end)
    return window
end

function Library:_MakeRow(section, name, height, searchText)
    local row=make("Frame",{Name=name or "Control",Size=UDim2.new(1,0,0,height or 34),BackgroundTransparency=1},section.Frame)
    table.insert(section.Tab.Window._rows,{Frame=row,Tab=section.Tab,SearchText=(name or "").." "..(searchText or "")})
    section.Tab.Window:_ApplySearch()
    return row
end

function Library:_AddTabSection(tab, options)
    if type(options)=="string" then options={Title=options} end
    options=options or {}; local title=options.Title or options.Name or "Section"
    local card=make("Frame",{Name=title,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,BackgroundColor3=THEME.Card,BorderSizePixel=0},tab.Page)
    corner(card,8); stroke(card)
    make("UIPadding",{PaddingTop=UDim.new(0,11),PaddingBottom=UDim.new(0,12),PaddingLeft=UDim.new(0,12),PaddingRight=UDim.new(0,12)},card)
    local layout=make("UIListLayout",{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},card)
    local head=label(card,title,12,THEME.Text,Enum.Font.GothamBold); head.Size=UDim2.new(1,0,0,18); head.LayoutOrder=0
    local section={Frame=card,Tab=tab,Layout=layout,Controls={}}
    setmetatable(section,{__index={
        AddToggle=function(s,id,opts) return Library._AddToggle(Library,s,id,opts) end,
        AddButton=function(s,id,opts) return Library._AddButton(Library,s,id,opts) end,
        AddSlider=function(s,id,opts) return Library._AddSlider(Library,s,id,opts) end,
        AddDropdown=function(s,id,opts) return Library._AddDropdown(Library,s,id,opts) end,
        AddKeybind=function(s,id,opts) return Library._AddKeybind(Library,s,id,opts) end,
        AddInput=function(s,id,opts) return Library._AddInput(Library,s,id,opts) end,
        AddParagraph=function(s,opts) return Library._AddParagraph(Library,s,opts) end,
        AddLabel=function(s,text) return Library._AddParagraph(Library,s,{Title=text}) end,
    }})
    table.insert(tab.Sections,section)
    return section
end

function Library._AddToggle(_,s,id,opts)
    opts=opts or {}; local title=opts.Title or id or "Toggle"; local state=opts.Default==true
    local row=Library._MakeRow(Library,s,title,30,opts.Description)
    local text=label(row,title,11,THEME.Text); text.Size=UDim2.new(1,-55,0,16)
    if opts.Description then local d=label(row,opts.Description,9,THEME.Muted); d.Position=UDim2.fromOffset(0,15); d.Size=UDim2.new(1,-55,0,12) end
    local track=make("TextButton",{Size=UDim2.fromOffset(32,16),Position=UDim2.new(1,-32,.5,-8),BackgroundColor3=state and THEME.Accent or THEME.ToggleOff,Text="",AutoButtonColor=false},row); corner(track,9)
    local knob=make("Frame",{Size=UDim2.fromOffset(12,12),Position=state and UDim2.new(1,-14,.5,-6) or UDim2.new(0,2,.5,-6),BackgroundColor3=THEME.White,BorderSizePixel=0},track); corner(knob,9)
    local control={Value=state,SetValue=function(self,v) state=not not v; self.Value=state; tween(track,{BackgroundColor3=state and THEME.Accent or THEME.ToggleOff}); tween(knob,{Position=state and UDim2.new(1,-14,.5,-6) or UDim2.new(0,2,.5,-6)}) end}
    track.MouseButton1Click:Connect(function() control:SetValue(not state); if opts.Callback then opts.Callback(state) end end)
    table.insert(s.Controls,control); return control
end
function Library._AddButton(_,s,id,opts)
    opts=opts or {}; local title=opts.Title or id or "Button"; local row=Library._MakeRow(Library,s,title,32,opts.Description)
    local b=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundColor3=THEME.SidebarActive,Text=title,TextColor3=THEME.Text,Font=Enum.Font.GothamMedium,TextSize=10,AutoButtonColor=false},row); corner(b,6); stroke(b)
    b.MouseButton1Click:Connect(function() if opts.Callback then opts.Callback() end end); return {Button=b}
end
function Library._AddSlider(_,s,id,opts)
    opts=opts or {}; local title=opts.Title or id or "Slider"; local min=opts.Min or 0; local max=opts.Max or 100; local value=math.clamp(opts.Default or min,min,max)
    local row=Library._MakeRow(Library,s,title,44,opts.Description); local t=label(row,title,11,THEME.Text); t.Size=UDim2.new(1,-50,0,16)
    local val=label(row,tostring(value),10,THEME.Muted); val.Size=UDim2.fromOffset(45,16); val.Position=UDim2.new(1,-45,0,0); val.TextXAlignment=Enum.TextXAlignment.Right
    local bar=make("TextButton",{Size=UDim2.new(1,0,0,5),Position=UDim2.fromOffset(0,29),BackgroundColor3=THEME.ToggleOff,Text="",AutoButtonColor=false},row); corner(bar,4)
    local fill=make("Frame",{Size=UDim2.new((value-min)/math.max(max-min,1),0,1,0),BackgroundColor3=THEME.Accent,BorderSizePixel=0},bar); corner(fill,4)
    local function set(v) value=math.clamp(v,min,max); val.Text=tostring(value); fill.Size=UDim2.new((value-min)/math.max(max-min,1),0,1,0); if opts.Callback then opts.Callback(value) end end
    local function update(x) set(math.floor(min+(max-min)*math.clamp((x-bar.AbsolutePosition.X)/math.max(bar.AbsoluteSize.X,1),0,1)+.5)) end
    bar.MouseButton1Down:Connect(function(x) update(x) end); UIS.InputChanged:Connect(function(input) if input.UserInputType==Enum.UserInputType.MouseMovement and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then update(input.Position.X) end end)
    return {GetValue=function() return value end,SetValue=set}
end
function Library._AddDropdown(_,s,id,opts)
    opts=opts or {}; local title=opts.Title or id or "Dropdown"; local values=opts.Values or opts.Options or {}; local selected=opts.Default
    local row=Library._MakeRow(Library,s,title,34,table.concat(values," ")); local b=make("TextButton",{Size=UDim2.new(1,0,1,0),BackgroundColor3=THEME.SidebarActive,Text=title.."  ▾  "..tostring(selected or "Select"),TextColor3=THEME.Text,Font=Enum.Font.Gotham,TextSize=10,AutoButtonColor=false},row); corner(b,5)
    b.MouseButton1Click:Connect(function() if #values==0 then return end; local i=table.find(values,selected) or 0; selected=values[i%#values+1]; b.Text=title.."  ▾  "..tostring(selected); if opts.Callback then opts.Callback(selected) end end)
    return {GetValue=function() return selected end,SetValue=function(v) selected=v; b.Text=title.."  ▾  "..tostring(v) end}
end
function Library._AddKeybind(_,s,id,opts)
    opts=opts or {}; local title=opts.Title or id or "Keybind"; local key=opts.Default or Enum.KeyCode.Unknown
    local row=Library._MakeRow(Library,s,title,30); local t=label(row,title,11,THEME.Text); t.Size=UDim2.new(1,-75,1,0)
    local b=make("TextButton",{Size=UDim2.fromOffset(65,22),Position=UDim2.new(1,-65,.5,-11),BackgroundColor3=THEME.SidebarActive,Text=key.Name,TextColor3=THEME.Text,Font=Enum.Font.GothamBold,TextSize=9},row); corner(b,4); stroke(b)
    local listening=false; b.MouseButton1Click:Connect(function() listening=true; b.Text="..." end)
    local conn; conn=UIS.InputBegan:Connect(function(input,processed) if listening and input.UserInputType==Enum.UserInputType.Keyboard then listening=false; key=input.KeyCode; b.Text=key.Name; if opts.Changed then opts.Changed(key) end elseif not processed and not listening and input.KeyCode==key and opts.Callback then opts.Callback() end end)
    return {GetValue=function() return key end,SetValue=function(v) key=v; b.Text=v.Name end,Destroy=function() conn:Disconnect() end}
end
function Library._AddInput(_,s,id,opts)
    opts=opts or {}; local title=opts.Title or id or "Input"; local row=Library._MakeRow(Library,s,title,34)
    local box=make("TextBox",{Size=UDim2.new(1,0,1,0),BackgroundColor3=THEME.SidebarActive,Text=opts.Default or "",PlaceholderText=opts.Placeholder or title,TextColor3=THEME.Text,PlaceholderColor3=THEME.Muted,Font=Enum.Font.Gotham,TextSize=10,ClearTextOnFocus=false},row); corner(box,5)
    box.FocusLost:Connect(function() if opts.Callback then opts.Callback(box.Text) end end); return {Input=box,GetValue=function() return box.Text end,SetValue=function(_,v) box.Text=tostring(v) end}
end
function Library._AddParagraph(_,s,opts)
    opts=opts or {}; local title=opts.Title or ""; local desc=opts.Content or opts.Description or ""; local row=Library._MakeRow(Library,s,title,math.max(24,desc~="" and 38 or 20),title.." "..desc)
    local t=label(row,title,11,THEME.Text,Enum.Font.GothamBold); t.Size=UDim2.new(1,0,0,16)
    if desc~="" then local d=label(row,desc,9,THEME.Muted); d.Position=UDim2.fromOffset(0,17); d.Size=UDim2.new(1,0,0,20); d.TextWrapped=true end
    return {Frame=row}
end

function Library:_AddTab(tabOptions)
    return self:_AddTabSection(tabOptions)
end

return setmetatable(Library, Library)
