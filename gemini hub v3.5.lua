--------------------------------------------------------
-- GEMINI HUB V3.5 (ULTRA-SLIM FUTURISTIC)
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
-- GUI DESIGN V3.5
--------------------------------------------------------

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "GeminiHub_V3_5"
gui.ResetOnSpawn = false

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 300)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(5, 5, 8)
frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0

local corner = Instance.new("UICorner", frame)
corner.CornerRadius = UDim.new(0, 6)

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 255, 230)
stroke.Thickness = 1.2
stroke.Transparency = 0.4

-- Title Bar Slim
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "GEMINI HUB // V3.5"
title.Font = Enum.Font.GothamBold
title.TextSize = 13
title.TextColor3 = Color3.fromRGB(0, 255, 230)
title.BackgroundTransparency = 1

local line = Instance.new("Frame", frame)
line.Size = UDim2.new(0.9, 0, 0, 1)
line.Position = UDim2.new(0.05, 0, 0, 35)
line.BackgroundColor3 = Color3.fromRGB(0, 255, 230)
line.BackgroundTransparency = 0.6
line.BorderSizePixel = 0

-- Drag System
local dragging, dragStart, startPos
title.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true; dragStart = input.Position; startPos = frame.Position
	end
end)
UIS.InputChanged:Connect(function(input)
	if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end
end)
UIS.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

-- FOV Circle
local FOV = Instance.new("Frame", gui)
FOV.Size = UDim2.fromOffset(AIM_FOV * 2, AIM_FOV * 2)
FOV.AnchorPoint = Vector2.new(0.5, 0.5)
FOV.BackgroundTransparency = 1; FOV.Visible = false
Instance.new("UICorner", FOV).CornerRadius = UDim.new(1, 0)
local fovStroke = Instance.new("UIStroke", FOV)
fovStroke.Color = Color3.fromRGB(0, 255, 230)
fovStroke.Thickness = 1
fovStroke.Transparency = 0.5

--------------------------------------------------------
-- BUTTON ENGINE (FUTURISTIC STYLE)
--------------------------------------------------------

local holder = Instance.new("Frame", frame)
holder.Size = UDim2.new(1, -20, 1, -50)
holder.Position = UDim2.new(0, 10, 0, 45)
holder.BackgroundTransparency = 1
Instance.new("UIListLayout", holder).Padding = UDim.new(0, 8)

local function makeBtn(name, key)
	local b = Instance.new("TextButton", holder)
	b.Size = UDim2.new(1, 0, 0, 32)
	b.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
	b.BackgroundTransparency = 0.5
	b.Text = name .. " [" .. key .. "]"
	b.TextColor3 = Color3.fromRGB(200, 200, 200)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 11
	b.BorderSizePixel = 0
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	
	-- Glowing side indicator
	local indicator = Instance.new("Frame", b)
	indicator.Size = UDim2.new(0, 2, 0.6, 0)
	indicator.Position = UDim2.new(0, 5, 0.2, 0)
	indicator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
	indicator.BorderSizePixel = 0
	
	return b, indicator
end

local btnFly, indFly = makeBtn("FLIGHT SYSTEM", "F")
local btnNoclip, indNoclip = makeBtn("NOCLIP OVERRIDE", "N")
local btnAim, indAim = makeBtn("COMBAT ASSIST", "E")
local btnTp, _ = makeBtn("RANDOM BREACH", "U")

local function updateVis(btn, ind, state)
	TweenService:Create(ind, TweenInfo.new(0.3), {BackgroundColor3 = state and Color3.fromRGB(0, 255, 230) or Color3.fromRGB(100, 100, 100)}):Play()
	TweenService:Create(btn, TweenInfo.new(0.3), {TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(200, 200, 200)}):Play()
end

--------------------------------------------------------
-- LOGIC (V3.2.4 RE-PORTED)
--------------------------------------------------------

local function setupFlyForce(hrpPart)
	if bv then bv:Destroy() end
	if bg then bg:Destroy() end
	bv = Instance.new("BodyVelocity", hrpPart)
	bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
	bv.Velocity = Vector3.new(0,0.1,0)
	bg = Instance.new("BodyGyro", hrpPart)
	bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
	bg.CFrame = camera.CFrame
