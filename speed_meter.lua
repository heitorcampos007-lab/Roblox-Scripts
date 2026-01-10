-- ===============================
-- CONFIGURAÇÕES
-- ===============================
local player = game.Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

-- Conversão Brookhaven (bug)
local function converterVelocidade(v)
	if v <= 100 then
		return math.floor((v / 10) * 7 + 0.5)
	else
		return 80
	end
end

-- Arredondar de 10 em 10
local function arredondar10(v)
	return math.floor(v / 10) * 10
end

-- ===============================
-- GUI
-- ===============================
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.Name = "PainelKart"

-- Painel principal
local painel = Instance.new("Frame", gui)
painel.Size = UDim2.fromScale(0.28, 0.25)
painel.Position = UDim2.fromScale(0.05, 0.55)
painel.BackgroundColor3 = Color3.fromRGB(15,15,15)
painel.BorderSizePixel = 0
painel.Name = "Painel"

Instance.new("UICorner", painel).CornerRadius = UDim.new(0,12)

-- Botão minimizar (X)
local minimizar = Instance.new("TextButton", painel)
minimizar.Text = "X"
minimizar.Size = UDim2.fromScale(0.08,0.15)
minimizar.Position = UDim2.fromScale(0.9,0.05)
minimizar.BackgroundTransparency = 1
minimizar.TextColor3 = Color3.new(1,1,1)
minimizar.TextScaled = true

-- Título
local titulo = Instance.new("TextLabel", painel)
titulo.Text = "Painel - Kart Brookhaven 🏁"
titulo.Size = UDim2.fromScale(1,0.18)
titulo.BackgroundTransparency = 1
titulo.TextColor3 = Color3.new(1,1,1)
titulo.TextScaled = true

-- Nick
local nick = Instance.new("TextLabel", painel)
nick.Text = player.Name
nick.Position = UDim2.fromScale(0,0.18)
nick.Size = UDim2.fromScale(1,0.12)
nick.BackgroundTransparency = 1
nick.TextColor3 = Color3.new(1,1,1)
nick.TextScaled = true

-- Velocidade
local velLabel = Instance.new("TextLabel", painel)
velLabel.Text = "Vel: 0"
velLabel.Position = UDim2.fromScale(0,0.3)
velLabel.Size = UDim2.fromScale(1,0.15)
velLabel.BackgroundTransparency = 1
velLabel.TextColor3 = Color3.fromRGB(0,255,0)
velLabel.TextScaled = true

-- ===============================
-- BOTÕES
-- ===============================
local function criarToggle(texto, posY)
	local frame = Instance.new("Frame", painel)
	frame.Position = UDim2.fromScale(0.1, posY)
	frame.Size = UDim2.fromScale(0.8,0.14)
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

local velOn = false
local cronOn = false

local btnVel = criarToggle("Velocímetro", 0.48)
local btnCron = criarToggle("Cronômetro", 0.65)

-- ===============================
-- CRONÔMETRO
-- ===============================
local cronLabel = Instance.new("TextLabel", painel)
cronLabel.Position = UDim2.fromScale(0,0.82)
cronLabel.Size = UDim2.fromScale(1,0.15)
cronLabel.BackgroundTransparency = 1
cronLabel.TextColor3 = Color3.new(1,1,1)
cronLabel.TextScaled = true
cronLabel.Visible = false

local tempo = 0

-- ===============================
-- VELOCIDADE DO VEÍCULO
-- ===============================
local function pegarVelocidadeVeiculo()
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local hrp = player.Character.HumanoidRootPart
		local vel = hrp.AssemblyLinearVelocity.Magnitude
		return arredondar10(vel)
	end
	return 0
end

-- ===============================
-- TOGGLES
-- ===============================
btnVel.MouseButton1Click:Connect(function()
	velOn = not velOn
	btnVel.Text = velOn and "ON" or "OFF"
	btnVel.BackgroundColor3 = velOn and Color3.fromRGB(0,120,0) or Color3.fromRGB(120,0,0)
end)

btnCron.MouseButton1Click:Connect(function()
	cronOn = not cronOn
	btnCron.Text = cronOn and "ON" or "OFF"
	btnCron.BackgroundColor3 = cronOn and Color3.fromRGB(0,120,0) or Color3.fromRGB(120,0,0)
	cronLabel.Visible = cronOn
	tempo = 0
end)

-- ===============================
-- MINIMIZAR
-- ===============================
local botaoMini = Instance.new("TextButton", gui)
botaoMini.Size = UDim2.fromScale(0.06,0.1)
botaoMini.Position = UDim2.fromScale(0.05,0.8)
botaoMini.BackgroundColor3 = Color3.new(0,0,0)
botaoMini.Text = "🏁"
botaoMini.TextScaled = true
botaoMini.Visible = false
Instance.new("UICorner", botaoMini).CornerRadius = UDim.new(1,0)

minimizar.MouseButton1Click:Connect(function()
	TweenService:Create(painel, TweenInfo.new(0.3), {Size = UDim2.fromScale(0,0)}):Play()
	task.wait(0.3)
	painel.Visible = false
	botaoMini.Visible = true
end)

botaoMini.MouseButton1Click:Connect(function()
	painel.Visible = true
	TweenService:Create(painel, TweenInfo.new(0.3), {Size = UDim2.fromScale(0.28,0.25)}):Play()
	botaoMini.Visible = false
end)

-- ===============================
-- LOOP
-- ===============================
RunService.RenderStepped:Connect(function(dt)
	if velOn then
		local v = pegarVelocidadeVeiculo()
		local conv = converterVelocidade(v)

		if v <= 100 then
			velLabel.TextColor3 = Color3.fromRGB(0,255,0)
			velLabel.Text = "Vel: "..conv
		else
			velLabel.TextColor3 = Color3.fromRGB(255,0,0)
			velLabel.Text = "Vel: "..conv.." 🚨"
		end
	end

	if cronOn then
		tempo += dt
		cronLabel.Text = string.format("Cronômetro: %.2f s", tempo)
	end
end)
