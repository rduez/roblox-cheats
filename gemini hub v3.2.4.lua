--------------------------------------------------------
-- GEMINI HUB V3.2.4 (STABLE + FLY RESPAWN FIX)
--------------------------------------------------------

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------------
-- CONFIG
--------------------------------------------------------

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
-- CORE FUNCTIONS
--------------------------------------------------------

local function tpToEnemy()
	local targets = {}
	for _, p in pairs(Players:GetPlayers()) do
		if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then 
			table.insert(targets, p.Character.HumanoidRootPart) 
		end
	end
	if #targets > 0 then
		local randomTarget = targets[math.random(1, #targets)]
		player.Character.HumanoidRootPart.CFrame = randomTarget.CFrame * CFrame.new(0, 0, 3)
	end
end

-- Fonction pour créer les forces de vol
local function setupFlyForce(hrpPart)
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	
	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = Vector3.new(0,0.1,0)
	bv.Parent = hrpPart
	
	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bg.CFrame = camera.CFrame
	bg.Parent = hrpPart
end

-- DETECTION DU RESPAWN
player.CharacterAdded:Connect(function(char)
	local hrp = char:WaitForChild("HumanoidRootPart", 5)
	if hrp and flyEnabled then
		task.wait(0.2) -- Petit délai pour laisser le moteur physique charger
		setupFlyForce(hrp)
	end
end)

--------------------------------------------------------
-- GUI & DRAG SYSTEM
--------------------------------------------------------

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "GeminiHub_V3_Stable"
gui.ResetOnSpawn = false

local FOV = Instance.new("Frame", gui)
FOV.Size = UDim2.fromOffset(AIM_FOV * 2, AIM_FOV * 2)
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.BackgroundTransparency = 1; FOV.Visible = false
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1, 0)
Instance.new("UIStroke", FOV).Color = Color3.fromRGB(0, 255, 200)

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 260, 0, 320)
frame.Position = UDim2.new(0, 60, 0, 10)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 10)
Instance.new("UIStroke", frame).Color = Color3.fromRGB(0, 255, 200)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40); title.Text = "GEMINI HUB V3.2.4"; title.Font = Enum.Font.GothamBold; title.TextColor3 = Color3.new(1,1,1); title.BackgroundTransparency = 1

-- Drag Logic
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = frame.Position
		input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)

--------------------------------------------------------
-- BOUTONS & ESP
--------------------------------------------------------

local holder = Instance.new("Frame", frame)
holder.Size = UDim2.new(1,0,1,-50); holder.Position = UDim2.new(0,0,0,45); holder.BackgroundTransparency = 1
Instance.new("UIListLayout", holder).HorizontalAlignment = Enum.HorizontalAlignment.Center

local function makeBtn(txt, callback)
	local b = Instance.new("TextButton", holder)
	b.Size = UDim2.new(0, 230, 0, 38); b.BackgroundColor3 = Color3.fromRGB(20, 20, 26); b.Text = txt; b.TextColor3 = Color3.new(1, 1, 1); b.Font = Enum.Font.GothamMedium
	Instance.new("UICorner", b)
	b.MouseButton1Click:Connect(function() callback(b) end)
	return b
end

makeBtn("FLY : OFF", function(b)
	flyEnabled = not flyEnabled
	b.Text = "FLY : " .. (flyEnabled and "ON" or "OFF")
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if flyEnabled and hrp then setupFlyForce(hrp) else if bv then bv:Destroy() end if bg then bg:Destroy() end end
end)

makeBtn("NOCLIP : OFF", function(b)
	noclipEnabled = not noclipEnabled
	b.Text = "NOCLIP : " .. (noclipEnabled and "ON" or "OFF")
	if not noclipEnabled and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do if part:IsA("BasePart") then part.CanCollide = true end end
	end
end)

