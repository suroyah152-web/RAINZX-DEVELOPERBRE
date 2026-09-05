--[[
    RAINZX DEV - Responsive Release Loader
    by RAINZX DEV (suroyah152-web)

    Supported places:
      Get Rich ASAP          : 128481067661991
      Chicken Farm           : 137233438285284
      SevenM Hood            : 131558436575033
      +1 Speed Monkey Escape : 114697347887839
      +1 Power Per Click     : 74889851913797
      Dig & Clean             : 83038462357724
      Magic Loot             : 133188236593503
      Sniper Arena universe  : GameId 9534705677 (all current/future subplaces)
      One Tap universe       : GameId 9294074907 (root PlaceId 90568084448279)
      Kick a Lucky Block     : GameId 10004244222 (root PlaceId 89469502395769)
      Murder Mystery 2       : 142823291
      Build a Gun Army        : 134162299584012

    One free loader for all supported RAINZX DEV scripts.
    Includes automatic PlaceId + universe detection, an automatic script menu, and universal anti-AFK.
    After a module loads, the loader verifies that a menu actually appeared; if a loaded module
    silently exits without showing any menu (wrong game / script version), it reopens the script
    menu automatically so the user can pick another script instead of being stuck.
]]

local ENV = (getgenv and getgenv()) or _G

ENV.__RAINZXDEV_CONFIG_SHARED_STATE =
    ENV.__RAINZXDEV_CONFIG_SHARED_STATE
    or {
        Root = "RAINZXDEV/Configs",
        AutoSaveDefault = true,
        AutoLoadDefault = true,
    }

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local HttpService = game:GetService("HttpService")

ENV.__RAINZXDEV_UI_SHARED_STATE = ENV.__RAINZXDEV_UI_SHARED_STATE or {
    ToggleKeyName = "K",
    LayoutMode = "Auto",
    UIScalePercent = 100,
}

local SHARED_UI_STATE = ENV.__RAINZXDEV_UI_SHARED_STATE
SHARED_UI_STATE.LayoutMode = tostring(SHARED_UI_STATE.LayoutMode or "Auto")
SHARED_UI_STATE.UIScalePercent = math.clamp(tonumber(SHARED_UI_STATE.UIScalePercent) or 100, 75, 125)

local REPO_OWNER = "suroyah152-web"
local REPO_NAME = "RAINZX-DEVELOPERBRE"
local BASE_URL = "https://raw.githubusercontent.com/" .. REPO_OWNER .. "/" .. REPO_NAME .. "/main/"


-- =========================
-- EMBEDDED MODULES (offline, no download needed)
-- =========================
local EMBEDDED_SOURCES = {
    ['RAINZX-DEVELOPERBRE/AimbotRage_FullBuild.lua'] = [===[--[[
    RAINZX DEV · Sniper Arena
    AutoAim + Auto Shoot + ESP · Shared UI · Universe v4.6.5 · Native LMB / RMB Auto Shoot

    FULL BUILD — 100% source code + fungsional aimbot rage diambil utuh dari
    sumber asli (PuckAFK/Sniper Arena.lua, 4098 baris), dibobol sampai dalam:
    inti aim/rage/preset, config store autosave, integrasi modul game 4 lapis,
    entity/visibility backend, ESP + chams + tracer, FOV ring, semua tab UI
    (Combat/Legit/Rage/Visuals/Settings/Configs), triggerbot auto shoot, dan
    cleanup/render loop. Rebrand RAINZX DEV; logika kode tetap verbatim.

    DEPENDENSI: NONE — build self-contained (UI library di-embed langsung,
    tidak perlu download dari repo. Loader dan versi file tunggal siap pakai.
    Menu tampil otomatis saat execute; tombol "–" minimize, "✕" close, tanpa keybind.
]]

-- RAINZX DEV · Aim / ESP · UI Library Edition
-- Exact shared RAINZXDev_UI visual/control layer + v7 human/model finding.

local compiler = loadstring or load
if type(compiler) ~= "function" then
    return warn("[RAINZX DEV Sniper Arena] loadstring/load unavailable")
end

-- RAINZXDev_UI.lua embedded (self-contained build, tidak perlu download dari repo)
local uiSource = [==[
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
]==]

local uiChunk, uiError = compiler(uiSource)
if not uiChunk then
    return warn("[RAINZX DEV Sniper Arena] UI library compile failed: " .. tostring(uiError))
end

local okLib, RAINZXDevUI = pcall(uiChunk)
if not okLib
    or type(RAINZXDevUI) ~= "table"
    or type(RAINZXDevUI.CreateWindow) ~= "function"
then
    return warn("[RAINZX DEV Sniper Arena] invalid UI library")
end

--// Clean up an older copy
local ENV = (getgenv and getgenv()) or _G
if ENV.__RAINZX_SNIPER_ARENA_AIM_ESP_CLEANUP then
    pcall(ENV.__RAINZX_SNIPER_ARENA_AIM_ESP_CLEANUP)
end

--// Services
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

--// Sniper Arena universe support
-- The script is intentionally universe-based instead of PlaceId-only so new
-- Sniper Arena subplaces continue to work without another script update.
local SNIPER_ARENA_UNIVERSE_ID = 9534705677

if tonumber(game.GameId) ~= SNIPER_ARENA_UNIVERSE_ID then
    warn(("[RAINZX DEV Sniper Arena] Wrong universe. Expected %s, got GameId %s / PlaceId %s")
        :format(tostring(SNIPER_ARENA_UNIVERSE_ID), tostring(game.GameId), tostring(game.PlaceId)))
    return
end

local PLACE_INFO = {
    [122446657157717] = {Name = "Main Lobby", Kind = "lobby"},
    [74424488747487] = {Name = "Mobile Lobby", Kind = "lobby"},
    [80344694749728] = {Name = "Unnamed / Internal", Kind = "dynamic"},
    [81864505280935] = {Name = "Gun Game", Kind = "combat"},
    [90165746516953] = {Name = "Matchmaking / Ranked", Kind = "dynamic"},
    [90625015569871] = {Name = "Test Arcade", Kind = "dynamic"},
    [92726474449929] = {Name = "Test Trading Market", Kind = "market"},
    [96216501849190] = {Name = "Arcade Mobile", Kind = "combat"},
    [101571206862372] = {Name = "Knife FFA Mobile", Kind = "combat"},
    [102220551718323] = {Name = "Test", Kind = "dynamic"},
    [109094919875208] = {Name = "TDM 8v8", Kind = "combat"},
    [111189101942839] = {Name = "No Bots FFA Mobile", Kind = "combat"},
    [112261221918322] = {Name = "Test Matchmaking", Kind = "dynamic"},
    [113390337779988] = {Name = "Dash Arcade Mobile", Kind = "combat"},
    [114188007571146] = {Name = "Knife FFA", Kind = "combat"},
    [115517196855730] = {Name = "Dash Arcade", Kind = "combat"},
    [118561101017718] = {Name = "Rapid Fire Arcade", Kind = "combat"},
    [119259569670784] = {Name = "Arcade Beginner", Kind = "combat"},
    [119661268047775] = {Name = "Free For All (No Bots)", Kind = "combat"},
    [124955530864032] = {Name = "Free For All Mobile", Kind = "combat"},
    [125154235269776] = {Name = "Trading Market", Kind = "market"},
    [126042865144779] = {Name = "Classic Arcade", Kind = "combat"},
}

local function getCurrentPlaceInfo()
    return PLACE_INFO[game.PlaceId]
        or {
            Name = "Future / Unknown Sniper Arena Place",
            Kind = "dynamic",
        }
end

-- If Sniper Arena teleports to another place in the same universe, queue the
-- universal loader when the executor supports it.
do
    local queueFunction =
        (type(queue_on_teleport) == "function" and queue_on_teleport)
        or (type(queueonteleport) == "function" and queueonteleport)
        or (syn and type(syn.queue_on_teleport) == "function" and syn.queue_on_teleport)

    if type(queueFunction) == "function" and not ENV.__RAINZX_SNIPER_TELEPORT_QUEUED then
        ENV.__RAINZX_SNIPER_TELEPORT_QUEUED = true
        pcall(queueFunction, [[loadstring(game:HttpGet("https://raw.githubusercontent.com/suroyah152-web/RAINZX-DEVELOPERBRE/main/RainzxDev_Loader.lua"))()]])
    end
end

--// Configuration
local Config = {
    AimMode = "Custom",

    Aim = {
        Enabled = true,
        HoldRMB = true,
        VisibleCheck = true,
        RespectGameVisibility = true,
        RespectSmoke = true,
        RespectFlash = true,
        HeadPriority = true, -- legacy compatibility
        AimPoint = "Head",   -- Head / Upper Torso / Closest Part

        AutoShoot = false,
        AutoShootButton = "RMB", -- RMB / LMB; always reads the player's real mouse button
        AutoShootRadius = 10, -- pixels from the predicted aim point
        AutoShootDelay = 0.00, -- optional extra delay; 0 = instant / weapon-native fire rate

        FOV = 220,             -- pixels from screen centre
        SmoothSpeed = 46,     -- higher = faster
        MaxDistance = 700,    -- game's Config.Combat.BulletMaxDistance
        StickyTarget = true,
        StickyMultiplier = 1.30,

        Prediction = true,
        PredictionTime = 0.06, -- seconds of target velocity lead
        PredictionSmoothing = 0.72, -- velocity EMA, higher = steadier prediction
        MaxPredictionOffset = 14, -- studs; prevents one bad velocity frame from throwing aim away
        AdaptiveSmoothing = true,
        MicroSnapRadius = 1.5, -- pixels
        TargetPriority = "Hybrid", -- Crosshair / Distance / Low Health / Hybrid
        SwitchDelay = 0.05,   -- seconds before changing to a different target
        SwitchThreshold = 0.12, -- new target must score this much better before switching
        LockGrace = 0.18,     -- retain last valid target through tiny visibility/FOV hiccups

        ShowFOV = true,
    },

    ESP = {
        Enabled = true,
        Boxes = true,
        Names = true,
        Health = true,
        Distance = true,
        Tracers = false,
        Chams = true,

        MaxDistance = 1200,
    },

    UI = {
        Visible = true,
    }
}

local function normalizeAutoShootButton(value)
    value = tostring(value or "RMB"):upper()
    return value == "LMB" and "LMB" or "RMB"
end


--// Persistent configs
-- Shared root/defaults so every RAINZX DEV game script can use the same convention.
ENV.__RAINZXDEV_CONFIG_SHARED_STATE =
    ENV.__RAINZXDEV_CONFIG_SHARED_STATE
    or {
        Root = "RAINZXDEV/Configs",
        AutoSaveDefault = true,
        AutoLoadDefault = true,
    }

local SharedConfigState = ENV.__RAINZXDEV_CONFIG_SHARED_STATE
SharedConfigState.Root = tostring(SharedConfigState.Root or "RAINZXDEV/Configs")
if SharedConfigState.AutoSaveDefault == nil then
    SharedConfigState.AutoSaveDefault = true
end
if SharedConfigState.AutoLoadDefault == nil then
    SharedConfigState.AutoLoadDefault = true
end

local ConfigStore = {
    Id = "SniperArena",
    Selected = "default",
    AutoSave = SharedConfigState.AutoSaveDefault == true,
    AutoLoad = SharedConfigState.AutoLoadDefault == true,
    Applying = false,
    LastFingerprint = nil,
    StatusLabel = nil,
    ProfileDropdown = nil,
    ProfileInput = nil,
    PendingProfile = nil,
}

local FS = {
    Write = type(writefile) == "function" and writefile or nil,
    Read = type(readfile) == "function" and readfile or nil,
    IsFile = type(isfile) == "function" and isfile or nil,
    MakeFolder = type(makefolder) == "function" and makefolder or nil,
    ListFiles = type(listfiles) == "function" and listfiles or nil,
    DeleteFile = type(delfile) == "function" and delfile or nil,
}

ConfigStore.Available =
    FS.Write ~= nil
    and FS.Read ~= nil
    and FS.IsFile ~= nil
    and FS.MakeFolder ~= nil

ConfigStore.Folder = SharedConfigState.Root .. "/" .. ConfigStore.Id
ConfigStore.MetaPath = ConfigStore.Folder .. "/_meta.json"

local function sanitizeConfigName(value, fallback)
    local text = tostring(value or "")
    text = text:gsub("[^%w%-%._ ]", "_")
    text = text:gsub("^%s+", ""):gsub("%s+$", "")
    text = text:gsub("%s+", "_")
    text = text:gsub("_+", "_")

    if text == "" then
        text = tostring(fallback or "default")
    end

    return text:sub(1, 80)
end

local function ensureConfigFolders()
    if not FS.MakeFolder then
        return false
    end

    local current = ""
    for part in ConfigStore.Folder:gmatch("[^/\\]+") do
        current = current == "" and part or (current .. "/" .. part)
        pcall(FS.MakeFolder, current)
    end

    return true
end

local function configPath(name)
    return ConfigStore.Folder
        .. "/"
        .. sanitizeConfigName(name, "default")
        .. ".json"
end

local function encodeJSON(value)
    local ok, result = pcall(function()
        return HttpService:JSONEncode(value)
    end)
    return ok and result or nil
end

local function decodeJSON(text)
    local ok, result = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    return ok and result or nil
end

local function setConfigStatus(text)
    if ConfigStore.StatusLabel and ConfigStore.StatusLabel.Set then
        ConfigStore.StatusLabel:Set(tostring(text or ""))
    end
end

local function configSnapshot()
    return {
        Version = 6,
        AimMode = Config.AimMode,
        Aim = {
            Enabled = Config.Aim.Enabled,
            HoldRMB = Config.Aim.HoldRMB,
            VisibleCheck = Config.Aim.VisibleCheck,
            RespectGameVisibility = Config.Aim.RespectGameVisibility,
            RespectSmoke = Config.Aim.RespectSmoke,
            RespectFlash = Config.Aim.RespectFlash,
            HeadPriority = Config.Aim.HeadPriority,
            AimPoint = Config.Aim.AimPoint,
            AutoShoot = Config.Aim.AutoShoot,
            AutoShootButton = normalizeAutoShootButton(Config.Aim.AutoShootButton),
            AutoShootRadius = Config.Aim.AutoShootRadius,
            AutoShootDelay = Config.Aim.AutoShootDelay,
            FOV = Config.Aim.FOV,
            SmoothSpeed = Config.Aim.SmoothSpeed,
            MaxDistance = Config.Aim.MaxDistance,
            StickyTarget = Config.Aim.StickyTarget,
            StickyMultiplier = Config.Aim.StickyMultiplier,
            Prediction = Config.Aim.Prediction,
            PredictionTime = Config.Aim.PredictionTime,
            PredictionSmoothing = Config.Aim.PredictionSmoothing,
            MaxPredictionOffset = Config.Aim.MaxPredictionOffset,
            AdaptiveSmoothing = Config.Aim.AdaptiveSmoothing,
            MicroSnapRadius = Config.Aim.MicroSnapRadius,
            TargetPriority = Config.Aim.TargetPriority,
            SwitchDelay = Config.Aim.SwitchDelay,
            SwitchThreshold = Config.Aim.SwitchThreshold,
            LockGrace = Config.Aim.LockGrace,
            ShowFOV = Config.Aim.ShowFOV,
        },
        ESP = {
            Enabled = Config.ESP.Enabled,
            Boxes = Config.ESP.Boxes,
            Names = Config.ESP.Names,
            Health = Config.ESP.Health,
            Distance = Config.ESP.Distance,
            Tracers = Config.ESP.Tracers,
            Chams = Config.ESP.Chams,
            MaxDistance = Config.ESP.MaxDistance,
        },
    }
end

local function configFingerprint()
    return encodeJSON(configSnapshot()) or ""
end

local function applyConfigTable(data)
    if type(data) ~= "table" then
        return false
    end

    ConfigStore.Applying = true

    if type(data.AimMode) == "string" and data.AimMode ~= "" then
        Config.AimMode = data.AimMode
    end

    local aim = type(data.Aim) == "table" and data.Aim or {}
    local esp = type(data.ESP) == "table" and data.ESP or {}

    local aimKeys = {
        "Enabled", "HoldRMB", "VisibleCheck", "RespectGameVisibility",
        "RespectSmoke", "RespectFlash", "HeadPriority", "AimPoint",
        "AutoShoot", "AutoShootButton", "AutoShootRadius", "AutoShootDelay", "FOV",
        "SmoothSpeed", "MaxDistance", "StickyTarget", "StickyMultiplier",
        "Prediction", "PredictionTime", "PredictionSmoothing", "MaxPredictionOffset",
        "AdaptiveSmoothing", "MicroSnapRadius", "TargetPriority", "SwitchDelay",
        "SwitchThreshold", "LockGrace", "ShowFOV",
    }

    for _, key in ipairs(aimKeys) do
        if aim[key] ~= nil then
            Config.Aim[key] = aim[key]
        end
    end

    -- v4.6.4 migration: older profiles saved 0.12 as the stock Auto Shoot delay.
    -- Treat that exact legacy default as 0 so upgrading does not preserve latency.
    local savedVersion = tonumber(data.Version) or 0
    if savedVersion < 5 and tonumber(aim.AutoShootDelay) == 0.12 then
        Config.Aim.AutoShootDelay = 0
    end

    -- v4.6.5: old profiles had no separate Auto Shoot activation button. Keep RMB
    -- as the backwards-compatible default and sanitize any manually edited value.
    Config.Aim.AutoShootButton = normalizeAutoShootButton(Config.Aim.AutoShootButton)

    local espKeys = {
        "Enabled", "Boxes", "Names", "Health",
        "Distance", "Tracers", "Chams", "MaxDistance",
    }

    for _, key in ipairs(espKeys) do
        if esp[key] ~= nil then
            Config.ESP[key] = esp[key]
        end
    end

    ConfigStore.Applying = false
    return true
end

local function saveMeta()
    if not ConfigStore.Available then
        return false
    end

    local text = encodeJSON({
        Version = 1,
        Selected = ConfigStore.Selected,
        AutoSave = ConfigStore.AutoSave,
        AutoLoad = ConfigStore.AutoLoad,
    })

    if not text then
        return false
    end

    return pcall(FS.Write, ConfigStore.MetaPath, text)
end

local function loadMeta()
    if not ConfigStore.Available or not FS.IsFile(ConfigStore.MetaPath) then
        return
    end

    local ok, text = pcall(FS.Read, ConfigStore.MetaPath)
    if not ok then
        return
    end

    local data = decodeJSON(text)
    if type(data) ~= "table" then
        return
    end

    if data.Selected ~= nil then
        ConfigStore.Selected = sanitizeConfigName(data.Selected, "default")
    end
    if data.AutoSave ~= nil then
        ConfigStore.AutoSave = data.AutoSave == true
    end
    if data.AutoLoad ~= nil then
        ConfigStore.AutoLoad = data.AutoLoad == true
    end
end

local function saveConfig(name, notify)
    if not ConfigStore.Available then
        setConfigStatus("Unavailable • executor filesystem APIs missing")
        return false
    end

    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    ConfigStore.Selected = clean
    ensureConfigFolders()

    local text = encodeJSON(configSnapshot())
    if not text then
        setConfigStatus("Save failed • JSON error")
        return false
    end

    local ok, err = pcall(FS.Write, configPath(clean), text)
    if not ok then
        setConfigStatus("Save failed • " .. tostring(err))
        return false
    end

    saveMeta()
    ConfigStore.LastFingerprint = configFingerprint()
    setConfigStatus("Saved • " .. clean)

    if notify and RAINZXDevUI then
        RAINZXDevUI:Notify({
            Title = "Configs",
            Content = "Saved " .. clean,
            Duration = 2,
        })
    end

    return true
end

local function loadConfig(name, notify)
    if not ConfigStore.Available then
        setConfigStatus("Unavailable • executor filesystem APIs missing")
        return false
    end

    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    local path = configPath(clean)

    if not FS.IsFile(path) then
        setConfigStatus("Not found • " .. clean)
        return false
    end

    local ok, text = pcall(FS.Read, path)
    if not ok then
        setConfigStatus("Load failed • read error")
        return false
    end

    local data = decodeJSON(text)
    if type(data) ~= "table" then
        setConfigStatus("Load failed • invalid file")
        return false
    end

    if not applyConfigTable(data) then
        setConfigStatus("Load failed • invalid values")
        return false
    end

    ConfigStore.Selected = clean
    saveMeta()
    ConfigStore.LastFingerprint = configFingerprint()
    setConfigStatus("Loaded • " .. clean)

    if notify and RAINZXDevUI then
        RAINZXDevUI:Notify({
            Title = "Configs",
            Content = "Loaded " .. clean,
            Duration = 2,
        })
    end

    return true
end

local function listConfigProfiles()
    local result = {}
    local seen = {}

    local function add(name)
        local clean = sanitizeConfigName(name, "default")
        if not seen[clean] then
            seen[clean] = true
            table.insert(result, clean)
        end
    end

    add("default")
    add(ConfigStore.Selected)

    if ConfigStore.Available and FS.ListFiles then
        local ok, files = pcall(FS.ListFiles, ConfigStore.Folder)
        if ok and type(files) == "table" then
            for _, file in ipairs(files) do
                local normalized = tostring(file):gsub("\\", "/")
                local name = normalized:match("([^/]+)%.json$")
                if name and name ~= "_meta" then
                    add(name)
                end
            end
        end
    end

    table.sort(result)
    return result
end

local function deleteConfig(name)
    if not ConfigStore.Available or not FS.DeleteFile then
        setConfigStatus("Delete unavailable in this executor")
        return false
    end

    local clean = sanitizeConfigName(name or ConfigStore.Selected, "default")
    local path = configPath(clean)

    if not FS.IsFile(path) then
        setConfigStatus("Not found • " .. clean)
        return false
    end

    local ok = pcall(FS.DeleteFile, path)
    if not ok then
        setConfigStatus("Delete failed • " .. clean)
        return false
    end

    if ConfigStore.Selected == clean then
        ConfigStore.Selected = "default"
    end

    saveMeta()
    setConfigStatus("Deleted • " .. clean)
    return true
end

-- Load metadata/config before UI controls are created, so every control opens
-- already showing its saved value.
if ConfigStore.Available then
    ensureConfigFolders()
    loadMeta()

    if ConfigStore.AutoLoad and FS.IsFile(configPath(ConfigStore.Selected)) then
        local ok, text = pcall(FS.Read, configPath(ConfigStore.Selected))
        if ok then
            local data = decodeJSON(text)
            if type(data) == "table" then
                applyConfigTable(data)
            end
        end
    end
end

--// Game integration
-- Exact paths confirmed from the inspected place:
-- ReplicatedStorage/Remote/EntityService
-- ReplicatedStorage/Remote/GameService
-- ReplicatedStorage/Client/CameraController
-- ReplicatedStorage/Client/EntityController
-- ReplicatedStorage/Client/Effects
-- ReplicatedStorage/Client/WatchingHelper
--
-- Some executors cannot require already-running game ModuleScripts directly.
-- Integration order:
-- 1) normal require
-- 2) getloadedmodules cached require
-- 3) getgc returned-table discovery
-- 4) game-specific replicated fallback using Team/Health/MaxHealth attributes
--    plus CollectionService Entity/Bot tags.

