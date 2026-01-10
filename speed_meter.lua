-- ===============================
-- Roblox Brookhaven - Painel Final Único
-- Velocímetro (veículo) + Cronômetro
-- Painéis arrastáveis, mesmo minimizados
-- ===============================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- ===============================
-- FUNÇÃO PARA ARRASTAR QUALQUER FRAME
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
-- FUNÇÃO PARA PEGAR VELOCIDADE REAL DO VEÍCULO
-- ===============================
local function getCarSpeedValue(character)
	if not character then return nil end
	local humanoid = character:FindFirstChildWhichIsA("Humanoid")
	if not humanoid then return nil end
	local seat = humanoid.SeatPart
	if not seat then return nil end
	local carModel = seat:FindFirstAncestorWhichIsA("Model")
	if not carModel then return nil end

	for _, obj in ipairs(carModel:GetDescendants()) do
		if obj:IsA("NumberValue") and obj.Name:lower():find("speed") then
			return obj
		end
	end
	return nil
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

-- ---------- PAINEL VELOCÍMETRO ----------
local painel = Instance.new("Frame", gui)
painel.Size = UDim2.fromOffset(280,140)
painel.Position = UDim2.fromScale(0.05,0.55)
painel.BackgroundColor3 = Color3.fromRGB(15,15,15)
painel.BorderSizePixel = 0
Instance.new("UICorner", painel).CornerRadius = UDim.new(0,12)
makeDraggable(painel)

local titulo = Instance.new("TextLabel", painel)
titulo.Text = "Painel - Kart Brookhaven 🏁"
titulo.Size = UDim2.fromScale(1,0.2)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.new(1,1,1)
titulo.TextScaled = true

local btnClose = Instance.new("TextButton", painel)
btnClose.Text = "X"
btnClose.Size = UDim2.fromScale(0.08,0.2)
btnClose.Position = UDim2.fromScale(0.92,0)
btnClose.BackgroundTransparency = 1
btnClose.TextColor3 = Color3.new(1,1,1)
btnClose.TextScaled = true

-- Função Mini Painel 🏁
local miniPainel = Instance.new("TextButton", gui)
miniPainel.Size = UDim2.fromOffset(50,50)
miniPainel.Position = painel.Position
miniPainel.BackgroundColor3 = Color3.new(0,0,0)
miniPainel.Text = "🏁"
miniPainel.TextScaled = true
miniPainel.Visible = false
Instance.new("UICorner", miniPainel).CornerRadius = UDim.new(1,0)
makeDraggable(miniPainel)

btnClose.MouseButton1Click:Connect(function()
	-- animação de minimizar
	TweenService:Create(painel,TweenInfo.new(0.3),{Size=UDim2.fromOffset(50,50)}):Play()
	task.wait(0.3)
	painel.Visible = false
	miniPainel.Position = painel.Position
	miniPainel.Visible = true
end)
miniPainel.MouseButton1Click:Connect(function()
	painel.Position = miniPainel.Position
	painel.Size = UDim2.fromOffset(280,140)
	painel.Visible = true
	miniPainel.Visible = false
end)

-- ---------- BOTÃO VELOCÍMETRO ----------
local btnVel = Instance.new("TextButton", painel)
btnVel.Size = UDim2.fromOffset(80,30)
btnVel.Position = UDim2.fromOffset(20,50)
btnVel.Text = "OFF"
btnVel.BackgroundColor3 = Color3.fromRGB(130,0,0)
btnVel.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", btnVel)
btnVel.MouseButton1Click:Connect(function()
	velEnabled = not velEnabled
	if velEnabled then
		btnVel.Text = "ON"
		btnVel.BackgroundColor3 = Color3.fromRGB(0,180,0)
		-- cria velocímetros para todos players
		for _,p in pairs(Players:GetPlayers()) do
			if p.Character then
				local hrp = p.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					local bb = Instance.new("BillboardGui", hrp)
					bb.Name = "SpeedMeter"
					bb.Size = UDim2.new(0,140,0,35)
					bb.StudsOffset = Vector3.new(0,3,0)
					bb.AlwaysOnTop = true
					local txt = Instance.new("TextLabel", bb)
					txt.Size = UDim2.new(1,0,1,0)
					txt.BackgroundTransparency = 1
					txt.Font = Enum.Font.SourceSansBold
					txt.TextScaled = true
					txt.TextStrokeTransparency = 0
					txt.TextColor3 = Color3.new(0,1,0)
					txt.Text = "Vel: 0"
					meters[p] = {gui=bb,label=txt}
				end
			end
		end
	else
		btnVel.Text = "OFF"
		btnVel.BackgroundColor3 = Color3.fromRGB(130,0,0)
		-- remove velocímetros
		for _,d in pairs(meters) do
			if d.gui then d.gui:Destroy() end
		end
		meters = {}
	end
end)

