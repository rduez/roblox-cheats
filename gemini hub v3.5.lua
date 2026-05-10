--------------------------------------------------------
-- GEMINI HUB // V3.5.2 (FUTURISTIC + NOCLIP FIX)
--------------------------------------------------------

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flyEnabled = false
local noclipEnabled = false
local aimbotEnabled = false
local aiming = false

local AIM_FOV = 150
local AIM_SMOOTHNESS = 0.18
local FLY_SPEED = 70

local bv, bg
local flyControls = {W = false, S = false, A = false, D = false}

--------------------------------------------------------
-- DESIGN UI V3.5.2
--------------------------------------------------------

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "GeminiHub_V3_5_2"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 310)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
frame.BackgroundTransparency = 0.15
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 230)
stroke.Thickness = 1.2
stroke.Transparency = 0.4

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "GEMINI HUB // V3.5.2"; title.Font = Enum.Font.GothamBold; title.TextSize = 13; title.TextColor3 = Color3.fromRGB(0, 255, 230); title.BackgroundTransparency = 1

-- Drag Logic
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = frame.Position end end)
UIS.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local holder = Instance.new("Frame", frame)
holder.Size = UDim2.new(1, -20, 1, -55); holder.Position = UDim2.new(0, 10, 0, 45); holder.BackgroundTransparency = 1
Instance.new("UIListLayout", holder).Padding = UDim.new(0, 8)

local FOV = Instance.new("Frame", gui)
FOV.Size = UDim2.fromOffset(AIM_FOV * 2, AIM_FOV * 2); FOV.AnchorPoint = Vector2.new(0.5, 0.5); FOV.BackgroundTransparency = 1; FOV.Visible = false
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1, 0); Instance.new("UIStroke", FOV).Color = Color3.fromRGB(0, 255, 230)

--------------------------------------------------------
-- FUNCTIONS & TOGGLES
--------------------------------------------------------

local function makeBtn(txt)
	local b = Instance.new("TextButton", holder)
	b.Size = UDim2.new(1, 0, 0, 35); b.BackgroundColor3 = Color3.fromRGB(20, 20, 25); b.Text = txt; b.TextColor3 = Color3.fromRGB(200, 200, 200); b.Font = Enum.Font.GothamMedium; b.TextSize = 11
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	local ind = Instance.new("Frame", b); ind.Size = UDim2.new(0, 2, 0.6, 0); ind.Position = UDim2.new(0, 5, 0.2, 0); ind.BackgroundColor3 = Color3.fromRGB(100, 100, 100); ind.BorderSizePixel = 0
	return b, ind
end

local function updateState(btn, ind, state, baseText)
	TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 230) or Color3.fromRGB(100, 100, 100)}):Play()
	btn.Text = baseText .. " : " .. (state and "ON" or "OFF")
	btn.TextColor3 = state and Color3.new(1,1,1) or Color3.fromRGB(200,200,200)
end

local btnFly, indFly = makeBtn("FLY (F) : OFF")
local btnNoclip, indNoclip = makeBtn("NOCLIP (N) : OFF")
local btnAim, indAim = makeBtn("AIM & ESP (E) : OFF")
local btnTp = makeBtn("TP TO ENEMY (U)")

-- FLY LOGIC
local function toggleFly()
	flyEnabled = not flyEnabled
	updateState(btnFly, indFly, flyEnabled, "FLY (F)")
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if flyEnabled and hrp then
		if bv then bv:Destroy() end if bg then bg:Destroy() end
		bv = Instance.new("BodyVelocity", hrp); bv.MaxForce = Vector3.new(1e9, 1e9, 1e9); bv.Velocity = Vector3.new(0,0.1,0)
		bg = Instance.new("BodyGyro", hrp); bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9); bg.CFrame = camera.CFrame
	else if bv then bv:Destroy() end if bg then bg:Destroy() end end
end

-- NOCLIP LOGIC (FIXED)
local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	updateState(btnNoclip, indNoclip, noclipEnabled, "NOCLIP (N)")
	-- Si on désactive, on remet les collisions immédiatement
	if not noclipEnabled and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = true end
		end
	end
end

local function toggleAim()
	aimbotEnabled = not aimbotEnabled
	FOV.Visible = aimbotEnabled
	updateState(btnAim, indAim, aimbotEnabled, "AIM & ESP (E)")
end

local function tpToEnemy()
	local targets = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(targets, p.Character.HumanoidRootPart) end
	end
	if #targets > 0 then player.Character.HumanoidRootPart.CFrame = targets[math.random(1, #targets)].CFrame * CFrame.new(0, 0, 3) end
end

btnFly.MouseButton1Click:Connect(toggleFly)
btnNoclip.MouseButton1Click:Connect(toggleNoclip)
btnAim.MouseButton1Click:Connect(toggleAim)
btnTp.MouseButton1Click:Connect(tpToEnemy)