local EntityService = nil
local WorldManager = nil
local CameraController = nil
local GameService = nil
local WatchingHelper = nil
local EntityController = nil
local Effects = nil
local WeaponController = nil
local LocalEntity = nil

local moduleInitState = "Starting..."
local backendName = "Fallback"
local setStatus = function(_) end
local requireErrors = {}

local function isForcedIdlePlace()
    local info = getCurrentPlaceInfo()
    return info.Kind == "lobby" or info.Kind == "market"
end

local function combatRuntimeActive()
    if tonumber(game.GameId) ~= SNIPER_ARENA_UNIVERSE_ID then
        return false
    end

    -- Main/mobile lobbies and the Trading Market should never run combat logic.
    if isForcedIdlePlace() then
        return false
    end

    -- The game itself replicates Lobby as a Team attribute in queue/lobby states.
    if LocalPlayer:GetAttribute("Team") == "Lobby" then
        return false
    end

    -- Native game state is stronger when available. Dynamic Matchmaking places
    -- can therefore transition from idle -> combat without a hard-coded PlaceId rule.
    if GameService then
        local okJoined, joined = pcall(function()
            if GameService.IsJoined then
                return GameService.IsJoined()
            end
        end)

        if okJoined and joined == false then
            return false
        end

        local okPaused, paused = pcall(function()
            if GameService.IsPaused then
                return GameService.IsPaused()
            end
        end)

        if okPaused and paused == true then
            return false
        end
    end

    return true
end

local function getRuntimeStatusText()
    local info = getCurrentPlaceInfo()
    local state = combatRuntimeActive() and "COMBAT ACTIVE" or "IDLE"
    return ("%s • PlaceId %s • %s"):format(info.Name, tostring(game.PlaceId), state)
end

local function rememberRequireError(instance, err)
    if instance then
        requireErrors[instance:GetFullName()] = tostring(err)
    end
end

local function safeRequire(instance)
    if not instance or not instance:IsA("ModuleScript") then
        return nil
    end

    local ok, result = pcall(require, instance)
    if ok and result ~= nil then
        return result
    end

    rememberRequireError(instance, result)
    return nil
end

local function getExactModule(folderName, moduleName)
    local folder = ReplicatedStorage:FindFirstChild(folderName)
    if not folder then
        return nil
    end

    local child = folder:FindFirstChild(moduleName)
    if child and child:IsA("ModuleScript") then
        return child
    end

    return nil
end

local function refreshLocalEntity()
    if not EntityService then
        LocalEntity = nil
        return nil
    end

    local current

    pcall(function()
        current = EntityService.LocalEntity
        if not current and EntityService.GetLocalEntity then
            current = EntityService.GetLocalEntity()
        end
    end)

    if current then
        LocalEntity = current
    end

    return LocalEntity
end

local function tableHasFunction(t, key)
    if type(t) ~= "table" then
        return false
    end

    local ok, value = pcall(rawget, t, key)
    return ok and type(value) == "function"
end

local function tableHasValue(t, key)
    if type(t) ~= "table" then
        return false
    end

    local ok, value = pcall(rawget, t, key)
    return ok and value ~= nil
end

local function classifyModuleTable(t)
    if type(t) ~= "table" then
        return
    end

    if not EntityService
        and tableHasFunction(t, "FetchEntity")
        and tableHasFunction(t, "GetOrCreateEntity")
        and tableHasFunction(t, "GetEntity")
        and tableHasValue(t, "WorldManager")
    then
        EntityService = t
    end

    if not GameService
        and tableHasFunction(t, "IsJoined")
        and tableHasFunction(t, "GetTeam")
        and tableHasValue(t, "RoomManager")
        and tableHasValue(t, "LocalGameClient")
    then
        GameService = t
    end

    if not CameraController
        and tableHasFunction(t, "GetCamera")
        and tableHasFunction(t, "GetTargetingFn")
        and (tableHasFunction(t, "UpdateTarging") or tableHasFunction(t, "GetTargetingEntity"))
    then
        CameraController = t
    end

    if not EntityController
        and tableHasFunction(t, "GetController")
        and tableHasValue(t, "ControllerChanged")
    then
        EntityController = t
    end

    if not Effects
        and tableHasValue(t, "Smoke")
        and tableHasValue(t, "Flash")
        and (tableHasValue(t, "Bullet") or tableHasValue(t, "Projectile"))
    then
        Effects = t
    end

    if not WatchingHelper
        and tableHasValue(t, "Watching")
        and tableHasValue(t, "WatchingEntity")
        and tableHasFunction(t, "FilterEntity")
    then
        WatchingHelper = t
    end

    -- ReplicatedStorage.Client.WeaponController. The inspected game module exposes
    -- GetWeapon/GetWeapons plus the client weapon/component tables. GetWeapon()
    -- resolves the locally equipped weapon used by the normal primary action.
    if not WeaponController
        and tableHasFunction(t, "GetWeapon")
        and tableHasFunction(t, "GetWeapons")
        and tableHasValue(t, "Components")
        and tableHasValue(t, "ClientWeapon")
        and tableHasValue(t, "API")
    then
        WeaponController = t
    end
end

local function tryExactRequires()
    EntityService = EntityService or safeRequire(getExactModule("Remote", "EntityService"))
    GameService = GameService or safeRequire(getExactModule("Remote", "GameService"))
    CameraController = CameraController or safeRequire(getExactModule("Client", "CameraController"))
    EntityController = EntityController or safeRequire(getExactModule("Client", "EntityController"))
    Effects = Effects or safeRequire(getExactModule("Client", "Effects"))
    WatchingHelper = WatchingHelper or safeRequire(getExactModule("Client", "WatchingHelper"))
    WeaponController = WeaponController or safeRequire(getExactModule("Client", "WeaponController"))

    if EntityService then
        pcall(function()
            WorldManager = WorldManager or EntityService.WorldManager
        end)
    end
end

local function tryLoadedModules()
    if type(getloadedmodules) ~= "function" then
        return
    end

    local ok, modules = pcall(getloadedmodules)
    if not ok or type(modules) ~= "table" then
        return
    end

    for _, module in ipairs(modules) do
        if typeof(module) == "Instance" and module:IsA("ModuleScript") then
            local fullName = module:GetFullName()

            if not EntityService and fullName == "ReplicatedStorage.Remote.EntityService" then
                EntityService = safeRequire(module)
            elseif not GameService and fullName == "ReplicatedStorage.Remote.GameService" then
                GameService = safeRequire(module)
            elseif not CameraController and fullName == "ReplicatedStorage.Client.CameraController" then
                CameraController = safeRequire(module)
            elseif not EntityController and fullName == "ReplicatedStorage.Client.EntityController" then
                EntityController = safeRequire(module)
            elseif not Effects and fullName == "ReplicatedStorage.Client.Effects" then
                Effects = safeRequire(module)
            elseif not WatchingHelper and fullName == "ReplicatedStorage.Client.WatchingHelper" then
                WatchingHelper = safeRequire(module)
            elseif not WeaponController and fullName == "ReplicatedStorage.Client.WeaponController" then
                WeaponController = safeRequire(module)
            end
        end
    end

    if EntityService then
        pcall(function()
            WorldManager = WorldManager or EntityService.WorldManager
        end)
    end
end

local function tryGarbageCollector()
    if type(getgc) ~= "function" then
        return
    end

    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then
        return
    end

    for _, object in ipairs(objects) do
        if type(object) == "table" then
            pcall(classifyModuleTable, object)
        end

        if EntityService and GameService and CameraController and EntityController and Effects and WatchingHelper and WeaponController then
            break
        end
    end

    if EntityService then
        pcall(function()
            WorldManager = WorldManager or EntityService.WorldManager
        end)
    end
end

local function updateBackendStatus()
    refreshLocalEntity()

    local loaded = {}

    if EntityService then table.insert(loaded, "Entity") end
    if GameService then table.insert(loaded, "Room") end
    if CameraController then table.insert(loaded, "Camera") end
    if EntityController then table.insert(loaded, "Visibility") end
    if Effects then table.insert(loaded, "Effects") end
    if WeaponController then table.insert(loaded, "Weapon") end

    if EntityService and WorldManager and CameraController and WeaponController then
        backendName = "Native"
        moduleInitState = "READY • native " .. table.concat(loaded, "/")
    elseif #loaded > 0 then
        backendName = "Hybrid"
        moduleInitState = "READY • hybrid " .. table.concat(loaded, "/") .. " + fallback"
    else
        backendName = "Fallback"
        moduleInitState = "READY • replicated fallback active"
    end

    setStatus(moduleInitState)
end

local function initializeGameModules()
    moduleInitState = "Finding game backend..."
    setStatus(moduleInitState)

    tryExactRequires()

    if not (EntityService and GameService and CameraController and WeaponController) then
        tryLoadedModules()
    end

    if not (EntityService and GameService and CameraController and WeaponController) then
        tryGarbageCollector()
    end

    updateBackendStatus()
end

--// Runtime state
local destroyed = false
local lockedTarget = nil
local lockedTargetLastInfo = nil
local lockedTargetLastValidAt = 0
local lastTargetChangeAt = 0
local lastAutoShotAt = 0
local lastAutoShotAttemptAt = 0
local lastAutoShootTarget = nil
local autoShootPressPending = false
local targetVelocityHistory = setmetatable({}, {__mode = "k"})
local espObjects = {}
local connections = {}
local renderName = "__RAINZX_SniperArena_AimESP_" .. tostring(math.random(100000, 999999))

-- Mouse-native aim backend inspired by the reference AimAssist.
-- It preserves Sniper Arena's own camera movement (jumping, bob, recoil, ADS)
-- instead of replacing Camera.CFrame every frame.
local mouseAimSupported = type(mousemoverel) == "function"
local mouseAimMoveConst = Vector2.new(1, 0.77) * math.rad(0.5)
local userGameSettings = nil

pcall(function()
    userGameSettings = UserSettings():GetService("UserGameSettings")
end)

local function wrapAimAngle(value)
    value = value % math.pi
    value = value - (value >= (math.pi / 2) and math.pi or 0)
    value = value + (value < -(math.pi / 2) and math.pi or 0)
    return value
end

local function getAimMouseSensitivity()
    local sensitivity = 1

    if userGameSettings then
        local ok, value = pcall(function()
            return userGameSettings.MouseSensitivity
        end)

        if ok and type(value) == "number" and value > 0 then
            sensitivity = value
        end
    end

    return math.max(sensitivity, 0.001)
end

local function moveAimWithMouse(cam, targetPosition, dt, responseSpeed, snap)
    if not mouseAimSupported or not cam or not targetPosition then
        return false
    end

    local offset = targetPosition - cam.CFrame.Position
    if offset.Magnitude <= 0.001 then
        return true
    end

    local facing = cam.CFrame.LookVector
    local targetDirection = offset.Unit

    if targetDirection.X ~= targetDirection.X
        or targetDirection.Y ~= targetDirection.Y
        or targetDirection.Z ~= targetDirection.Z
    then
        return false
    end

    local diffYaw = wrapAimAngle(
        math.atan2(facing.X, facing.Z)
        - math.atan2(targetDirection.X, targetDirection.Z)
    )

    local facingY = math.clamp(facing.Y, -1, 1)
    local targetY = math.clamp(targetDirection.Y, -1, 1)
    local diffPitch = math.asin(facingY) - math.asin(targetY)

    local sensitivity = getAimMouseSensitivity()
    local denominator = mouseAimMoveConst * sensitivity

    local delta = Vector2.new(
        diffYaw / math.max(math.abs(denominator.X), 0.000001),
        diffPitch / math.max(math.abs(denominator.Y), 0.000001)
    )

    -- The reference AimAssist uses Speed * dt. Scale our existing speed values
    -- into the same response range while keeping Legit/Rage presets meaningful.
    local response = 1 - math.exp(
        -(math.max(responseSpeed, 0.01) * 0.68) * math.max(dt, 0)
    )

    if snap then
        response = 1
    end

    delta = delta * math.clamp(response, 0, 1)

    -- Guard against one bad replicated frame producing a giant synthetic mouse move.
    delta = Vector2.new(
        math.clamp(delta.X, -450, 450),
        math.clamp(delta.Y, -450, 450)
    )

    local ok = pcall(mousemoverel, delta.X, delta.Y)
    return ok
end

local function addConnection(connection)
    table.insert(connections, connection)
    return connection
end

local function safeCall(fn, ...)
    local ok, a, b, c, d = pcall(fn, ...)
    if ok then
        return a, b, c, d
    end
    return nil
end

--// GUI parent
-- PlayerGui first: some executors expose gethui/CoreGui but do not actually render
-- ScreenGuis there correctly for this game.
local guiParent = LocalPlayer:FindFirstChildOfClass("PlayerGui")
if not guiParent then
    guiParent = LocalPlayer:WaitForChild("PlayerGui", 10)
end

if not guiParent and gethui then
    local ok, result = pcall(gethui)
    if ok and result then
        guiParent = result
    end
end

if not guiParent then
    guiParent = CoreGui
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SniperArenaAimESP"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999999

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
end)

ScreenGui.Parent = guiParent

local OverlayFolder = Instance.new("Folder")
OverlayFolder.Name = "ESP"
OverlayFolder.Parent = ScreenGui

--// Utility
local function currentCamera()
    Camera = workspace.CurrentCamera or Camera
    return Camera
end

local function getRawInstance(entity)
    if typeof(entity) == "Instance" then
        return entity
    end

    if type(entity) == "table" then
        local instance = safeCall(function()
            return entity.Instance
        end)

        if typeof(instance) == "Instance" then
            return instance
        end
    end

    return nil
end

local function getAttribute(entity, name)
    local instance = getRawInstance(entity)
    if not instance then
        return nil
    end

    return safeCall(function()
        return instance:GetAttribute(name)
    end)
end

local function getPlayerFromEntityLike(entity)
    local instance = getRawInstance(entity)
    if not instance then
        return nil
    end

    if instance:IsA("Player") then
        return instance
    end

    if instance:IsA("Model") then
        return Players:GetPlayerFromCharacter(instance)
    end

    local model = instance:FindFirstAncestorOfClass("Model")
    if model then
        return Players:GetPlayerFromCharacter(model)
    end

    return nil
end

local function getEntityModel(entity)
    if not entity then
        return nil
    end

    local rawInstance = getRawInstance(entity)

    if rawInstance then
        if rawInstance:IsA("Player") then
            return rawInstance.Character
        elseif rawInstance:IsA("Model") then
            return rawInstance
        elseif rawInstance:IsA("BasePart") then
            return rawInstance:FindFirstAncestorOfClass("Model") or rawInstance
        end
    end

    local model = safeCall(function()
        if entity.GetModel then
            return entity:GetModel()
        end
    end)

    if typeof(model) == "Instance" then
        return model
    end

    local workspaceRoot = safeCall(function()
        if entity.GetWorkspaceRoot then
            return entity:GetWorkspaceRoot()
        end
    end)

    if typeof(workspaceRoot) == "Instance" then
        return workspaceRoot
    end

    local root = safeCall(function()
        if entity.GetRootPart then
            return entity:GetRootPart()
        end
    end)

    if typeof(root) == "Instance" then
        if root:IsA("Model") then
            return root
        elseif root:IsA("BasePart") then
            return root:FindFirstAncestorOfClass("Model") or root
        end
    end

    return nil
end

local function getRootPart(entity)
    if not entity then
        return nil
    end

    if typeof(entity) ~= "Instance" then
        local root = safeCall(function()
            if entity.GetRootPart then
                return entity:GetRootPart()
            end
        end)

        if typeof(root) == "Instance" and root:IsA("BasePart") then
            return root
        end
    end

    local model = getEntityModel(entity)

    if model then
        if model:IsA("Model") then
            return model:FindFirstChild("HumanoidRootPart")
                or model.PrimaryPart
                or model:FindFirstChild("UpperTorso")
                or model:FindFirstChild("Torso")
                or model:FindFirstChildWhichIsA("BasePart")
        elseif model:IsA("BasePart") then
            return model
        end
    end

    return nil
end

local function getHeadPart(entity)
    if not entity then
        return nil
    end

    if typeof(entity) ~= "Instance" then
        local head = safeCall(function()
            if entity.GetHeadPart then
                return entity:GetHeadPart()
            end
        end)

        if typeof(head) == "Instance" and head:IsA("BasePart") then
            return head
        end
    end

    local model = getEntityModel(entity)

    if model and model:IsA("Model") then
        local found = model:FindFirstChild("Head")

        if found and found:IsA("BasePart") then
            return found
        end
    end

    return nil
end

local function getAimPosition(entity)
    local model = getEntityModel(entity)
    local aimPoint = tostring(Config.Aim.AimPoint or "Head")

    local function validPart(part)
        return typeof(part) == "Instance"
            and part:IsA("BasePart")
            and part.Parent ~= nil
    end

    local head = getHeadPart(entity)
    local torso = nil
    local root = getRootPart(entity)

    if model and model:IsA("Model") then
        torso = model:FindFirstChild("UpperTorso")
            or model:FindFirstChild("Torso")
            or model:FindFirstChild("LowerTorso")
            or root
    else
        torso = root
    end

    if aimPoint == "Upper Torso" then
        if validPart(torso) then
            return torso.Position, torso
        end
        if validPart(head) then
            return head.Position, head
        end
    elseif aimPoint == "Closest Part" and model and model:IsA("Model") then
        local cam = currentCamera()
        local bestPart = nil
        local bestScreenDistance = math.huge

        if cam then
            local viewportCenter = cam.ViewportSize * 0.5
            local candidates = {
                head,
                model:FindFirstChild("UpperTorso"),
                model:FindFirstChild("Torso"),
                model:FindFirstChild("LowerTorso"),
                root,
            }

            for _, part in ipairs(candidates) do
                if validPart(part) then
                    local screen, visible = cam:WorldToViewportPoint(part.Position)
                    if visible and screen.Z > 0 then
                        local delta = Vector2.new(screen.X, screen.Y) - viewportCenter
                        local distance = delta.Magnitude
                        if distance < bestScreenDistance then
                            bestScreenDistance = distance
                            bestPart = part
                        end
                    end
                end
            end
        end

        if bestPart then
            return bestPart.Position, bestPart
        end
    else
        if validPart(head) then
            return head.Position, head
        end

        if typeof(entity) ~= "Instance" then
            local headCF = safeCall(function()
                if entity.GetHeadAt then
                    return entity:GetHeadAt()
                end
            end)

            if typeof(headCF) == "CFrame" then
                return headCF.Position, nil
            end
        end
    end

    if typeof(entity) ~= "Instance" then
        local pivot = safeCall(function()
            if entity.GetPivot then
                return entity:GetPivot(true)
            end
        end)

        if typeof(pivot) == "CFrame" then
            return pivot.Position, root
        end
    end

    if validPart(root) then
        return root.Position, root
    end

    if model and model:IsA("Model") then
        local pivot = safeCall(function()
            return model:GetPivot()
        end)

        if typeof(pivot) == "CFrame" then
            return pivot.Position, model.PrimaryPart
        end
    end

    return nil, nil
end

local function getTargetVelocity(entity, aimPart)
    local rawVelocity = nil

    if typeof(entity) ~= "Instance" then
        rawVelocity = safeCall(function()
            if entity.GetVelocity then
                return entity:GetVelocity()
            end
        end)
    end

    if typeof(rawVelocity) ~= "Vector3" then
        local part = aimPart
        if not (typeof(part) == "Instance" and part:IsA("BasePart")) then
            part = getRootPart(entity)
        end

        if typeof(part) == "Instance" and part:IsA("BasePart") then
            rawVelocity = part.AssemblyLinearVelocity
        end
    end

    if typeof(rawVelocity) ~= "Vector3" then
        rawVelocity = Vector3.zero
    end

    if rawVelocity.Magnitude > 250 then
        rawVelocity = rawVelocity.Unit * 250
    end

    -- Smooth transient animation/replication velocity spikes. This is especially
    -- important for moving/jumping targets where one bad frame used to yank the
    -- predicted point far enough away to drop the lock.
    local smoothing = math.clamp(tonumber(Config.Aim.PredictionSmoothing) or 0.72, 0, 0.98)
    local previous = targetVelocityHistory[entity]

    local filtered
    if typeof(previous) == "Vector3" then
        filtered = previous:Lerp(rawVelocity, 1 - smoothing)
    else
        filtered = rawVelocity
    end

    targetVelocityHistory[entity] = filtered
    return filtered
end

local function getPredictedAimPosition(entity, position, part)
    if not Config.Aim.Prediction then
        return position
    end

    local lead = math.clamp(tonumber(Config.Aim.PredictionTime) or 0, 0, 0.30)
    if lead <= 0 then
        return position
    end

    local velocity = getTargetVelocity(entity, part)

    -- Sniper Arena is much less stable if a jump's full Y velocity is predicted.
    -- Keep horizontal lead, but heavily damp vertical lead while airborne / moving
    -- vertically so the crosshair follows the actual head/body instead of shooting
    -- above or below a jumping target.
    local verticalScale = math.abs(velocity.Y) >= 8 and 0.10 or 0.30
    local offset = Vector3.new(
        velocity.X * lead,
        velocity.Y * lead * verticalScale,
        velocity.Z * lead
    )

    -- Vertical prediction gets its own tight clamp; horizontal prediction keeps the
    -- existing global clamp.
    offset = Vector3.new(
        offset.X,
        math.clamp(offset.Y, -2.25, 2.25),
        offset.Z
    )

    local maxOffset = math.max(tonumber(Config.Aim.MaxPredictionOffset) or 14, 0)
    if maxOffset > 0 and offset.Magnitude > maxOffset then
        offset = offset.Unit * maxOffset
    end

    return position + offset
