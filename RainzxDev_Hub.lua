--[[
    RAINZX DEV Hub - Universal Loader (Final, single-file)
    Rework by RAINZX DEV.
    - Universal anti-AFK
    - Auto game detection (universe + PlaceId)
    - Manual script picker fallback
    - Sniper Arena uses local SniperArena_Rework.lua first, then online fallback

    NOTE: URL di tabel ROUTES adalah alamat server eksternal (host script).
    Itu BUKAN branding dan tidak diganti — biar fetch game lain tetap jalan.
    Semua tampilan/nama/menu memakai RAINZX DEV.
]]

local ENV = (getgenv and getgenv()) or _G

ENV.__RAINZX_CONFIG_SHARED_STATE = ENV.__RAINZX_CONFIG_SHARED_STATE or {
    Root = "RAINZXDEV/Configs",
    AutoSaveDefault = true,
    AutoLoadDefault = true,
}

ENV.__RAINZX_UI_SHARED_STATE = ENV.__RAINZX_UI_SHARED_STATE or {
    ToggleKeyName = "K",
    LayoutMode = "Auto",
    UIScalePercent = 100,
}

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")

-- Fallback online source for Sniper Arena if no local file. Swap for your host.
local SNIPER_ARENA_URL = "https://raw.githubusercontent.com/PuckAFK/Sniper-Arena/main/Sniper%20Arena.lua"
local SNIPER_LOCAL_FILE = "SniperArena_Rework.lua"

-- =========================
-- Universal Anti-AFK
-- =========================
local GLOBAL_ENV = (function()
    if type(getgenv) == "function" then
        local ok, env = pcall(getgenv)
        if ok and type(env) == "table" then return env end
    end
    return _G
end)()

local ANTI_AFK_KEY = "__RAINZX_LOADER_ANTI_AFK"

local function enableAntiAFK()
    local old = GLOBAL_ENV[ANTI_AFK_KEY]
    if type(old) == "table" and old.Connection then
        pcall(function() old.Connection:Disconnect() end)
    end

    local player = Players.LocalPlayer or Players.PlayerAdded:Wait()
    local conn = player.Idled:Connect(function()
        pcall(function() VirtualUser:CaptureController() end)
        pcall(function() VirtualUser:ClickButton2(Vector2.new(0, 0)) end)
        pcall(function()
            local cam = workspace.CurrentCamera
            local cf = cam and cam.CFrame or CFrame.new()
            VirtualUser:Button2Down(Vector2.new(0, 0), cf)
            task.wait(0.05)
            VirtualUser:Button2Up(Vector2.new(0, 0), cf)
        end)
    end)

    GLOBAL_ENV[ANTI_AFK_KEY] = { Connection = conn, Enabled = true }
end

enableAntiAFK()

-- =========================
-- Routing: game -> script
-- =========================
local SNIPER = {
    name = "Sniper Arena",
    localFile = SNIPER_LOCAL_FILE,
    url = SNIPER_ARENA_URL,
}

local UNIVERSE_ROUTES = {
    [9534705677] = SNIPER,
}

local ROUTES = {
    [90568084448279] = { name = "One Tap", url = "https://raw.githubusercontent.com/PuckAFK/One-Tap/main/onetap.lua" },
    [89469502395769] = { name = "Kick a Lucky Block", url = "https://raw.githubusercontent.com/PuckAFK/Kick-a-Lucky-Block/main/Kick%20a%20Lucky%20Block.lua" },
    [83038462357724] = { name = "Dig & Clean", url = "https://raw.githubusercontent.com/PuckAFK/Dig-Clean-/main/Dig%20%26%20Clean.lua" },
    [134162299584012] = { name = "Build a Gun Army", url = "https://puckafk.site/scripts/build-a-gun-army/autofarm.lua" },
    [142823291]        = { name = "Murder Mystery 2", url = "https://puckafk.site/scripts/murder-mystery-2/mm2.lua" },
    [74889851913797]   = { name = "+1 Power Per Click", url = "https://raw.githubusercontent.com/PuckAFK/-1-Power-Per-Click/main/%2B1%20Power%20Per%20Click.lua" },
    [133188236593503]  = { name = "Magic Loot", url = "https://raw.githubusercontent.com/PuckAFK/Magic-Loot/main/Magic%20Loot.lua" },
    [128481067661991]  = { name = "Get Rich ASAP", url = "https://raw.githubusercontent.com/PuckAFK/Get-rich-asap/main/Get%20Rich%20Asap%20Script" },
    [137233438285284]  = { name = "Chicken Farm", url = "https://raw.githubusercontent.com/PuckAFK/Chicken-Farm-Auto/main/Chicken%20Empire" },
    [131558436575033]  = { name = "SevenM Hood", url = "https://raw.githubusercontent.com/PuckAFK/SevenM-Hood/main/aim.lua" },
    [114697347887839]  = { name = "+1 Speed Monkey Escape", url = "https://raw.githubusercontent.com/PuckAFK/1-Speed-Monkey-Escape/main/1%20Speed%20Monkey%20Escape.lua" },
    [122446657157717]  = SNIPER,
    [119259569670784]  = SNIPER,
}

local THEME = {
    Main = Color3.fromRGB(12, 12, 12),
    Section = Color3.fromRGB(18, 18, 18),
    Element = Color3.fromRGB(24, 24, 24),
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
-- Source resolution
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

-- Local-first resolution, online fallback.
local function resolveSource(route)
    if route.localFile and type(readfile) == "function" then
        local ok, src = pcall(readfile, route.localFile)
        if ok and type(src) == "string" and #src > 0 then
            return true, src, "(local)"
        end
    end
    if route.url and #route.url > 0 then
        local okS, body = fetchSource(route.url)
        if okS then return true, body, "(online)" end
        return false, body
    end
    return false, "No local file or URL for this route"
end

-- =========================
-- Manual picker
-- =========================
local manualRoutes = {
    SNIPER,
    ROUTES[90568084448279], ROUTES[89469502395769], ROUTES[83038462357724],
    ROUTES[134162299584012], ROUTES[142823291], ROUTES[74889851913797],
    ROUTES[133188236593503], ROUTES[128481067661991], ROUTES[137233438285284],
    ROUTES[131558436575033], ROUTES[114697347887839],
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

    setStatus(route.name, "Resolving source...")
    setProgress(0.5)

    local okSrc, source, sourceTag = resolveSource(route)
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

    setStatus(route.name, "Compiling... " .. (sourceTag or ""))
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
