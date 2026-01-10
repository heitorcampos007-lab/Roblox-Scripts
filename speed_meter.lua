-- Painel - Kart Brookhaven 🏁 | Speed Meter ESP | Delta Executor

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

-- Painel principal
local Panel = Instance.new("Frame", ScreenGui)
Panel.Size = UDim2.new(0, 280, 0, 140)
Panel.Position = UDim2.new(0.05, 0, 0.4, 0)
Panel.BackgroundColor3 = Color3.fromRGB(10,10,10)
Panel.BorderSizePixel = 0
Instance.new("UICorner", Panel).CornerRadius = UDim.new(0,12)

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

-- Título 🏁
local Title = Instance.new("TextLabel", Panel)
Title.Size = UDim2.new(1, -50, 0, 30)
Title.Position = UDim2.new(0, 10, 0, 10)
Title.BackgroundTransparency = 1
Title.Text = "Painel - Kart Brookhaven 🏁"
Title.Font = Enum.Font.SourceSansBold
Title.TextSize = 18
Title.TextColor3 = Color3.fromRGB(255,255,255)
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Botão X (minimizar)
local CloseBtn = Instance.new("TextButton", Panel)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -34, 0, 12)
CloseBtn.Text = "X"
CloseBtn.Font = Enum.Font.SourceSansBold
CloseBtn.TextSize = 16
CloseBtn.TextColor3 = Color3.fromRGB(255,255,255)
CloseBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
CloseBtn.BorderSizePixel = 0
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(1,0)

-- Caixa do velocímetro
local Box = Instance.new("Frame", Panel)
Box.Size = UDim2.new(1, -20, 0, 55)
Box.Position = UDim2.new(0, 10, 0, 55)
Box.BackgroundColor3 = Color3.fromRGB(45,45,45)
Box.BorderSizePixel = 0
Instance.new("UICorner", Box).CornerRadius = UDim.new(0,8)

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
Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

local Knob = Instance.new("Frame", Switch)
Knob.Size = UDim2.new(0, 22, 0, 22)
Knob.Position = UDim2.new(0, 2, 0.5, -11)
Knob.BackgroundColor3 = Color3.fromRGB(240,240,240)
Knob.BorderSizePixel = 0
Instance.new("UICorner", Knob).CornerRadius = UDim.new(1,0)

local StateLabel = Instance.new("TextLabel", Box)
StateLabel.Size = UDim2.new(0, 40, 1, 0)
StateLabel.Position = UDim2.new(1, -60, 0, 0)
StateLabel.BackgroundTransparency = 1
StateLabel.Font = Enum.Font.SourceSansBold
StateLabel.TextSize = 14
StateLabel.TextColor3 = Color3.fromRGB(255,255,255)
StateLabel.Text = "OFF"

local function updateSwitch()
	if enabled then
		Switch.BackgroundColor3 = Color3.fromRGB(160,90,255)
		Knob.Position = UDim2.new(1, -24, 0.5, -11)
		StateLabel.Text = "ON"
	else
		Switch.BackgroundColor3 = Color3.fromRGB(130,130,130)
		Knob.Position = UDim2.new(0, 2, 0.5, -11)
		StateLabel.Text = "OFF"
	end
end

Switch.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1
	or input.UserInputType == Enum.UserInputType.Touch then
		enabled = not enabled
		updateSwitch()

		if not enabled then
			for _, d in pairs(meters) do
				if d.gui then d.gui:Destroy() end
			end
			meters = {}
		end
	end
end)

-- ================= MINIMIZADO (CÍRCULO 🏁) =================
local Mini = Instance.new("TextButton", ScreenGui)
Mini.Size = UDim2.new(0, 50, 0, 50)
Mini.Position = Panel.Position
Mini.Text = "🏁"
Mini.Font = Enum.Font.SourceSansBold
Mini.TextSize = 26
Mini.TextColor3 = Color3.fromRGB(255,255,255)
Mini.BackgroundColor3 = Color3.fromRGB(10,10,10)
Mini.BorderSizePixel = 0
Mini.Visible = false
Instance.new("UICorner", Mini).CornerRadius = UDim.new(1,0)

-- Drag do círculo
do
	local dragging, dragStart, startPos
	Mini.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = Mini.Position
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			Mini.Position = UDim2.new(
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

-- ================= VELOCÍMETRO =================
local function createMeter(character, player)
	if not character:FindFirstChild("HumanoidRootPart") then return end
	local hrp = character.HumanoidRootPart

	local bb = Instance.new("BillboardGui", hrp)
	bb.Name = "SpeedMeter"
	bb.Size = UDim2.new(0, 140, 0, 35)
	bb.StudsOffset = Vector3.new(0, 3, 0)
	bb.AlwaysOnTop = true

	local txt = Instance.new("TextLabel", bb)
	txt.Size = UDim2.new(1,0,1,0)
	txt.BackgroundTransparency = 1
	txt.Font = Enum.Font.SourceSansBold
	txt.TextScaled = true
	txt.TextStrokeTransparency = 0

	meters[player] = { gui = bb, label = txt, lastPos = hrp.Position }
end

for _, p in pairs(Players:GetPlayers()) do
	p.CharacterAdded:Connect(function(char)
		task.wait(1)
		if enabled then createMeter(char, p) end
	end)
	if p.Character and enabled then createMeter(p.Character, p) end
end

RunService.RenderStepped:Connect(function(dt)
	if not enabled then return end
	for p, d in pairs(meters) do
		if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = p.Character.HumanoidRootPart
			local speed = math.floor((hrp.Position - d.lastPos).Magnitude / dt)
			d.lastPos = hrp.Position

			if speed <= 100 then
				d.label.Text = "Vel: " .. speed
				d.label.TextColor3 = Color3.fromRGB(0,255,0)
			else
				d.label.Text = "Vel: " .. speed .. " ⚠️"
				d.label.TextColor3 = Color3.fromRGB(255,0,0)
			end
		end
	end
end)

updateSwitch()