end

local function getDisplayName(entity)
    local rawInstance = getRawInstance(entity)

    if rawInstance then
        if rawInstance:IsA("Player") then
            return rawInstance.DisplayName or rawInstance.Name
        end

        local display = safeCall(function()
            return rawInstance:GetAttribute("DisplayName")
        end)

        if type(display) == "string" and #display > 0 then
            return display
        end

        return rawInstance.Name
    end

    local name = safeCall(function()
        if entity.GetDisplayName then
            return entity:GetDisplayName()
        end
    end)

    if type(name) == "string" and #name > 0 then
        return name
    end

    local player = safeCall(function()
        return entity.Player
    end)

    if typeof(player) == "Instance" and player:IsA("Player") then
        return player.DisplayName or player.Name
    end

    return "Enemy"
end

local function getHealth(entity)
    local rawInstance = getRawInstance(entity)

    if rawInstance then
        local health = safeCall(function()
            return rawInstance:GetAttribute("Health")
        end)

        local maxHealth = safeCall(function()
            return rawInstance:GetAttribute("MaxHealth")
        end)

        if type(health) ~= "number" or type(maxHealth) ~= "number" then
            local model = getEntityModel(entity)
            local humanoid = model and model:FindFirstChildOfClass("Humanoid")

            if humanoid then
                health = type(health) == "number" and health or humanoid.Health
                maxHealth = type(maxHealth) == "number" and maxHealth or humanoid.MaxHealth
            end
        end

        health = tonumber(health) or 0
        maxHealth = tonumber(maxHealth) or math.max(health, 100)

        if maxHealth <= 0 then
            maxHealth = math.max(health, 100)
        end

        return health, maxHealth
    end

    local health = safeCall(function()
        return entity.Health
    end)

    local maxHealth = safeCall(function()
        return entity.MaxHealth
    end)

    health = tonumber(health) or 0
    maxHealth = tonumber(maxHealth) or math.max(health, 100)

    if maxHealth <= 0 then
        maxHealth = math.max(health, 100)
    end

    return health, maxHealth
end

local function isAlive(entity)
    if not entity then
        return false
    end

    if typeof(entity) ~= "Instance" then
        local alive = safeCall(function()
            if entity.IsAlive then
                return entity:IsAlive()
            end
        end)

        if alive ~= nil then
            return alive == true
        end
    end

    local root = getRootPart(entity)

    if not root or not root.Parent then
        return false
    end

    local health = getHealth(entity)
    return health > 0
end

local function getTeamValue(entity)
    local instance = getRawInstance(entity)

    if instance then
        local team = safeCall(function()
            return instance:GetAttribute("Team")
        end)

        if team ~= nil then
            return team
        end

        local player = getPlayerFromEntityLike(entity)

        if player then
            local playerTeam = safeCall(function()
                return player:GetAttribute("Team")
            end)

            if playerTeam ~= nil then
                return playerTeam
            end

            if player.Team then
                return player.Team
            end
        end
    end

    return safeCall(function()
        return entity.Team
    end)
end

local function isEnemy(entity)
    refreshLocalEntity()

    if not entity or not isAlive(entity) then
        return false
    end

    local rawInstance = getRawInstance(entity)
    local player = getPlayerFromEntityLike(entity)

    if rawInstance == LocalPlayer
        or rawInstance == LocalPlayer.Character
        or player == LocalPlayer
        or entity == LocalEntity
    then
        return false
    end

    if LocalEntity and typeof(entity) ~= "Instance" then
        local friendly = safeCall(function()
            return LocalEntity:IsFriendly(entity)
        end)

        if friendly == true then
            return false
        elseif friendly == false then
            return true
        end
    end

    local localTeam = LocalPlayer:GetAttribute("Team")
    local targetTeam = getTeamValue(entity)

    if localTeam == "Lobby" or targetTeam == "Lobby" then
        return false
    end

    -- Confirmed by the game's NameTag/Friendly source:
    -- Team3 behaves as free-for-all and all other entities are enemies.
    if localTeam == "Team3" then
        return true
    end

    if localTeam ~= nil and targetTeam ~= nil then
        return localTeam ~= targetTeam
    end

    if player and LocalPlayer.Team and player.Team and not LocalPlayer.Neutral and not player.Neutral then
        return LocalPlayer.Team ~= player.Team
    end

    return true
end

local function gameSaysVisible(entity)
    if not Config.Aim.RespectGameVisibility or not EntityController then
        return true
    end

    local controller = safeCall(function()
        return EntityController.GetController(entity)
    end)

    if not controller or not controller.VisibleController then
        return true
    end

    local visibleController = controller.VisibleController

    if visibleController.CurrentVisible == false then
        return false
    end

    if tonumber(visibleController.CurrentTransparency) == 1 then
        return false
    end

    return true
end

local function blockedByEffects(position)
    if not Effects then
        return false
    end

    if Config.Aim.RespectFlash then
        local flashAlpha = safeCall(function()
            return Effects.Flash.GetFlashingAlpha()
        end)

        if type(flashAlpha) == "number" and flashAlpha > 0.5 then
            return true
        end
    end

    if Config.Aim.RespectSmoke then
        local inSmoke = safeCall(function()
            return Effects.Smoke.InSmoke()
        end)

        if inSmoke then
            return true
        end

        local posInSmoke = safeCall(function()
            return Effects.Smoke.PosInSmoke(position)
        end)

        if posInSmoke then
            return true
        end
    end

    return false
end

local visibilityParams = RaycastParams.new()
visibilityParams.FilterType = Enum.RaycastFilterType.Exclude
visibilityParams.RespectCanCollide = false
pcall(function()
    visibilityParams.CollisionGroup = "CanCollide"
end)

local function hasLineOfSight(entity, position)
    local cam = currentCamera()
    if not cam or not position then
        return false
    end

    if not Config.Aim.VisibleCheck then
        return true
    end

    local filter = {}
    if LocalPlayer.Character then
        table.insert(filter, LocalPlayer.Character)
    end

    local model = getEntityModel(entity)
    if model then
        table.insert(filter, model)
    end

    visibilityParams.FilterDescendantsInstances = filter

    local origin = cam.CFrame.Position
    local direction = position - origin

    if direction.Magnitude <= 0.01 then
        return true
    end

    local result = workspace:Raycast(origin, direction, visibilityParams)
    return result == nil
end

local function getFocusedEntities()
    if not WorldManager then
        return {}
    end

    local result = safeCall(function()
        return WorldManager.GetFocusedEntities()
    end)

    if type(result) == "table" then
        return result
    end

    local world = safeCall(function()
        return WorldManager.GetFocusedWorld()
    end)

    if world and type(world.Entities) == "table" then
        return world.Entities
    end

    return {}
end

local function convertInstanceToNativeEntity(instance)
    if not EntityService or typeof(instance) ~= "Instance" then
        return nil
    end

    return safeCall(function()
        if EntityService.GetEntity then
            return EntityService.GetEntity(instance)
        end
    end)
end

local function iterateReplicatedFallback(callback, alreadySeen)
    local seen = alreadySeen or {}

    local function consider(candidate)
        if not candidate or seen[candidate] then
            return
        end

        seen[candidate] = true

        local native = convertInstanceToNativeEntity(candidate)

        if native and not seen[native] then
            seen[native] = true

            if isEnemy(native) then
                callback(native)
                return
            end
        end

        if isEnemy(candidate) then
            callback(candidate)
        end
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            consider(player)
        end
    end

    for _, tagName in ipairs({ "Entity", "Bot" }) do
        local tagged = safeCall(function()
            return CollectionService:GetTagged(tagName)
        end)

        if type(tagged) == "table" then
            for _, instance in ipairs(tagged) do
                if typeof(instance) == "Instance" then
                    consider(instance)
                end
            end
        end
    end
end

local function iterateEnemies(callback)
    local seen = {}
    local usedNative = false

    if GameService and GameService.RoomManager then
        local room = safeCall(function()
            return GameService.RoomManager.GetFocusedRoom()
        end)

        local modeHandler = room and room.ModeHandler

        if room and modeHandler and room.ClientsByTeam and modeHandler.GetEnemyTeams then
            local enemyTeams = safeCall(function()
                return modeHandler:GetEnemyTeams()
            end)

            if type(enemyTeams) == "table" then
                for _, team in pairs(enemyTeams) do
                    local clients = room.ClientsByTeam[team]

                    if type(clients) == "table" then
                        for _, client in pairs(clients) do
                            local entity = safeCall(function()
                                return client:GetEntity()
                            end)

                            if entity and not seen[entity] and isEnemy(entity) then
                                seen[entity] = true
                                usedNative = true
                                callback(entity)
                            end
                        end
                    end
                end
            end
        end
    end

    if not usedNative then
        for _, entity in pairs(getFocusedEntities()) do
            if entity and not seen[entity] and isEnemy(entity) then
                seen[entity] = true
                usedNative = true
                callback(entity)
            end
        end
    end

    if not usedNative then
        iterateReplicatedFallback(callback, seen)
    end
end

local function worldToScreen(position)
    local cam = currentCamera()
    if not cam then
        return nil, false, nil
    end

    local v, onScreen = cam:WorldToViewportPoint(position)
    return Vector2.new(v.X, v.Y), onScreen and v.Z > 0, v.Z
end

local function screenCenter()
    local cam = currentCamera()
    if not cam then
        return Vector2.zero
    end
    return cam.ViewportSize / 2
end

--// Aim target selection
local function targetInfo(entity, fovMultiplier)
    if not isEnemy(entity) then
        return nil
    end

    local rawPosition, part = getAimPosition(entity)
    if not rawPosition then
        return nil
    end

    local cam = currentCamera()
    if not cam then
        return nil
    end

    -- Use the root as the selection anchor when possible. Head animations and
    -- jump poses move much more than the character root and used to make target
    -- scoring/FOV membership wobble even while the same player stayed centred.
    local selectionPosition = rawPosition
    local selectionRoot = getRootPart(entity)

    if typeof(selectionRoot) == "Instance"
        and selectionRoot:IsA("BasePart")
        and selectionRoot.Parent ~= nil
    then
        selectionPosition = selectionRoot.Position
    end

    local distance = (selectionPosition - cam.CFrame.Position).Magnitude
    if distance > Config.Aim.MaxDistance then
        return nil
    end

    if not gameSaysVisible(entity) then
        return nil
    end

    if blockedByEffects(rawPosition) then
        return nil
    end

    local visible = hasLineOfSight(entity, rawPosition)
    if Config.Aim.VisibleCheck and not visible then
        return nil
    end

    -- FOV/score use the stable body anchor. The actual aim output still uses the
    -- configured Head / Upper Torso / Closest Part point below.
    local rawScreenPos, rawOnScreen = worldToScreen(selectionPosition)
    if not rawOnScreen then
        return nil
    end

    local rawScreenDistance = (rawScreenPos - screenCenter()).Magnitude
    local maxFov = Config.Aim.FOV * (fovMultiplier or 1)

    if rawScreenDistance > maxFov then
        return nil
    end

    local position = getPredictedAimPosition(entity, rawPosition, part)
    local predictedScreenPos, predictedOnScreen = worldToScreen(position)

    -- If the lead point itself leaves the viewport, fall back to the raw point
    -- rather than dropping an otherwise valid target.
    if not predictedOnScreen then
        position = rawPosition
        predictedScreenPos = rawScreenPos
    end

    local predictedScreenDistance = (predictedScreenPos - screenCenter()).Magnitude

    local health, maxHealth = getHealth(entity)
    local healthRatio = maxHealth > 0 and math.clamp(health / maxHealth, 0, 1) or 1
    local distanceRatio = math.clamp(distance / math.max(Config.Aim.MaxDistance, 1), 0, 1)
    local priority = tostring(Config.Aim.TargetPriority or "Hybrid")

    local score
    if priority == "Distance" then
        score = (rawScreenDistance * 0.35) + (distanceRatio * maxFov * 0.65)
    elseif priority == "Low Health" then
        score = (rawScreenDistance * 0.60) + (healthRatio * maxFov * 0.40)
    elseif priority == "Hybrid" then
        score = (rawScreenDistance * 0.65)
            + (distanceRatio * maxFov * 0.20)
            + (healthRatio * maxFov * 0.15)

        if visible then
            score = score * 0.92
        end
    else
        score = rawScreenDistance
    end

    return {
        Entity = entity,
        Position = position,
        RawPosition = rawPosition,
        Part = part,
        Distance = distance,
        ScreenDistance = predictedScreenDistance,
        RawScreenDistance = rawScreenDistance,
        Score = score,
        Visible = visible,
        Velocity = getTargetVelocity(entity, part),
    }
end

local function keepLockedTargetThroughGrace()
    if not lockedTarget or not lockedTargetLastInfo then
        return nil
    end

    local grace = math.max(tonumber(Config.Aim.LockGrace) or 0, 0)
    if grace <= 0 or (os.clock() - lockedTargetLastValidAt) > grace then
        return nil
    end

    -- Never grace a target that is actually dead/friendly. Grace is only for
    -- tiny rendering, visibility, FOV, or replication hiccups.
    if not isEnemy(lockedTarget) then
        return nil
    end

    local rawPosition, part = getAimPosition(lockedTarget)
    if rawPosition then
        local info = lockedTargetLastInfo
        info.RawPosition = rawPosition
        info.Part = part
        info.Position = getPredictedAimPosition(lockedTarget, rawPosition, part)
        info.Velocity = getTargetVelocity(lockedTarget, part)

        local screenPos, onScreen = worldToScreen(info.Position)
        if onScreen then
            info.ScreenDistance = (screenPos - screenCenter()).Magnitude
        end

        return info
    end

    return lockedTargetLastInfo
end

local function acquireTarget()
    local currentInfo = nil

    if lockedTarget then
        currentInfo = targetInfo(lockedTarget, Config.Aim.StickyMultiplier)

        if currentInfo then
            currentInfo.Score = currentInfo.Score * 0.78
            lockedTargetLastInfo = currentInfo
            lockedTargetLastValidAt = os.clock()
        else
            currentInfo = keepLockedTargetThroughGrace()
        end
    end

    local best = nil

    iterateEnemies(function(entity)
        if entity ~= lockedTarget then
            local info = targetInfo(entity, 1)
            if info and (not best or info.Score < best.Score) then
                best = info
            end
        end
    end)

    -- If we still have a valid/grace-held target, only switch when the new
    -- candidate is meaningfully better. This prevents nearby enemies crossing
    -- each other from causing one-frame lock swaps.
    if currentInfo then
        if not best then
            return currentInfo
        end

        local threshold = math.clamp(tonumber(Config.Aim.SwitchThreshold) or 0.12, 0, 0.90)
        local requiredScore = currentInfo.Score * (1 - threshold)
        local delay = math.max(tonumber(Config.Aim.SwitchDelay) or 0, 0)
        local delayPassed = (os.clock() - lastTargetChangeAt) >= delay

        if not delayPassed or best.Score >= requiredScore then
            return currentInfo
        end
    end

    if best then
        if lockedTarget ~= best.Entity then
            lastTargetChangeAt = os.clock()
        end

        lockedTarget = best.Entity
        lockedTargetLastInfo = best
        lockedTargetLastValidAt = os.clock()
        return best
    end

    lockedTarget = nil
    lockedTargetLastInfo = nil
    return nil
end

local function localPlayerAlive()
    if LocalEntity then
        local alive = safeCall(function()
            return LocalEntity:IsAlive()
        end)

        if alive ~= nil then
            return alive == true
        end
    end

    local character = LocalPlayer.Character

    if not character then
        return false
    end

    local root = character:FindFirstChild("HumanoidRootPart")

    if not root then
        return false
    end

    local health = LocalPlayer:GetAttribute("Health")

    if type(health) == "number" then
        return health > 0
    end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return humanoid == nil or humanoid.Health > 0
end

local function nativeMouseButtonHeld(buttonName)
    -- Read the player's actual hardware mouse state. Auto Shoot never synthesizes
    -- its activation button, so Sniper Arena still receives normal LMB/RMB input.
    local normalized = normalizeAutoShootButton(buttonName)
    local inputType = normalized == "LMB"
        and Enum.UserInputType.MouseButton1
        or Enum.UserInputType.MouseButton2

    local ok, held = pcall(function()
        return UserInputService:IsMouseButtonPressed(inputType)
    end)

    return ok and held == true
end

local function nativeRMBHeld()
    return nativeMouseButtonHeld("RMB")
end

local function autoShootButtonHeld()
    return nativeMouseButtonHeld(Config.Aim.AutoShootButton)
end

local function autoShootActive()
    if not Config.Aim.AutoShoot then
        return false
    end

    if not combatRuntimeActive() then
        lockedTarget = nil
        return false
    end

    refreshLocalEntity()

    if not localPlayerAlive() then
        return false
    end

    if WatchingHelper and WatchingHelper.Watching and WatchingHelper.Watching ~= LocalPlayer then
        return false
    end

    if CameraController and CameraController.IsBusy then
        local busy = safeCall(CameraController.IsBusy)

        if busy == true then
            return false
        end
    end

    -- v4.6.5: Auto Shoot is armed by the player's selected REAL mouse button.
    -- RMB keeps normal ADS/scope behavior; LMB keeps the game's normal fire input.
    return autoShootButtonHeld()
end

local function aimActive()
    if not Config.Aim.Enabled then
        return false
    end

    if not combatRuntimeActive() then
        lockedTarget = nil
        return false
    end

    refreshLocalEntity()

    if not localPlayerAlive() then
        return false
    end

    if WatchingHelper and WatchingHelper.Watching and WatchingHelper.Watching ~= LocalPlayer then
        return false
    end

    if CameraController and CameraController.IsBusy then
        local busy = safeCall(CameraController.IsBusy)

        if busy == true then
            return false
        end
    end

    if not Config.Aim.HoldRMB then
        return true
    end

    return nativeRMBHeld()
end

local function getLocalShootable()
    if not WeaponController or type(WeaponController.GetWeapon) ~= "function" then
        return nil
    end

    -- Sniper Arena's WeaponController.GetWeapon() returns the locally equipped
    -- adapted ClientWeapon. The gun's primary action calls this same object's
    -- _Shootable:LocalShoot() for semi-auto weapons.
    local weapon = safeCall(function()
        return WeaponController.GetWeapon()
    end)

    if not weapon then
        return nil
    end

    local function fromWeapon(candidate)
        if type(candidate) ~= "table" then
            return nil
        end

        local shootable = safeCall(function()
            return candidate._Shootable
        end)

        if type(shootable) == "table" and type(shootable.LocalShoot) == "function" then
            return shootable
        end

        return nil
    end

    local direct = fromWeapon(weapon)
    if direct then
        return direct
    end

    -- Multiple/dual weapon wrappers can contain adapted child weapons. Keep this
    -- fallback so Auto Shoot still resolves a real Shootable component there.
    local children = safeCall(function()
        return weapon.Weapons
    end)

    if type(children) == "table" then
        for _, child in pairs(children) do
            local shootable = fromWeapon(child)
            if shootable then
                return shootable
            end
        end
    end

    return nil
end

local function sendNativePrimaryFire()
    local shootable = getLocalShootable()

    if not shootable then
        return false
    end

    -- This is Sniper Arena's own primary-fire path. LocalShoot performs the same
    -- client weapon checks / ammo / reload / fire-rate / server action work as a
    -- real click, so it is much more reliable than synthetic mouse input.
    local ok = pcall(function()
        shootable:LocalShoot()
    end)

    return ok
end

local function sendPrimaryFireInput()
    -- Preferred v4.6.3 path: invoke the active Sniper Arena weapon component.
    if sendNativePrimaryFire() then
        return true
    end

    -- Compatibility fallback for executors where game ModuleScripts cannot be
    -- required or their active weapon controller cannot be resolved.
    if type(mouse1click) == "function" then
        local ok = pcall(mouse1click)
        if ok then
            return true
        end
    end

    if type(mouse1press) == "function" and type(mouse1release) == "function" then
        if autoShootPressPending then
            return false
        end

        autoShootPressPending = true
        local ok = pcall(mouse1press)

        task.delay(0.018, function()
            pcall(mouse1release)
            autoShootPressPending = false
        end)

        if ok then
            return true
        end

        autoShootPressPending = false
    end

    local okService, vim = pcall(function()
        return game:GetService("VirtualInputManager")
    end)

    if okService and vim then
        local centre = screenCenter()
        local ok = pcall(function()
            vim:SendMouseButtonEvent(
                math.floor(centre.X),
                math.floor(centre.Y),
                0,
                true,
                game,
                0
            )
            vim:SendMouseButtonEvent(
                math.floor(centre.X),
                math.floor(centre.Y),
                0,
                false,
                game,
                0
            )
        end)

        if ok then
            return true
        end
    end

    -- One more broadly available Roblox fallback. Some executors expose
    -- VirtualUser while blocking direct mouse helpers / VirtualInputManager.
    local okVU, virtualUser = pcall(function()
        return game:GetService("VirtualUser")
    end)

    if okVU and virtualUser then
        local centre = screenCenter()
        local ok = pcall(function()
            virtualUser:Button1Down(Vector2.new(centre.X, centre.Y), currentCamera() and currentCamera().CFrame or CFrame.new())
            task.delay(0.018, function()
                pcall(function()
                    virtualUser:Button1Up(Vector2.new(centre.X, centre.Y), currentCamera() and currentCamera().CFrame or CFrame.new())
                end)
            end)
        end)

        if ok then
            return true
        end
    end

    return false
end