-- Atualiza velocímetro
RunService.RenderStepped:Connect(function()
	if not velEnabled then return end
	for p,d in pairs(meters) do
		if p.Character then
			local speedVal = getCarSpeedValue(p.Character)
			local speed = 0
			if speedVal then speed = math.floor(speedVal.Value) end
			d.label.Text = "Vel: "..speed
			if speed <= 100 then
				d.label.TextColor3 = Color3.fromRGB(0,255,0)
			else
				d.label.TextColor3 = Color3.fromRGB(255,0,0)
				d.label.Text = d.label.Text.." ⚠️"
			end
		end
	end
end)

-- ---------- PAINEL CRONÔMETRO ----------
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

-- Mini Cronômetro ⏱️
local miniCron = Instance.new("TextButton", gui)
miniCron.Size = UDim2.fromOffset(50,50)
miniCron.Position = painelCron.Position
miniCron.BackgroundColor3 = Color3.new(0,0,0)
miniCron.Text = "⏱️"
miniCron.TextScaled = true
miniCron.Visible = false
Instance.new("UICorner", miniCron).CornerRadius = UDim.new(1,0)
makeDraggable(miniCron)

-- Botão Cronômetro On/Off
btnCron.MouseButton1Click:Connect(function()
	chronoEnabled = not chronoEnabled
	if chronoEnabled then
		btnCron.Text = "ON"
		btnCron.BackgroundColor3 = Color3.fromRGB(0,180,0)
		painelCron.Visible = true
	else
		btnCron.Text = "OFF"
		btnCron.BackgroundColor3 = Color3.fromRGB(130,0,0)
		painelCron.Visible = false
	end
end)

-- Fechar painel cronômetro
btnCloseCron.MouseButton1Click:Connect(function()
	TweenService:Create(painelCron,TweenInfo.new(0.3),{Size=UDim2.fromOffset(50,50)}):Play()
	task.wait(0.3)
	painelCron.Visible = false
	miniCron.Position = painelCron.Position
	miniCron.Visible = true
end)
miniCron.MouseButton1Click:Connect(function()
	painelCron.Position = miniCron.Position
	painelCron.Size = UDim2.fromOffset(220,80)
	painelCron.Visible = true
	miniCron.Visible = false
end)

-- Cronômetro lógica
btnStartStop.MouseButton1Click:Connect(function()
	chronoRunning = not chronoRunning
	if chronoRunning then
		btnStartStop.Text = "Parar"
		btnStartStop.BackgroundColor3 = Color3.fromRGB(255,0,0)
	else
		btnStartStop.Text = "Iniciar"
		btnStartStop.BackgroundColor3 = Color3.fromRGB(130,0,255)
	end
end)

btnReset.MouseButton1Click:Connect(function()
	chronoTime = 0
	cronLabel.Text = "00:00:00"
end)

RunService.RenderStepped:Connect(function(dt)
	if chronoRunning then
		chronoTime = chronoTime + dt
		local minutes = math.floor(chronoTime/60)
		local seconds = math.floor(chronoTime%60)
		local milliseconds = math.floor((chronoTime*100)%100)
		cronLabel.Text = string.format("%02d:%02d:%02d",minutes,seconds,milliseconds)
	end
end)
