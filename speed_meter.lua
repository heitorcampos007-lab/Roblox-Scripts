-- Painel Kart Brookhaven 🏁 | Velocímetro + Cronômetro | Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
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

-- ================= PAINEL PRINCIPAL =================
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 300, 0, 230)
Panel.Position = UDim2.new(0.05, 0, 0.4, 0)
Panel.BackgroundColor3 = Color3.fromRGB(10,10,10)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,12)
makeDraggable(Panel)

-- Título
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, -40, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "Painel - Kart Brookhaven 🏁"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.new(1,1,1)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão X
local CloseBtn = Instance.new("TextButton", Panel)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -30, 0, 8)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.new(1,1,1)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

-- Minimizado
local Mini = Instance.new("TextButton", ScreenGui)
Mini.Size = UDim2.new(0, 50, 0, 50)
Mini.Text = "🏁"
Mini.Font = Enum.Font.SourceSansBold
Mini.TextSize = 26
Mini.TextColor3 = Color3.new(1,1,1)
Mini.BackgroundColor3 = Color3.fromRGB(10,10,10)
Mini.BorderSizePixel = 0
Mini.Visible = false
Instance.new("UICorner", Mini).CornerRadius = UDim.new(1,0)
makeDraggable(Mini)

CloseBtn.MouseButton1Click:Connect(function()
	Mini.Position = Panel.Position
	Panel.Visible = false
	Mini.Visible = true
end)

Mini.MouseButton1Click:Connect(function()
	Panel.Position = Mini.Position
	Panel.Visible = true
	Mini.Visible = false
end)

-- ================= FUNÇÃO SWITCH =================
local function createSwitch(parent, y, text)
	local box = Instance.new("Frame", parent)
	box.Size = UDim2.new(1, -20, 0, 50)
	box.Position = UDim2.new(0, 10, 0, y)
	box.BackgroundColor3 = Color3.fromRGB(45,45,45)
	box.BorderSizePixel = 0
	Instance.new("UICorner", box).CornerRadius = UDim.new(0,8)

	local label = Instance.new("TextLabel", box)
	label.Size = UDim2.new(0.45,0,1,0)
	label.Position = UDim2.new(0,10,0,0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.Font = Enum.Font.SourceSansBold
	label.TextSize = 16
	label.TextColor3 = Color3.new(1,1,1)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local state = Instance.new("TextLabel", box)
	state.Size = UDim2.new(0,40,1,0)
	state.Position = UDim2.new(1,-50,0,0)
	state.BackgroundTransparency = 1
	state.Font = Enum.Font.SourceSansBold
	state.TextSize = 14

	local switch = Instance.new("Frame", box)
	switch.Size = UDim2.new(0,50,0,26)
	switch.Position = UDim2.new(1,-120,0.5,-13)
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

-- ================= VELOCÍMETRO =================
local speedBox, speedSwitch, speedKnob, speedState =
	createSwitch(Panel, 45, "Velocímetro:")

local function updateSpeedSwitch()
	if speedEnabled then
		speedSwitch.BackgroundColor3 = Color3.fromRGB(0,200,0)
		speedKnob.Position = UDim2.new(1,-24,0.5,-11)
		speedState.Text = "ON"
		speedState.TextColor3 = Color3.fromRGB(0,255,0)
	else
		speedSwitch.BackgroundColor3 = Color3.fromRGB(200,0,0)
		speedKnob.Position = UDim2.new(0,2,0.5,-11)
		speedState.Text = "OFF"
		speedState.TextColor3 = Color3.fromRGB(255,0,0)
	end
end

-- ================= CRONÔMETRO SWITCH =================
local chronoBox, chronoSwitch, chronoKnob, chronoState =
	createSwitch(Panel, 105, "Cronômetro:")

local function updateChronoSwitch()
	if chronoEnabled then
		chronoSwitch.BackgroundColor3 = Color3.fromRGB(160,90,255)
		chronoKnob.Position = UDim2.new(1,-24,0.5,-11)
		chronoState.Text = "ON"
		chronoState.TextColor3 = Color3.fromRGB(0,255,0)
	else
		chronoSwitch.BackgroundColor3 = Color3.fromRGB(130,130,130)
		chronoKnob.Position = UDim2.new(0,2,0.5,-11)
		chronoState.Text = "OFF"
		chronoState.TextColor3 = Color3.fromRGB(255,0,0)
	end
end

-- ================= PAINEL CRONÔMETRO =================
local ChronoPanel = Instance.new("Frame", ScreenGui)
ChronoPanel.Size = UDim2.new(0, 260, 0, 160)
ChronoPanel.Position = UDim2.new(0.4, 0, 0.4, 0)
ChronoPanel.BackgroundColor3 = Color3.fromRGB(10,10,10)
ChronoPanel.BorderSizePixel = 0
ChronoPanel.Visible = false
Instance.new("UICorner", ChronoPanel).CornerRadius = UDim.new(0,12)
makeDraggable(ChronoPanel)

local ChronoTimeLabel = Instance.new("TextLabel", ChronoPanel)
ChronoTimeLabel.Size = UDim2.new(1,0,0,60)
ChronoTimeLabel.Position = UDim2.new(0,0,0,20)
ChronoTimeLabel.BackgroundTransparency = 1
ChronoTimeLabel.Font = Enum.Font.SourceSansBold
ChronoTimeLabel.TextSize = 28
ChronoTimeLabel.TextColor3 = Color3.new(1,1,1)
ChronoTimeLabel.Text = "00h 00m 00s"

local StartStop = Instance.new("TextButton", ChronoPanel)
StartStop.Size = UDim2.new(0.45,0,0,40)
StartStop.Position = UDim2.new(0.05,0,1,-50)
StartStop.Font = Enum.Font.SourceSansBold
StartStop.TextSize = 16
StartStop.TextColor3 = Color3.new(1,1,1)
StartStop.BorderSizePixel = 0
Instance.new("UICorner", StartStop).CornerRadius = UDim.new(0,8)

local ResetBtn = Instance.new("TextButton", ChronoPanel)
ResetBtn.Size = UDim2.new(0.45,0,0,40)
ResetBtn.Position = UDim2.new(0.5,0,1,-50)
ResetBtn.Text = "Resetar Timer"
ResetBtn.Font = Enum.Font.SourceSansBold
ResetBtn.TextSize = 14
ResetBtn.TextColor3 = Color3.new(1,1,1)
ResetBtn.BackgroundColor3 = Color3.fromRGB(90,90,90)
ResetBtn.BorderSizePixel = 0
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0,8)

