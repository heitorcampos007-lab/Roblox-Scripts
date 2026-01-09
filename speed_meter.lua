-- Speed Meter ESP com Botão Arrastável | Brookhaven | Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local enabled = true
local meters = {}

-- ===== UI =====
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SpeedMeterGUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 120, 0, 40)
ToggleButton.Position = UDim2.new(0, 20, 0.5, -20)
ToggleButton.Font = Enum.Font.SourceSansBold
ToggleButton.TextScaled = true
ToggleButton.BorderSizePixel = 0
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextStrokeTransparency = 0
ToggleButton.Parent = ScreenGui

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)

-- Atualizar botão
local function updateButton()
	if enabled then
		ToggleButton.Text = "ON"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
	else
		ToggleButton.Text = "OFF"
		ToggleButton.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
	end
end

-- ===== BOTÃO ARRASTÁVEL =====
do
	local dragging = false
	local dragStart, startPos

	ToggleButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = ToggleButton.Position
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			ToggleButton.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
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

-- ===== VELOCÍMETRO =====
local function createMeter(character, player)
	if player == LocalPlayer then return end
	if not character:FindFirstChild("HumanoidRootPart") then return end

	local hrp = character.HumanoidRootPart

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "SpeedMeter"
	billboard.Adornee = hrp
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.AlwaysOnTop = true
	billboard.Parent = hrp

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, 0, 1, 0)
	text.BackgroundTransparency = 1
	text.TextScaled = true
	text.Font = Enum.Font.SourceSansBold
	text.TextColor3 = Color3.fromRGB(255, 255, 255)
	text.TextStrokeTransparency = 0
	text.Parent = billboard

	meters[player] = {
		gui = billboard,
		label = text,
		lastPos = hrp.Position
	}
end

local function removeAllMeters()
	for _, data in pairs(meters) do
		if data.gui then
			data.gui:Destroy()
		end
	end
	meters = {}
end

-- Jogadores
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
			local speed = (hrp.Position - data.lastPos).Magnitude / dt
			data.lastPos = hrp.Position

			data.label.Text = string.format(
				"%s\nVel: %.1f",
				player.Name,
				speed
			)
		end
	end
end)

-- Clique do botão
ToggleButton.MouseButton1Click:Connect(function()
	enabled = not enabled
	updateButton()

	if not enabled then
		removeAllMeters()
	else
		for _, player in pairs(Players:GetPlayers()) do
			if player.Character then
				createMeter(player.Character, player)
			end
		end
	end
end)

updateButton()