makeBtn("AIM & ESP : OFF", function(b)
	aimbotEnabled = not aimbotEnabled
	b.Text = "AIM & ESP : " .. (aimbotEnabled and "ON" or "OFF")
	FOV.Visible = aimbotEnabled
end)

makeBtn("TP TO ENEMY (U)", function() tpToEnemy() end)

--------------------------------------------------------
-- ESP & MAIN LOOP
--------------------------------------------------------

local ESP_Table = {}
local function createESP(plr)
	if plr == player then return end
	local box = Instance.new("Frame", gui); box.BackgroundTransparency = 1; box.Visible = false; box.AnchorPoint = Vector2.new(0.5, 0.5)
	Instance.new("UIStroke", box).Color = Color3.fromRGB(0, 255, 200)
	local hbBg = Instance.new("Frame", box); hbBg.Size = UDim2.new(0, 2, 1, 0); hbBg.Position = UDim2.new(0, -5, 0, 0); hbBg.BackgroundColor3 = Color3.new(0, 0, 0)
	local hbMain = Instance.new("Frame", hbBg); hbMain.Size = UDim2.new(1, 0, 1, 0); hbMain.BackgroundColor3 = Color3.fromRGB(0, 255, 100); hbMain.AnchorPoint = Vector2.new(0, 1); hbMain.Position = UDim2.new(0, 0, 1, 0)
	local nl = Instance.new("TextLabel", box); nl.Size = UDim2.new(1,0,0,15); nl.Position = UDim2.new(0,0,0,-18); nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.new(1,1,1); nl.Font = Enum.Font.GothamBold; nl.TextSize = 10
	ESP_Table[plr] = {Box = box, Bar = hbMain, NameTag = nl}
end
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

UIS.InputBegan:Connect(function(i, g)
	if g then return end
	if i.UserInputType == Enum.UserInputType.MouseButton2 then aiming = true end
	if i.KeyCode == Enum.KeyCode.U then tpToEnemy() end
	if i.KeyCode == Enum.KeyCode.W then flyControls.W = true end
	if i.KeyCode == Enum.KeyCode.S then flyControls.S = true end
	if i.KeyCode == Enum.KeyCode.A then flyControls.A = true end
	if i.KeyCode == Enum.KeyCode.D then flyControls.D = true end
end)

UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton2 then aiming = false end
	if i.KeyCode == Enum.KeyCode.W then flyControls.W = false end
	if i.KeyCode == Enum.KeyCode.S then flyControls.S = false end
	if i.KeyCode == Enum.KeyCode.A then flyControls.A = false end
	if i.KeyCode == Enum.KeyCode.D then flyControls.D = false end
end)

RunService.RenderStepped:Connect(function()
	local curChar = player.Character
	local hrp = curChar and curChar:FindFirstChild("HumanoidRootPart")
	local mPos = UIS:GetMouseLocation()

	FOV.Position = UDim2.fromOffset(mPos.X, mPos.Y)

	if noclipEnabled and curChar then
		for _, p in ipairs(curChar:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
	end

	-- Mouvement du Fly
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
		local char = plr.Character
		if char and char:FindFirstChild("HumanoidRootPart") and char:FindFirstChild("Humanoid") and aimbotEnabled then
			local root = char.HumanoidRootPart
			local pos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen and char.Humanoid.Health > 0 then
				local dist = (camera.CFrame.Position - root.Position).Magnitude
				local scale = (1 / dist) * 1000
				data.Box.Visible = true; data.Box.Position = UDim2.fromOffset(pos.X, pos.Y); data.Box.Size = UDim2.fromOffset(2.5 * scale, 4.5 * scale)
				data.Bar.Size = UDim2.new(1, 0, char.Humanoid.Health / char.Humanoid.MaxHealth, 0)
				data.NameTag.Text = plr.Name
			else data.Box.Visible = false end
		else data.Box.Visible = false end
	end

	-- Aimbot
	if aimbotEnabled and aiming then
		local target = nil
		local shortest = AIM_FOV
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