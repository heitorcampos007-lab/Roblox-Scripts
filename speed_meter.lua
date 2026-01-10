-- Painel - Kart Brookhaven 🏁 | Speed Meter + Cronômetro | Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local meters = {}

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "KartPanelGUI"
ScreenGui.ResetOnSpawn = false

-- ================= PAINEL PRINCIPAL =================
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 280, 0, 190)
Panel.Position = UDim2.new(0.05, 0, 0.4, 0)
Panel.BackgroundColor3 = Color3.fromRGB(10,10,10)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,12)

-- Drag
do
	local dragging, dragStart, startPos
	Panel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Panel.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Título
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Painel - Kart Brookhaven 🏁"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- ================= VELOCÍMETRO BOX =================
local Box = Instance.new("Frame", Panel)
Box.Size = UDim2.new(1, -20, 0, 55)
Box.Position = UDim2.new(0, 10, 0, 55)
Box.BackgroundColor3 = Color3.fromRGB(45,45,45)
Box.BorderSizePixel = 0
Instance.new("UICorner", Box).CornerRadius = UDim.new(0,8)

local BoxLabel = Instance.new("TextLabel", Box)
BoxLabel.Size = UDim2.new(0.5, 0, 1, 0)
BoxLabel.Position = UDim2.new(0, 10, 0, 0)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Velocímetro:"
BoxLabel.Font = Enum.Font.SourceSansBold
BoxLabel.TextSize = 16
BoxLabel.TextColor3 = Color3.fromRGB(255,255,255)
BoxLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Estado ON/OFF
local StateLabel = Instance.new("TextLabel", Box)
StateLabel.Size = UDim2.new(0, 50, 1, 0)
StateLabel.Position = UDim2.new(1, -60, 0, 0)
StateLabel.BackgroundTransparency = 1
StateLabel.Font = Enum.Font.SourceSansBold
StateLabel.TextSize = 14
StateLabel.Text = "OFF"
StateLabel.TextColor3 = Color3.fromRGB(255,0,0)

-- Switch botão
local SwitchBtn = Instance.new("TextButton", Box)
SwitchBtn.Size = UDim2.new(0, 70, 0, 30)
SwitchBtn.Position = UDim2.new(1, -150, 0.5, -15)
SwitchBtn.Text = "ON / OFF"
SwitchBtn.Font = Enum.Font.SourceSansBold
SwitchBtn.TextSize = 14
SwitchBtn.TextColor3 = Color3.fromRGB(255,255,255)
SwitchBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
SwitchBtn.BorderSizePixel = 0
Instance.new("UICorner", SwitchBtn).CornerRadius = UDim.new(0,8)

-- ================= BOTÃO CRONÔMETRO =================
local ChronoBtn = Instance.new("TextButton", Panel)
ChronoBtn.Size = UDim2.new(1, -20, 0, 40)
ChronoBtn.Position = UDim2.new(0, 10, 0, 120)
ChronoBtn.Text = "Cronômetro"
ChronoBtn.Font = Enum.Font.SourceSansBold
ChronoBtn.TextSize = 16
ChronoBtn.TextColor3 = Color3.fromRGB(255,255,255)
ChronoBtn.BackgroundColor3 = Color3.fromRGB(160,90,255)
ChronoBtn.BorderSizePixel = 0
Instance.new("UICorner", ChronoBtn).CornerRadius = UDim.new(0,10)

-- ================= CRONÔMETRO PAINEL =================
local ChronoPanel = Instance.new("Frame", ScreenGui)
ChronoPanel.Size = UDim2.new(0, 260, 0, 180)
ChronoPanel.Position = UDim2.new(0.45, 0, 0.4, 0)
ChronoPanel.BackgroundColor3 = Color3.fromRGB(0,0,0)
ChronoPanel.BorderSizePixel = 0
ChronoPanel.Visible = false
Instance.new("UICorner", ChronoPanel).CornerRadius = UDim.new(0,12)

-- Drag cronômetro
do
	local dragging, dragStart, startPos
	ChronoPanel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = ChronoPanel.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			ChronoPanel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
