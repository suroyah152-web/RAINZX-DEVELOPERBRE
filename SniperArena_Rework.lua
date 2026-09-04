-- == RAINZX DEV | Sniper Arena :: RAGE v5.0 ==
-- Rage Aimbot (engine PuckAFK-style) + ESP + Chams + WalkSpeed + Auto Fire
-- Teknik aimbot rage diambil dari source PuckAFK milik pengguna:
--   * Prediction (velocity lead) + lerp velocity smoothing
--   * Sticky target + grace lock + switch threshold
--   * FOV besar, closest-part / head aim, snap instan, ignore visibilitas
--   * mousemoverel (kalau ada) ATAU cam.CFrame lerp (fallback - PASTI JALAN)
-- Diadaptasi ke sistem EntityService Sniper Arena oleh RAINZX DEV.
-- Branding RAINZX DEV.

task.spawn(function()
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UIS = game:GetService("UserInputService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Camera = workspace.CurrentCamera
	local LocalPlayer = Players.LocalPlayer

	workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
		Camera = workspace.CurrentCamera
	end)

	-- =====================================================================
	-- CONFIG.AIM (mirip source PuckAFK yang diadaptasi)
	-- =====================================================================
	local Config = {
		Aim = {
			Enabled = true,
			HoldRMB = false,            -- true = wajib tahan RMB (Legit), false = aktif terus (Rage)
			VisibleCheck = false,        -- Rage Max: abaikan pengecekan visibilitas
			RespectGameVisibility = false,
			RespectSmoke = false,
			RespectFlash = false,
			HeadPriority = true,
			AimPoint = "Closest Part",   -- "Head" / "Upper Torso" / "Closest Part"

			AutoShoot = false,
			AutoShootRadius = 10,
			AutoShootDelay = 0.00,

			FOV = 180,                   -- dipakai buat FOV circle (mode legat/rage)
			SmoothSpeed = 120,           -- snap hampir instan buat rage
			MaxDistance = 700,
			StickyTarget = true,
			StickyMultiplier = 1.60,

			Prediction = true,
			PredictionTime = 0.10,
			PredictionSmoothing = 0.55,
			MaxPredictionOffset = 18,
			AdaptiveSmoothing = false,
			MicroSnapRadius = 8,
			TargetPriority = "Crosshair",
			SwitchDelay = 0,
			SwitchThreshold = 0.03,
			LockGrace = 0.12,

			ShowFOV = true,
		},
	}

	local mode = "Rage"  -- "Off" / "Legit" / "Rage"
	local function aimOn()
		return mode ~= "Off" and Config.Aim.Enabled
	end

	-- =====================================================================
	-- SERVICE LOOKUP (EntityService + ClientShootableComponent)
	-- =====================================================================
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

	-- =====================================================================
	-- HELPERS ALA SOURCE PUCKAFK (diadaptasi ke EntityService)
	-- =====================================================================
	local mouseAimSupported = type(mousemoverel) == "function"
	local mouserelSensitivity = 1
	local targetVelocityHistory = {}

	local function safeCall(fn, ...)
		local ok, res = pcall(fn, ...)
		if ok then return res end
		return nil
	end

	local function currentCamera()
		return Camera
	end

	local function screenCenter()
		if Camera then return Camera.ViewportSize * 0.5 end
		return Vector2.new()
	end

	local function worldToScreen(worldPos)
		if not Camera then return nil, false end
		local sp, on = Camera:WorldToViewportPoint(worldPos)
		if on and sp.Z > 0 then return Vector2.new(sp.X, sp.Y), true end
		return nil, false
	end

	local function wrapAimAngle(a)
		while a > math.pi do a = a - (math.pi * 2) end
		while a < -math.pi do a = a + (math.pi * 2) end
		return a
	end

	local function mouseAimMoveConst()
		return Vector2.new(0.22, 0.22)
	end

	local function getAimMouseSensitivity()
		return Vector2.new(1, 1)
	end

	local function getLocalEntity()
		if EntityService and EntityService.GetLocalEntity then
			return safeCall(EntityService.GetLocalEntity, EntityService)
		end
		return nil
	end

	local localEntityModel = nil
	local function refreshLocalEntity()
		local le = getLocalEntity()
		if le then
			local inst = le.Instance
			localEntityModel = (inst and inst:IsA("Player") and inst.Character) or inst
		end
	end

	local function localPlayerAlive()
		if LocalPlayer.Character then
			local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.Health > 0 then return true end
		end
		return false
	end

	local function combatRuntimeActive()
		return localPlayerAlive()
	end

	local function getEntityModel(entity)
		if typeof(entity) == "Instance" then
			if entity:IsA("Model") then return entity end
			return entity.Parent
		end
		local inst = entity.Instance
		return (inst and inst:IsA("Player") and inst.Character) or inst or (entity.Model)
	end

	local function getHeadPart(entity)
		local model = getEntityModel(entity)
		if model and model:IsA("Model") then
			local h = model:FindFirstChild("Head")
			if h and h:IsA("BasePart") then return h end
		end
		return nil
	end

	local function getRootPart(entity)
		local model = getEntityModel(entity)
		if model and model:IsA("Model") then
			local r = model:FindFirstChild("HumanoidRootPart")
			if r and r:IsA("BasePart") then return r end
		end
		return nil
	end

	local function isEnemy(entity)
		if EntityService and EntityService.IsLocalEntity then
			if safeCall(EntityService.IsLocalEntity, EntityService, entity) then return false end
		end
		if not entity then return false end
		if entity.IsAlive and not entity:IsAlive() then return false end
		local char = getEntityModel(entity)
		if not char then return false end
		local hum = char:FindFirstChildOfClass("Humanoid")
		if not hum or hum.Health <= 0 then return false end
		return true
	end

	local function iterateEnemies(fn)
		local le = getLocalEntity()
		if not le or not le.World or not le.World.EntitiesByTeam then return end
		local localTeamId = nil
		if EntityService and EntityService.GetTeamOfEntity then
			localTeamId = safeCall(EntityService.GetTeamOfEntity, EntityService, le)
		end
		for _, teamDict in pairs(le.World.EntitiesByTeam) do
			local items = teamDict._items or teamDict
			for _, ent in pairs(items) do
				if isEnemy(ent) then
					fn(ent)
				end
			end
		end
	end

	local function gameSaysVisible(entity)
		if not Config.Aim.RespectGameVisibility then return true end
		return true
	end

	local function blockedByEffects(pos)
		if not Config.Aim.RespectSmoke and not Config.Aim.RespectFlash then return false end
		return false
	end

	local function hasLineOfSight(entity, worldPos)
		-- cek raycast dari camera ke target
		if not Camera then return true end
		local origin = Camera.CFrame.Position
		local dir = (worldPos - origin)
		local rayUnit = dir.Unit
		local dist = dir.Magnitude
		local params = RaycastParams.new()
		params.FilterType = Enum.RaycastFilterType.Exclude
		local char = LocalPlayer.Character
		local filter = {}
		if char then table.insert(filter, char) end
		local tchar = getEntityModel(entity)
		if tchar then table.insert(filter, tchar) end
		params.FilterDescendantsInstances = filter
		local hit = workspace:Raycast(origin, rayUnit * dist, params)
		if hit then return false end
		return true
	end

	local function getHealth(entity)
		local char = getEntityModel(entity)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if hum then return hum.Health, hum.MaxHealth end
		return 100, 100
	end

	local function nativeRMBHeld()
		if UIS.MouseBehavior == Enum.MouseBehavior.LockCenter then return true end
		return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	end

	local function autoShootButtonHeld()
		if Config.Aim.AutoShootButton == "RMB" then return nativeRMBHeld() end
		return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
	end

	-- =====================================================================
	-- getAimPosition — pilih bagian tubuh yang di-aim
	-- =====================================================================
	local function getAimPosition(entity)
		local model = getEntityModel(entity)
		local aimPoint = tostring(Config.Aim.AimPoint or "Head")

		local function validPart(part)
			return typeof(part) == "Instance"
				and part:IsA("BasePart")
				and part.Parent ~= nil
		end

		local head = getHeadPart(entity)
		local root = getRootPart(entity)
		local torso = nil

		if model and model:IsA("Model") then
			torso = model:FindFirstChild("UpperTorso")
				or model:FindFirstChild("Torso")
				or model:FindFirstChild("LowerTorso")
				or root
		else
			torso = root
		end

		if aimPoint == "Upper Torso" then
			if validPart(torso) then return torso.Position, torso end
			if validPart(head) then return head.Position, head end
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

			if bestPart then return bestPart.Position, bestPart end
		else
			if validPart(head) then return head.Position, head end
		end

		if validPart(root) then return root.Position, root end

		if model and model:IsA("Model") then
			local pivot = safeCall(function() return model:GetPivot() end)
			if typeof(pivot) == "CFrame" then return pivot.Position, model.PrimaryPart end
			local pv = model.PrimaryPart
			if pv and pv:IsA("BasePart") then return pv.Position, pv end
		end

		return nil, nil
	end

	-- =====================================================================
	-- getTargetVelocity — velocity difilter buat prediksi
	-- =====================================================================
	local function getTargetVelocity(entity, aimPart)
		local rawVelocity = nil

		if typeof(entity) ~= "Instance" then
			rawVelocity = safeCall(function()
				if entity.GetVelocity then return entity:GetVelocity() end
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

	-- =====================================================================
	-- getPredictedAimPosition — velocity lead
	-- =====================================================================
	local function getPredictedAimPosition(entity, position, part)
		if not Config.Aim.Prediction then return position end

		local lead = math.clamp(tonumber(Config.Aim.PredictionTime) or 0, 0, 0.30)
		if lead <= 0 then return position end

		local velocity = getTargetVelocity(entity, part)

		local verticalScale = math.abs(velocity.Y) >= 8 and 0.10 or 0.30
		local offset = Vector3.new(
			velocity.X * lead,
			velocity.Y * lead * verticalScale,
			velocity.Z * lead
		)

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

	-- =====================================================================
	-- targetInfo — scoring & validasi per entity
	-- =====================================================================
	local function targetInfo(entity, fovMultiplier)
		if not isEnemy(entity) then return nil end

		local rawPosition, part = getAimPosition(entity)
		if not rawPosition then return nil end

		local cam = currentCamera()
		if not cam then return nil end

		local selectionPosition = rawPosition
		local selectionRoot = getRootPart(entity)
		if typeof(selectionRoot) == "Instance" and selectionRoot:IsA("BasePart") and selectionRoot.Parent ~= nil then
			selectionPosition = selectionRoot.Position
		end

		local distance = (selectionPosition - cam.CFrame.Position).Magnitude
		if distance > Config.Aim.MaxDistance then return nil end

		if not gameSaysVisible(entity) then return nil end
		if blockedByEffects(rawPosition) then return nil end

		local visible = hasLineOfSight(entity, rawPosition)
		if Config.Aim.VisibleCheck and not visible then return nil end

		local rawScreenPos, rawOnScreen = worldToScreen(selectionPosition)
		if not rawOnScreen then return nil end

		local rawScreenDistance = (rawScreenPos - screenCenter()).Magnitude
		local maxFov = Config.Aim.FOV * (fovMultiplier or 1)

		if rawScreenDistance > maxFov then return nil end

		local position = getPredictedAimPosition(entity, rawPosition, part)
		local predictedScreenPos, predictedOnScreen = worldToScreen(position)
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
			if visible then score = score * 0.92 end
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

	-- =====================================================================
	-- keepLockedTargetThroughGrace + acquireTarget (sticky lock)
	-- =====================================================================
	local lockedTarget = nil
	local lockedTargetLastInfo = nil
	local lockedTargetLastValidAt = 0
	local lastTargetChangeAt = 0

	local function keepLockedTargetThroughGrace()
		if not lockedTarget or not lockedTargetLastInfo then return nil end
		local grace = math.max(tonumber(Config.Aim.LockGrace) or 0, 0)
		if grace <= 0 or (os.clock() - lockedTargetLastValidAt) > grace then return nil end
		if not isEnemy(lockedTarget) then return nil end

		local rawPosition, part = getAimPosition(lockedTarget)
		if rawPosition then
			local info = lockedTargetLastInfo
			info.RawPosition = rawPosition
			info.Part = part
			info.Position = getPredictedAimPosition(lockedTarget, rawPosition, part)
			info.Velocity = getTargetVelocity(lockedTarget, part)
			local screenPos, onScreen = worldToScreen(info.Position)
			if onScreen then info.ScreenDistance = (screenPos - screenCenter()).Magnitude end
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

		if currentInfo then
			if not best then return currentInfo end
			local threshold = math.clamp(tonumber(Config.Aim.SwitchThreshold) or 0.12, 0, 0.90)
			local requiredScore = currentInfo.Score * (1 - threshold)
			local delay = math.max(tonumber(Config.Aim.SwitchDelay) or 0, 0)
			local delayPassed = (os.clock() - lastTargetChangeAt) >= delay
			if not delayPassed or best.Score >= requiredScore then return currentInfo end
		end

		if best then
			if lockedTarget ~= best.Entity then lastTargetChangeAt = os.clock() end
			lockedTarget = best.Entity
			lockedTargetLastInfo = best
			lockedTargetLastValidAt = os.clock()
			return best
		end

		lockedTarget = nil
		lockedTargetLastInfo = nil
		return nil
	end

	-- =====================================================================
	-- moveAimWithMouse (mousemoverel) — native, paling ampuh anti-deteksi
	-- =====================================================================
	local function moveAimWithMouse(cam, targetPosition, dt, responseSpeed, snap)
		if not mouseAimSupported or not cam or not targetPosition then return false end

		local offset = targetPosition - cam.CFrame.Position
		if offset.Magnitude <= 0.001 then return true end

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
		local denominator = mouseAimMoveConst() * sensitivity

		local delta = Vector2.new(
			diffYaw / math.max(math.abs(denominator.X), 0.000001),
			diffPitch / math.max(math.abs(denominator.Y), 0.000001)
		)

		local response = 1 - math.exp(-(math.max(responseSpeed, 0.01) * 0.68) * math.max(dt, 0))
		if snap then response = 1 end

		delta = delta * math.clamp(response, 0, 1)
		delta = Vector2.new(
			math.clamp(delta.X, -450, 450),
			math.clamp(delta.Y, -450, 450)
		)

		local ok = pcall(mousemoverel, delta.X, delta.Y)
		return ok
	end

	-- =====================================================================
	-- aimActive + applyAim (inti render loop)
	-- =====================================================================
	local function aimActive()
		if not aimOn() then return false end
		if not combatRuntimeActive() then lockedTarget = nil; return false end
		refreshLocalEntity()
		if not localPlayerAlive() then return false end
		if not Config.Aim.HoldRMB then return true end
		return nativeRMBHeld()
	end

	local lastAutoShootAt = 0
	local function autoShootActive()
		return Config.Aim.AutoShoot
	end

	local function tryAutoShoot(info)
		if not info then return end
		if (os.clock() - lastAutoShootAt) < Config.Aim.AutoShootDelay then return end
		local radius = math.max(tonumber(Config.Aim.AutoShootRadius) or 10, 0)
		if info.ScreenDistance > radius then return end
		pcall(function() mouse1click() end)
		lastAutoShootAt = os.clock()
	end

	local function applyAim(dt)
		local shouldAim = aimActive()
		local shouldAutoShoot = autoShootActive()

		if not shouldAim and not shouldAutoShoot then
			if not combatRuntimeActive() or not localPlayerAlive() then
				lockedTarget = nil
				lockedTargetLastInfo = nil
			end
			return
		end

		local info = acquireTarget()
		if not info then return end

		lockedTarget = info.Entity
		local cam = currentCamera()
		if not cam then return end

		if shouldAim then
			local current = cam.CFrame
			local speed = math.max(tonumber(Config.Aim.SmoothSpeed) or 0.01, 0.01)

			if Config.Aim.AdaptiveSmoothing then
				local normalized = math.clamp(info.ScreenDistance / math.max(Config.Aim.FOV, 1), 0, 1)
				local multiplier = 0.55 + (math.sqrt(normalized) * 1.45)
				speed = speed * multiplier
			end

			local snapRadius = math.max(tonumber(Config.Aim.MicroSnapRadius) or 0, 0)
			local shouldSnap = snapRadius > 0 and info.ScreenDistance <= snapRadius

			local usedMouseAim = moveAimWithMouse(cam, info.Position, dt, speed, shouldSnap)

			if not usedMouseAim then
				local desired = CFrame.lookAt(current.Position, info.Position)
				local alpha = 1 - math.exp(-speed * math.max(dt, 0))
				if shouldSnap then alpha = 1 end
				cam.CFrame = current:Lerp(desired, math.clamp(alpha, 0, 1))
			end
		end

		if shouldAutoShoot then tryAutoShoot(info) end
	end

	-- applyAimPreset: tombol preset rage (dari source PuckAFK yang diadaptasi)
	local applyAimPreset
	applyAimPreset = function(name, overrides, desc)
		-- adapt: terapkan override ke Config.Aim
		for k, v in pairs(overrides) do
			Config.Aim[k] = v
		end
		mode = name:match("Rage") and "Rage" or "Legit"
		return true
	end

	local PRESETS = {
		{ name = "Rage • Visible", desc = "Aktif terus • FOV 500 • cepat • cuma yang kelihatan", data = {
			Enabled = true, HoldRMB = false, VisibleCheck = true, RespectGameVisibility = true,
			RespectSmoke = false, RespectFlash = false, HeadPriority = true, AimPoint = "Head",
			Prediction = true, PredictionTime = 0.08, PredictionSmoothing = 0.62, MaxPredictionOffset = 16,
			SwitchThreshold = 0.07, LockGrace = 0.14, AdaptiveSmoothing = false, MicroSnapRadius = 4,
			TargetPriority = "Crosshair", SwitchDelay = 0, FOV = 500, SmoothSpeed = 92, MaxDistance = 700,
			StickyTarget = true, StickyMultiplier = 1.45, ShowFOV = true,
		}},
		{ name = "Rage • Max", desc = "Aktif terus • FOV maks • respons instan • abaikan semua", data = {
			Enabled = true, HoldRMB = false, VisibleCheck = false, RespectGameVisibility = false,
			RespectSmoke = false, RespectFlash = false, HeadPriority = true, AimPoint = "Closest Part",
			Prediction = true, PredictionTime = 0.10, PredictionSmoothing = 0.55, MaxPredictionOffset = 18,
			SwitchThreshold = 0.03, LockGrace = 0.12, AdaptiveSmoothing = false, MicroSnapRadius = 8,
			TargetPriority = "Crosshair", SwitchDelay = 0, FOV = 600, SmoothSpeed = 120, MaxDistance = 700,
			StickyTarget = true, StickyMultiplier = 1.60, ShowFOV = true,
		}},
	}

	-- =====================================================================
	-- FOV CIRCLE
	-- =====================================================================
	local FOVCircle = Drawing.new("Circle")
	FOVCircle.Thickness = 1
	FOVCircle.Transparency = 0.7
	FOVCircle.Color = Color3.fromRGB(255, 255, 255)
	FOVCircle.NumSides = 64
	FOVCircle.Visible = false

	local function updateFOV()
		FOVCircle.Position = UIS:GetMouseLocation()
		FOVCircle.Radius = Config.Aim.FOV
		FOVCircle.Visible = Config.Aim.ShowFOV and aimOn()
	end

	-- =====================================================================
	-- ESP ENGINE
	-- =====================================================================
	local espEnabled = false
	local espBox = true
	local espHealth = true
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
		local top = worldToScreen(root.Position + Vector3.new(0, 5, 0))
		local bottom = worldToScreen(root.Position - Vector3.new(0, 5, 0))
		if not top or not bottom then return end
		local height = (top - bottom).Magnitude
		local width = height * 0.6
		local e = espFor(char)
		local cx, cy = top.X, top.Y
		if espBox then
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
		e.health.Visible = espHealth
		if e.health.Visible then
			e.health.From = Vector2.new(cx - width/2 - 4, cy + height)
			e.health.To = Vector2.new(cx - width/2 - 4, cy + height - (height * hf))
			e.health.Color = Color3.fromRGB(math.clamp((1 - hf) * 255, 0, 255), math.clamp(hf * 255, 0, 255), 0)
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

	-- =====================================================================
	-- CHAMS
	-- =====================================================================
	local chamsEnabled = false
	local highlights = {}
	local function applyChams()
		if not chamsEnabled then
			for char, hl in pairs(highlights) do
				pcall(function() hl:Destroy() end)
			end
			highlights = {}
		end
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= LocalPlayer and plr.Character then
				local char = plr.Character
				if chamsEnabled and not highlights[char] then
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
		while task.wait(0.5) do applyChams() end
	end)

	-- =====================================================================
	-- RENDER BIND (jalur utama)
	-- =====================================================================
	RunService:BindToRenderStep("RainzxSniperAim", Enum.RenderPriority.Camera.Value + 25, function(dt)
		applyAim(dt)
		updateFOV()
		if espEnabled then
			for char in pairs(espObjs) do
				if not char.Parent then clearAllESP(); break end
			end
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= LocalPlayer and plr.Character then
					renderESP(plr.Character, plr.Name)
				end
			end
		else
			hideAllESP()
		end
	end)

	-- =====================================================================
	-- UI (RAINZX DEV)
	-- =====================================================================
	local gui = Instance.new("ScreenGui")
	gui.Name = "RainzxDevSniper"
	pcall(function() gui.Parent = game:GetService("CoreGui") end)
	if not gui.Parent then gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 260, 0, 470)
	frame.Position = UDim2.new(0.5, -130, 0.5, -220)
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
		local f = section(parent, y, 24)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = Color3.fromRGB(55, 55, 60)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = label
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 13
		btn.Parent = f
		local function refresh()
			btn.Text = label .. ": " .. (getter() and "ON" or "OFF")
			btn.BackgroundColor3 = getter() and Color3.fromRGB(0, 150, 70) or Color3.fromRGB(55, 55, 60)
		end
		btn.MouseButton1Click:Connect(function()
			setter(not getter())
			refresh()
		end)
		refresh()
	end

	local function actionButton(parent, y, label, fn, color)
		local f = section(parent, y, 24)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = color or Color3.fromRGB(70, 70, 75)
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.Text = label
		btn.Font = Enum.Font.SourceSans
		btn.TextSize = 13
		btn.Parent = f
		btn.MouseButton1Click:Connect(fn)
	end

	local function numeric(parent, y, label, key)
		local f = section(parent, y, 24)
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
		box.Text = tostring(Config.Aim[key])
		box.Font = Enum.Font.SourceSans
		box.TextSize = 13
		box.Parent = f
		box.FocusLost:Connect(function()
			local v = tonumber(box.Text)
			if v then Config.Aim[key] = v end
		end)
	end

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Text = "RAINZX DEV | Sniper Arena RAGE"
	title.Font = Enum.Font.SourceSansBold
	title.TextSize = 15
	title.Parent = frame

	local statusTxt = Instance.new("TextLabel")
	statusTxt.Size = UDim2.new(1, -20, 0, 16)
	statusTxt.Position = UDim2.new(0, 10, 0, 32)
	statusTxt.BackgroundTransparency = 1
	statusTxt.TextColor3 = Color3.fromRGB(130, 200, 255)
	statusTxt.Text = ("Aim Engine: "
		.. (mouseAimSupported and "mousemoverel (native)" or "cam.CFrame lock (fallback)"))
	statusTxt.Font = Enum.Font.SourceSans
	statusTxt.TextSize = 11
	statusTxt.TextXAlignment = Enum.TextXAlignment.Left
	statusTxt.Parent = frame

	local y = 52
	actionButton(frame, y, "PRESET: Rage • Max", function()
		local p = PRESETS[2]
		applyAimPreset(p.name, p.data, p.desc)
		statusTxt.Text = "Preset: " .. p.name .. " — " .. p.desc
	end, Color3.fromRGB(150, 40, 40)); y = y + 28
	actionButton(frame, y, "PRESET: Rage • Visible", function()
		local p = PRESETS[1]
		applyAimPreset(p.name, p.data, p.desc)
		statusTxt.Text = "Preset: " .. p.name .. " — " .. p.desc
	end, Color3.fromRGB(150, 70, 40)); y = y + 28

	toggleButton(frame, y, "Aim Active", function() return aimOn() end, function(v)
		if v then mode = "Rage" else mode = "Off" end
		Config.Aim.Enabled = true
	end); y = y + 28

	toggleButton(frame, y, "Hold RMB", function() return Config.Aim.HoldRMB end, function(v) Config.Aim.HoldRMB = v end); y = y + 28
	toggleButton(frame, y, "Visible Check", function() return Config.Aim.VisibleCheck end, function(v) Config.Aim.VisibleCheck = v end); y = y + 28
	toggleButton(frame, y, "Prediction", function() return Config.Aim.Prediction end, function(v) Config.Aim.Prediction = v end); y = y + 28
	toggleButton(frame, y, "Auto Shoot", function() return Config.Aim.AutoShoot end, function(v) Config.Aim.AutoShoot = v end); y = y + 28
	numeric(frame, y, "FOV", "FOV"); y = y + 28
	numeric(frame, y, "Smooth", "SmoothSpeed"); y = y + 28
	toggleButton(frame, y, "ESP", function() return espEnabled end, function(v)
		espEnabled = v
		if not v then hideAllESP() end
	end); y = y + 24
	toggleButton(frame, y, "ESP Box", function() return espBox end, function(v) espBox = v end); y = y + 24
	toggleButton(frame, y, "ESP Health", function() return espHealth end, function(v) espHealth = v end); y = y + 24
	toggleButton(frame, y, "Chams", function() return chamsEnabled end, function(v) chamsEnabled = v end); y = y + 24

	y = y + 2
	local close = Instance.new("TextButton")
	close.Size = UDim2.new(1, -20, 0, 24)
	close.Position = UDim2.new(0, 10, 0, y)
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

	print("RAINZX DEV | Sniper Arena RAGE v5.0 loaded.")
end)
