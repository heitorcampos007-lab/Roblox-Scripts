-- ===============================
-- Roblox Brookhaven - Painel Final Único
-- Velocímetro + Cronômetro
-- Delta Executor / LocalScript
-- ===============================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- FUNÇÕES ÚTEIS
-- ===============================
local function makeDraggable(frame)
	local dragging, dragStart, startPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	frame.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

-- ===============================
-- VARIÁVEIS
-- ===============================
local velEnabled = false
local chronoEnabled = false
local chronoRunning = false
local chronoTime = 0
local meters = {}

-- ===============================
-- GUI PRINCIPAL
-- ===============================
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "KartPanelGUI"
gui.ResetOnSpawn = false

-- Painel Principal
local painel = Instance.new("Frame", gui)
painel.Size = UDim2.fromOffset(280,140)
painel.Position = UDim2.fromScale(0.05,0.55)
painel.BackgroundColor3 = Color3.fromRGB(15,15,15)
painel.BorderSizePixel = 0
Instance.new("UICorner", painel).CornerRadius = UDim.new(0,12)
makeDraggable(painel)

-- Título
local titulo = Instance.new("TextLabel", painel)
titulo.Text = "Painel - Kart Brookhaven 🏁"
titulo.Size = UDim2.fromScale(1,0.2)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.new(1,1,1)
titulo.TextScaled = true

-- Botão X
local btnClose = Instance.new("TextButton", painel)
btnClose.Text = "X"
btnClose.Size = UDim2.fromScale(0.08,0.2)
btnClose.Position = UDim2.fromScale(0.92,0)
btnClose.BackgroundTransparency = 1
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.TextScaled = true

-- ===============================
-- BOTÕES ON/OFF
-- ===============================
local function criarToggle(texto, posY)
	local frame = Instance.new("Frame", painel)
	frame.Position = UDim2.fromScale(0.1,posY)
	frame.Size = UDim2.fromScale(0.8,0.12)
	frame.BackgroundColor3 = Color3.fromRGB(40,40,40)
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,8)

	local label = Instance.new("TextLabel", frame)
	label.Text = texto
	label.Size = UDim2.fromScale(0.6,1)
	label.BackgroundTransparency = 1
	label.TextColor3 = Color3.new(1,1,1)
	label.TextScaled = true

	local btn = Instance.new("TextButton", frame)
	btn.Size = UDim2.fromScale(0.35,0.7)
	btn.Position = UDim2.fromScale(0.63,0.15)
	btn.Text = "OFF"
	btn.BackgroundColor3 = Color3.fromRGB(120,0,0)
	btn.TextColor3 = Color3.new(1,1,1)
	btn.TextScaled = true
	Instance.new("UICorner", btn)

	return btn
end

local btnVel = criarToggle("Velocímetro",0.3)
local btnCron = criarToggle("Cronômetro",0.55)

-- ===============================
-- PAINEL DO CRONÔMETRO
-- ===============================
local painelCron = Instance.new("Frame", gui)
painelCron.Size = UDim2.fromOffset(220,80)
painelCron.Position = UDim2.fromScale(0.4,0.5)
painelCron.BackgroundColor3 = Color3.fromRGB(15,15,15)
painelCron.BorderSizePixel = 0
Instance.new("UICorner", painelCron).CornerRadius = UDim.new(0,12)
makeDraggable(painelCron)
painelCron.Visible = false

local tituloCron = Instance.new("TextLabel", painelCron)
tituloCron.Text = "Cronômetro"
tituloCron.Size = UDim2.fromScale(1,0.3)
tituloCron.BackgroundTransparency = 1
tituloCron.TextColor3 = Color3.new(1,1,1)
tituloCron.TextScaled = true

local btnCloseCron = Instance.new("TextButton", painelCron)
btnCloseCron.Text = "X"
btnCloseCron.Size = UDim2.fromScale(0.1,0.3)
btnCloseCron.Position = UDim2.fromScale(0.9,0)
btnCloseCron.BackgroundTransparency = 1
btnCloseCron.TextColor3 = Color3.new(1,1,1)
btnCloseCron.TextScaled = true

local cronLabel = Instance.new("TextLabel", painelCron)
cronLabel.Position = UDim2.fromScale(0,0.3)
cronLabel.Size = UDim2.fromScale(1,0.4)
cronLabel.BackgroundTransparency = 1
cronLabel.TextColor3 = Color3.new(1,1,1)
cronLabel.TextScaled = true
cronLabel.Text = "00:00:00"

local btnStartStop = Instance.new("TextButton", painelCron)
btnStartStop.Size = UDim2.fromScale(0.4,0.35)
btnStartStop.Position = UDim2.fromScale(0.05,0.65)
btnStartStop.Text = "Iniciar"
btnStartStop.BackgroundColor3 = Color3.fromRGB(130,0,255)
btnStartStop.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btnStartStop)

local btnReset = Instance.new("TextButton", painelCron)
btnReset.Size = UDim2.fromScale(0.4,0.35)
btnReset.Position = UDim2.fromScale(0.55,0.65)
btnReset.Text = "Resetar"
btnReset.BackgroundColor3 = Color3.fromRGB(100,100,100)
btnReset.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btnReset)

-- ===============================
-- CÍRCULOS MINIMIZADOS
-- ===============================
local miniPainel = Instance.new("TextButton", gui)
miniPainel.Size = UDim2.fromOffset(50,50)
miniPainel.Position = painel.Position
miniPainel.BackgroundColor3 = Color3.new(0,0,0)
miniPainel.Text = "🏁"
miniPainel.TextScaled = true
miniPainel.Visible = false
Instance.new("UICorner", miniPainel).CornerRadius = UDim.new(1,0)
makeDraggable(miniPainel)

