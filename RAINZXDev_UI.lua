--[[
    RAINZX DEV · UI Library (v1.0)
    Buatan RAINZX DEV — pengganti layer UI lama. API 100% kompatibel dengan
    engine aimbot (CreateWindow/CreateTab/CreateSection/CreateLabel/CreateParagraph/
    CreateButton/CreateToggle/CreateDropdown/CreateSlider/CreateInput/Notify).

    Tema: dark glass, aksen RAINZX DEV (merah/oranye), rounded, bisa di-drag,
    tab bar, konten scrollable per tab, slider draggable, notifikasi.
]]

local RAINZXDev_UI = {}

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

local THEME = {
    Background = Color3.fromRGB(13, 14, 20),
    Background2 = Color3.fromRGB(21, 23, 33),
    Background3 = Color3.fromRGB(28, 31, 44),
    Element = Color3.fromRGB(34, 38, 54),
    ElementHover = Color3.fromRGB(43, 48, 68),
    Stroke = Color3.fromRGB(58, 64, 88),
    Accent = Color3.fromRGB(255, 69, 48),
    Accent2 = Color3.fromRGB(255, 118, 56),
    Text = Color3.fromRGB(238, 240, 248),
    TextDim = Color3.fromRGB(150, 156, 178),
}

local FONT = Enum.Font.GothamMedium
local FONT_BOLD = Enum.Font.GothamBold

if not table.clear then
    table.clear = function(t)
        for k in pairs(t) do t[k] = nil end
    end
end

local function getParent()
    local parent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
    if not parent then
        pcall(function() parent = LocalPlayer:WaitForChild("PlayerGui", 10) end)
    end
    if not parent and gethui then
        local ok, g = pcall(gethui)
        if ok and g then parent = g end
    end
    if not parent then parent = game:GetService("CoreGui") end
    return parent
end

local function new(className, props)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then
            pcall(function() inst[k] = v end)
        end
    end
    return inst
end

local function corner(radius)
    return new("UICorner", { CornerRadius = UDim.new(0, radius) })
end

local function contains(t, v)
    for _, item in ipairs(t) do
        if item == v then return true end
    end
    return false
end

local function stroke(object, color, thickness, transparency)
    return new("UIStroke", {
        Color = color or THEME.Stroke,
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        Parent = object,
    })
end

local function makeText(text, size, color, font)
    return new("TextLabel", {
        Text = text or "",
        TextColor3 = color or THEME.Text,
        TextSize = size or 14,
        Font = font or FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
    })
end

-- ============================== NOTIFIER ==============================
local notificationHolder = nil
local notificationQueue = {}
local notifyOffset = -8

local function ensureNotificationHolder()
    if notificationHolder and notificationHolder.Parent then
        return notificationHolder
    end
    notificationHolder = new("ScreenGui", {
        Name = "RAINZXDev_Notifications",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 999999,
        Parent = getParent(),
    })
    if syn and syn.protect_gui then pcall(syn.protect_gui, notificationHolder) end
    return notificationHolder
end

RAINZXDev_UI.Notify = function(opts)
    task.spawn(function()
        pcall(function()
            local holder = ensureNotificationHolder()
            local title = tostring(opts and opts.Title or "")
            local content = tostring(opts and opts.Content or "")
            local duration = math.max(tonumber(opts and opts.Duration) or 2.5, 0.5)

            local toast = new("Frame", {
                Name = "Toast",
                BackgroundColor3 = THEME.Background2,
                BorderSizePixel = 0,
                Size = UDim2.fromOffset(300, 0),
                Position = UDim2.new(1, 8, 0, notifyOffset),
                ZIndex = 50,
                Parent = holder,
            })
            corner(toast, 10)
            stroke(toast, THEME.Accent, 1, 0.1)
            new("UIPadding", {
                PaddingTop = UDim.new(0, 10),
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 12),
                PaddingRight = UDim.new(0, 12),
                Parent = toast,
            })
            new("UIListLayout", { Padding = UDim.new(0, 2), Parent = toast })

            local tf = new("TextLabel", {
                Text = "<b>" .. title .. "</b>",
                TextColor3 = THEME.Accent,
                TextSize = 14,
                Font = FONT_BOLD,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 18),
                Parent = toast,
            })
            tf.TextXAlignment = Enum.TextXAlignment.Left

            local bf = new("TextLabel", {
                Text = content,
                TextColor3 = THEME.TextDim,
                TextSize = 13,
                Font = FONT,
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                Size = UDim2.new(0, 276, 0, 0),
                TextWrapped = true,
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = toast,
            })

            task.delay(0.05, function()
                toast.Size = UDim2.fromOffset(300, bf.AbsoluteSize.Y + 44)
            end)

            notificationQueue[#notificationQueue + 1] = toast
            notifyOffset = notifyOffset - 306

            task.delay(duration, function()
                local ok = pcall(function()
                    toast:TweenPosition(UDim2.new(1, 8, 0, notifyOffset + 306), "In", "Quad", 0.3, true, function()
                        toast:Destroy()
                    end)
                end)
                for i = 1, #notificationQueue do
                    if notificationQueue[i] == toast then
                        table.remove(notificationQueue, i)
                        break
                    end
                end
                notifyOffset = math.min(notifyOffset + 306, -8)
            end)
        end)
    end)