end

local function toggleFly()
	flyEnabled = not flyEnabled
	updateVis(btnFly, indFly, flyEnabled)
	local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if flyEnabled and hrp then setupFlyForce(hrp) else if bv then bv:Destroy() end if bg then bg:Destroy() end end
end

local function toggleNoclip()
	noclipEnabled = not noclipEnabled
	updateVis(btnNoclip, indNoclip, noclipEnabled)
end

local function toggleAim()
	aimbotEnabled = not aimbotEnabled
	FOV.Visible = aimbotEnabled
	updateVis(btnAim, indAim, aimbotEnabled)
end

btnFly.MouseButton1Click:Connect(toggleFly)
btnNoclip.MouseButton1Click:Connect(toggleNoclip)
btnAim.MouseButton1Click:Connect(toggleAim)
btnTp.MouseButton1Click:Connect(tpToEnemy)

--------------------------------------------------------
-- ESP & RENDER LOOP
--------------------------------------------------------

local ESP_Table = {}
local function createESP(plr)
	if plr == player then return end
	local box = Instance.new("Frame", gui); box.BackgroundTransparency = 1; box.Visible = false; box.AnchorPoint = Vector2.new(0.5, 0.5)
	local s = Instance.new("UIStroke", box); s.Color = Color3.fromRGB(0, 255, 230); s.Thickness = 1
	local nl = Instance.new("TextLabel", box); nl.Size = UDim2.new(1,0,0,15); nl.Position = UDim2.new(0,0,0,-18); nl.BackgroundTransparency = 1; nl.TextColor3 = Color3.new(1,1,1); nl.Font = Enum.Font.GothamBold; nl.TextSize = 9
	ESP_Table[plr] = {Box = box, NameTag = nl}
end
for _, p in pairs(Players:GetPlayers()) do createESP(p) end
Players.PlayerAdded:Connect(createESP)

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

	if noclipEnabled and char then
		for _, p in ipairs(char:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end
	end

	if flyEnabled and bv and hrp then
		local mv = Vector3.zero
		if flyControls.W then mv += camera.CFrame.LookVector end
		if flyControls.S then mv -= camera.CFrame.LookVector end
		if flyControls.A then mv -= camera.CFrame.RightVector end
		if flyControls.D then mv += camera.CFrame.RightVector end
		bv.Velocity = mv.Magnitude > 0 and mv.Unit * FLY_SPEED or Vector3.new(0,0.1,0)
		bg.CFrame = camera.CFrame
	end

	for plr, data in pairs(ESP_Table) do
		if plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and aimbotEnabled then
			local root = plr.Character.HumanoidRootPart
			local pos, onScreen = camera:WorldToViewportPoint(root.Position)
			if onScreen and plr.Character.Humanoid.Health > 0 then
				local dist = (camera.CFrame.Position - root.Position).Magnitude
				local scale = (1 / dist) * 1000
				data.Box.Visible = true; data.Box.Position = UDim2.fromOffset(pos.X, pos.Y); data.Box.Size = UDim2.fromOffset(2.2 * scale, 4.0 * scale)
				data.NameTag.Text = string.upper(plr.Name)
			else data.Box.Visible = false end
		else data.Box.Visible = false end
	end

	if aimbotEnabled and aiming then
		local target = nil; local shortest = AIM_FOV
		for _, p in pairs(Players:GetPlayers()) do
			if p ~= player and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
				local pos, onScreen = camera:WorldToViewportPoint(p.Character.Head.Position)
				if onScreen then
					local d = (Vector2.new(pos.X, pos.Y) - mPos).Magnitude
					if d < shortest then shortest = d target = p.Character.Head end
				end
			end
		end
		if target then camera.CFrame = camera.CFrame:Lerp(CFrame.lookAt(camera.CFrame.Position, target.Position), AIM_SMOOTHNESS) end
	end
end)

function tpToEnemy()
	local t = {}
	for _, p in pairs(Players:GetPlayers()) do if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then table.insert(t, p.Character.HumanoidRootPart) end end
	if #t > 0 then player.Character.HumanoidRootPart.CFrame = t[math.random(1, #t)].CFrame * CFrame.new(0, 0, 3) end
end