local function tryAutoShoot(info)
    if not Config.Aim.AutoShoot or not info or not info.Entity then
        return
    end

    -- Auto Shoot uses the same validated enemy-target backend as Auto Aim and is
    -- armed only while the selected physical LMB/RMB button is actually held.
    if lockedTarget ~= info.Entity or not isEnemy(info.Entity) then
        return
    end

    if not combatRuntimeActive() or not localPlayerAlive() then
        return
    end

    -- If Auto Shoot is armed by RMB, respect a separate manual LMB shot and do not
    -- inject a second one. In LMB mode the held LMB IS the Auto Shoot activation, so
    -- native LocalShoot is allowed to run; the weapon's own cooldown rejects doubles.
    if normalizeAutoShootButton(Config.Aim.AutoShootButton) ~= "LMB"
        and nativeMouseButtonHeld("LMB")
    then
        return
    end

    -- Reproject the predicted aim point using the latest camera state. This makes
    -- Auto Shoot wait until the crosshair is actually on target instead of firing
    -- as soon as a target merely enters the larger aim FOV.
    local screenPos, onScreen = worldToScreen(info.Position)
    if not onScreen then
        return
    end

    local errorPixels = (screenPos - screenCenter()).Magnitude
    local radius = math.clamp(tonumber(Config.Aim.AutoShootRadius) or 10, 1, 50)

    if errorPixels > radius then
        return
    end

    -- Keep the trigger conservative even if lock grace is currently carrying a
    -- target through a tiny replication hiccup.
    local freshInfo = targetInfo(info.Entity, Config.Aim.StickyMultiplier)
    if not freshInfo then
        return
    end

    local now = os.clock()
    local delay = math.clamp(tonumber(Config.Aim.AutoShootDelay) or 0, 0, 1)

    -- A newly acquired target always gets an immediate first attempt. Any optional
    -- user delay only affects repeat attempts on the SAME target. With delay = 0,
    -- Sniper Arena's own Shootable component is the only fire-rate limiter.
    if lastAutoShootTarget ~= info.Entity then
        lastAutoShootTarget = info.Entity
        lastAutoShotAttemptAt = 0
    elseif delay > 0 and (now - lastAutoShotAttemptAt) < delay then
        return
    end

    lastAutoShotAttemptAt = now

    if sendPrimaryFireInput() then
        lastAutoShotAt = now
    end
end

local function applyAim(dt)
    local shouldAim = aimActive()
    local shouldAutoShoot = autoShootActive()

    if not shouldAim and not shouldAutoShoot then
        -- Releasing RMB no longer disables Auto Shoot. Only clear the lock when
        -- combat/player state is invalid or both combat features are disabled.
        if not combatRuntimeActive()
            or not localPlayerAlive()
            or (not Config.Aim.Enabled and not Config.Aim.AutoShoot)
        then
            lockedTarget = nil
            lockedTargetLastInfo = nil
        end
        return
    end

    local info = acquireTarget()
    if not info then
        return
    end

    lockedTarget = info.Entity

    local cam = currentCamera()
    if not cam then
        return
    end

    if shouldAim then
        local current = cam.CFrame
        local instantAutoShot = shouldAutoShoot and autoShootButtonHeld()

        if instantAutoShot then
            -- Do not spend several render frames smoothing into Shoot Radius once the
            -- selected physical Auto Shoot button is held. Put the camera on the
            -- validated target in this same frame, refresh the game's targeting cache
            -- below, then invoke its native LocalShoot path immediately.
            cam.CFrame = CFrame.lookAt(current.Position, info.Position)
        else
            local speed = math.max(tonumber(Config.Aim.SmoothSpeed) or 0.01, 0.01)

            -- Adaptive smoothing moves decisively while far from the target and slows
            -- down near the final point, reducing overshoot and micro-jitter.
            if Config.Aim.AdaptiveSmoothing then
                local normalized = math.clamp(
                    info.ScreenDistance / math.max(Config.Aim.FOV, 1),
                    0,
                    1
                )
                local multiplier = 0.55 + (math.sqrt(normalized) * 1.45)
                speed = speed * multiplier
            end

            local snapRadius = math.max(tonumber(Config.Aim.MicroSnapRadius) or 0, 0)
            local shouldSnap = snapRadius > 0 and info.ScreenDistance <= snapRadius

            local usedMouseAim = moveAimWithMouse(
                cam,
                info.Position,
                dt,
                speed,
                shouldSnap
            )

            if not usedMouseAim then
                local desired = CFrame.lookAt(current.Position, info.Position)
                local alpha = 1 - math.exp(-speed * math.max(dt, 0))

                if shouldSnap then
                    alpha = 1
                end

                cam.CFrame = current:Lerp(desired, math.clamp(alpha, 0, 1))
            end
        end
    end

    -- LocalShoot reads CameraController.GetTargetingFn(). Refresh it after any
    -- aim correction, and also when Auto Shoot is acting as a triggerbot alone.
    pcall(function()
        if CameraController and CameraController.UpdateTarging then
            CameraController.UpdateTarging()
        end
    end)

    if shouldAutoShoot then
        tryAutoShoot(info)
    end
end

--// ESP helpers
local function makeStroke(parent, thickness)
    local stroke = Instance.new("UIStroke")
    stroke.Thickness = thickness or 1
    stroke.Color = Color3.fromRGB(255, 78, 78)
    stroke.Transparency = 0
    stroke.Parent = parent
    return stroke
end

local function makeText(parent)
    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.BorderSizePixel = 0
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.TextStrokeTransparency = 0.35
    label.TextSize = 13
    label.ZIndex = 10
    label.Parent = parent
    return label
end

local function createESP(entity)
    if espObjects[entity] then
        return espObjects[entity]
    end

    local holder = Instance.new("Frame")
    holder.Name = "EntityESP"
    holder.BackgroundTransparency = 1
    holder.BorderSizePixel = 0
    holder.Visible = false
    holder.ZIndex = 5
    holder.Parent = OverlayFolder

    local box = Instance.new("Frame")
    box.Name = "Box"
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.Size = UDim2.fromScale(1, 1)
    box.ZIndex = 5
    box.Parent = holder
    local boxStroke = makeStroke(box, 1.5)

    local nameLabel = makeText(holder)
    nameLabel.Name = "Name"
    nameLabel.AnchorPoint = Vector2.new(0.5, 1)
    nameLabel.Position = UDim2.new(0.5, 0, 0, -3)
    nameLabel.Size = UDim2.new(1.7, 0, 0, 18)
    nameLabel.TextXAlignment = Enum.TextXAlignment.Center

    local infoLabel = makeText(holder)
    infoLabel.Name = "Info"
    infoLabel.AnchorPoint = Vector2.new(0.5, 0)
    infoLabel.Position = UDim2.new(0.5, 0, 1, 3)
    infoLabel.Size = UDim2.new(1.8, 0, 0, 18)
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center

    local hpBack = Instance.new("Frame")
    hpBack.Name = "HealthBack"
    hpBack.AnchorPoint = Vector2.new(1, 0)
    hpBack.Position = UDim2.new(0, -4, 0, 0)
    hpBack.Size = UDim2.new(0, 4, 1, 0)
    hpBack.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    hpBack.BorderSizePixel = 0
    hpBack.ZIndex = 6
    hpBack.Parent = holder

    local hpFill = Instance.new("Frame")
    hpFill.Name = "Health"
    hpFill.AnchorPoint = Vector2.new(0, 1)
    hpFill.Position = UDim2.new(0, 0, 1, 0)
    hpFill.Size = UDim2.fromScale(1, 1)
    hpFill.BackgroundColor3 = Color3.fromRGB(85, 255, 110)
    hpFill.BorderSizePixel = 0
    hpFill.ZIndex = 7
    hpFill.Parent = hpBack

    local tracer = Instance.new("Frame")
    tracer.Name = "Tracer"
    tracer.AnchorPoint = Vector2.new(0, 0.5)
    tracer.BackgroundColor3 = Color3.fromRGB(255, 78, 78)
    tracer.BorderSizePixel = 0
    tracer.Size = UDim2.fromOffset(0, 1)
    tracer.Visible = false
    tracer.ZIndex = 3
    tracer.Parent = OverlayFolder

    local highlight = Instance.new("Highlight")
    highlight.Name = "AimESPHighlight"
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.FillColor = Color3.fromRGB(255, 60, 60)
    highlight.FillTransparency = 0.82
    highlight.OutlineColor = Color3.fromRGB(255, 115, 115)
    highlight.OutlineTransparency = 0
    highlight.Enabled = false
    highlight.Parent = workspace

    local object = {
        Holder = holder,
        Box = box,
        BoxStroke = boxStroke,
        Name = nameLabel,
        Info = infoLabel,
        HealthBack = hpBack,
        HealthFill = hpFill,
        Tracer = tracer,
        Highlight = highlight,
    }

    espObjects[entity] = object
    return object
end

local function removeESP(entity)
    local object = espObjects[entity]
    if not object then
        return
    end

    for _, instance in pairs(object) do
        if typeof(instance) == "Instance" then
            pcall(function()
                instance:Destroy()
            end)
        end
    end

    espObjects[entity] = nil
end

local function getBounds(entity)
    local model = getEntityModel(entity)
    if not model then
        return nil
    end

    local cf, size

    if model:IsA("Model") then
        local ok, a, b = pcall(model.GetBoundingBox, model)
        if not ok then
            return nil
        end
        cf, size = a, b
    elseif model:IsA("BasePart") then
        cf, size = model.CFrame, model.Size
    else
        return nil
    end

    if typeof(cf) ~= "CFrame" or typeof(size) ~= "Vector3" then
        return nil
    end

    -- Small padding keeps the box away from the character edges.
    size = size + Vector3.new(0.25, 0.35, 0.25)

    local half = size * 0.5
    local corners = {
        Vector3.new(-half.X, -half.Y, -half.Z),
        Vector3.new(-half.X, -half.Y,  half.Z),
        Vector3.new(-half.X,  half.Y, -half.Z),
        Vector3.new(-half.X,  half.Y,  half.Z),
        Vector3.new( half.X, -half.Y, -half.Z),
        Vector3.new( half.X, -half.Y,  half.Z),
        Vector3.new( half.X,  half.Y, -half.Z),
        Vector3.new( half.X,  half.Y,  half.Z),
    }

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyInFront = false
    local cam = currentCamera()

    for _, localCorner in ipairs(corners) do
        local worldCorner = cf:PointToWorldSpace(localCorner)
        local point = cam:WorldToViewportPoint(worldCorner)
        if point.Z > 0 then
            anyInFront = true
            minX = math.min(minX, point.X)
            minY = math.min(minY, point.Y)
            maxX = math.max(maxX, point.X)
            maxY = math.max(maxY, point.Y)
        end
    end

    if not anyInFront or minX == math.huge then
        return nil
    end

    local width = maxX - minX
    local height = maxY - minY

    if width < 2 or height < 2 then
        return nil
    end

    return minX, minY, width, height, model
end

local function updateTracer(frame, from, to)
    local delta = to - from
    local length = delta.Magnitude
    local angle = math.deg(math.atan2(delta.Y, delta.X))

    frame.Position = UDim2.fromOffset(from.X, from.Y)
    frame.Size = UDim2.fromOffset(length, 1)
    frame.Rotation = angle
end

local function hideESPObject(object)
    object.Holder.Visible = false
    object.Tracer.Visible = false
    object.Highlight.Enabled = false
end

local function updateESP()
    if not Config.ESP.Enabled or not combatRuntimeActive() then
        for _, object in pairs(espObjects) do
            hideESPObject(object)
        end
        return
    end

    local seen = {}
    local cam = currentCamera()

    iterateEnemies(function(entity)
        seen[entity] = true

        local position = getAimPosition(entity)
        if not position then
            local object = espObjects[entity]
            if object then
                hideESPObject(object)
            end
            return
        end

        local distance = (position - cam.CFrame.Position).Magnitude
        if distance > Config.ESP.MaxDistance then
            local object = espObjects[entity]
            if object then
                hideESPObject(object)
            end
            return
        end

        local object = createESP(entity)
        local minX, minY, width, height, model = getBounds(entity)

        local locked = entity == lockedTarget
        local mainColor = locked
            and Color3.fromRGB(100, 255, 125)
            or Color3.fromRGB(255, 78, 78)

        object.BoxStroke.Color = mainColor
        object.Tracer.BackgroundColor3 = mainColor
        object.Highlight.FillColor = mainColor
        object.Highlight.OutlineColor = mainColor

        object.Highlight.Adornee = model
        object.Highlight.Enabled = Config.ESP.Chams and model ~= nil

        if minX then
            object.Holder.Visible = true
            object.Holder.Position = UDim2.fromOffset(minX, minY)
            object.Holder.Size = UDim2.fromOffset(width, height)

            object.Box.Visible = Config.ESP.Boxes

            object.Name.Visible = Config.ESP.Names
            object.Name.Text = getDisplayName(entity)

            local health, maxHealth = getHealth(entity)
            local ratio = math.clamp(health / math.max(maxHealth, 1), 0, 1)

            object.HealthBack.Visible = Config.ESP.Health
            object.HealthFill.Size = UDim2.fromScale(1, ratio)

            local info = {}
            if Config.ESP.Health then
                table.insert(info, ("%d HP"):format(math.max(0, math.floor(health + 0.5))))
            end
            if Config.ESP.Distance then
                table.insert(info, ("%d studs"):format(math.floor(distance + 0.5)))
            end
            object.Info.Visible = #info > 0
            object.Info.Text = table.concat(info, "  •  ")

            if Config.ESP.Tracers then
                local from = Vector2.new(cam.ViewportSize.X * 0.5, cam.ViewportSize.Y - 2)
                local to = Vector2.new(minX + width * 0.5, minY + height)
                updateTracer(object.Tracer, from, to)
                object.Tracer.Visible = true
            else
                object.Tracer.Visible = false
            end
        else
            object.Holder.Visible = false
            object.Tracer.Visible = false
        end
    end)

    for entity, _ in pairs(espObjects) do
        if not seen[entity] or not isAlive(entity) then
            removeESP(entity)
        end
    end
end

--// FOV ring
local FOVRing = Instance.new("Frame")
FOVRing.Name = "FOV"
FOVRing.AnchorPoint = Vector2.new(0.5, 0.5)
FOVRing.BackgroundTransparency = 1
FOVRing.BorderSizePixel = 0
FOVRing.ZIndex = 2
FOVRing.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVRing

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Thickness = 1
FOVStroke.Transparency = 0.25
FOVStroke.Color = Color3.fromRGB(255, 255, 255)
FOVStroke.Parent = FOVRing

local function updateFOV()
    local centre = screenCenter()
    local diameter = Config.Aim.FOV * 2

    FOVRing.Position = UDim2.fromOffset(centre.X, centre.Y)
    FOVRing.Size = UDim2.fromOffset(diameter, diameter)
    FOVRing.Visible = Config.Aim.ShowFOV and Config.Aim.Enabled and combatRuntimeActive()
    FOVStroke.Color = lockedTarget
        and Color3.fromRGB(100, 255, 125)
        or Color3.fromRGB(255, 255, 255)
end

-- ============================================================================
-- RAINZX DEV · Sniper Arena · UI
-- ============================================================================

local Window = RAINZXDevUI:CreateWindow({
    Name = "RAINZX DEV · Sniper Arena",
    GuiName = "RAINZX_SniperArena",
    ConfigId = "SniperArena",
    DisableBuiltInConfigs = true, -- Sniper uses the richer game-specific Configs tab below.
    Width = 500,
    Height = 560,
})

local CombatTab = Window:CreateTab("Combat")
local LegitTab = Window:CreateTab("Legit")
local RageTab = Window:CreateTab("Rage")
local VisualTab = Window:CreateTab("Visuals")
local SettingsTab = Window:CreateTab("Settings")
local ConfigsTab = Window:CreateTab("Configs")

local UIControls = {}
local syncUIFromConfig
local LegitModeLabel
local RageModeLabel

-- Dynamic backend status.
CombatTab:CreateSection("Game Integration")
local BackendStatusLabel = CombatTab:CreateLabel(moduleInitState)

setStatus = function(text)
    moduleInitState = tostring(text or "Unknown")
    if BackendStatusLabel and BackendStatusLabel.Set then
        BackendStatusLabel:Set(moduleInitState)
    end
end

CombatTab:CreateLabel("Native game hooks are used when available; replicated fallback remains active otherwise.")

local RuntimeStatusLabel = CombatTab:CreateLabel(getRuntimeStatusText())
CombatTab:CreateLabel("Universe-based support: all current and future Sniper Arena subplaces are accepted automatically.")

-- ============================================================================
-- Combat
-- ============================================================================

CombatTab:CreateSection("Auto Aim")

UIControls.AimEnabled = CombatTab:CreateToggle({
    Name = "Enable Auto Aim",
    CurrentValue = Config.Aim.Enabled,
    Callback = function(value)
        Config.Aim.Enabled = value
        if not value then
            lockedTarget = nil
        end
    end,
})

UIControls.AimActivation = CombatTab:CreateDropdown({
    Name = "Aim Activation",
    Options = {"Hold RMB", "Always On"},
    CurrentOption = {Config.Aim.HoldRMB and "Hold RMB" or "Always On"},
    Flag = "PuckSniper_AimActivation",
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option

        Config.Aim.HoldRMB = value ~= "Always On"
        lockedTarget = nil

        RAINZXDevUI:Notify({
            Title = "Auto Aim",
            Content = Config.Aim.HoldRMB
                and "Activation: Hold RMB"
                or "Activation: Always On",
            Duration = 1.8,
        })
    end,
})

CombatTab:CreateLabel("Always On aims automatically whenever you are in an active Sniper Arena combat state.")

CombatTab:CreateSection("Auto Shoot")

UIControls.AutoShoot = CombatTab:CreateToggle({
    Name = "Enable Auto Shoot",
    CurrentValue = Config.Aim.AutoShoot,
    Callback = function(value)
        Config.Aim.AutoShoot = value
        lastAutoShotAt = 0
        lastAutoShotAttemptAt = 0
        lastAutoShootTarget = nil
    end,
})

UIControls.AutoShootButton = CombatTab:CreateDropdown({
    Name = "Auto Shoot Button",
    Options = {"RMB", "LMB"},
    CurrentOption = {normalizeAutoShootButton(Config.Aim.AutoShootButton)},
    Flag = "PuckSniper_AutoShootButton",
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.AutoShootButton = normalizeAutoShootButton(value)
        lastAutoShotAt = 0
        lastAutoShotAttemptAt = 0
        lastAutoShootTarget = nil

        RAINZXDevUI:Notify({
            Title = "Auto Shoot",
            Content = "Activation button: " .. Config.Aim.AutoShootButton,
            Duration = 1.8,
        })
    end,
})

UIControls.AutoShootRadius = CombatTab:CreateSlider({
    Name = "Shoot Radius",
    Range = {2, 30},
    Increment = 1,
    CurrentValue = Config.Aim.AutoShootRadius,
    Suffix = " px",
    Callback = function(value)
        Config.Aim.AutoShootRadius = value
    end,
})

UIControls.AutoShootDelay = CombatTab:CreateSlider({
    Name = "Extra Shot Delay",
    Range = {0.00, 0.50},
    Increment = 0.01,
    CurrentValue = Config.Aim.AutoShootDelay,
    Suffix = " s",
    Callback = function(value)
        Config.Aim.AutoShootDelay = value
    end,
})

CombatTab:CreateLabel("Choose RMB or LMB for Auto Shoot. The selected REAL mouse button arms it; no activation button is simulated. Extra Shot Delay 0 fires on the first valid frame using Sniper Arena native firing.")

CombatTab:CreateSection("Aim Point / Lock")

UIControls.AimPoint = CombatTab:CreateDropdown({
    Name = "Aim Point",
    Options = {"Head", "Upper Torso", "Closest Part"},
    CurrentOption = {Config.Aim.AimPoint},
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.AimPoint = value or "Head"
        Config.Aim.HeadPriority = Config.Aim.AimPoint == "Head"
        lockedTarget = nil
    end,
})

UIControls.StickyTarget = CombatTab:CreateToggle({
    Name = "Sticky Target",
    CurrentValue = Config.Aim.StickyTarget,
    Callback = function(value)
        Config.Aim.StickyTarget = value
        if not value then
            lockedTarget = nil
        end
    end,
})

CombatTab:CreateSection("Visibility")

UIControls.VisibleCheck = CombatTab:CreateToggle({
    Name = "Wall / Visibility Check",
    CurrentValue = Config.Aim.VisibleCheck,
    Callback = function(value)
        Config.Aim.VisibleCheck = value
        lockedTarget = nil
    end,
})

UIControls.GameVisibility = CombatTab:CreateToggle({
    Name = "Respect Game Visibility",
    CurrentValue = Config.Aim.RespectGameVisibility,
    Callback = function(value)
        Config.Aim.RespectGameVisibility = value
    end,
})

UIControls.RespectSmoke = CombatTab:CreateToggle({
    Name = "Respect Smoke",
    CurrentValue = Config.Aim.RespectSmoke,
    Callback = function(value)
        Config.Aim.RespectSmoke = value
    end,
})

UIControls.RespectFlash = CombatTab:CreateToggle({
    Name = "Respect Flash",
    CurrentValue = Config.Aim.RespectFlash,
    Callback = function(value)
        Config.Aim.RespectFlash = value
    end,
})

CombatTab:CreateSection("FOV / Response")

UIControls.ShowFOV = CombatTab:CreateToggle({
    Name = "Show FOV Circle",
    CurrentValue = Config.Aim.ShowFOV,
    Callback = function(value)
        Config.Aim.ShowFOV = value
    end,
})

UIControls.FOV = CombatTab:CreateSlider({
    Name = "FOV Radius",
    Range = {40, 600},
    Increment = 5,
    CurrentValue = Config.Aim.FOV,
    Suffix = " px",
    Callback = function(value)
        Config.Aim.FOV = value
    end,
})

UIControls.AimSpeed = CombatTab:CreateSlider({
    Name = "Aim Speed",
    Range = {4, 120},
    Increment = 1,
    CurrentValue = Config.Aim.SmoothSpeed,
    Callback = function(value)
        Config.Aim.SmoothSpeed = value
    end,
})