end

-- ============================== CONTROL BASE ==============================

local Control = {}
Control.__index = Control

function Control.new()
    return setmetatable({ _destroyed = false }, Control)
end

function Control:Destroy()
    if self._destroyed then return end
    self._destroyed = true
    if self._instance and self._instance.Destroy then
        pcall(function() self._instance:Destroy() end)
    end
end

-- ============================== LABEL ==============================

local function createLabel(text)
    local label = new("TextLabel", {
        Text = tostring(text or ""),
        TextColor3 = THEME.TextDim,
        TextSize = 13,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, 16),
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    local obj = Control.new()
    obj.Set = function(_, v) pcall(function() label.Text = tostring(v or "") end) end
    obj._instance = label
    return obj, label
end

-- ============================== PARAGRAPH ==============================

local function createParagraph(data)
    local h = math.max(tonumber(data and data.Height) or 64, 34)
    local frame = new("Frame", {
        BackgroundColor3 = THEME.Background3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, h),
    })
    corner(frame, 8)
    new("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = frame,
    })

    local title = new("TextLabel", {
        Text = "<b>" .. tostring(data and data.Title or "") .. "</b>",
        TextColor3 = THEME.Accent,
        TextSize = 14,
        Font = FONT_BOLD,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local body = new("TextLabel", {
        Text = tostring(data and data.Content or ""),
        TextColor3 = THEME.TextDim,
        TextSize = 13,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        TextWrapped = true,
        Size = UDim2.new(1, 0, 0, h - 30),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        Parent = frame,
    })

    return Control.new(), frame
end

-- ============================== BUTTON ==============================

local function createButton(data)
    local frame = new("TextButton", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Text = tostring(data and data.Name or "Button"),
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT_BOLD,
        Size = UDim2.new(1, 0, 0, 34),
        AutoButtonColor = false,
    })
    corner(frame, 8)
    stroke(frame, THEME.Stroke, 1, 0.2)

    frame.MouseEnter:Connect(function()
        pcall(function() frame.BackgroundColor3 = THEME.ElementHover end)
    end)
    frame.MouseLeave:Connect(function()
        pcall(function() frame.BackgroundColor3 = THEME.Element end)
    end)
    frame.MouseButton1Click:Connect(function()
        if data and data.Callback then pcall(data.Callback) end
    end)

    local obj = Control.new()
    obj._instance = frame
    return obj, frame
end

-- ============================== TOGGLE ==============================

local function createToggle(data)
    local value = (data and data.CurrentValue) == true

    local frame = new("Frame", {
        BackgroundColor3 = THEME.Background3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
    })
    corner(frame, 8)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = frame })

    local title = new("TextLabel", {
        Text = tostring(data and data.Name or "Toggle"),
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -60, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = frame,
    })

    local pill = new("Frame", {
        BackgroundColor3 = value and THEME.Accent or THEME.Element,
        BorderSizePixel = 0,
        Position = UDim2.new(1, -56, 0, 8),
        Size = UDim2.fromOffset(46, 22),
        Parent = frame,
    })
    corner(pill, 11)
    stroke(pill, THEME.Stroke, 1, 0.2)

    local knob = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Position = UDim2.new(0, value and 24 or 3, 0, 3),
        Size = UDim2.fromOffset(16, 16),
        ZIndex = 2,
        Parent = pill,
    })
    corner(knob, 8)

    local clickable = new("TextButton", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = "",
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame,
    })

    local function applyGlyph()
        pill.BackgroundColor3 = value and THEME.Accent or THEME.Element
        knob.Position = UDim2.new(0, value and 24 or 3, 0, 3)
    end

    local function setValue(v, runCallback)
        v = v == true
        if v == value then return end
        value = v
        applyGlyph()
        if runCallback ~= false and data and data.Callback then
            pcall(data.Callback, value)
        end
    end

    clickable.MouseButton1Click:Connect(function()
        setValue(not value)
    end)

    applyGlyph()

    local obj = Control.new()
    obj.Set = function(_, v) setValue(v, false) end
    obj.Get = function() return value end
    obj._instance = frame
    return obj, frame
