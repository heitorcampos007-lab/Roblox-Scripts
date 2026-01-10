-- Painel - Kart Brookhaven 🏁 | Vehicle Speed Meter + Cronômetro | Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ================= VARIÁVEIS =================
local speedEnabled = false
local chronoEnabled = false
local chronoRunning = false
local chronoStart = 0
local chronoElapsed = 0
local meters = {}

-- ================= GUI BASE =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KartBrookhavenGUI"
ScreenGui.ResetOnSpawn = false

-- ================= FUNÇÃO DRAG =================
local function makeDraggable(frame)
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- ================= PAINEL PRINCIPAL =================
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 300, 0, 200)
Panel.Position = UDim2.new(0.05, 0, 0.4, 0)
Panel.BackgroundColor3 = Color3.fromRGB(10,10,10)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,12)
makeDraggable(Panel)

-- Título
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Painel - Kart Brookhaven 🏁"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão X
local CloseBtn = Instance.new("TextButton", Panel)
CloseBtn.Size = UDim2.new(0, 26, 0, 26)
CloseBtn.Position = UDim2.new(1, -36, 0, 10)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

-- ================= BOTÃO MINIMIZADO =================
local Mini = Instance.new("TextButton", ScreenGui)
Mini.Size = UDim2.new(0, 50, 0, 50)
Mini.Position = Panel.Position
Mini.Text = "🏁"
Mini.TextSize = 26
Mini.BackgroundColor3 = Color3.fromRGB(10,10,10)
Mini.TextColor3 = Color3.new(1,1,1)
Mini.BorderSizePixel = 0
Mini.Visible = false
Instance.new("UICorner", Mini).CornerRadius = UDim.new(1,0)
makeDraggable(Mini)

CloseBtn.MouseButton1Click:Connect(function()
	local tween = TweenService:Create(Panel, TweenInfo.new(0.25), {
		Size = UDim2.new(0,50,0,50),
		BackgroundTransparency = 1
	})
	tween:Play()
	tween.Completed:Wait()
	Mini.Position = Panel.Position
	Panel.Visible = false
	Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
	Panel.Position = Mini.Position
	Panel.Size = UDim2.new(0,300,0,200)
	Panel.BackgroundTransparency = 0
	Panel.Visible = true
	Mini.Visible = false
end)

-- ================= FUNÇÃO SWITCH =================
local function createSwitch(parent, yPos, labelText)
	local box = Instance.new("Frame", parent)
	box.Size = UDim2.new(1, -20, 0, 50)
	box.Position = UDim2.new(0, 10, 0, yPos)
	box.BackgroundColor3 = Color3.fromRGB(45,45,45)
	box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

	local label = Instance.new("TextLabel", box)
	label.Size = UDim2.new(0.45,0,1,0)
	label.Position = UDim2.new(0,10,0,0)
	label.BackgroundTransparency = 1
	label.Text = labelText
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 16
	label.TextColor3 = Color3.new(1,1,1)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local state = Instance.new("TextLabel", box)
	state.Size = UDim2.new(0,40,1,0)
	state.Position = UDim2.new(1,-60,0,0)
	state.BackgroundTransparency = 1
	state.Font = Enum.Font.SourceSansBold
	state.TextSize = 14

	local switch = Instance.new("Frame", box)
	switch.Size = UDim2.new(0,52,0,26)
	switch.Position = UDim2.new(1,-120,0.5,-13)
	switch.BackgroundColor3 = Color3.fromRGB(130,130,130)
	switch.BorderSizePixel = 0
	Instance.new("UICorner", switch).CornerRadius = UDim.new(1,0)

	local knob = Instance.new("Frame", switch)
	knob.Size = UDim2.new(0,22,0,22)
	knob.Position = UDim2.new(0,2,0.5,-11)
	knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
	knob.BorderSizePixel = 0
	Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

	return box, switch, knob, state
end

-- ================= VELOCÍMETRO SWITCH =================
local _, SpeedSwitch, SpeedKnob, SpeedState =
	createSwitch(Panel, 50, "Velocímetro:")

local function updateSpeedSwitch()
	if speedEnabled then
		SpeedSwitch.BackgroundColor3 = Color3.fromRGB(0,180,0)
		SpeedKnob.Position = UDim2.new(1,-24,0.5,-11)
		SpeedState.Text = "ON"
		SpeedState.TextColor3 = Color3.fromRGB(0,255,0)
	else
		SpeedSwitch.BackgroundColor3 = Color3.fromRGB(180,0,0)
		SpeedKnob.Position = UDim2.new(0,2,0.5,-11)
		SpeedState.Text = "OFF"
		SpeedState.TextColor3 = Color3.fromRGB(255,0,0)
	end
end

-- ================= CRIAR MEDIDOR =================
local function createMeter(player)
	local char = player.Character
	if not char then return end
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hrp then return end

	local bb = Instance.new("BillboardGui", hrp)
	bb.Size = UDim2.new(0,160,0,45)
	bb.StudsOffset = Vector3.new(0,4,0)
	bb.AlwaysOnTop = true

	local nameLabel = Instance.new("TextLabel", bb)
	nameLabel.Size = UDim2.new(1,0,0.5,0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = player.Name
	nameLabel.Font = Enum.Font.SourceSansBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = Color3.new(1,1,1)

	local speedLabel = Instance.new("TextLabel", bb)
	speedLabel.Position = UDim2.new(0,0,0.5,0)
	speedLabel.Size = UDim2.new(1,0,0.5,0)
	speedLabel.BackgroundTransparency = 1
	speedLabel.Font = Enum.Font.SourceSansBold
	speedLabel.TextScaled = true
	speedLabel.TextStrokeTransparency = 0

	meters[player] = {
		gui = bb,
		speedLabel = speedLabel,
		humanoid = humanoid
	}
end

-- ================= SWITCH CLICK =================
SpeedSwitch.InputBegan:Connect(function(input)
	if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
		return
	end

	speedEnabled = not speedEnabled
	updateSpeedSwitch()

	for _, d in pairs(meters) do
		if d.gui then d.gui:Destroy() end
	end
	meters = {}

	if speedEnabled then
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character then createMeter(p) end
			p.CharacterAdded:Connect(function()
				task.wait(1)
				if speedEnabled then createMeter(p) end
			end)
		end
	end
end)

-- ================= LOOP VELOCIDADE DO VEÍCULO =================
RunService.RenderStepped:Connect(function()
	if not speedEnabled then return end

	for player, data in pairs(meters) do
		local hum = data.humanoid
		if hum and hum.SeatPart and hum.SeatPart:IsA("BasePart") then
			local vehiclePart = hum.SeatPart
			local rawSpeed = vehiclePart.AssemblyLinearVelocity.Magnitude
			local speed = math.floor((rawSpeed + 5) / 10) * 10

			if speed <= 100 then
				data.speedLabel.Text = "Vel: "..speed
				data.speedLabel.TextColor3 = Color3.fromRGB(0,255,0)
			else
				data.speedLabel.Text = "Vel: "..speed.." ⚠️"
				data.speedLabel.TextColor3 = Color3.fromRGB(255,0,0)
			end
		else
			data.speedLabel.Text = "Vel: 0"
			data.speedLabel.TextColor3 = Color3.fromRGB(0,255,0)
		end
	end
end)

updateSpeedSwitch()