UIControls.AimDistance = CombatTab:CreateSlider({
    Name = "Aim Max Distance",
    Range = {100, 700},
    Increment = 25,
    CurrentValue = Config.Aim.MaxDistance,
    Suffix = " studs",
    Callback = function(value)
        Config.Aim.MaxDistance = value
        lockedTarget = nil
    end,
})


CombatTab:CreateSection("Advanced Targeting")

UIControls.TargetPriority = CombatTab:CreateDropdown({
    Name = "Target Priority",
    Options = {"Crosshair", "Distance", "Low Health", "Hybrid"},
    CurrentOption = {Config.Aim.TargetPriority},
    Callback = function(option)
        local value = type(option) == "table" and option[1] or option
        Config.Aim.TargetPriority = value or "Hybrid"
        lockedTarget = nil
    end,
})

UIControls.Prediction = CombatTab:CreateToggle({
    Name = "Motion Prediction",
    CurrentValue = Config.Aim.Prediction,
    Callback = function(value)
        Config.Aim.Prediction = value
    end,
})

UIControls.PredictionTime = CombatTab:CreateSlider({
    Name = "Prediction Time",
    Range = {0, 0.30},
    Increment = 0.01,
    CurrentValue = Config.Aim.PredictionTime,
    Suffix = " s",
    Callback = function(value)
        Config.Aim.PredictionTime = value
    end,
})

UIControls.AdaptiveSmoothing = CombatTab:CreateToggle({
    Name = "Adaptive Smoothing",
    CurrentValue = Config.Aim.AdaptiveSmoothing,
    Callback = function(value)
        Config.Aim.AdaptiveSmoothing = value
    end,
})

UIControls.MicroSnap = CombatTab:CreateSlider({
    Name = "Micro Snap Radius",
    Range = {0, 10},
    Increment = 0.5,
    CurrentValue = Config.Aim.MicroSnapRadius,
    Suffix = " px",
    Callback = function(value)
        Config.Aim.MicroSnapRadius = value
    end,
})

UIControls.SwitchDelay = CombatTab:CreateSlider({
    Name = "Target Switch Delay",
    Range = {0, 0.30},
    Increment = 0.01,
    CurrentValue = Config.Aim.SwitchDelay,
    Suffix = " s",
    Callback = function(value)
        Config.Aim.SwitchDelay = value
    end,
})


CombatTab:CreateSection("Lock Stability")

UIControls.LockGrace = CombatTab:CreateSlider({
    Name = "Target Lock Grace",
    Range = {0, 0.50},
    Increment = 0.01,
    CurrentValue = Config.Aim.LockGrace,
    Suffix = " s",
    Callback = function(value)
        Config.Aim.LockGrace = value
    end,
})

UIControls.SwitchThreshold = CombatTab:CreateSlider({
    Name = "Switch Improvement Required",
    Range = {0, 0.50},
    Increment = 0.01,
    CurrentValue = Config.Aim.SwitchThreshold,
    Suffix = "",
    Callback = function(value)
        Config.Aim.SwitchThreshold = value
    end,
})

UIControls.PredictionSmoothing = CombatTab:CreateSlider({
    Name = "Prediction Stability",
    Range = {0, 0.95},
    Increment = 0.01,
    CurrentValue = Config.Aim.PredictionSmoothing,
    Callback = function(value)
        Config.Aim.PredictionSmoothing = value
    end,
})

UIControls.MaxPredictionOffset = CombatTab:CreateSlider({
    Name = "Max Prediction Offset",
    Range = {0, 30},
    Increment = 1,
    CurrentValue = Config.Aim.MaxPredictionOffset,
    Suffix = " studs",
    Callback = function(value)
        Config.Aim.MaxPredictionOffset = value
    end,
})

CombatTab:CreateLabel("Higher lock grace / switch requirement reduces random target drop-offs.")

-- ============================================================================
-- Visuals
-- ============================================================================

VisualTab:CreateSection("ESP")

UIControls.ESPEnabled = VisualTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = Config.ESP.Enabled,
    Callback = function(value)
        Config.ESP.Enabled = value
        if not value then
            for _, object in pairs(espObjects) do
                hideESPObject(object)
            end
        end
    end,
})

UIControls.Boxes = VisualTab:CreateToggle({
    Name = "Boxes",
    CurrentValue = Config.ESP.Boxes,
    Callback = function(value)
        Config.ESP.Boxes = value
    end,
})

UIControls.Names = VisualTab:CreateToggle({
    Name = "Names",
    CurrentValue = Config.ESP.Names,
    Callback = function(value)
        Config.ESP.Names = value
    end,
})

UIControls.Health = VisualTab:CreateToggle({
    Name = "Health",
    CurrentValue = Config.ESP.Health,
    Callback = function(value)
        Config.ESP.Health = value
    end,
})

UIControls.Distance = VisualTab:CreateToggle({
    Name = "Distance",
    CurrentValue = Config.ESP.Distance,
    Callback = function(value)
        Config.ESP.Distance = value
    end,
})

UIControls.Chams = VisualTab:CreateToggle({
    Name = "Chams",
    CurrentValue = Config.ESP.Chams,
    Callback = function(value)
        Config.ESP.Chams = value
    end,
})

UIControls.Tracers = VisualTab:CreateToggle({
    Name = "Tracers",
    CurrentValue = Config.ESP.Tracers,
    Callback = function(value)
        Config.ESP.Tracers = value
    end,
})

VisualTab:CreateSection("ESP Range")

UIControls.ESPDistance = VisualTab:CreateSlider({
    Name = "ESP Max Distance",
    Range = {100, 3000},
    Increment = 50,
    CurrentValue = Config.ESP.MaxDistance,
    Suffix = " studs",
    Callback = function(value)
        Config.ESP.MaxDistance = value
    end,
})

VisualTab:CreateLabel("Locked targets are highlighted differently from normal enemy ESP.")

-- ============================================================================
-- Legit / Rage
-- ============================================================================

local function updateAimModeLabels()
    local text = "Current mode • " .. tostring(Config.AimMode or "Custom")

    if LegitModeLabel and LegitModeLabel.Set then
        LegitModeLabel:Set(text)
    end

    if RageModeLabel and RageModeLabel.Set then
        RageModeLabel:Set(text)
    end
end

local function applyAimPreset(name, values, notification)
    ConfigStore.Applying = true
    Config.AimMode = name

    for key, value in pairs(values or {}) do
        if Config.Aim[key] ~= nil then
            Config.Aim[key] = value
        end
    end

    ConfigStore.Applying = false
    lockedTarget = nil

    if syncUIFromConfig then
        syncUIFromConfig()
    end

    updateAimModeLabels()

    RAINZXDevUI:Notify({
        Title = name,
        Content = notification or (name .. " applied"),
        Duration = 2.2,
    })
end

LegitTab:CreateSection("Legit Aim")
LegitModeLabel = LegitTab:CreateLabel("Current mode • " .. tostring(Config.AimMode))

LegitTab:CreateParagraph({
    Title = "Legit mode",
    Content = "Smooth visible-target aiming designed to look less abrupt. Legit presets keep wall checks, game visibility, smoke and flash handling enabled.",
    Height = 68,
})

LegitTab:CreateButton({
    Name = "Legit • Subtle",
    Callback = function()
        applyAimPreset("Legit • Subtle", {
            Enabled = true,
            HoldRMB = true,
            VisibleCheck = true,
            RespectGameVisibility = true,
            RespectSmoke = true,
            RespectFlash = true,
            HeadPriority = true,
            AimPoint = "Head",
            Prediction = true,
            PredictionTime = 0.04,
            PredictionSmoothing = 0.82,
            MaxPredictionOffset = 10,
            SwitchThreshold = 0.22,
            LockGrace = 0.24,
            AdaptiveSmoothing = true,
            MicroSnapRadius = 0.5,
            TargetPriority = "Hybrid",
            SwitchDelay = 0.12,
            FOV = 80,
            SmoothSpeed = 13,
            MaxDistance = 700,
            StickyTarget = true,
            StickyMultiplier = 1.15,
            ShowFOV = false,
        }, "Hold RMB • 80px FOV • smooth but more responsive • visibility-safe")
    end,
})

LegitTab:CreateButton({
    Name = "Legit • Balanced",
    Callback = function()
        applyAimPreset("Legit • Balanced", {
            Enabled = true,
            HoldRMB = true,
            VisibleCheck = true,
            RespectGameVisibility = true,
            RespectSmoke = true,
            RespectFlash = true,
            HeadPriority = true,
            AimPoint = "Head",
            Prediction = true,
            PredictionTime = 0.06,
            PredictionSmoothing = 0.78,
            MaxPredictionOffset = 12,
            SwitchThreshold = 0.18,
            LockGrace = 0.22,
            AdaptiveSmoothing = true,
            MicroSnapRadius = 1.0,
            TargetPriority = "Hybrid",
            SwitchDelay = 0.08,
            FOV = 120,
            SmoothSpeed = 22,
            MaxDistance = 700,
            StickyTarget = true,
            StickyMultiplier = 1.20,
            ShowFOV = true,
        }, "Hold RMB • 120px FOV • fast balanced response")
    end,
})

LegitTab:CreateButton({
    Name = "Legit • Strong",
    Callback = function()
        applyAimPreset("Legit • Strong", {
            Enabled = true,
            HoldRMB = true,
            VisibleCheck = true,
            RespectGameVisibility = true,
            RespectSmoke = true,
            RespectFlash = true,
            HeadPriority = true,
            AimPoint = "Head",
            Prediction = true,
            PredictionTime = 0.07,
            PredictionSmoothing = 0.72,
            MaxPredictionOffset = 14,
            SwitchThreshold = 0.14,
            LockGrace = 0.18,
            AdaptiveSmoothing = true,
            MicroSnapRadius = 1.5,
            TargetPriority = "Crosshair",
            SwitchDelay = 0.05,
            FOV = 180,
            SmoothSpeed = 36,
            MaxDistance = 700,
            StickyTarget = true,
            StickyMultiplier = 1.25,
            ShowFOV = true,
        }, "Hold RMB • 180px FOV • very fast response")
    end,
})

LegitTab:CreateSection("Legit Helpers")