end

-- ============================== SLIDER ==============================

local function createSlider(data)
    local rngMin = tonumber(data and data.Range and data.Range[1]) or 0
    local rngMax = tonumber(data and data.Range and data.Range[2]) or 100
    local inc = math.max(tonumber(data and data.Increment) or 1, 0.01)
    local suffix = tostring(data and data.Suffix or "")
    local value = math.clamp(tonumber(data and data.CurrentValue) or rngMin, rngMin, rngMax)

    local frame = new("Frame", {
        BackgroundColor3 = THEME.Background3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 54),
    })
    corner(frame, 8)
    new("UIPadding", { PaddingLeft = UDim.new(0, 10), PaddingRight = UDim.new(0, 10), Parent = frame })

    local title = new("TextLabel", {
        Text = tostring(data and data.Name or "Slider"),
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -80, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local valueLabel = new("TextLabel", {
        Text = "",
        TextColor3 = THEME.Accent,
        TextSize = 13,
        Font = FONT_BOLD,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 74, 0, 18),
        Position = UDim2.new(1, -84, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = frame,
    })

    local track = new("Frame", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 32),
        Size = UDim2.new(1, -16, 0, 4),
        Parent = frame,
    })
    corner(track, 2)

    local fill = new("Frame", {
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 0, 1, 0),
        Parent = track,
    })
    corner(fill, 2)

    local grip = new("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        Size = UDim2.fromOffset(14, 14),
        ZIndex = 2,
        Parent = track,
    })
    corner(grip, 7)

    local function stepValue(raw)
        local stepped = math.floor((raw - rngMin) / inc + 0.5) * inc + rngMin
        return math.clamp(stepped, rngMin, rngMax)
    end

    local function render()
        local ratio = (value - rngMin) / math.max(rngMax - rngMin, 0.0001)
        fill.Size = UDim2.fromScale(math.clamp(ratio, 0, 1), 1)
        grip.Position = UDim2.new(math.clamp(ratio, 0, 1), 0, 0.5, 0)
        valueLabel.Text = tostring(value) .. suffix
    end

    local function setValue(v, runCallback)
        v = stepValue(v)
        if math.abs(v - value) < inc / 2 then
            value = v
        else
            value = v
        end
        render()
        if runCallback ~= false and data and data.Callback then
            pcall(data.Callback, value)
        end
    end

    local dragActive = false

    local function updateFromMouse()
        local abs = track.AbsolutePosition
        local width = math.max(track.AbsoluteSize.X, 1)
        local rel = (UIS:GetMouseLocation().X - abs.X) / width
        setValue(rngMin + math.clamp(rel, 0, 1) * (rngMax - rngMin))
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = true
            updateFromMouse()
        end
    end)
    grip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = true
            updateFromMouse()
        end
    end)
    UIS.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 and dragActive then
            dragActive = true
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragActive then
            updateFromMouse()
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragActive = false
        end
    end)

    render()

    local obj = Control.new()
    obj.Set = function(_, v) setValue(v, false) end
    obj.Get = function() return value end
    obj._instance = frame
    return obj, frame
end

-- ============================== DROPDOWN ==============================

