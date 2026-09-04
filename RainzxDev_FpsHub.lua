--[[
    RAINZX DEV | Universal FPS Hub
    Works across FPS games: Blox Strike, Rivals, Sniper Arena, and more.
    Aimbot (Off/Legit/Rage) + ESP + Chams + Anti-AFK + Auto Fire.
    Camera-rotate based (no hookfunction needed) - works on most executors.
    Rebuilt by RAINZX DEV.
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