LegitTab:CreateButton({
    Name = "Force Visible Targets Only",
    Callback = function()
        Config.AimMode = "Legit • Custom"
        Config.Aim.VisibleCheck = true
        Config.Aim.RespectGameVisibility = true
        Config.Aim.RespectSmoke = true
        Config.Aim.RespectFlash = true
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

LegitTab:CreateButton({
    Name = "Use Hold RMB",
    Callback = function()
        Config.AimMode = "Legit • Custom"
        Config.Aim.HoldRMB = true
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

LegitTab:CreateLabel("Fine-tune FOV, speed and visibility from Combat after applying a preset.")

RageTab:CreateSection("Rage Aim")
RageModeLabel = RageTab:CreateLabel("Current mode • " .. tostring(Config.AimMode))

RageTab:CreateParagraph({
    Title = "Rage mode",
    Content = "Aggressive target snapping with Always On support, larger FOV and maximum response. Max Rage can acquire targets even when the normal wall/effect filters are disabled.",
    Height = 76,
})

RageTab:CreateButton({
    Name = "Rage • Visible",
    Callback = function()
        applyAimPreset("Rage • Visible", {
            Enabled = true,
            HoldRMB = false,
            VisibleCheck = true,
            RespectGameVisibility = true,
            RespectSmoke = false,
            RespectFlash = false,
            HeadPriority = true,
            AimPoint = "Head",
            Prediction = true,
            PredictionTime = 0.08,
            PredictionSmoothing = 0.62,
            MaxPredictionOffset = 16,
            SwitchThreshold = 0.07,
            LockGrace = 0.14,
            AdaptiveSmoothing = false,
            MicroSnapRadius = 4,
            TargetPriority = "Crosshair",
            SwitchDelay = 0,
            FOV = 500,
            SmoothSpeed = 92,
            MaxDistance = 700,
            StickyTarget = true,
            StickyMultiplier = 1.45,
            ShowFOV = true,
        }, "Always On • 500px FOV • very fast • visible targets only")
    end,
})

RageTab:CreateButton({
    Name = "Rage • Max",
    Callback = function()
        applyAimPreset("Rage • Max", {
            Enabled = true,
            HoldRMB = false,
            VisibleCheck = false,
            RespectGameVisibility = false,
            RespectSmoke = false,
            RespectFlash = false,
            HeadPriority = true,
            AimPoint = "Closest Part",
            Prediction = true,
            PredictionTime = 0.10,
            PredictionSmoothing = 0.55,
            MaxPredictionOffset = 18,
            SwitchThreshold = 0.03,
            LockGrace = 0.12,
            AdaptiveSmoothing = false,
            MicroSnapRadius = 8,
            TargetPriority = "Crosshair",
            SwitchDelay = 0,
            FOV = 600,
            SmoothSpeed = 120,
            MaxDistance = 700,
            StickyTarget = true,
            StickyMultiplier = 1.60,
            ShowFOV = true,
        }, "Always On • max FOV / instant-class response • ignores visibility/effect filters")
    end,
})

RageTab:CreateSection("Rage Helpers")

RageTab:CreateButton({
    Name = "Always On",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.Enabled = true
        Config.Aim.HoldRMB = false
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:CreateButton({
    Name = "Ignore Walls / Visibility",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.VisibleCheck = false
        Config.Aim.RespectGameVisibility = false
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:CreateButton({
    Name = "Ignore Smoke / Flash",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.RespectSmoke = false
        Config.Aim.RespectFlash = false
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:CreateButton({
    Name = "Max Prediction / Closest Part",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.AimPoint = "Closest Part"
        Config.Aim.Prediction = true
        Config.Aim.PredictionTime = 0.10
        Config.Aim.PredictionSmoothing = 0.55
        Config.Aim.MaxPredictionOffset = 18
        Config.Aim.TargetPriority = "Crosshair"
        Config.Aim.MicroSnapRadius = 8
        Config.Aim.SwitchDelay = 0
        Config.Aim.SwitchThreshold = 0.03
        Config.Aim.LockGrace = 0.12
        lockedTarget = nil
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:CreateButton({
    Name = "Max FOV / Aim Speed",
    Callback = function()
        Config.AimMode = "Rage • Custom"
        Config.Aim.FOV = 600
        Config.Aim.SmoothSpeed = 120
        Config.Aim.MaxDistance = 700
        if syncUIFromConfig then syncUIFromConfig() end
        updateAimModeLabels()
    end,
})

RageTab:CreateLabel("Use Rage • Visible if you still want normal wall checks.")

-- ============================================================================
-- Configs
-- ============================================================================

syncUIFromConfig = function()
    ConfigStore.Applying = true

    local pairsToSet = {
        {UIControls.AimEnabled, Config.Aim.Enabled},
        {UIControls.AimActivation, Config.Aim.HoldRMB and "Hold RMB" or "Always On"},
        {UIControls.AutoShoot, Config.Aim.AutoShoot},
        {UIControls.AutoShootButton, normalizeAutoShootButton(Config.Aim.AutoShootButton)},
        {UIControls.AutoShootRadius, Config.Aim.AutoShootRadius},
        {UIControls.AutoShootDelay, Config.Aim.AutoShootDelay},
        {UIControls.AimPoint, Config.Aim.AimPoint},
        {UIControls.StickyTarget, Config.Aim.StickyTarget},
        {UIControls.VisibleCheck, Config.Aim.VisibleCheck},
        {UIControls.GameVisibility, Config.Aim.RespectGameVisibility},
        {UIControls.RespectSmoke, Config.Aim.RespectSmoke},
        {UIControls.RespectFlash, Config.Aim.RespectFlash},
        {UIControls.ShowFOV, Config.Aim.ShowFOV},
        {UIControls.FOV, Config.Aim.FOV},
        {UIControls.AimSpeed, Config.Aim.SmoothSpeed},
        {UIControls.AimDistance, Config.Aim.MaxDistance},
        {UIControls.TargetPriority, Config.Aim.TargetPriority},
        {UIControls.Prediction, Config.Aim.Prediction},
        {UIControls.PredictionTime, Config.Aim.PredictionTime},
        {UIControls.AdaptiveSmoothing, Config.Aim.AdaptiveSmoothing},
        {UIControls.MicroSnap, Config.Aim.MicroSnapRadius},
        {UIControls.SwitchDelay, Config.Aim.SwitchDelay},
        {UIControls.LockGrace, Config.Aim.LockGrace},
        {UIControls.SwitchThreshold, Config.Aim.SwitchThreshold},
        {UIControls.PredictionSmoothing, Config.Aim.PredictionSmoothing},
        {UIControls.MaxPredictionOffset, Config.Aim.MaxPredictionOffset},
        {UIControls.ESPEnabled, Config.ESP.Enabled},
        {UIControls.Boxes, Config.ESP.Boxes},
        {UIControls.Names, Config.ESP.Names},
        {UIControls.Health, Config.ESP.Health},
        {UIControls.Distance, Config.ESP.Distance},
        {UIControls.Chams, Config.ESP.Chams},
        {UIControls.Tracers, Config.ESP.Tracers},
        {UIControls.ESPDistance, Config.ESP.MaxDistance},
    }

    for _, pair in ipairs(pairsToSet) do
        local control, value = pair[1], pair[2]
        if control and control.Set then
            pcall(function()
                control:Set(value)
            end)
        end
    end

    ConfigStore.Applying = false
    lockedTarget = nil
    updateAimModeLabels()
end

ConfigsTab:CreateSection("Profiles")

ConfigStore.StatusLabel = ConfigsTab:CreateLabel(
    ConfigStore.Available
        and ("Ready • " .. ConfigStore.Selected)
        or "Unavailable • executor filesystem APIs missing"
)

if ConfigStore.Available then
    ConfigStore.ProfileDropdown = ConfigsTab:CreateDropdown({
        Name = "Config Profile",
        Options = listConfigProfiles(),
        CurrentOption = {ConfigStore.Selected},
        Callback = function(option)
            local value = type(option) == "table" and option[1] or option
            if value ~= nil then
                ConfigStore.Selected = sanitizeConfigName(value, "default")
                ConfigStore.PendingProfile = ConfigStore.Selected
                if ConfigStore.ProfileInput and ConfigStore.ProfileInput.Set then
                    ConfigStore.ProfileInput:Set(ConfigStore.Selected)
                end
                saveMeta()
                setConfigStatus("Selected • " .. ConfigStore.Selected)
            end
        end,
    })

    ConfigStore.ProfileInput = ConfigsTab:CreateInput({
        Name = "Profile Name",
        CurrentValue = ConfigStore.Selected,
        PlaceholderText = "default",
        Callback = function(value)
            ConfigStore.PendingProfile = sanitizeConfigName(value, ConfigStore.Selected)
        end,
    })

    ConfigsTab:CreateButton({
        Name = "Save / Create Profile",
        Callback = function()
            local profile = ConfigStore.PendingProfile or ConfigStore.Selected
            ConfigStore.Selected = sanitizeConfigName(profile, "default")

            if saveConfig(ConfigStore.Selected, true) then
                ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
                ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
            end
        end,
    })

    ConfigsTab:CreateButton({
        Name = "Load Selected Profile",
        Callback = function()
            if loadConfig(ConfigStore.Selected, true) then
                syncUIFromConfig()
            end
        end,
    })

    ConfigsTab:CreateButton({
        Name = "Refresh Profiles",
        Callback = function()
            ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
            ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
            setConfigStatus("Profiles refreshed")
        end,
    })

    ConfigsTab:CreateButton({
        Name = "Delete Selected Profile",
        Callback = function()
            local deleted = ConfigStore.Selected
            if deleteConfig(deleted) then
                ConfigStore.ProfileDropdown:Refresh(listConfigProfiles())
                ConfigStore.ProfileDropdown:Set(ConfigStore.Selected)
                ConfigStore.ProfileInput:Set(ConfigStore.Selected)

                RAINZXDevUI:Notify({
                    Title = "Configs",
                    Content = "Deleted " .. deleted,
                    Duration = 2,
                })
            end
        end,
    })

    ConfigsTab:CreateSection("Automation")

    ConfigsTab:CreateToggle({
        Name = "Auto Save",
        CurrentValue = ConfigStore.AutoSave,
        Callback = function(value)
            ConfigStore.AutoSave = value == true
            saveMeta()

            if ConfigStore.AutoSave then
                saveConfig(ConfigStore.Selected, false)
            end

            setConfigStatus(
                ConfigStore.AutoSave
                    and ("Auto Save ON • " .. ConfigStore.Selected)
                    or "Auto Save OFF"
            )
        end,
    })

    ConfigsTab:CreateToggle({
        Name = "Auto Load",
        CurrentValue = ConfigStore.AutoLoad,
        Callback = function(value)
            ConfigStore.AutoLoad = value == true
            saveMeta()

            setConfigStatus(
                ConfigStore.AutoLoad
                    and ("Auto Load ON • " .. ConfigStore.Selected)
                    or "Auto Load OFF"
            )
        end,
    })

    ConfigsTab:CreateLabel("Auto Save and Auto Load default to ON.")
    ConfigsTab:CreateLabel("Auto Load restores the selected profile next execution.")
else
    ConfigsTab:CreateParagraph({
        Title = "Persistent configs unavailable",
        Content = "Your executor needs writefile, readfile, isfile and makefolder. AutoAim/ESP still works normally without saved configs.",
        Height = 64,
    })
end

-- ============================================================================
-- Settings
-- The shared RAINZXDev_UI automatically adds the global UI keybind control here.
-- ============================================================================

SettingsTab:CreateSection("Sniper Arena")

SettingsTab:CreateButton({
    Name = "Reset Aim Settings",
    Callback = function()
        Config.AimMode = "Custom"
        Config.Aim.Enabled = true
        Config.Aim.HoldRMB = true
        Config.Aim.VisibleCheck = true
        Config.Aim.RespectGameVisibility = true
        Config.Aim.RespectSmoke = true
        Config.Aim.RespectFlash = true
        Config.Aim.HeadPriority = true
        Config.Aim.AimPoint = "Head"
        Config.Aim.AutoShoot = false
        Config.Aim.AutoShootButton = "RMB"
        Config.Aim.AutoShootRadius = 10
        Config.Aim.AutoShootDelay = 0.00
        Config.Aim.FOV = 220
        Config.Aim.SmoothSpeed = 46
        Config.Aim.MaxDistance = 700
        Config.Aim.StickyTarget = true
        Config.Aim.StickyMultiplier = 1.30
        Config.Aim.Prediction = true
        Config.Aim.PredictionTime = 0.06
        Config.Aim.PredictionSmoothing = 0.72
        Config.Aim.MaxPredictionOffset = 14
        Config.Aim.AdaptiveSmoothing = true
        Config.Aim.MicroSnapRadius = 1.5
        Config.Aim.TargetPriority = "Hybrid"
        Config.Aim.SwitchDelay = 0.05
        Config.Aim.SwitchThreshold = 0.12
        Config.Aim.LockGrace = 0.18
        Config.Aim.ShowFOV = true
        lockedTarget = nil
        if syncUIFromConfig then
            syncUIFromConfig()
        end

        RAINZXDevUI:Notify({
            Title = "Sniper Arena",
            Content = "Aim settings reset • Activation: Hold RMB. Reopen the UI to refresh displayed control values.",
            Duration = 2.5,
        })
    end,
})

SettingsTab:CreateButton({
    Name = "Reset ESP Settings",
    Callback = function()
        Config.ESP.Enabled = true
        Config.ESP.Boxes = true
        Config.ESP.Names = true
        Config.ESP.Health = true
        Config.ESP.Distance = true
        Config.ESP.Tracers = false
        Config.ESP.Chams = true
        Config.ESP.MaxDistance = 1200

        RAINZXDevUI:Notify({
            Title = "Sniper Arena",
            Content = "ESP settings reset. Reopen the UI to refresh displayed control values.",
            Duration = 2.5,
        })
    end,
})

local cleanup

SettingsTab:CreateButton({
    Name = "Unload Sniper Arena",
    Callback = function()
        if cleanup then
            cleanup()
        end
    end,
})

-- Auto-save the whole game config whenever any option changes.
task.spawn(function()
    task.wait(1)

    if not ConfigStore.Available then
        return
    end

    ConfigStore.LastFingerprint = configFingerprint()

    if ConfigStore.AutoSave and not FS.IsFile(configPath(ConfigStore.Selected)) then
        saveConfig(ConfigStore.Selected, false)
    end

    while not destroyed do
        if ConfigStore.AutoSave and not ConfigStore.Applying then
            local current = configFingerprint()

            if current ~= ""
                and current ~= ConfigStore.LastFingerprint then
                saveConfig(ConfigStore.Selected, false)
            end
        end

        task.wait(0.5)
    end
end)

-- ============================================================================
-- Cleanup / startup
-- ============================================================================

cleanup = function()
    if destroyed then
        return
    end

    destroyed = true
    lockedTarget = nil
    lastAutoShotAt = 0

    -- Ensure a fallback press/release pair cannot leave primary fire held.
    if type(mouse1release) == "function" then
        pcall(mouse1release)
    end
    autoShootPressPending = false

    pcall(function()
        RunService:UnbindFromRenderStep(renderName)
    end)

    for _, connection in ipairs(connections) do
        pcall(function()
            connection:Disconnect()
        end)
    end
    table.clear(connections)

    for entity, _ in pairs(espObjects) do
        removeESP(entity)
    end

    pcall(function()
        ScreenGui:Destroy()
    end)

    pcall(function()
        Window:Destroy()
    end)

    if ENV.__RAINZX_SNIPER_ARENA_AIM_ESP_CLEANUP == cleanup then
        ENV.__RAINZX_SNIPER_ARENA_AIM_ESP_CLEANUP = nil
    end
end

ENV.__RAINZX_SNIPER_ARENA_AIM_ESP_CLEANUP = cleanup

Window:SetCloseCallback(function()
    cleanup()
end)

addConnection(workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end))

-- Retry native integration after UI creation.
-- Replicated fallback is already usable while this runs.
task.spawn(function()
    for attempt = 1, 6 do
        if destroyed then
            return
        end

        local ok = pcall(initializeGameModules)

        if not ok then
            moduleInitState = "READY • fallback (native init failed)"
            setStatus(moduleInitState)
        end

        if EntityService and WorldManager and CameraController and WeaponController then
            break
        end

        task.wait(2)
    end

    if not destroyed then
        updateBackendStatus()
    end
end)

-- Keep the displayed place/combat state current. Ranked/matchmaking can move
-- from an idle queue state into a live match without changing this script.
task.spawn(function()
    while not destroyed do
        if RuntimeStatusLabel and RuntimeStatusLabel.Set then
            pcall(function()
                RuntimeStatusLabel:Set(getRuntimeStatusText())
            end)
        end
        task.wait(1)
    end
end)

-- Aim runs after the game's camera post-handler and shaker.
RunService:BindToRenderStep(renderName, Enum.RenderPriority.Camera.Value + 25, function(dt)
    if destroyed then
        return
    end

    applyAim(dt)
    updateFOV()
    updateESP()
end)

RAINZXDevUI:Notify({
    Title = "RAINZX DEV • Sniper Arena",
    Content = "Universe-wide Auto Aim + Auto Shoot + ESP loaded • v4.6.5 • native Auto Shoot fix • configs " .. (ConfigStore.Available and "ready" or "unavailable") .. " • " .. getCurrentPlaceInfo().Name,
    Duration = 2.5,
})

print("[RAINZX DEV · Sniper Arena] AutoAim + ESP loaded")
]===],
    ['RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua'] = [=[--[[
	RAINZX DEV Hub - Universal Loader
	Rebuilt & rebranded by RAINZX DEV.
	- Universal anti-AFK
	- Auto game detection (universe + PlaceId)
	- Manual script picker fallback
	- All game routes point to RAINZX DEV hosted scripts (no PuckAFK).
]]

local ENV = (getgenv and getgenv()) or _G

ENV.__RAINZX_CONFIG_SHARED_STATE = ENV.__RAINZX_CONFIG_SHARED_STATE or {
	Root = "RAINZXDEV/Configs",
	AutoSaveDefault = true,
	AutoLoadDefault = true,
}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Hosting root (RAINZX DEV GitHub repo)
local RAW_ROOT = "https://raw.githubusercontent.com/suroyah152-web/RAINZX-DEVELOPERBRE/main/"

-- =========================
-- Universal Anti-AFK
-- =========================
local function getGlobalEnvironment()
	if type(getgenv) == "function" then
		local ok, env = pcall(getgenv)
		if ok and type(env) == "table" then return env end
	end
	return _G
end

local GLOBAL_ENV = getGlobalEnvironment()
local ANTI_AFK_KEY = "__RAINZX_LOADER_ANTI_AFK"

local function enableAntiAFK()
	local oldState = GLOBAL_ENV[ANTI_AFK_KEY]
	if type(oldState) == "table" and oldState.Connection then
		pcall(function() oldState.Connection:Disconnect() end)
	end

	local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
	local connection = player.Idled:Connect(function()
		pcall(function() VirtualUser:CaptureController() end)
		pcall(function() VirtualUser:ClickButton2(Vector2.new(0, 0)) end)
		pcall(function()
			local camera = workspace.CurrentCamera
			local cf = camera and camera.CFrame or CFrame.new()
			VirtualUser:Button2Down(Vector2.new(0, 0), cf)
			task.wait(0.05)
			VirtualUser:Button2Up(Vector2.new(0, 0), cf)
		end)
	end)

	GLOBAL_ENV[ANTI_AFK_KEY] = { Connection = connection, Enabled = true }
end

enableAntiAFK()

-- =========================
-- Routing: game -> script (RAINZX DEV only)
-- =========================
local SNIPER = {
	name = "Sniper Arena",
	-- Uses the camera-rotate FPS hub (works without hookfunction), which now
	-- includes a full Rage mode. The dedicated silent-aim rework needs a
	-- hook-capable executor, so the hub defaults to the compatible build.
	url = RAW_ROOT .. "RainzxDev_FpsHub.lua",
}

-- Sniper Arena universe + subplaces
local UNIVERSE_ROUTES = {
	[9534705677] = SNIPER,
}

local ROUTES = {
	[122446657157717] = SNIPER,
	[119259569670784] = SNIPER,
}

local MATCH = {
	["Sniper Arena"] = SNIPER,
}

-- =========================
-- UI theme & helpers
-- =========================
local THEME = {
	Main = Color3.fromRGB(12, 12, 12),
	Section = Color3.fromRGB(18, 18, 18),
	Element = Color3.fromRGB(24, 24, 24),
	ElementHover = Color3.fromRGB(32, 32, 32),
	Border = Color3.fromRGB(45, 45, 45),
	BorderDark = Color3.fromRGB(5, 5, 5),
	Text = Color3.fromRGB(170, 170, 170),
	DimText = Color3.fromRGB(100, 100, 100),
	BrightText = Color3.fromRGB(230, 230, 230),
	Accent = Color3.fromRGB(0, 95, 255),
	Danger = Color3.fromRGB(180, 58, 64),
	Success = Color3.fromRGB(48, 145, 78),
}

local function create(className, properties)
	local object = Instance.new(className)
	for key, value in pairs(properties or {}) do
		object[key] = value
	end
	return object
end

local function codeLabel(parent, text, size, color)
	return create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = tostring(text or ""),
		TextColor3 = color or THEME.Text,
		TextSize = size or 12,
		Font = Enum.Font.Code,
		TextXAlignment = Enum.TextXAlignment.Center,
		TextYAlignment = Enum.TextYAlignment.Center,
		ZIndex = 10,
		Parent = parent,
	})
end

-- =========================
-- UI
-- =========================
local function removeOld()
	local lp = Players.LocalPlayer
	if lp and lp:FindFirstChildOfClass("PlayerGui") then
		local o = lp:FindFirstChildOfClass("PlayerGui"):FindFirstChild("RAINZXHub")
		if o then o:Destroy() end
	end
	local o = CoreGui:FindFirstChild("RAINZXHub")
	if o then o:Destroy() end
end

removeOld()

local gui = create("ScreenGui", {
	Name = "RAINZXHub",
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	DisplayOrder = 10000,
})
pcall(function() gui.Parent = CoreGui end)
if not gui.Parent then
	gui.Parent = (Players.LocalPlayer or Players.PlayerAdded:Wait()):WaitForChild("PlayerGui")
end

local WIDTH, HEIGHT = 360, 200

local card = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.new(0.5, 0, 0.5, 0),
	Size = UDim2.fromOffset(WIDTH, HEIGHT),
	BackgroundColor3 = THEME.Main,
	BorderColor3 = THEME.BorderDark,
	BorderSizePixel = 1,
	Draggable = true,
	Active = true,
	ZIndex = 2,
	Parent = gui,
})

local function lbl(text, y, size, color)
	local l = codeLabel(card, text, size, color)
	l.Position = UDim2.fromOffset(0, y)
	l.Size = UDim2.new(1, 0, 0, 24)
	return l
end

lbl("RAINZX DEV Hub", 14, 16, THEME.BrightText)
local status = lbl("Starting...", 60, 13, THEME.BrightText)
local detail = lbl("", 86, 11, THEME.DimText)

local track = create("Frame", {
	AnchorPoint = Vector2.new(0.5, 0),
	Position = UDim2.new(0.5, 0, 0, 118),
	Size = UDim2.new(1, -64, 0, 10),
	BackgroundColor3 = THEME.Element,
	BorderColor3 = THEME.BorderDark,
	BorderSizePixel = 1,
	ClipsDescendants = true,
	ZIndex = 3,
	Parent = card,
})
local fill = create("Frame", {
	Size = UDim2.fromScale(0, 1),
	BackgroundColor3 = THEME.Accent,
	BorderSizePixel = 0,
	ZIndex = 3,
	Parent = track,
})

local close = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -2, 0, 2),
	Size = UDim2.fromOffset(20, 20),
	BackgroundTransparency = 1,
	Text = "x",
	TextColor3 = THEME.DimText,
	Font = Enum.Font.Code,
	TextSize = 13,
	ZIndex = 5,
	Parent = card,
})
local cancelled = false
close.MouseButton1Click:Connect(function()
	cancelled = true
	pcall(function() gui:Destroy() end)
end)

local function setStatus(main, sub, color)
	if cancelled then return end
	status.Text = main
	status.TextColor3 = color or THEME.BrightText
	detail.Text = sub or ""
end

local function setProgress(value)
	if cancelled then return end
	value = math.clamp(value or 0, 0, 1)
	TweenService:Create(fill, TweenInfo.new(0.2), { Size = UDim2.fromScale(value, 1) }):Play()
end

-- =========================
-- Source fetching (HttpGet + request fallback)
-- =========================
local function fetchSource(url)
	local ok, body = pcall(game.HttpGet, game, url)
	if ok and type(body) == "string" and #body > 0 then return true, body end

	local req = (type(request) == "function" and request)
		or (syn and type(syn.request) == "function" and syn.request)
		or (http and type(http.request) == "function" and http.request)
	if req then
		local rok, resp = pcall(req, { Url = url, Method = "GET" })
		if rok and type(resp) == "table" then
			local b = resp.Body or resp.body
			if type(b) == "string" and #b > 0 then return true, b end
		end
	end
	return false, body or "HTTP unavailable"
end

-- =========================
-- Manual picker (RAINZX DEV scripts)
-- =========================
local manualRoutes = {
	SNIPER,
	{ name = "FPS Hub (Blox Strike / Rivals)", url = RAW_ROOT .. "RainzxDev_FpsHub.lua" },
}

local function chooseRouteManually()
	setStatus("Choose a Script", "Auto-detection failed for this game")
	setProgress(0.3)

	local picker = create("Frame", {
		Position = UDim2.fromOffset(20, 150),
		Size = UDim2.new(1, -40, 0, 34),
		BackgroundTransparency = 1,
		ZIndex = 6,
		Parent = card,
	})

	local selector = create("TextButton", {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundColor3 = THEME.Element,
		BorderColor3 = THEME.BorderDark,
		BorderSizePixel = 1,
		Text = "  select script...",
		TextColor3 = THEME.Text,
		Font = Enum.Font.Code,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 7,
		Parent = picker,
	})

	local menu = create("ScrollingFrame", {
		Position = UDim2.fromOffset(0, 36),
		Size = UDim2.new(1, 0, 0, 150),
		BackgroundColor3 = THEME.Section,
		BorderColor3 = THEME.BorderDark,
		BorderSizePixel = 1,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 2,
		Visible = false,
		ZIndex = 8,
		Parent = picker,
	})

	create("UIListLayout", {
		Padding = UDim.new(0, 4),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = menu,
	})

	local selected, open = nil, false
	selector.MouseButton1Click:Connect(function()
		open = not open
		menu.Visible = open
		selector.Text = open and "  (click to close)" or "  select script..."
	end)

	for i, opt in ipairs(manualRoutes) do
		local item = create("TextButton", {
			LayoutOrder = i,
			Size = UDim2.new(1, -2, 0, 26),
			BackgroundColor3 = THEME.Element,
			BorderColor3 = THEME.BorderDark,
			BorderSizePixel = 1,
			Text = "  " .. opt.name,
			TextColor3 = THEME.Text,
			Font = Enum.Font.Code,
			TextSize = 11,
			TextXAlignment = Enum.TextXAlignment.Left,
			ZIndex = 9,
			Parent = menu,
		})
		item.MouseButton1Click:Connect(function()
			selected = opt
			selector.Text = "  " .. opt.name
			open = false
			menu.Visible = false
		end)
	end

	while not selected and gui.Parent and not cancelled do
		task.wait(0.03)
	end

	if selected then picker:Destroy() end
	return selected
end

-- =========================
-- Loader sequence
-- =========================
task.spawn(function()
	task.wait(0.15)
	if cancelled then return end

	setStatus("RAINZX DEV Hub", "Detecting game...")
	setProgress(0.1)

	local route = UNIVERSE_ROUTES[game.GameId] or ROUTES[game.PlaceId]

	setStatus("RAINZX DEV Hub", "Finding matching script...")
	setProgress(0.3)

	if not route then
		route = chooseRouteManually()
		if not route or cancelled then
			setStatus("Load Failed", "No script selected", THEME.Danger)
			fill.BackgroundColor3 = THEME.Danger
			return
		end
	end

	setStatus(route.name, "Downloading...")
	setProgress(0.5)

	local okSrc, source = fetchSource(route.url)
	if not okSrc then
		setStatus("Download Failed", tostring(source), THEME.Danger)
		fill.BackgroundColor3 = THEME.Danger
		return
	end

	if #source < 20 then
		setStatus("Invalid Script", "Source too small", THEME.Danger)
		fill.BackgroundColor3 = THEME.Danger
		return
	end

	setStatus(route.name, "Compiling...")
	setProgress(0.8)

	local compiler = loadstring or load
	if type(compiler) ~= "function" then
		setStatus("Compiler Unavailable", "No loadstring/load", THEME.Danger)
		return
	end

	local chunk, err = compiler(source)
	if not chunk then
		setStatus("Compile Failed", tostring(err), THEME.Danger)
		return
	end

	setStatus(route.name, "Launching...")
	setProgress(0.95)

	local finished, okRun, runErr = false, true
	task.spawn(function()
		okRun, runErr = pcall(chunk)
		finished = true
	end)

	task.wait(0.2)
	if finished and not okRun then
		setStatus("Launch Failed", tostring(runErr), THEME.Danger)
		return
	end

	setProgress(1)
	fill.BackgroundColor3 = THEME.Success
	setStatus(route.name, "Loaded successfully", THEME.Success)
	task.wait(0.7)

	if gui.Parent then
		TweenService:Create(card, TweenInfo.new(0.18),
			{ GroupTransparency = 1 }):Play()
		task.wait(0.2)
		pcall(function() gui:Destroy() end)
	end
end)
]=],
    ['RAINZX-DEVELOPERBRE/RainzxDev_FpsHub.lua'] = [=[--[[
    RAINZX DEV | Universal FPS Hub
    Works across FPS games: Blox Strike, Rivals, Sniper Arena, and more.
    Aimbot + ESP + Chams + Anti-AFK.
    Rework by RAINZX DEV.
]]

task.spawn(function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local VirtualUser = game:GetService("VirtualUser")
	local Camera = workspace.CurrentCamera
	local LP = Players.LocalPlayer

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Camera = workspace.CurrentCamera
	end)

	-- === Settings ===
	local cfg = {
		mode = "Off", -- "Off" / "Legit" / "Rage"
		autoFire = false,
		headshot = true,
		fov = 180,
		esp = false,
		espBox = true,
		espHealth = true,
		espName = true,
		chams = false,
		teamCheck = true,
		smoothness = 0.5,
		rageFov = 500,
		rageHead = true, -- false = closest part (max aggression)
	}

	local function isRage() return cfg.mode == "Rage" end
	local function isLegit() return cfg.mode == "Legit" end
	local function aimOn() return isRage() or isLegit() end

	-- === Anti-AFK ===
	do
		local player = LP or Players.PlayerAdded:Wait()
		player.Idled:Connect(function()
			pcall(function() VirtualUser:CaptureController() end)
			pcall(function() VirtualUser:ClickButton2(Vector2.new(0, 0)) end)
		end)
	end

	-- === FOV circle ===
	local fovCircle = Drawing.new("Circle")
	fovCircle.Thickness = 1
	fovCircle.Transparency = 0.7
	fovCircle.Color = Color3.fromRGB(255, 255, 255)
	fovCircle.NumSides = 64
	fovCircle.Visible = false

	-- === Target helpers ===
	local function isTeam(plr)
		if isRage() then return false end
		if not cfg.teamCheck then return false end
		if not LP then return true end
		if LP.Team == plr.Team and plr.Team ~= nil then return true end
		local c1, c2 = LP.TeamColor, plr.TeamColor
		if c1 and c2 then
			local a, b = c1.Color, c2.Color
			if (a - b).Magnitude < 0.2 then return true end
		end
		return false
	end

	local function getTargetPart(char)
		if isRage() and not cfg.rageHead then
			return char:FindFirstChild("HumanoidRootPart")
		end
		local part = cfg.headshot and char:FindFirstChild("Head") or nil
		if part and part:IsA("BasePart") then return part end
		part = char:FindFirstChild("HumanoidRootPart")
		return (part and part:IsA("BasePart")) and part or nil
	end

	local function getAlive()
		local out = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character then
				local char = plr.Character
				local hum = char:FindFirstChildOfClass("Humanoid")
				if hum and hum.Health > 0 and not isTeam(plr) then
					local part = getTargetPart(char)
					if part then out[#out + 1] = { plr = plr, char = char, part = part } end
				end
			end
		end
		return out
	end

	local function toScreen(worldPos)
		if not Camera then return nil end
		local sp, on = Camera:WorldToViewportPoint(worldPos)
		if not on then return nil end
		return Vector2.new(sp.X, sp.Y)
	end

	local function closestInFOV()
		local mx, my = UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y
		local best, bestD = nil, math.huge
		local useFov = isRage() and cfg.rageFov or cfg.fov
		for _, t in ipairs(getAlive()) do
			local sp = toScreen(t.part.Position)
			if sp then
				local d = (sp - Vector2.new(mx, my)).Magnitude
				if d <= useFov and d < bestD then
					best, bestD = t, d
				end
			end
		end
		return best
	end

	-- === Aimbot main loop ===
	RunService.RenderStepped:Connect(function()
		fovCircle.Position = UIS:GetMouseLocation()
		fovCircle.Radius = isRage() and cfg.rageFov or cfg.fov
		fovCircle.Visible = aimOn()

		if aimOn() then
			local target = closestInFOV()
			if target then
				local cam = Camera
				if isRage() then
					cam.CFrame = CFrame.lookAt(cam.Position, target.part.Position)
					if cfg.autoFire then
						pcall(function() mouse1click() end)
					end
				else
					if cfg.smoothness > 0 and cfg.smoothness <= 1 then
						local current = cam.CFrame
						local goal = CFrame.lookAt(current.Position, target.part.Position)
						cam.CFrame = current:Lerp(goal, cfg.smoothness)
					else
						cam.CFrame = CFrame.lookAt(cam.Position, target.part.Position)
					end
					if cfg.autoFire then
						pcall(function() mouse1click() end)
					end
				end
			end
		end
	end)

	-- === ESP engine ===
	local espObjs = {}
	local function makeDrawing(kind)
		local d = Drawing.new(kind)
		d.Visible = false
		return d
	end

	local function espFor(char)
		local e = espObjs[char]
		if e then return e end
		e = {
			box = makeDrawing("Quad"),
			name = makeDrawing("Text"),
			health = makeDrawing("Line"),
		}
		e.box.Thickness = 1
		e.box.Color = Color3.fromRGB(255, 80, 80)
		e.name.Size = 13
		e.name.Center = true
		e.name.Outline = true
		e.name.Color = Color3.fromRGB(255, 255, 255)
		e.health.Color = Color3.fromRGB(80, 255, 80)
		e.health.Thickness = 2
		espObjs[char] = e
		return e
	end

	local function renderESP(plr, char)
		local root = char:FindFirstChild("HumanoidRootPart")
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not root or not hum or hum.Health <= 0 then return end
		local top = toScreen(root.Position + Vector3.new(0, 5, 0))
		local bottom = toScreen(root.Position - Vector3.new(0, 5, 0))
		if not top or not bottom then return end
		local height = (top - bottom).Magnitude
		local width = height * 0.6
		local e = espFor(char)
		local cx, cy = top.X, top.Y
		if cfg.espBox then
			e.box.Visible = true
			e.box.PointA = Vector2.new(cx - width/2, cy)
			e.box.PointB = Vector2.new(cx + width/2, cy)
			e.box.PointC = Vector2.new(cx + width/2, cy + height)
			e.box.PointD = Vector2.new(cx - width/2, cy + height)
		else
			e.box.Visible = false
		end
		if cfg.espName then
			e.name.Visible = true
			e.name.Position = Vector2.new(cx, cy - 16)
			e.name.Text = plr.Name
		else
			e.name.Visible = false
		end
		if cfg.espHealth then
			local hf = hum.Health / hum.MaxHealth
			e.health.Visible = true
			e.health.From = Vector2.new(cx - width/2 - 4, cy + height)
			e.health.To = Vector2.new(cx - width/2 - 4, cy + height - (height * hf))
			e.health.Color = Color3.fromRGB(
				math.clamp((1 - hf) * 255, 0, 255),
				math.clamp(hf * 255, 0, 255), 0)
		else
			e.health.Visible = false
		end
	end

	local function hideAllESP()
		for _, e in pairs(espObjs) do
			e.box.Visible = false
			e.name.Visible = false
			e.health.Visible = false
		end
	end

	local function clearAllESP()
		for _, e in pairs(espObjs) do
			pcall(function() e.box:Remove() end)
			pcall(function() e.name:Remove() end)
			pcall(function() e.health:Remove() end)
		end
		espObjs = {}
	end

	-- === Chams ===
	local highlights = {}
	local function applyChams()
		if not cfg.chams then
			for char, hl in pairs(highlights) do
				pcall(function() hl:Destroy() end)
			end
			highlights = {}
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LP and plr.Character and not isTeam(plr) then
				local char = plr.Character
				if cfg.chams and not highlights[char] then
					local hl = Instance.new("Highlight")
					hl.FillColor = Color3.fromRGB(255, 0, 0)
					hl.OutlineColor = Color3.fromRGB(255, 255, 255)
					hl.FillTransparency = 0.5
					hl.Adornee = char
					hl.Parent = char
					highlights[char] = hl
				end
			end
		end
	end

	-- === Render ESP loop ===
	RunService.RenderStepped:Connect(function()
		if cfg.esp then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Character then
					renderESP(plr, plr.Character)
				end
			end
		else
			hideAllESP()
		end
	end)

	task.spawn(function()
		while task.wait(0.5) do applyChams() end
	end)

	-- === UI ===
	local gui = Instance.new("ScreenGui")
	gui.Name = "RainzxFpsHub"
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 400)
	frame.Position = UDim2.new(0.5, -130, 0.5, -200)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = gui

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "RAINZX DEV | FPS Hub"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 16
	title.Parent = frame

	local function section(parent, y, h)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -20, 0, h)
		f.Position = UDim2.new(0, 10, 0, y)
		f.BackgroundTransparency = 1
		f.Parent = parent
		return f
	end

	local function toggle(parent, y, label, key, onChange)
		local f = section(parent, y, 26)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 14
		btn.Parent = f
		local function refresh()
			btn.Text = label .. ": " .. (cfg[key] and "ON" or "OFF")
			btn.BackgroundColor3 = cfg[key] and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(55, 55, 60)
		end
		btn.MouseButton1Click:Connect(function()
			cfg[key] = not cfg[key]
			refresh()
			if onChange then onChange() end
		end)
		refresh()
	end

	local function cycle(parent, y, label, options, key)
		local f = section(parent, y, 26)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 14
		btn.Parent = f
		local function refresh()
			local cur = cfg[key]
			btn.Text = label .. ": " .. tostring(cur)
			btn.BackgroundColor3 = (cur == options[1]) and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(55, 55, 60)
		end
		btn.MouseButton1Click:Connect(function()
			local cur = cfg[key]
			local idx = 0
			for i, o in ipairs(options) do if o == cur then idx = i break end end
			cfg[key] = options[(idx % #options) + 1]
			refresh()
		end)
		refresh()
	end

	local function numeric(parent, y, label, key, apply)
		local f = section(parent, y, 26)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, -5, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
		lbl.Text = label
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 14
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0.4, -5, 1, 0)
		box.Position = UDim2.new(0.6, 0, 0, 0)
		box.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.Text = tostring(cfg[key])
		box.Font = Enum.Font.SourceSans
		box.TextSize = 14
		box.Parent = f
		box.FocusLost:Connect(function()
			local v = tonumber(box.Text)
			if v then cfg[key] = v if apply then apply(v) end end
		end)
	end

	cycle(frame, 36, "Aim Mode", { "Off", "Legit", "Rage" }, "mode")
	toggle(frame, 68, "Auto Fire", "autoFire")
	toggle(frame, 100, "Headshot", "headshot")
	numeric(frame, 132, "FOV", "fov")
	numeric(frame, 164, "Smoothness", "smoothness")
	toggle(frame, 196, "ESP", "esp", function() if not cfg.esp then hideAllESP() end end)
	toggle(frame, 228, "ESP Box", "espBox")
	toggle(frame, 260, "ESP Health", "espHealth")
	toggle(frame, 292, "ESP Name", "espName")
	toggle(frame, 324, "Chams", "chams")
	toggle(frame, 356, "Team Check", "teamCheck")

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(1, -20, 0, 18)
	close.Position = UDim2.new(0, 10, 0, 382)
	close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Text = "Tutup Script"
	close.Font = Enum.Font.SourceSans
	close.TextSize = 13
	close.Parent = frame
	close.MouseButton1Click:Connect(function()
		clearAllESP()
		for _, hl in pairs(highlights) do pcall(function() hl:Destroy() end) end
		highlights = {}
		pcall(function() fovCircle:Remove() end)
		gui:Destroy()
	end)

	print("RAINZX DEV | FPS Hub loaded.")
end)
]=]
}