local function createDropdown(data)
    local options = {}
    for _, opt in ipairs(data and data.Options or {}) do
        table.insert(options, tostring(opt))
    end

    local current = tostring(data and data.CurrentOption and data.CurrentOption[1] or options[1] or "")
    local listRef = nil
    local open = false

    local frame = new("Frame", {
        BackgroundColor3 = THEME.Background3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 38),
        ClipsDescendants = false,
        ZIndex = 5,
    })
    corner(frame, 8)

    local button = new("TextButton", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Text = "",
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT,
        AutoButtonColor = false,
        Size = UDim2.new(1, 0, 1, 0),
        Parent = frame,
    })
    corner(button, 8)

    local title = new("TextLabel", {
        Text = tostring(data and data.Name or "Dropdown"),
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -30, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = button,
    })

    local caret = new("TextLabel", {
        Text = "▾",
        TextColor3 = THEME.Accent,
        TextSize = 14,
        Font = FONT_BOLD,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(22, 1),
        Position = UDim2.new(1, -24, 0, 0),
        ZIndex = 3,
        Parent = frame,
    })

    local valueLabel = new("TextLabel", {
        Text = current,
        TextColor3 = THEME.Accent2,
        TextSize = 13,
        Font = FONT_BOLD,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, -130, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Right,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = button,
    })

    local function applySelection()
        valueLabel.Text = current
    end

    local function closeList()
        if listRef and listRef.Parent then
            listRef:Destroy()
        end
        listRef = nil
        open = false
    end

    local function rebuildList()
        closeList()
        local list = new("Frame", {
            BackgroundColor3 = THEME.Background2,
            BorderSizePixel = 0,
            Position = UDim2.new(0, 0, 1, 4),
            Size = UDim2.new(1, 0, 0, 0),
            ClipsDescendants = true,
            ZIndex = 20,
            Parent = frame,
        })
        corner(list, 8)
        stroke(list, THEME.Accent, 1, 0.1)
        new("UIPadding", {
            PaddingTop = UDim.new(0, 4),
            PaddingBottom = UDim.new(0, 4),
            PaddingLeft = UDim.new(0, 4),
            PaddingRight = UDim.new(0, 4),
            Parent = list,
        })
        new("UIListLayout", { Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder, Parent = list })

        local itemCount = 0
        for _, opt in ipairs(options) do
            itemCount = itemCount + 1
            local row = new("TextButton", {
                BackgroundColor3 = opt == current and THEME.Accent2 or THEME.Element,
                BorderSizePixel = 0,
                Text = opt,
                TextColor3 = THEME.Text,
                TextSize = 13,
                Font = FONT,
                AutoButtonColor = false,
                Size = UDim2.new(1, 0, 0, 30),
                ZIndex = 21,
                Parent = list,
            })
            corner(row, 6)
            row.MouseButton1Click:Connect(function()
                if opt ~= current then
                    current = opt
                    applySelection()
                    if data and data.Callback then
                        pcall(data.Callback, opt)
                    end
                end
                closeList()
            end)
        end

        list.Size = UDim2.new(1, 0, 0, math.max(itemCount * 32 + 8, 40))
        listRef = list
        open = true
    end

    button.MouseButton1Click:Connect(function()
        if open then
            closeList()
        else
            rebuildList()
        end
    end)

    local obj = Control.new()
    obj.Set = function(_, v)
        local key = tostring(v)
        for _, opt in ipairs(options) do
            if opt == key then
                current = opt
                applySelection()
                break
            end
        end
    end
    obj.Get = function() return current end
    obj.Refresh = function(_, newOptions)
        options = {}
        for _, opt in ipairs(newOptions or {}) do
            table.insert(options, tostring(opt))
        end
        if #options > 0 and not contains(options, current) then
            current = options[1]
        end
        applySelection()
    end
    obj._closeList = closeList
    obj._instance = frame
    return obj, frame
end

-- ============================== INPUT ==============================

local function createInput(data)
    local frame = new("Frame", {
        BackgroundColor3 = THEME.Background3,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 40),
    })
    corner(frame, 8)
    new("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8), Parent = frame })

    local title = new("TextLabel", {
        Text = tostring(data and data.Name or "Input"),
        TextColor3 = THEME.TextDim,
        TextSize = 13,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 118, 0, 24),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame,
    })

    local box = new("TextBox", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Text = tostring(data and data.CurrentValue or ""),
        PlaceholderText = tostring(data and data.PlaceholderText or ""),
        PlaceholderColor3 = THEME.TextDim,
        TextColor3 = THEME.Text,
        TextSize = 13,
        Font = FONT,
        ClearTextOnFocus = false,
        Position = UDim2.new(0, 118, 0, 8),
        Size = UDim2.new(1, -132, 0, 24),
        Parent = frame,
    })
    corner(box, 6)

    box.FocusLost:Connect(function()
        if data and data.Callback then
            pcall(data.Callback, box.Text)
        end
    end)

    local obj = Control.new()
    obj.Set = function(_, v) pcall(function() box.Text = tostring(v or "") end) end
    obj.Get = function() return box.Text end
    obj._instance = frame
    return obj, frame