-- ================= LÓGICAS =================
speedSwitch.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		speedEnabled = not speedEnabled
		updateSpeedSwitch()

		for _, d in pairs(meters) do
			if d.gui then d.gui:Destroy() end
		end
		meters = {}

		if speedEnabled then
			for _, p in pairs(Players:GetPlayers()) do
				if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
					local hrp = p.Character.HumanoidRootPart
					local bb = Instance.new("BillboardGui", hrp)
					bb.Size = UDim2.new(0,140,0,35)
					bb.StudsOffset = Vector3.new(0,3,0)
					bb.AlwaysOnTop = true

					local txt = Instance.new("TextLabel", bb)
					txt.Size = UDim2.new(1,0,1,0)
					txt.BackgroundTransparency = 1
					txt.Font = Enum.Font.SourceSansBold
					txt.TextScaled = true
					txt.TextStrokeTransparency = 0

					meters[p] = {gui = bb, label = txt, hrp = hrp}
				end
			end
		end
	end
end)

chronoSwitch.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		chronoEnabled = not chronoEnabled
		updateChronoSwitch()
		ChronoPanel.Visible = chronoEnabled
	end
end)

StartStop.MouseButton1Click:Connect(function()
	chronoRunning = not chronoRunning
	if chronoRunning then
		chronoStart = tick() - chronoElapsed
		StartStop.Text = "Parar"
		StartStop.BackgroundColor3 = Color3.fromRGB(200,0,0)
	else
		chronoElapsed = tick() - chronoStart
		StartStop.Text = "Iniciar"
		StartStop.BackgroundColor3 = Color3.fromRGB(160,90,255)
	end
end)

ResetBtn.MouseButton1Click:Connect(function()
	chronoElapsed = 0
	chronoStart = tick()
	ChronoTimeLabel.Text = "00h 00m 00s"
end)

RunService.RenderStepped:Connect(function()
	if speedEnabled then
		for _, d in pairs(meters) do
			local raw = d.hrp.AssemblyLinearVelocity.Magnitude
			local speed = math.floor((raw + 5) / 10) * 10

			if speed <= 100 then
				d.label.Text = "Vel: "..speed
				d.label.TextColor3 = Color3.fromRGB(0,255,0)
			else
				d.label.Text = "Vel: "..speed.." ⚠️"
				d.label.TextColor3 = Color3.fromRGB(255,0,0)
			end
		end
	end

	if chronoRunning then
		local t = tick() - chronoStart
		local h = math.floor(t / 3600)
		local m = math.floor((t % 3600) / 60)
		local s = math.floor(t % 60)
		ChronoTimeLabel.Text =
			string.format("%02dh %02dm %02ds", h, m, s)
	end
end)

updateSpeedSwitch()
updateChronoSwitch()
StartStop.Text = "Iniciar"
StartStop.BackgroundColor3 = Color3.fromRGB(160,90,255)
