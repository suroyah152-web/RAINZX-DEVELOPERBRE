--[[
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
-- The repo name ends with a period ("RAINZX-DEV."); raw.githubusercontent requires
-- that trailing dot percent-encoded (%2E) or it returns 404. Fixed across all routes.
local RAW_ROOT = "https://raw.githubusercontent.com/suroyah152-web/RAINZX-DEV%2E/main/"

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