local function normalizeLayoutMode(value)
    local lowered = string.lower(tostring(value or "Auto"))
    if lowered == "phone" or lowered == "mobile" then
        return "Phone"
    elseif lowered == "desktop" or lowered == "pc" then
        return "Desktop"
    end
    return "Auto"
end

local function getViewportSize()
    local camera = workspace.CurrentCamera
    local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
    if viewport.X < 1 or viewport.Y < 1 then
        return Vector2.new(1280, 720)
    end
    return viewport
end

local function resolveLayoutMode(mode, viewport)
    mode = normalizeLayoutMode(mode)
    if mode ~= "Auto" then
        return mode
    end
    viewport = viewport or getViewportSize()
    local smallViewport = viewport.X < 760 or viewport.Y < 500
    local touchPhone = UserInputService.TouchEnabled and math.min(viewport.X, viewport.Y) <= 720
    return (smallViewport or touchPhone) and "Phone" or "Desktop"
end

local function loadSharedUIPreferences()
    if type(readfile) ~= "function" or type(isfile) ~= "function" then
        return
    end

    local root = tostring((ENV.__RAINZXDEV_CONFIG_SHARED_STATE or {}).Root or "RAINZXDEV/Configs")
    local path = root .. "/_ui_layout.json"
    local okExists, exists = pcall(isfile, path)
    if not okExists or not exists then
        return
    end

    local okRead, text = pcall(readfile, path)
    if not okRead or type(text) ~= "string" then
        return
    end

    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(text)
    end)
    if not okDecode or type(data) ~= "table" then
        return
    end

    SHARED_UI_STATE.LayoutMode = normalizeLayoutMode(data.LayoutMode or SHARED_UI_STATE.LayoutMode)
    SHARED_UI_STATE.UIScalePercent = math.clamp(
        tonumber(data.UIScalePercent) or SHARED_UI_STATE.UIScalePercent or 100,
        75,
        125
    )
end

loadSharedUIPreferences()


-- =========================
-- Universal Anti-AFK
-- =========================

local function getGlobalEnvironment()
    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then
            return env
        end
    end
    return _G
end

local GLOBAL_ENV = getGlobalEnvironment()
local ANTI_AFK_KEY = "__RAINZXDEV_LOADER_ANTI_AFK"

local function enableAntiAFK()
    local oldState = GLOBAL_ENV[ANTI_AFK_KEY]
    if type(oldState) == "table" and oldState.Connection then
        pcall(function()
            oldState.Connection:Disconnect()
        end)
    end

    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local connection = player.Idled:Connect(function()
        pcall(function()
            VirtualUser:CaptureController()
        end)

        pcall(function()
            VirtualUser:ClickButton2(Vector2.new(0, 0))
        end)

        pcall(function()
            local camera = workspace.CurrentCamera
            local cameraCFrame = camera and camera.CFrame or CFrame.new()
            VirtualUser:Button2Down(Vector2.new(0, 0), cameraCFrame)
            task.wait(0.05)
            VirtualUser:Button2Up(Vector2.new(0, 0), cameraCFrame)
        end)
    end)

    GLOBAL_ENV[ANTI_AFK_KEY] = {
        Connection = connection,
        Enabled = true,
    }
end

enableAntiAFK()


-- =========================
-- Route Table
-- =========================

local SNIPER_ARENA_ROUTE = {
    name = "Sniper Arena",
    source = "RAINZX-DEVELOPERBRE/AimbotRage_FullBuild.lua",
    url = BASE_URL .. "AimbotRage_FullBuild.lua",
}

local ONE_TAP_ROUTE = {
    name = "One Tap",
    source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
    url = BASE_URL .. "RainzxDev_Hub.lua",
}

local KICK_A_LUCKY_BLOCK_ROUTE = {
    name = "Kick a Lucky Block",
    source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
    url = BASE_URL .. "RainzxDev_Hub.lua",
}

local UNIVERSE_ROUTES = {
    [9534705677] = SNIPER_ARENA_ROUTE,
    [9294074907] = ONE_TAP_ROUTE,
    [10004244222] = KICK_A_LUCKY_BLOCK_ROUTE,
}

local ROUTES = {
    [90568084448279] = ONE_TAP_ROUTE,
    [89469502395769] = KICK_A_LUCKY_BLOCK_ROUTE,
    [83038462357724] = {
        name = "Dig & Clean",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_FpsHub.lua",
        url = BASE_URL .. "RainzxDev_FpsHub.lua",
    },
    [134162299584012] = {
        name = "Build a Gun Army",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
        url = BASE_URL .. "RainzxDev_Hub.lua",
    },
    [142823291] = {
        name = "Murder Mystery 2",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
        url = BASE_URL .. "RainzxDev_Hub.lua",
    },
    [74889851913797] = {
        name = "+1 Power Per Click",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_FpsHub.lua",
        url = BASE_URL .. "RainzxDev_FpsHub.lua",
    },
    [133188236593503] = {
        name = "Magic Loot",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
        url = BASE_URL .. "RainzxDev_Hub.lua",
    },
    [128481067661991] = {
        name = "Get Rich ASAP",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
        url = BASE_URL .. "RainzxDev_Hub.lua",
    },
    [137233438285284] = {
        name = "Chicken Farm",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_FpsHub.lua",
        url = BASE_URL .. "RainzxDev_FpsHub.lua",
    },
    [131558436575033] = {
        name = "SevenM Hood",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_Hub.lua",
        url = BASE_URL .. "RainzxDev_Hub.lua",
    },
    [114697347887839] = {
        name = "+1 Speed Monkey Escape",
        source = "RAINZX-DEVELOPERBRE/RainzxDev_FpsHub.lua",
        url = BASE_URL .. "RainzxDev_FpsHub.lua",
    },
    [122446657157717] = SNIPER_ARENA_ROUTE,
    [119259569670784] = SNIPER_ARENA_ROUTE,
}


-- =========================
-- Theme & UI Utilities
-- =========================

local THEME = {
    Main = Color3.fromRGB(12, 12, 12),
    Top = Color3.fromRGB(12, 12, 12),
    Tab = Color3.fromRGB(12, 12, 12),
    Section = Color3.fromRGB(18, 18, 18),
    SectionInner = Color3.fromRGB(18, 18, 18),
    Element = Color3.fromRGB(24, 24, 24),
    ElementHover = Color3.fromRGB(32, 32, 32),
    Border = Color3.fromRGB(45, 45, 45),
    BorderDark = Color3.fromRGB(5, 5, 5),
    Text = Color3.fromRGB(170, 170, 170),
    DimText = Color3.fromRGB(100, 100, 100),
    BrightText = Color3.fromRGB(230, 230, 230),
    Accent = Color3.fromRGB(0, 95, 255),
    Danger = Color3.fromRGB(180, 58, 64),
    Success = Color3.fromRGB(48, 145, 78),
}

local function create(className, properties)
    local object = Instance.new(className)
    local viewport = getViewportSize()
    local phoneLayout = resolveLayoutMode(SHARED_UI_STATE.LayoutMode, viewport) == "Phone"

    for key, value in pairs(properties or {}) do
        if key == "TextSize" and phoneLayout and type(value) == "number" then
            object[key] = math.floor(value * 1.10 + 0.5)
        else
            object[key] = value
        end
    end

    return object
end

local function tween(object, duration, properties, style, direction)
    local animation = TweenService:Create(
        object,
        TweenInfo.new(
            duration or 0.12,
            style or Enum.EasingStyle.Quad,
            direction or Enum.EasingDirection.Out
        ),
        properties
    )
    animation:Play()
    return animation
end

local function codeLabel(parent, text, size, color, zIndex)
    return create("TextLabel", {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Text = tostring(text or ""),
        TextColor3 = color or THEME.Text,
        TextSize = size or 12,
        Font = Enum.Font.Code,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = zIndex or 10,
        Parent = parent,
    })
end

local function getGuiParent(screenGui)
    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local playerGui = player:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        playerGui = player:WaitForChild("PlayerGui", 10)
    end
    if playerGui then
        local ok = pcall(function()
            screenGui.Parent = playerGui
        end)
        if ok and screenGui.Parent == playerGui then
            return playerGui
        end
    end
    if type(gethui) == "function" then
        local ok, target = pcall(gethui)
        if ok and target then
            local parented = pcall(function()
                screenGui.Parent = target
            end)
            if parented then
                return target
            end
        end
    end
    return nil
end

local function removeOld()
    local possibleParents = {CoreGui}
    local player = Players.LocalPlayer
    if player then
        local playerGui = player:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            table.insert(possibleParents, playerGui)
        end
    end
    if type(gethui) == "function" then
        local ok, result = pcall(gethui)
        if ok and result then
            table.insert(possibleParents, result)
        end
    end
    for _, parent in ipairs(possibleParents) do
        pcall(function()
            local old = parent:FindFirstChild("RAINZXDEVLoader")
            if old then
                old:Destroy()
            end
        end)
    end
end

removeOld()


-- =========================
-- GUI Setup
-- =========================

local gui = create("ScreenGui", {
    Name = "RAINZXDEVLoader",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    DisplayOrder = 10000,
})

getGuiParent(gui)

local WINDOW_WIDTH = 480
local WINDOW_HEIGHT = 260
local EXPANDED_HEIGHT = 365
local LOADER_LAYOUT = "Desktop"
local LOADER_EXPANDED = false
local LOADER_SCALE = 1

local function calculateLoaderLayout()
    local viewport = getViewportSize()
    local resolved = resolveLayoutMode(SHARED_UI_STATE.LayoutMode, viewport)
    local phoneLayout = resolved == "Phone"
    local landscape = viewport.X > viewport.Y

    if phoneLayout then
        WINDOW_WIDTH = landscape and 500 or 350
        WINDOW_HEIGHT = landscape and 235 or 260
        EXPANDED_HEIGHT = landscape and 350 or 365
    else
        WINDOW_WIDTH = 480
        WINDOW_HEIGHT = 260
        EXPANDED_HEIGHT = 365
    end

    local requestedScale = math.clamp(tonumber(SHARED_UI_STATE.UIScalePercent) or 100, 75, 125) / 100
    local fitScale = math.min(
        (viewport.X - 16) / math.max(WINDOW_WIDTH, 1),
        (viewport.Y - 16) / math.max(EXPANDED_HEIGHT, 1)
    )

    LOADER_LAYOUT = resolved
    LOADER_SCALE = math.max(0.65, math.min(requestedScale, fitScale))
end

calculateLoaderLayout()
local targetCardSize = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT)

local shadow = create("Frame", {
    Name = "Shadow",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 4, 0.5, 4),
    Size = targetCardSize,
    BackgroundColor3 = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,
    BorderSizePixel = 0,
    ZIndex = 1,
    Parent = gui,
})

local card = create("CanvasGroup", {
    Name = "LoaderCard",
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.fromScale(0.5, 0.5),
    Size = targetCardSize,
    BackgroundColor3 = THEME.Main,
    BackgroundTransparency = 0,
    BorderColor3 = THEME.BorderDark,
    BorderSizePixel = 1,
    GroupTransparency = 1,
    Active = true,
    ZIndex = 2,
    Parent = gui,
})

local cardScale = create("UIScale", {Scale = LOADER_SCALE, Parent = card})
local shadowScale = create("UIScale", {Scale = LOADER_SCALE, Parent = shadow})

local function applyLoaderResponsiveLayout()
    if not gui.Parent then return end
    calculateLoaderLayout()
    targetCardSize = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT)
    cardScale.Scale = LOADER_SCALE
    shadowScale.Scale = LOADER_SCALE
    local desired = LOADER_EXPANDED
        and UDim2.fromOffset(WINDOW_WIDTH, EXPANDED_HEIGHT)
        or targetCardSize
    card.Size = desired
    shadow.Size = desired
end

local viewportConnection = nil
local function attachViewportListener()
    if viewportConnection then
        pcall(function() viewportConnection:Disconnect() end)
        viewportConnection = nil
    end
    local camera = workspace.CurrentCamera
    if camera then
        viewportConnection = camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            task.defer(applyLoaderResponsiveLayout)
        end)
    end
end

attachViewportListener()
local cameraConnection = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    attachViewportListener()
    task.defer(applyLoaderResponsiveLayout)
end)

gui.AncestryChanged:Connect(function(_, parent)
    if parent == nil then
        if viewportConnection then pcall(function() viewportConnection:Disconnect() end) end
        if cameraConnection then pcall(function() cameraConnection:Disconnect() end) end
    end
end)


-- =========================
-- Rose Background (Procedural RAINZX DEV)
-- =========================

local roseBackground = create("CanvasGroup", {
    Name = "RoseBackground",
    Size = UDim2.fromScale(1, 1),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    GroupTransparency = 0.78,
    ZIndex = 3,
    Parent = card,
})

local roseColor = Color3.fromRGB(255, 255, 255)

local function softPart(parent, position, anchor, size, rotation, transparency)
    local part = create("Frame", {
        AnchorPoint = anchor or Vector2.new(0.5, 0.5),
        Position = position,
        Size = size,
        Rotation = rotation or 0,
        BackgroundColor3 = roseColor,
        BackgroundTransparency = transparency or 0.84,
        BorderSizePixel = 0,
        ZIndex = 3,
        Parent = parent,
    })
    create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = part})
    return part
end

local function createRose(x, y, scale, tilt)
    local motif = create("Frame", {
        Position = UDim2.fromOffset(x - 36, y - 36),
        Size = UDim2.fromOffset(72, 72),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Rotation = tilt or 0,
        ZIndex = 3,
        Parent = roseBackground,
    })
    local center = UDim2.fromScale(0.5, 0.43)
    for index = 0, 5 do
        softPart(motif, center, Vector2.new(0.5, 0.92),
            UDim2.fromOffset(math.max(6, math.floor(13 * scale)), math.max(12, math.floor(24 * scale))),
            index * 60, 0.78)
    end
    for index = 0, 4 do
        softPart(motif, center, Vector2.new(0.5, 0.90),
            UDim2.fromOffset(math.max(4, math.floor(9 * scale)), math.max(8, math.floor(16 * scale))),
            index * 72 + 36, 0.72)
    end
    softPart(motif, center, Vector2.new(0.5, 0.5), UDim2.fromOffset(4, 4), 0, 0.62)
    softPart(motif, UDim2.new(0.5, -5, 0.68, 0), Vector2.new(1, 0.5), UDim2.fromOffset(17, 4), -32, 0.80)
    softPart(motif, UDim2.new(0.5, 5, 0.71, 0), Vector2.new(0, 0.5), UDim2.fromOffset(17, 4), 32, 0.80)
    local stem = create("Frame", {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(0.5, 0, 0.60, 0),
        Size = UDim2.fromOffset(1, 24),
        BackgroundColor3 = roseColor,
        BackgroundTransparency = 0.78,
        BorderSizePixel = 0,
        ZIndex = 2,
        Parent = motif,
    })
    create("UIGradient", {
        Rotation = 90,
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.12),
            NumberSequenceKeypoint.new(1, 1),
        }),
        Parent = stem,
    })
end

createRose(74, 112, 0.68, -7)
createRose(220, 176, 0.60, 7)
createRose(385, 105, 0.64, -5)
createRose(448, 218, 0.52, 8)


-- =========================
-- Title Bar + Close + Drag
-- =========================

