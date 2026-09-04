-- == RAINZX DEV | Sniper Arena :: REBUILD v4.0 ==
-- Rage + Legit + ESP + Chams + WalkSpeed + Auto Fire
-- Hybrid aim:
--   * Silent aim  (via hookfunction/EntityService)  -- dipakai bila executor punya hook
--   * Aim lock    (putar kamera langsung, cam.CFrame = lookAt) -- FALLBACK, PASTI JALAN
--     di executor yang TIDAK punya hookfunction (mis. Real Project)
-- Dibongkar dari AnonmyHub | Sniper Arena oleh RAINZX DEV. Branding RAINZX DEV.

task.spawn(function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Camera = workspace.CurrentCamera
	local LP = Players.LocalPlayer

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Camera = workspace.CurrentCamera
	end)

	-- === Config ===
	local cfg = {
		mode = "Off",        -- "Off" / "Legit" / "Rage"
		aimMethod = "Auto",  -- "Auto": pakai silent aim kalau hook ada, selain itu putar kamera
		                     -- "Camera": paksa putar kamera (paling aman)
		headshot = true,
		fov = 180,
		rageFov = 500,
		rageHead = true,     -- false = closest part (max aggression)
		esp = false,
		espBox = true,
		espHealth = true,
		chams = false,
		speed = 16,
		autoFire = false,
		teamCheck = false,
	}

	local function isRage() return cfg.mode == "Rage" end
	local function isLegit() return cfg.mode == "Legit" end
	local function aimOn() return isRage() or isLegit() end

	-- Deteksi hookfunction
	local HAS_HOOK = (type(hookfunction) == "function") and (type(camlock) ~= "table" or true)
	local function useSilent()
		-- silent aim hanya kalau hook ada, mode bukan "Camera", dan servicenya ketemu
		return (cfg.aimMethod ~= "Camera") and HAS_HOOK
	end

	-- === Service lookup (EntityService + ClientShootableComponent) ===
	local EntityService, Shootable
	do
		local okE, ent = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Remote", 6):WaitForChild("EntityService", 6))
		end)
		local okS, sh = pcall(function()
			return require(ReplicatedStorage:WaitForChild("Client", 6)
				:WaitForChild("CombatController", 6)
				:WaitForChild("ClientComponent", 6)
				:WaitForChild("ClientShootableComponent", 6))
		end)
		EntityService = okE and ent or nil
		Shootable = okS and sh or nil
	end

	-- === FOV circle ===
	local FOVCircle = Drawing.new("Circle")
	FOVCircle.Thickness = 1
	FOVCircle.Transparency = 0.7
	FOVCircle.Color = Color3.fromRGB(255, 255, 255)
	FOVCircle.NumSides = 64
	FOVCircle.Visible = false

	-- === Helpers ===
	local function getTargetPart(char)
		if isRage() and not cfg.rageHead then
			return char:FindFirstChild("HumanoidRootPart")
		end
		local part = cfg.headshot and char:FindFirstChild("Head") or nil
		if part and part:IsA("BasePart") then return part end
		part = char:FindFirstChild("HumanoidRootPart")
		return (part and part:IsA("BasePart")) and part or nil
	end

	local function isEnemy(entity)
		if EntityService and EntityService.IsLocalEntity and EntityService.IsLocalEntity(entity) then return false end
		if not entity.IsAlive then return false end
		if not entity:IsAlive() then return false end
		local inst = entity.Instance
		local char = (inst and inst:IsA("Player") and inst.Character) or inst
		if not char then return false end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return false end
		if cfg.teamCheck and not isRage() and EntityService and EntityService.GetTeamOfEntity then
			local lt = EntityService.GetTeamOfEntity(EntityService.GetLocalEntity())
			local et = EntityService.GetTeamOfEntity(entity)
			if lt == et then return false end
		end
		return char
	end

	local function toScreen(worldPos)
		if not Camera then return nil end
		local sp, on = Camera:WorldToViewportPoint(worldPos)
		if not on then return nil end
		return Vector2.new(sp.X, sp.Y)
	end

	local function getCurrentTarget()
		if not (EntityService and EntityService.GetLocalEntity) then return nil end
		local localEntity = EntityService.GetLocalEntity()
		if not localEntity or not localEntity.World or not localEntity.World.EntitiesByTeam then return nil end
		local best, bestD = nil, math.huge
		local mx, my = UIS:GetMouseLocation().X, UIS:GetMouseLocation().Y
		local useFov = isRage() and cfg.rageFov or (isLegit() and cfg.fov or 0)
		if not aimOn() then return nil end
		for _, teamDict in pairs(localEntity.World.EntitiesByTeam) do
			local items = teamDict._items or teamDict
			for _, ent in pairs(items) do
				local char = isEnemy(ent)
				if char then
					local part = getTargetPart(char)
					if part then
						if isRage() and not cfg.rageHead then
							-- rage non-head: closest part, jarak 3D bukan FOV layar
							local d = (Camera.CFrame.Position - part.Position).Magnitude
							if d < bestD then
								best, bestD = { part = part, pos = part.Position }, d
							end
						else
							local sp = toScreen(part.Position)
							if sp then
								local d = (sp - Vector2.new(mx, my)).Magnitude
								if d <= useFov and d < bestD then
									best, bestD = { part = part, pos = part.Position }, d
								end
							end
						end
					end
				end
			end
		end
		return best
	end

	-- === Silent aim injection (hanya kalau hookfunction ada) ===
	local silentTarget = nil
	do
		local okHook = type(hookfunction) == "function" and type(debug) == "table" and debug.getupvalue
		local okSvc = Shootable and Shootable.LocalShoot
		if okHook and okSvc then
			local targetFn, originFn
			local origShoot = Shootable.LocalShoot
			for i = 1, 24 do
				local okv, v = pcall(debug.getupvalue, origShoot, i)
				if okv and type(v) == "function" then
					local okr, r1, r2, r3 = pcall(v)
					if okr then
						if typeof(r1) == "CFrame" and typeof(r3) == "table" then originFn = v end
						if typeof(r1) == "Vector3" and typeof(r2) == "Instance" then targetFn = v end
					end
				end
			end
			pcall(function()
				if originFn then
					local old; old = hookfunction(originFn, function(...)
						local cf, pos, meta = old(...)
						if useSilent() and aimOn() and silentTarget then
							return CFrame.lookAt(cf.Position, silentTarget.pos), pos, meta
						end
						return cf, pos, meta
					end)
				end
				if targetFn then
					local old; old = hookfunction(targetFn, function(...)
						if useSilent() and aimOn() and silentTarget then
							return silentTarget.pos, silentTarget.part
						end
						return old(...)
					end)
				end
				local oldShoot; oldShoot = hookfunction(origShoot, function(self, ...)
					if aimOn() and useSilent() then silentTarget = getCurrentTarget() end
					if type(oldShoot) == "function" then
						local res = oldShoot(self, ...)
						silentTarget = nil
						return res
					end
				end)
			end)
		end
	end

	-- === Camera aim lock (FALLBACK - dijamin jalan di executor tanpa hook) ===
	-- Putar kamera langsung ke target. Dipakai saat aimMethod == "Camera" ATAU
	-- saat silent aim tidak tersedia (executor tanpa hookfunction).
	local camLockActive = false
	RunService.RenderStepped:Connect(function(dt)
		-- FOV circle
		FOVCircle.Position = UIS:GetMouseLocation()
		FOVCircle.Radius = isRage() and cfg.rageFov or cfg.fov
		FOVCircle.Visible = aimOn()

		if not aimOn() then camLockActive = false return end

		-- Putar kamera bila: mode Camera dipilih, ATAU silent aim tidak dipakai
		local shouldCam = (cfg.aimMethod == "Camera") or (not useSilent())
		if not shouldCam then return end

		local t = getCurrentTarget()
		local char = LP.Character
		local origin = char and char:FindFirstChild("Head") or nil
		if not origin then origin = Camera.CFrame.Position end
		local from = (typeof(origin) == "CFrame") and origin.Position or origin

		if t then
			camLockActive = true
			pcall(function() Camera.CFrame = CFrame.lookAt(from, t.pos) end)
		elseif cfg.aimMethod == "Camera" then
			-- keep last lock when no camera-mode target changes camera
			camLockActive = false
		end
	end)

	-- === Auto fire ===
	local autoFireCd = 0
	task.spawn(function()
		while task.wait(0.05) do
			if cfg.autoFire and aimOn() and tick() >= autoFireCd then
				local t = getCurrentTarget()
				if t then
					pcall(function() mouse1click() end)
					autoFireCd = tick() + 0.12
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

	local function renderESP(char, playerName)
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
		e.name.Visible = true
		e.name.Position = Vector2.new(cx, cy - 16)
		e.name.Text = playerName
		local hf = hum.Health / hum.MaxHealth
		e.health.Visible = cfg.espHealth
		if e.health.Visible then
			e.health.From = Vector2.new(cx - width/2 - 4, cy + height)
			e.health.To = Vector2.new(cx - width/2 - 4, cy + height - (height * hf))
			e.health.Color = Color3.fromRGB(
				math.clamp((1 - hf) * 255, 0, 255),
				math.clamp(hf * 255, 0, 255),
				0
			)
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

	RunService.RenderStepped:Connect(function()
		if cfg.esp then
			for char in pairs(espObjs) do
				if not char.Parent then
					clearAllESP()
					break
				end
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LP and plr.Character then
					renderESP(plr.Character, plr.Name)
				end
			end
		else
			hideAllESP()
		end
	end)

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
			if plr ~= LP and plr.Character then
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
	task.spawn(function()
		while task.wait(0.5) do
			applyChams()
		end
	end)

	-- === UI ===
	local gui = Instance.new("ScreenGui")
	gui.Name = "RainzxDevSniper"
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent = LP:WaitForChild("PlayerGui") end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 418)
	frame.Position = UDim2.new(0.5, -130, 0.5, -195)
	frame.BackgroundColor3 = Color3.fromRGB(24, 24, 28)
	frame.BorderSizePixel = 0
	frame.Active = true
	frame.Draggable = true
	frame.Parent = gui

	local function section(parent, y, h)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -20, 0, h)
		f.Position = UDim2.new(0, 10, 0, y)
		f.BackgroundTransparency = 1
		f.Parent = parent
		return f
	end

	local function toggleButton(parent, y, label, getter, setter)
		local f = section(parent, y, 26)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = label
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 13
		btn.Parent = f
		local function refresh()
			local on = getter()
			btn.Text = label .. ": " .. (on and "ON" or "OFF")
			btn.BackgroundColor3 = on and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(55, 55, 60)
		end
		btn.MouseButton1Click:Connect(function()
			setter(not getter())
			refresh()
		end)
		refresh()
	end

	local function cycleButton(parent, y, label, options, getter, setter)
		local f = section(parent, y, 26)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = label
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 13
		btn.Parent = f
		local function refresh()
			local cur = getter()
			btn.Text = label .. ": " .. tostring(cur)
			btn.BackgroundColor3 = (cur == options[1]) and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(55, 55, 60)
		end
		btn.MouseButton1Click:Connect(function()
			local cur = getter()
			local idx = 0
			for i, o in ipairs(options) do if o == cur then idx = i break end end
			setter(options[(idx % #options) + 1])
			refresh()
		end)
		refresh()
	end

	local function numeric(parent, y, label, key)
		local f = section(parent, y, 26)
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(0.6, -5, 1, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
		lbl.Text = label
		lbl.Font = Enum.Font.SourceSans
		lbl.TextSize = 13
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = f
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(0.4, -5, 1, 0)
		box.Position = UDim2.new(0.6, 0, 0, 0)
		box.BackgroundColor3 = Color3.fromRGB(70, 70, 75)
		box.TextColor3 = Color3.fromRGB(255, 255, 255)
		box.Text = tostring(cfg[key])
		box.Font = Enum.Font.SourceSans
		box.TextSize = 13
		box.Parent = f
		box.FocusLost:Connect(function()
			local v = tonumber(box.Text)
			if v then
				cfg[key] = v
				if key == "speed" and LP.Character and LP.Character:FindFirstChild("Humanoid") then
					LP.Character.Humanoid.WalkSpeed = v
				end
			end
		end)
	end

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 32)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "RAINZX DEV | Sniper Arena"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 16
	title.Parent = frame

	-- Line 1: status aim method
	local statusTxt = Instance.new("TextLabel")
	statusTxt.Size = UDim2.new(1, -20, 0, 18)
	statusTxt.Position = UDim2.new(0, 10, 0, 34)
	statusTxt.BackgroundTransparency = 1
	statusTxt.TextColor3 = Color3.fromRGB(130, 200, 255)
	statusTxt.Text = (useSilent() and "Aim Engine: Silent Aim (hook)" or "Aim Engine: Camera Lock (fallback)")
	statusTxt.Font = Enum.Font.SourceSans
	statusTxt.TextSize = 12
	statusTxt.TextXAlignment = Enum.TextXAlignment.Left
	statusTxt.Parent = frame

	cycleButton(frame, 54, "Aim Mode", { "Off", "Legit", "Rage" },
		function() return cfg.mode end,
		function(v) cfg.mode = v end)
	cycleButton(frame, 84, "Engine", { "Auto", "Camera" },
		function() return cfg.aimMethod end,
		function(v) cfg.aimMethod = v end)
	toggleButton(frame, 114, "Auto Fire", function() return cfg.autoFire end, function(v) cfg.autoFire = v end)
	toggleButton(frame, 144, "Headshot", function() return cfg.headshot end, function(v) cfg.headshot = v end)
	numeric(frame, 174, "FOV", "fov")
	toggleButton(frame, 204, "ESP", function() return cfg.esp end, function(v)
		cfg.esp = v
		if not v then hideAllESP() end
	end)
	toggleButton(frame, 234, "ESP Box", function() return cfg.espBox end, function(v) cfg.espBox = v end)
	toggleButton(frame, 264, "ESP Health", function() return cfg.espHealth end, function(v) cfg.espHealth = v end)
	toggleButton(frame, 294, "Chams", function() return cfg.chams end, function(v) cfg.chams = v end)
	numeric(frame, 324, "WalkSpeed", "speed")

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(1, -20, 0, 26)
	close.Position = UDim2.new(0, 10, 0, 356)
	close.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
	close.TextColor3 = Color3.fromRGB(255, 255, 255)
	close.Text = "Tutup Script"
	close.Font = Enum.Font.SourceSans
	close.TextSize = 14
	close.Parent = frame
	close.MouseButton1Click:Connect(function()
		clearAllESP()
		for _, hl in pairs(highlights) do
			pcall(function() hl:Destroy() end)
		end
		highlights = {}
		pcall(function() FOVCircle:Remove() end)
		gui:Destroy()
	end)

	print("RAINZX DEV | Sniper Arena v4.0 loaded. Aim engine: " .. (useSilent() and "Silent Aim" or "Camera Lock"))
end)