end

-- Display tempo
local TimeLabel = Instance.new("TextLabel", ChronoPanel)
TimeLabel.Size = UDim2.new(1, 0, 0, 60)
TimeLabel.Position = UDim2.new(0, 0, 0, 20)
TimeLabel.BackgroundTransparency = 1
TimeLabel.Text = "00h 00m 00ms"
TimeLabel.Font = Enum.Font.SourceSansBold
TimeLabel.TextSize = 28
TimeLabel.TextColor3 = Color3.fromRGB(255,255,255)

-- Botões cronômetro
local ResetBtn = Instance.new("TextButton", ChronoPanel)
ResetBtn.Size = UDim2.new(0.45, -10, 0, 40)
ResetBtn.Position = UDim2.new(0.05, 0, 1, -55)
ResetBtn.Text = "Resetar Timer"
ResetBtn.Font = Enum.Font.SourceSansBold
ResetBtn.TextSize = 14
ResetBtn.BackgroundColor3 = Color3.fromRGB(120,120,120)
ResetBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0,8)

local StartBtn = Instance.new("TextButton", ChronoPanel)
StartBtn.Size = UDim2.new(0.45, -10, 0, 40)
StartBtn.Position = UDim2.new(0.5, 0, 1, -55)
StartBtn.Text = "Iniciar"
StartBtn.Font = Enum.Font.SourceSansBold
StartBtn.TextSize = 14
StartBtn.BackgroundColor3 = Color3.fromRGB(160,90,255)
StartBtn.TextColor3 = Color3.fromRGB(255,255,255)
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0,8)

-- ================= LÓGICA CRONÔMETRO =================
local running = false
local startTime = 0
local elapsed = 0

RunService.RenderStepped:Connect(function()
	if running then
		elapsed = tick() - startTime
		local ms = math.floor((elapsed % 1) * 100)
		local s = math.floor(elapsed % 60)
		local m = math.floor(elapsed / 60)
		TimeLabel.Text = string.format("%02dh %02dm %02dms",0,m,ms)
	end
end)

StartBtn.MouseButton1Click:Connect(function()
	running = not running
	if running then
		startTime = tick() - elapsed
		StartBtn.Text = "Parar"
		StartBtn.BackgroundColor3 = Color3.fromRGB(255,0,0)
	else
		StartBtn.Text = "Iniciar"
		StartBtn.BackgroundColor3 = Color3.fromRGB(160,90,255)
	end
end)

ResetBtn.MouseButton1Click:Connect(function()
	elapsed = 0
	startTime = tick()
	TimeLabel.Text = "00h 00m 00ms"
end)

ChronoBtn.MouseButton1Click:Connect(function()
	ChronoPanel.Visible = not ChronoPanel.Visible
end)

-- ================= VELOCÍMETRO ESP =================
local function createMeter(character, player)
	local hrp = character:WaitForChild("HumanoidRootPart",5)
	if not hrp then return end

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

	meters[player] = {label = txt, lastPos = hrp.Position}
end

SwitchBtn.MouseButton1Click:Connect(function()
	enabled = not enabled
	StateLabel.Text = enabled and "ON" or "OFF"
	StateLabel.TextColor3 = enabled and Color3.fromRGB(0,255,0) or Color3.fromRGB(255,0,0)

	for _,v in pairs(meters) do if v.label then v.label.Parent:Destroy() end end
	meters = {}

	if enabled then
		for _,p in pairs(Players:GetPlayers()) do
			if p.Character then createMeter(p.Character,p) end
		end
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if not enabled then return end
	for p,d in pairs(meters) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			local speed = math.floor((hrp.Position - d.lastPos).Magnitude / dt)
			d.lastPos = hrp.Position

			if speed <= 100 then
				d.label.Text = "Vel: "..speed
				d.label.TextColor3 = Color3.fromRGB(0,255,0)
			else
				d.label.Text = "Vel: "..speed.." ⚠️"
				d.label.TextColor3 = Color3.fromRGB(255,0,0)
			end
		end
	end
end)