create("Frame", {
    Name = "InnerBorder",
    Position = UDim2.fromOffset(1, 1),
    Size = UDim2.new(1, -2, 1, -2),
    BackgroundTransparency = 1,
    BorderColor3 = THEME.Border,
    BorderSizePixel = 1,
    ZIndex = 4,
    Parent = card,
})

local titleBar = create("Frame", {
    Name = "TitleBar",
    Position = UDim2.fromOffset(2, 2),
    Size = UDim2.new(1, -4, 0, 24),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ZIndex = 8,
    Parent = card,
})

local titleLabel = codeLabel(titleBar, "RAINZX DEV", 13, THEME.BrightText, 11)
titleLabel.Position = UDim2.fromOffset(6, 0)
titleLabel.Size = UDim2.new(1, -92, 1, 0)

local authorLabel = codeLabel(titleBar, "by RAINZX DEV", 9, THEME.DimText, 11)
authorLabel.AnchorPoint = Vector2.new(1, 0)
authorLabel.Position = UDim2.new(1, -24, 0, 7)
authorLabel.Size = UDim2.new(0, 80, 0, 12)

local cancelled = false

local closeButton = create("TextButton", {
    Name = "Close",
    AnchorPoint = Vector2.new(1, 0),
    Position = UDim2.new(1, -2, 0, 2),
    Size = UDim2.fromOffset(18, 19),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.Code,
    Text = "x",
    TextSize = 12,
    TextColor3 = THEME.DimText,
    ZIndex = 15,
    Parent = titleBar,
})

closeButton.MouseEnter:Connect(function()
    tween(closeButton, 0.08, {TextColor3 = THEME.BrightText})
end)
closeButton.MouseLeave:Connect(function()
    tween(closeButton, 0.08, {TextColor3 = THEME.DimText})
end)
closeButton.MouseButton1Click:Connect(function()
    cancelled = true
    pcall(function() gui:Destroy() end)
end)

local dragHandle = create("TextButton", {
    Name = "DragHandle",
    Position = UDim2.fromOffset(0, 0),
    Size = UDim2.new(1, -42, 1, 0),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Text = "",
    Active = true,
    ZIndex = 14,
    Parent = titleBar,
})

local dragging = false
local dragStart = nil
local startPosition = nil

dragHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPosition = card.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging or not dragStart or not startPosition then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        card.Position = UDim2.new(
            startPosition.X.Scale, startPosition.X.Offset + delta.X,
            startPosition.Y.Scale, startPosition.Y.Offset + delta.Y
        )
        shadow.Position = UDim2.new(
            card.Position.X.Scale, card.Position.X.Offset + 4,
            card.Position.Y.Scale, card.Position.Y.Offset + 4
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = false
    end
end)


-- =========================
-- Content Area
-- =========================

local accentTop = create("Frame", {
    Name = "AccentTop",
    Position = UDim2.fromOffset(2, 26),
    Size = UDim2.new(1, -4, 0, 1),
    BackgroundColor3 = THEME.Accent,
    BorderSizePixel = 0,
    ZIndex = 9,
    Parent = card,
})

local contentHost = create("Frame", {
    Name = "ContentHost",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 58),
    Size = UDim2.new(1, LOADER_LAYOUT == "Phone" and -28 or -48, 0, 132),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    ClipsDescendants = true,
    ZIndex = 6,
    Parent = card,
})

local section = create("Frame", {
    Name = "LoaderSection",
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = THEME.Section,
    BorderColor3 = THEME.Border,
    BorderSizePixel = 1,
    ZIndex = 7,
    Parent = contentHost,
})

create("Frame", {
    Position = UDim2.fromOffset(1, 1),
    Size = UDim2.new(1, -2, 1, -2),
    BackgroundTransparency = 1,
    BorderColor3 = THEME.BorderDark,
    BorderSizePixel = 1,
    ZIndex = 8,
    Parent = section,
})

local status = codeLabel(section, "Starting...", 13, THEME.BrightText, 11)
status.Position = UDim2.fromOffset(14, 22)
status.Size = UDim2.new(1, -28, 0, 30)
status.TextXAlignment = Enum.TextXAlignment.Center

local detail = codeLabel(section, "Preparing RAINZX DEV loader...", 11, THEME.DimText, 11)
detail.Position = UDim2.fromOffset(14, 53)
detail.Size = UDim2.new(1, -28, 0, 18)
detail.TextXAlignment = Enum.TextXAlignment.Center
detail.TextTruncate = Enum.TextTruncate.AtEnd

local progressTrack = create("Frame", {
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 83),
    Size = UDim2.new(1, -84, 0, 10),
    BackgroundColor3 = THEME.Element,
    BorderColor3 = THEME.BorderDark,
    BorderSizePixel = 1,
    ClipsDescendants = true,
    ZIndex = 10,
    Parent = section,
})

create("Frame", {
    Position = UDim2.fromOffset(1, 1),
    Size = UDim2.new(1, -2, 1, -2),
    BackgroundTransparency = 1,
    BorderColor3 = THEME.Border,
    BorderSizePixel = 1,
    ZIndex = 11,
    Parent = progressTrack,
})

local progressFill = create("Frame", {
    Size = UDim2.fromScale(0, 1),
    BackgroundColor3 = THEME.Accent,
    BorderSizePixel = 0,
    ZIndex = 10,
    Parent = progressTrack,
})

local autoText = codeLabel(section, "automatic script detection", 9, THEME.DimText, 10)
autoText.Position = UDim2.fromOffset(14, 102)
autoText.Size = UDim2.new(1, -28, 0, 14)
autoText.TextXAlignment = Enum.TextXAlignment.Center


-- =========================
-- Progress & Status Helpers
-- =========================

local progressValue = 0
local changingStatus = false

local function setProgress(value)
    if cancelled then return end
    value = math.clamp(tonumber(value) or 0, 0, 1)
    progressValue = value
    tween(progressFill, 0.20, {Size = UDim2.fromScale(value, 1)})
end

local function setStatus(mainText, detailText, color)
    if cancelled or not status.Parent or not detail.Parent then return end
    while changingStatus and not cancelled do task.wait() end
    if cancelled then return end
    changingStatus = true
    local mainValue = tostring(mainText or "RAINZX DEV")
    local detailValue = tostring(detailText or "")
    local mainChanged = status.Text ~= mainValue
    if mainChanged then
        local fade = tween(status, 0.06, {TextTransparency = 1})
        fade.Completed:Wait()
    end
    if cancelled or not status.Parent then
        changingStatus = false
        return
    end
    status.Text = mainValue
    status.TextColor3 = color or THEME.BrightText
    detail.Text = detailValue
    if mainChanged then
        tween(status, 0.08, {TextTransparency = 0})
    end
    changingStatus = false
end

local function fail(stage, message)
    if cancelled then return end
    progressFill.BackgroundColor3 = THEME.Danger
    accentTop.BackgroundColor3 = THEME.Danger
    autoText.Text = "loader error"
    autoText.TextColor3 = THEME.Danger
    setStatus("Load Failed",
        tostring(stage or "Loader Error") .. " • " .. tostring(message or "Unknown error"),
        THEME.BrightText)
end

local function fetchSource(url)
    local ok, result = pcall(function()
        return game:HttpGet(url)
    end)
    if ok and type(result) == "string" and #result > 0 then
        return true, result
    end
    local requestFunction =
        type(request) == "function" and request
        or type(http_request) == "function" and http_request
        or (syn and type(syn.request) == "function" and syn.request or nil)
        or (http and type(http.request) == "function" and http.request or nil)
    if type(requestFunction) == "function" then
        local requestOk, response = pcall(requestFunction, {
            Url = url, Method = "GET",
        })
        if requestOk and type(response) == "table" then
            local body = response.Body or response.body
            local code = response.StatusCode or response.Status or response.status
            if type(body) == "string" and #body > 0 and (not code or tonumber(code) == 200) then
                return true, body
            end
        end
    end
    return false, result or "HTTP request unavailable"
end


-- =========================
-- Script Menu (auto-opens when game detection fails)
-- =========================

local function showScriptMenu(placeId, universeId)
    if cancelled then return nil end
    setStatus("Choose a Script", "Automatic detection did not find this game")
    setProgress(0.30)

    local menuWidth = 320
    local menuHeight = 330
    local menuRoot = create("CanvasGroup", {
        Name = "RAINZXDEVMenu",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, math.floor(WINDOW_WIDTH / 2) + 16, 0.5, 0),
        Size = UDim2.fromOffset(menuWidth, menuHeight),
        BackgroundColor3 = THEME.Main,
        BorderColor3 = THEME.BorderDark,
        BorderSizePixel = 1,
        GroupTransparency = 1,
        Active = true,
        ZIndex = 30,
        Parent = gui,
    })
    create("UIScale", {Scale = LOADER_SCALE, Parent = menuRoot})

    local menuShadow = create("Frame", {
        Name = "Shadow",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = menuRoot.Position + UDim2.fromOffset(4, 4),
        Size = UDim2.fromOffset(menuWidth, menuHeight),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.5,
        BorderSizePixel = 0,
        ZIndex = 29,
        Parent = gui,
    })

    local titleBar = create("Frame", {
        Name = "TitleBar",
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = THEME.Top,
        BorderColor3 = THEME.BorderDark,
        BorderSizePixel = 1,
        ZIndex = 32,
        Parent = menuRoot,
    })

    create("Frame", {
        Position = UDim2.fromOffset(2, 43),
        Size = UDim2.new(1, -4, 0, 1),
        BackgroundColor3 = THEME.Accent,
        BorderSizePixel = 0,
        ZIndex = 33,
        Parent = titleBar,
    })

    codeLabel(titleBar, "RAINZX DEV", 13, THEME.BrightText, 34)
    local menuSubtitle = codeLabel(titleBar, "script menu", 10, THEME.DimText, 34)
    menuSubtitle.Position = UDim2.fromOffset(10, 22)
    menuSubtitle.Size = UDim2.fromOffset(170, 16)

    local minimizeButton = create("TextButton", {
        Name = "Minimize",
        Position = UDim2.new(1, -94, 0, 8),
        Size = UDim2.fromOffset(40, 28),
        BackgroundColor3 = THEME.Element,
        BorderColor3 = THEME.Border,
        BorderSizePixel = 1,
        AutoButtonColor = false,
        Font = Enum.Font.Code,
        Text = "-",
        TextColor3 = THEME.Text,
        TextSize = 14,
        ZIndex = 36,
        Parent = titleBar,
    })

    local closeButton = create("TextButton", {
        Name = "Close",
        Position = UDim2.new(1, -50, 0, 8),
        Size = UDim2.fromOffset(40, 28),
        BackgroundColor3 = THEME.Element,
        BorderColor3 = THEME.Border,
        BorderSizePixel = 1,
        AutoButtonColor = false,
        Font = Enum.Font.Code,
        Text = "x",
        TextColor3 = THEME.Danger,
        TextSize = 13,
        ZIndex = 36,
        Parent = titleBar,
    })

    local body = create("CanvasGroup", {
        Name = "Body",
        Position = UDim2.fromOffset(0, 44),
        Size = UDim2.new(1, 0, 1, -88),
        BackgroundColor3 = THEME.Section,
        BorderColor3 = THEME.Border,
        BorderSizePixel = 1,
        ZIndex = 31,
        Parent = menuRoot,
    })

    create("Frame", {
        Position = UDim2.fromOffset(1, 1),
        Size = UDim2.new(1, -2, 1, -2),
        BackgroundTransparency = 1,
        BorderColor3 = THEME.BorderDark,
        BorderSizePixel = 1,
        ZIndex = 32,
        Parent = body,
    })

    local scriptList = create("ScrollingFrame", {
        Name = "Scripts",
        Size = UDim2.new(1, 0, 1, -40),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = THEME.DimText,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ZIndex = 33,
        Parent = body,
    })

    create("UIPadding", {
        PaddingTop = UDim.new(0, 5), PaddingBottom = UDim.new(0, 5),
        PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5),
        Parent = scriptList,
    })

    create("UIListLayout", {
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = scriptList,
    })

    local footer = codeLabel(body, "tap a script to run it", 10, THEME.DimText, 33)
    footer.Position = UDim2.new(0, 10, 1, -34)
    footer.Size = UDim2.new(1, -20, 0, 28)
    footer.TextXAlignment = Enum.TextXAlignment.Center

    local function kindTag(sourceKey)
        if string.find(sourceKey or "", "AimbotRage_FullBuild") then return "SNIPER" end
        if string.find(sourceKey or "", "RainzxDev_Hub") then return "HUB" end
        if string.find(sourceKey or "", "RainzxDev_FpsHub") then return "FPS" end
        return "MOD"
    end

    local scriptOptions = {
        ROUTES[83038462357724],
        ROUTES[134162299584012],
        ROUTES[142823291],
        SNIPER_ARENA_ROUTE,
        ONE_TAP_ROUTE,
        ROUTES[74889851913797],
        ROUTES[133188236593503],
        ROUTES[128481067661991],
        ROUTES[137233438285284],
        ROUTES[131558436575033],
        ROUTES[114697347887839],
    }

    local selectedRoute = nil
    local closed = false
    local busy = false
    local collapsed = false

    minimizeButton.MouseEnter:Connect(function()
        if not busy then tween(minimizeButton, 0.08, {BackgroundColor3 = THEME.ElementHover}) end
    end)
    minimizeButton.MouseLeave:Connect(function()
        if not busy then tween(minimizeButton, 0.08, {BackgroundColor3 = THEME.Element}) end
    end)
    minimizeButton.MouseButton1Click:Connect(function()
        if busy or cancelled then return end
        collapsed = not collapsed
        body.Visible = not collapsed
        local target = collapsed
            and UDim2.fromOffset(menuWidth, 44)
            or UDim2.fromOffset(menuWidth, menuHeight)
        tween(menuRoot, 0.15, {Size = target})
        tween(menuShadow, 0.15, {Size = target})
    end)

    closeButton.MouseEnter:Connect(function()
        if not busy then tween(closeButton, 0.08, {BackgroundColor3 = THEME.ElementHover}) end
    end)
    closeButton.MouseLeave:Connect(function()
        if not busy then tween(closeButton, 0.08, {BackgroundColor3 = THEME.Element}) end
    end)
    closeButton.MouseButton1Click:Connect(function()
        if busy or cancelled then return end
        closed = true
    end)

    for index, option in ipairs(scriptOptions) do
        local routeOption = {name = option.name, source = option.source, url = option.url}
        local item = create("TextButton", {
            Name = "Script" .. tostring(index),
            LayoutOrder = index,
            Size = UDim2.new(1, -2, 0, 30),
            BackgroundColor3 = THEME.Element,
            BorderColor3 = THEME.BorderDark,
            BorderSizePixel = 1,
            AutoButtonColor = false,
            Font = Enum.Font.Code,
            Text = "  " .. routeOption.name,
            TextColor3 = THEME.Text,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 34,
            Parent = scriptList,
        })

        create("Frame", {
            Position = UDim2.fromOffset(1, 1), Size = UDim2.new(1, -2, 1, -2),
            BackgroundTransparency = 1, BorderColor3 = THEME.Border, BorderSizePixel = 1, ZIndex = 35, Parent = item,
        })

        local tag = codeLabel(item, kindTag(routeOption.source), 9, THEME.DimText, 36)
        tag.AnchorPoint = Vector2.new(1, 0.5)
        tag.Position = UDim2.new(1, -10, 0.5, 0)
        tag.Size = UDim2.fromOffset(54, 14)
        tag.TextXAlignment = Enum.TextXAlignment.Right

        item.MouseEnter:Connect(function()
            if not busy then tween(item, 0.08, {BackgroundColor3 = THEME.ElementHover}) end
        end)
        item.MouseLeave:Connect(function()
            if not busy then tween(item, 0.08, {BackgroundColor3 = THEME.Element}) end
        end)

        item.MouseButton1Click:Connect(function()
            if busy or cancelled then return end
            busy = true
            selectedRoute = {name = routeOption.name, source = routeOption.source, url = routeOption.url}
            setStatus(selectedRoute.name, "Preparing script...")
            item.BackgroundColor3 = THEME.ElementHover
        end)
    end

    footer.Text = "place " .. tostring(placeId or "?")
        .. " | universe " .. tostring(universeId or "?")
        .. " | not detected"

    tween(menuRoot, 0.12, {GroupTransparency = 0})
    tween(menuShadow, 0.12, {BackgroundTransparency = 0.5})

    while not selectedRoute and not closed and gui.Parent and not cancelled do
        task.wait(0.03)
    end

    local fade = tween(menuRoot, 0.10, {GroupTransparency = 1})
    tween(menuShadow, 0.10, {BackgroundTransparency = 1})
    fade.Completed:Wait()

    if menuRoot.Parent then pcall(function() menuRoot:Destroy() end) end
    if menuShadow.Parent then pcall(function() menuShadow:Destroy() end) end

    if cancelled or closed or not selectedRoute then return nil end
    return selectedRoute
end


-- =========================
-- Module Menu Detection
-- =========================

local function hasModuleMenu()
    local parents = {CoreGui}
    local player = Players.LocalPlayer
    if player then
        local playerGui = player:FindFirstChildOfClass("PlayerGui")
        if playerGui then
            table.insert(parents, 1, playerGui)
        end
    end
    if type(gethui) == "function" then
        local ok, target = pcall(gethui)
        if ok and target then
            table.insert(parents, target)
        end
    end

    for i = 1, #parents do
        local children = parents[i]:GetChildren()
        for j = 1, #children do
            local child = children[j]
            if child.ClassName == "ScreenGui" then
                local name = child.Name
                if name == "RAINZXHub"
                    or name == "RainzxFpsHub"
                    or name == "SniperArenaAimESP"
                    or (string.sub(name, 1, 10) == "RAINZXDev_"
                        and name ~= "RAINZXDev_Notifications")
                then
                    return true
                end
            end
        end
    end
    return false
end


-- =========================
-- Entrance Animation + Loader Sequence
-- =========================

card.Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT - 14)
shadow.Size = card.Size

tween(card, 0.20, {GroupTransparency = 0, Size = targetCardSize})
tween(shadow, 0.20, {Size = targetCardSize})

task.spawn(function()
    task.wait(0.18)
    if cancelled then return end

    setStatus("RAINZX DEV", "Detecting game...")
    setProgress(0.08)

    if not game:IsLoaded() then
        local loaded = false
        local connection
        connection = game.Loaded:Connect(function()
            loaded = true
            if connection then connection:Disconnect() end
        end)
        local started = os.clock()
        while not loaded and not game:IsLoaded() and os.clock() - started < 30 do
            task.wait(0.05)
        end
        if connection then pcall(function() connection:Disconnect() end) end
    end

    setProgress(0.18)
    task.wait(0.12)

    local placeId = game.PlaceId
    local universeId = game.GameId
    local route = UNIVERSE_ROUTES[universeId] or ROUTES[placeId]

    setStatus("RAINZX DEV", "Finding matching script...")
    setProgress(0.30)
    task.wait(0.20)

    if not route then
        route = showScriptMenu(placeId, universeId)
        if not route then
            fail("No Script Selected", "Manual script selection was closed")
            return
        end
    end

    if cancelled then return end

    local moduleMenuSeen = false
    local moduleMenuTimeout = 4.0

    while route and not cancelled and not moduleMenuSeen do
        progressFill.BackgroundColor3 = THEME.Accent
        accentTop.BackgroundColor3 = THEME.Accent
        autoText.Text = "automatic script detection"
        autoText.TextColor3 = THEME.DimText

        setStatus(route.name, "Script found")
        setProgress(0.42)
        task.wait(0.18)

        setStatus(route.name, "Connecting...")
        setProgress(0.52)

        local embedded = EMBEDDED_SOURCES[route.source]
        local downloadOk, source
        if type(embedded) == "string" and #embedded > 0 then
            downloadOk, source = true, embedded
            setStatus(route.name, "Offline embedded script")
        else
            downloadOk, source = fetchSource(route.url)
            if not downloadOk then
                fail("Download Failed", source)
                return
            end
        end

        setStatus(route.name, "Downloading...")
        setProgress(0.68)
        task.wait(0.20)

        if #source < 20 then
            fail("Invalid Script", "Script source returned an unexpectedly small file")
            return
        end

        setStatus(route.name, "Preparing...")
        setProgress(0.78)
        task.wait(0.15)

        local compiler = loadstring or load
        if type(compiler) ~= "function" then
            fail("Compiler Unavailable", "This environment does not provide loadstring/load")
            return
        end

        setStatus(route.name, "Compiling...")
        setProgress(0.88)

        local chunk, compileError = compiler(source)
        if not chunk then
            fail("Compile Failed", compileError)
            return
        end

        setStatus(route.name, "Waiting for menu...")
        setProgress(0.96)

        local runtimeFinished = false
        local runtimeOk = true
        local runtimeError

        task.spawn(function()
            runtimeOk, runtimeError = pcall(chunk)
            runtimeFinished = true
        end)

        local menuStarted = os.clock()
        while not cancelled and os.clock() - menuStarted < moduleMenuTimeout do
            if runtimeFinished and not runtimeOk then
                fail("Launch Failed", runtimeError)
                return
            end
            if hasModuleMenu() then
                moduleMenuSeen = true
                break
            end
            task.wait(0.05)
        end

        if moduleMenuSeen then break end
        if cancelled then return end

        fail("No Menu Detected",
            "Script exited but no menu appeared (wrong game / script version)")

        task.wait(0.70)
        route = showScriptMenu(placeId, universeId)
        if not route then
            fail("No Script Selected", "Manual script selection was closed")
            return
        end
    end

    if not route or not moduleMenuSeen then return end

    setProgress(1)
    progressFill.BackgroundColor3 = THEME.Success
    accentTop.BackgroundColor3 = THEME.Success
    autoText.Text = "ready"
    autoText.TextColor3 = THEME.Success
    setStatus(route.name, "Loaded successfully", THEME.BrightText)

    task.wait(0.75)

    local fade = tween(card, 0.18, {
        GroupTransparency = 1,
        Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT - 10),
    })
    tween(shadow, 0.18, {
        BackgroundTransparency = 1,
        Size = UDim2.fromOffset(WINDOW_WIDTH, WINDOW_HEIGHT - 10),
    })
    fade.Completed:Wait()

    pcall(function() gui:Destroy() end)
end)