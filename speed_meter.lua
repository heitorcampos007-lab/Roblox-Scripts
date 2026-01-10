-- Painel - Kart Brookhaven 🏁 | Speed Monitor + Cronômetro | Delta Executor

-- SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ================= VARIÁVEIS =================
local speedEnabled = false
local chronoRunning = false
local chronoTime = 0
local meters = {}

-- ================= GUI BASE =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KartBrookhavenGUI"
ScreenGui.ResetOnSpawn = false

-- ================= FUNÇÃO DRAG =================
local function makeDraggable(frame)
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

-- ================= PAINEL =================
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 300, 0, 220)
Panel.Position = UDim2.new(0.05, 0, 0.4, 0)
Panel.BackgroundColor3 = Color3.fromRGB(15,15,15)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,12)
makeDraggable(Panel)

-- TÍTULO
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 8)
Title.BackgroundTransparency = 1
Title.Text = "Kart Brookhaven 🏁"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- BOTÃO FECHAR
local Close = Instance.new("TextButton", Panel)
Close.Size = UDim2.new(0,26,0,26)
Close.Position = UDim2.new(1,-36,0,8)
Close.Text = "X"
Close.Font = Enum.Font.SourceSansBold
Close.TextSize = 16
Close.TextColor3 = Color3.new(1,1,1)
Close.BackgroundColor3 = Color3.fromRGB(35,35,35)
Close.BorderSizePixel = 0
Instance.new("UICorner", Close).CornerRadius = UDim.new(1,0)

-- ================= SWITCH VELOCÍMETRO =================
local SpeedBtn = Instance.new("TextButton", Panel)
SpeedBtn.Size = UDim2.new(1,-20,0,40)
SpeedBtn.Position = UDim2.new(0,10,0,45)
SpeedBtn.Text = "Velocímetro: OFF"
SpeedBtn.Font = Enum.Font.SourceSansBold
SpeedBtn.TextSize = 16
SpeedBtn.TextColor3 = Color3.new(1,1,1)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(180,0,0)
SpeedBtn.BorderSizePixel = 0
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0,8)

-- ================= CRONÔMETRO =================
local TimerLabel = Instance.new("TextLabel", Panel)
TimerLabel.Size = UDim2.new(1,-20,0,35)
TimerLabel.Position = UDim2.new(0,10,0,95)
TimerLabel.BackgroundTransparency = 1
TimerLabel.Text = "Cronômetro: 00:00"
TimerLabel.Font = Enum.Font.SourceSansBold
TimerLabel.TextSize = 18
TimerLabel.TextColor3 = Color3.fromRGB(0,255,0)

local TimerBtn = Instance.new("TextButton", Panel)
TimerBtn.Size = UDim2.new(1,-20,0,40)
TimerBtn.Position = UDim2.new(0,10,0,135)
TimerBtn.Text = "Iniciar Cronômetro"
TimerBtn.Font = Enum.Font.SourceSansBold
TimerBtn.TextSize = 16
TimerBtn.TextColor3 = Color3.new(1,1,1)
TimerBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
TimerBtn.BorderSizePixel = 0
Instance.new("UICorner", TimerBtn).CornerRadius = UDim.new(0,8)

-- ================= FUNÇÃO CONVERSÃO =================
local function convertSpeed(raw)
	if raw >= 101 then
		return "80+"
	end
	return math.floor(raw * 0.7)
end

-- ================= CRIAR MEDIDOR =================
local function createMeter(player)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not hum or not hrp then return end

	local bb = Instance.new("BillboardGui", hrp)
	bb.Size = UDim2.new(0,160,0,45)
	bb.StudsOffset = Vector3.new(0,4,0)
	bb.AlwaysOnTop = true

	local name = Instance.new("TextLabel", bb)
	name.Size = UDim2.new(1,0,0.5,0)
	name.BackgroundTransparency = 1
	name.Text = player.Name
	name.Font = Enum.Font.SourceSansBold
	name.TextScaled = true
	name.TextColor3 = Color3.new(1,1,1)

	local speed = Instance.new("TextLabel", bb)
	speed.Position = UDim2.new(0,0,0.5,0)
	speed.Size = UDim2.new(1,0,0.5,0)
	speed.BackgroundTransparency = 1
	speed.Font = Enum.Font.SourceSansBold
	speed.TextScaled = true
	speed.TextStrokeTransparency = 0

	meters[player] = {gui = bb, hum = hum, label = speed}
end

-- ================= BOTÃO VELOCÍMETRO =================
SpeedBtn.MouseButton1Click:Connect(function()
	speedEnabled = not speedEnabled

	SpeedBtn.Text = speedEnabled and "Velocímetro: ON" or "Velocímetro: OFF"
	SpeedBtn.BackgroundColor3 = speedEnabled and Color3.fromRGB(0,180,0) or Color3.fromRGB(180,0,0)

	for _, m in pairs(meters) do
		if m.gui then m.gui:Destroy() end
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

-- ================= BOTÃO CRONÔMETRO =================
TimerBtn.MouseButton1Click:Connect(function()
	chronoRunning = not chronoRunning
	if chronoRunning then
		chronoTime = 0
		TimerBtn.Text = "Parar Cronômetro"
	else
		TimerBtn.Text = "Iniciar Cronômetro"
	end
end)

-- ================= LOOP PRINCIPAL =================
RunService.RenderStepped:Connect(function(dt)
	-- Cronômetro
	if chronoRunning then
		chronoTime += dt
		local m = math.floor(chronoTime / 60)
		local s = math.floor(chronoTime % 60)
		TimerLabel.Text = string.format("Cronômetro: %02d:%02d", m, s)
	end

	-- Velocidade
	if not speedEnabled then return end

	for _, d in pairs(meters) do
		if d.hum and d.hum.SeatPart then
			local v = d.hum.SeatPart.AssemblyLinearVelocity.Magnitude
			local fixed = convertSpeed(v)
			d.label.Text = "Vel: "..fixed
			d.label.TextColor3 = v >= 101 and Color3.fromRGB(255,0,0) or Color3.fromRGB(0,255,0)
		else
			d.label.Text = "Vel: 0"
			d.label.TextColor3 = Color3.fromRGB(0,255,0)
		end
	end
end)

-- FECHAR PAINEL
Close.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)