local miniCron = Instance.new("TextButton", gui)
miniCron.Size = UDim2.fromOffset(50,50)
miniCron.Position = painelCron.Position
miniCron.BackgroundColor3 = Color3.new(0,0,0)
miniCron.Text = "⏱️"
miniCron.TextScaled = true
miniCron.Visible = false
Instance.new("UICorner", miniCron).CornerRadius = UDim.new(1,0)
makeDraggable(miniCron)

-- ===============================
-- BOTÕES E MINIMIZAÇÃO
-- ===============================
btnVel.MouseButton1Click:Connect(function()
	velEnabled = not velEnabled
	btnVel.Text = velEnabled and "ON" or "OFF"
	btnVel.BackgroundColor3 = velEnabled and Color3.fromRGB(0,120,0) or Color3.fromRGB(120,0,0)

	if not velEnabled then
		for _, d in pairs(meters) do
			if d.gui then d.gui:Destroy() end
		end
		meters = {}
	end
end)

btnCron.MouseButton1Click:Connect(function()
	chronoEnabled = not chronoEnabled
	btnCron.Text = chronoEnabled and "ON" or "OFF"
	btnCron.BackgroundColor3 = chronoEnabled and Color3.fromRGB(0,120,0) or Color3.fromRGB(120,0,0)
	painelCron.Visible = chronoEnabled
	if not chronoEnabled then miniCron.Visible = false end
	if chronoEnabled then chronoTime = 0 end
end)

btnStartStop.MouseButton1Click:Connect(function()
	chronoRunning = not chronoRunning
	btnStartStop.Text = chronoRunning and "Parar" or "Iniciar"
	btnStartStop.BackgroundColor3 = chronoRunning and Color3.fromRGB(255,0,0) or Color3.fromRGB(130,0,255)
end)

btnReset.MouseButton1Click:Connect(function()
	chronoTime = 0
end)

btnClose.MouseButton1Click:Connect(function()
	TweenService:Create(painel,TweenInfo.new(0.25),{Size=UDim2.fromOffset(0,0)}):Play()
	task.wait(0.25)
	painel.Visible = false
	miniPainel.Position = painel.Position
	miniPainel.Visible = true
end)

btnCloseCron.MouseButton1Click:Connect(function()
	TweenService:Create(painelCron,TweenInfo.new(0.25),{Size=UDim2.fromOffset(0,0)}):Play()
	task.wait(0.25)
	painelCron.Visible = false
	miniCron.Position = painelCron.Position
	miniCron.Visible = true
end)

miniPainel.MouseButton1Click:Connect(function()
	painel.Visible = true
	TweenService:Create(painel,TweenInfo.new(0.25),{Size=UDim2.fromOffset(280,140)}):Play()
	miniPainel.Visible = false
end)

miniCron.MouseButton1Click:Connect(function()
	painelCron.Visible = true
	TweenService:Create(painelCron,TweenInfo.new(0.25),{Size=UDim2.fromOffset(220,80)}):Play()
	miniCron.Visible = false
end)

-- ===============================
-- LOOP PRINCIPAL
-- ===============================
RunService.RenderStepped:Connect(function(dt)
	-- Velocímetro
	if velEnabled then
		for _, p in pairs(Players:GetPlayers()) do
			if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = p.Character.HumanoidRootPart

				-- ======= VELOCIDADE FIXA DO VEÍCULO =======
				local vehicleSpeed = hrp:FindFirstChild("VehicleSeat") and hrp.VehicleSeat.MaxSpeed or 0
				local convSpeed = vehicleSpeed

				local meter = meters[p]
				if not meter then
					local bb = Instance.new("BillboardGui", hrp)
					bb.Size = UDim2.new(0,140,0,35)
					bb.StudsOffset = Vector3.new(0,3,0)
					bb.AlwaysOnTop = true

					local nameLabel = Instance.new("TextLabel", bb)
					nameLabel.Size = UDim2.new(1,0,0.5,0)
					nameLabel.BackgroundTransparency = 1
					nameLabel.Text = p.Name
					nameLabel.Font = Enum.Font.SourceSansBold
					nameLabel.TextScaled = true
					nameLabel.TextColor3 = Color3.new(1,1,1)

					local speedLabel = Instance.new("TextLabel", bb)
					speedLabel.Size = UDim2.new(1,0,0.5,0)
					speedLabel.Position = UDim2.new(0,0,0.5,0)
					speedLabel.BackgroundTransparency = 1
					speedLabel.Font = Enum.Font.SourceSansBold
					speedLabel.TextScaled = true
					speedLabel.TextStrokeTransparency = 0

					meters[p] = {gui=bb, speedLabel=speedLabel}
					meter = meters[p]
				end

				if convSpeed <= 100 then
					meter.speedLabel.TextColor3 = Color3.fromRGB(0,255,0)
					meter.speedLabel.Text = "Vel: "..convSpeed
				else
					meter.speedLabel.TextColor3 = Color3.fromRGB(255,0,0)
					meter.speedLabel.Text = "Vel: "..convSpeed.." 🚨"
				end
			end
		end
	else
		for _, d in pairs(meters) do
			if d.gui then d.gui:Destroy() end
		end
		meters = {}
	end

	-- Cronômetro
	if chronoEnabled and chronoRunning then
		chronoTime += dt
	end
	local minutes = math.floor(chronoTime/60)
	local seconds = math.floor(chronoTime%60)
	local ms = math.floor((chronoTime*100)%100)
	cronLabel.Text = string.format("%02d:%02d:%02d",minutes,seconds,ms)
end)