end

-- ============================== TAB ==============================

local Tab = {}
Tab.__index = Tab

function Tab:Append(obj, instance)
    instance.LayoutOrder = #self._controls + 1
    instance.Parent = self._frame
    table.insert(self._controls, obj)
    return obj, instance
end

function Tab:CreateSection(title)
    local frame = new("Frame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 22),
    })
    local text = new("TextLabel", {
        Text = "<b>" .. tostring(title or "") .. "</b>",
        TextColor3 = THEME.Accent2,
        TextSize = 14,
        Font = FONT_BOLD,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, 0, 0, 18),
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = frame,
    })
    local line = new("Frame", {
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 1, -2),
        Size = UDim2.new(1, 0, 2, 0),
        Parent = frame,
    })
    corner(line, 1)
    local obj = Control.new()
    obj._instance = frame
    return self:Append(obj, frame)
end

function Tab:CreateLabel(text)
    local obj, instance = createLabel(text)
    return self:Append(obj, instance)
end

function Tab:CreateParagraph(data)
    local obj, instance = createParagraph(data)
    return self:Append(obj, instance)
end

function Tab:CreateButton(data)
    local obj, instance = createButton(data)
    return self:Append(obj, instance)
end

function Tab:CreateToggle(data)
    local obj, instance = createToggle(data)
    return self:Append(obj, instance)
end

function Tab:CreateSlider(data)
    local obj, instance = createSlider(data)
    return self:Append(obj, instance)
end

function Tab:CreateDropdown(data)
    local obj, instance = createDropdown(data)
    return self:Append(obj, instance)
end

function Tab:CreateInput(data)
    local obj, instance = createInput(data)
    return self:Append(obj, instance)
end

-- ============================== WINDOW ==============================

local Window = {}
Window.__index = Window

