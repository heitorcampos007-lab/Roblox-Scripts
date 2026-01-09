-- Painel - Kart Brookhaven | Speed Meter ESP | Delta Executor

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local enabled = false
local meters = {}

-- ================= GUI =================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "KartPanelGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

-- Painel principal
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 280, 0, 140)
Panel.Position = UDim2.new(0.05, 0, 0.4, 0)
Panel.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0, 12)

-- Drag do painel
do
	local dragging, dragStart, startPos
	Panel.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Panel.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Panel.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

-- Título
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, -20, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Painel - Kart Brookhaven"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Caixa do velocímetro
local Box = Instance.new("Frame", Panel)
Box.Size = UDim2.new(1, -20, 0, 55)
Box.Position = UDim2.new(0, 10, 0, 55)
Box.BackgroundColor3 = Color3.fromRGB(45,45,45)
Box.BorderSizePixel = 0
Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 8)

-- Texto "Velocímetro:"
local BoxLabel = Instance.new("TextLabel", Box)
BoxLabel.Size = UDim2.new(0.45, 0, 1, 0)
BoxLabel.Position = UDim2.new(0, 10, 0, 0)
BoxLabel.BackgroundTransparency = 1
BoxLabel.Text = "Velocímetro:"
BoxLabel.Font = Enum.Font.SourceSansBold
BoxLabel.TextSize = 16
BoxLabel.TextColor3 = Color3.fromRGB(255,255,255)
BoxLabel.TextXAlignment = Enum.TextXAlignment.Left

-- Switch
local Switch = Instance.new("Frame", Box)
Switch.Size = UDim2.new(0, 52, 0, 26)
Switch.Position = UDim2.new(1, -120, 0.5, -13)
Switch.BackgroundColor3 = Color3.fromRGB(130,130,130)
Switch.BorderSizePixel = 0
Instance.new("UICorner", Switch).CornerRadius = UDim.new(1, 0)

local Knob = Instance.new("Frame", Switch)
Knob.Size = UDim2.new(0, 22, 0, 22)
Knob.Position = UDim2.new(0, 2, 0.5, -11)
Knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
Knob.BorderSizePixel = 0
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

-- Texto ON / OFF
local StateLabel = Instance.new("TextLabel", Box)
StateLabel.Size = UDim2.new(0, 40, 1, 0)
StateLabel.Position = UDim2.new(1, -60, 0, 0)
StateLabel.BackgroundTransparency = 1
StateLabel.Font = Enum.Font.SourceSansBold
StateLabel.TextSize = 14
StateLabel.TextColor3 = Color3.fromRGB(255,255,255)
StateLabel.Text = "OFF"

-- Atualizar switch visual
local function updateSwitch()
	if enabled then
		Switch.BackgroundColor3 = Color3.fromRGB(160, 90, 255) -- roxo
		Knob.Position = UDim2.new(1, -24, 0.5, -11)
		StateLabel.Text = "ON"
	else
		Switch.BackgroundColor3 = Color3.fromRGB(130,130,130)
		Knob.Position = UDim2.new(0, 2, 0.5, -11)
		StateLabel.Text = "OFF"
	end
end

-- Clique no switch
Switch.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		enabled = not enabled
		updateSwitch()

		if not enabled then
			for _, data in pairs(meters) do
				if data.gui then data.gui:Destroy() end
			end
			meters = {}
		end
	end
end)

-- ================= VELOCÍMETRO =================
local function createMeter(character, player)
	if not character:FindFirstChild("HumanoidRootPart") then return end

	local hrp = character.HumanoidRootPart

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SpeedMeter"
	billboard.Adornee = hrp
	billboard.Size = UDim2.new(0, 140, 0, 35)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.SourceSansBold
	text.TextScaled = true
	text.TextStrokeTransparency = 0
	text.Parent = billboard

	meters[player] = {
		gui = billboard,
		label = text,
		lastPos = hrp.Position
	}
end

-- Criar meters nos jogadores
for _, player in pairs(Players:GetPlayers()) do
	player.CharacterAdded:Connect(function(char)
		task.wait(1)
		if enabled then
			createMeter(char, player)
		end
	end)

	if player.Character and enabled then
		createMeter(player.Character, player)
	end
end

-- Atualizar velocidade
RunService.RenderStepped:Connect(function(dt)
	if not enabled then return end

	for player, data in pairs(meters) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = player.Character.HumanoidRootPart
			local speed = math.floor((hrp.Position - data.lastPos).Magnitude / dt)
			data.lastPos = hrp.Position

			if speed <= 100 then
				data.label.Text = "Vel: " .. speed
				data.label.TextColor3 = Color3.fromRGB(0, 255, 0)
			else
				data.label.Text = "Vel: " .. speed .. " ⚠️"
				data.label.TextColor3 = Color3.fromRGB(255, 0, 0)
			end
		end
	end
end)

updateSwitch()