--------------------------------------------------------
-- ESP SYSTEM
--------------------------------------------------------
local ESP_Table = {}
local function createESP(plr)
	if plr == player then return end
	local box = Instance.new("Frame", gui); box.BackgroundTransparency = 1; box.Visible = false; box.AnchorPoint = Vector2.new(0.5, 0.5)
	Instance.new("UIStroke", box).Color = Color3.fromRGB(0, 255, 230)
	local hbBg = Instance.new("Frame", box); hbBg.Size = UDim2.new(0, 2, 1, 0); hbBg.Position = UDim2.new(0, -5, 0, 0); hbBg.BackgroundColor3 = Color3.new(0, 0, 0)
	local hbMain = Instance.new("Frame", hbBg); hbMain.Size = UDim2.new(1, 0, 1, 0); hbMain.BackgroundColor3 = Color3.fromRGB(0, 255, 100); hbMain.AnchorPoint = Vector2.new(0, 1); hbMain.Position = UDim2.new(0, 0, 1, 0)
	local nl = Instance.new("TextLabel", box); nl.Size = UDim2.new(1,0,0,15); nl.Position = UDim2.new(0,0,0,-18); nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.new(1,1,1); nl.Font = Enum.Font.GothamBold; nl.TextSize = 10
	ESP_Table[plr] = {Box = box, Bar = hbMain, NameTag = nl}
end
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

--------------------------------------------------------
-- MAIN ENGINE
--------------------------------------------------------

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.KeyCode == Enum.KeyCode.F then toggleFly() end
	if i.KeyCode == Enum.KeyCode.N then toggleNoclip() end
	if i.KeyCode == Enum.KeyCode.E then toggleAim() end
	if i.KeyCode == Enum.KeyCode.U then tpToEnemy() end
	if i.KeyCode == Enum.KeyCode.W then flyControls.W = true end
	if i.KeyCode == Enum.KeyCode.S then flyControls.S = true end
	if i.KeyCode == Enum.KeyCode.A then flyControls.A = true end
	if i.KeyCode == Enum.KeyCode.D then flyControls.D = true end
	if i.UserInputType == Enum.UserInputType.MouseButton2 then aiming = true end
end)

UIS.InputEnded:Connect(function(i)
	if i.KeyCode == Enum.KeyCode.W then flyControls.W = false end
	if i.KeyCode == Enum.KeyCode.S then flyControls.S = false end
	if i.KeyCode == Enum.KeyCode.A then flyControls.A = false end
	if i.KeyCode == Enum.KeyCode.D then flyControls.D = false end
	if i.UserInputType == Enum.UserInputType.MouseButton2 then aiming = false end
end)

RunService.RenderStepped:Connect(function()
	local char = player.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	local mPos = UIS:GetMouseLocation()
	FOV.Position = UDim2.fromOffset(mPos.X, mPos.Y)

	-- Noclip Loop
	if noclipEnabled and char then
		for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
	end

	-- Fly Loop
	if flyEnabled and bv and hrp then
		local mv = Vector3.zero
		if flyControls.W then mv += camera.CFrame.LookVector end
		if flyControls.S then mv -= camera.CFrame.LookVector end
		if flyControls.A then mv -= camera.CFrame.RightVector end
		if flyControls.D then mv += camera.CFrame.RightVector end
		bv.Velocity = mv.Magnitude > 0 and mv.Unit * FLY_SPEED or Vector3.new(0,0.1,0)
		bg.CFrame = camera.CFrame
	end

	-- ESP Update
	for plr, data in pairs(ESP_Table) do
		local eChar = plr.Character
		if eChar and eChar:FindFirstChild("HumanoidRootPart") and aimbotEnabled then
			local root = eChar.HumanoidRootPart
			local pos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen and eChar.Humanoid.Health > 0 then
				local dist = (camera.CFrame.Position - root.Position).Magnitude
				local scale = (1 / dist) * 1000
				data.Box.Visible = true; data.Box.Position = UDim2.fromOffset(pos.X, pos.Y); data.Box.Size = UDim2.fromOffset(2.2 * scale, 4.0 * scale)
				data.Bar.Size = UDim2.new(1, 0, eChar.Humanoid.Health / eChar.Humanoid.MaxHealth, 0); data.NameTag.Text = plr.Name
			else data.Box.Visible = false end
		else data.Box.Visible = false end
	end

	-- Aimbot Update
	if aimbotEnabled and aiming then
		local target = nil; local shortest = AIM_FOV
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
				local head = p.Character.Head
				local pos, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local d = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
					if d < shortest then shortest = d target = head end
				end
			end
		end
		if target then camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, target.Position), AIM_SMOOTHNESS) end
	end
end)