RAINZXDev_UI.CreateWindow = function(opts)
    opts = opts or {}
    local title = tostring(opts.Name or "RAINZX DEV")
    local width = tonumber(opts.Width) or 500
    local height = tonumber(opts.Height) or 560

    local screen = new("ScreenGui", {
        Name = "RAINZXDev_" .. tostring(opts.GuiName or "Menu"),
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 999998,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = getParent(),
    })
    if syn and syn.protect_gui then pcall(syn.protect_gui, screen) end

    local root = new("Frame", {
        Name = "Root",
        BackgroundColor3 = THEME.Background,
        BorderSizePixel = 0,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.5),
        Size = UDim2.fromOffset(width, height),
        Parent = screen,
    })
    corner(root, 14)
    stroke(root, THEME.Accent, 1, 0)

    -- Header
    local header = new("Frame", {
        BackgroundColor3 = THEME.Background2,
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, 46),
        Parent = root,
    })
    local headerTop = new("UICorner", { CornerRadius = UDim.new(0, 14) })
    headerTop.Parent = header

    new("UIPadding", {
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        Parent = header,
    })

    local logoTxt = new("TextLabel", {
        Text = "RZ",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = FONT_BOLD,
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        Size = UDim2.fromOffset(28, 28),
        Parent = header,
    })
    corner(logoTxt, 7)

    local titleLabel = new("TextLabel", {
        Text = "<b>" .. title .. "</b>",
        TextColor3 = THEME.Text,
        TextSize = 15,
        Font = FONT_BOLD,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        RichText = true,
        Size = UDim2.new(1, -70, 1, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local minimizeButton = new("TextButton", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Text = "–",
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT_BOLD,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -46, 0, 8),
        Size = UDim2.fromOffset(30, 30),
        ZIndex = 3,
        Parent = header,
    })
    corner(minimizeButton, 8)
    minimizeButton.MouseEnter:Connect(function() pcall(function() minimizeButton.BackgroundColor3 = THEME.Accent end) end)
    minimizeButton.MouseLeave:Connect(function() pcall(function() minimizeButton.BackgroundColor3 = THEME.Element end) end)

    local closeButton = new("TextButton", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Text = "✕",
        TextColor3 = THEME.Text,
        TextSize = 14,
        Font = FONT_BOLD,
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -8, 0, 8),
        Size = UDim2.fromOffset(30, 30),
        ZIndex = 3,
        Parent = header,
    })
    corner(closeButton, 8)
    closeButton.MouseEnter:Connect(function() pcall(function() closeButton.BackgroundColor3 = THEME.Accent end) end)
    closeButton.MouseLeave:Connect(function() pcall(function() closeButton.BackgroundColor3 = THEME.Element end) end)

    -- Drag
    local dragState = { active = false }
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragState.active = true
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragState.active = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragState.active and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = root.Position
            root.Position = UDim2.new(0, pos.X.Offset + input.Delta.X, 0, pos.Y.Offset + input.Delta.Y)
        end
    end)

    -- Tab bar
    local tabBar = new("Frame", {
        BackgroundColor3 = THEME.Background2,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 46),
        Size = UDim2.new(1, 0, 0, 38),
        Parent = root,
    })
    new("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        Parent = tabBar,
    })
    local tabLayout = new("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = tabBar,
    })

    -- Content
    local contentHolder = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 0, 0, 84),
        Size = UDim2.new(1, 0, 1, -104),
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = root,
    })

    local footer = new("TextLabel", {
        Text = "RAINZX DEV  •  – minimize     ✕ close",
        TextColor3 = THEME.TextDim,
        TextSize = 11,
        Font = FONT,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Position = UDim2.new(0, 12, 1, -22),
        Size = UDim2.new(1, -24, 0, 16),
        Parent = root,
    })

    local closeCallback = nil
    minimizeButton.MouseButton1Click:Connect(function()
        if closeCallback then pcall(closeCallback) end
        root.Visible = false
    end)
    closeButton.MouseButton1Click:Connect(function()
        if closeCallback then pcall(closeCallback) end
        pcall(function() screen:Destroy() end)
        root.Visible = false
    end)

    local self = setmetatable({
        _screen = screen,
        _root = root,
        _tabBar = tabBar,
        _contentHolder = contentHolder,
        _tabLayout = tabLayout,
        _tabs = {},
        _tabButtons = {},
    }, Window)

    self.Destroy = function()
        pcall(function() screen:Destroy() end)
    end

    self.SetCloseCallback = function(_, fn)
        closeCallback = fn
    end

    return self
end

function Window:CreateTab(name)
    local tabName = tostring(name or "Tab")

    local tabButton = new("TextButton", {
        BackgroundColor3 = THEME.Element,
        BorderSizePixel = 0,
        Text = tabName,
        TextColor3 = THEME.TextDim,
        TextSize = 13,
        Font = FONT_BOLD,
        AutoButtonColor = false,
        Size = UDim2.fromOffset(0, 28),
        Parent = self._tabBar,
    })
    corner(tabButton, 8)

    local tabFrame = new("ScrollingFrame", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = THEME.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = self._contentHolder,
    })
    new("UIPadding", {
        PaddingTop = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 12),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        Parent = tabFrame,
    })
    new("UIListLayout", {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        Parent = tabFrame,
    })

    local tab = setmetatable({ _name = tabName, _frame = tabFrame, _controls = {}, _button = tabButton }, Tab)

    local function selectTab()
        for _, other in pairs(self._tabButtons) do
            other:Set(false)
        end
        for _, other in pairs(self._tabs) do
            other._frame.Visible = false
        end
        tab._frame.Visible = true
        self._selectedTabName = tabName
        tabButton.BackgroundColor3 = THEME.Accent2
        tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    end

    tabButton.MouseButton1Click:Connect(selectTab)

    local state = {
        Set = function(_, active)
            if active then
                selectTab()
            else
                tabButton.BackgroundColor3 = THEME.Element
                tabButton.TextColor3 = THEME.TextDim
            end
        end,
    }

    table.insert(self._tabButtons, state)
    table.insert(self._tabs, tab)

    if #self._tabs == 1 then
        task.delay(0.05, selectTab)
    end

    tabButton.Size = UDim2.fromOffset(math.clamp(#tabName * 11 + 22, 50, 130), 28)

    return tab
end

return RAINZXDev_UI