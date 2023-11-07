--# Services
local Services = setmetatable({}, {
	__index = function(self, index)
		self[index] = game:GetService(index)
		return self[index]
	end
})

--# Dependencies
local Shared = Services.ReplicatedStorage:WaitForChild('Modules')
local spr = require(Shared:WaitForChild('spr'))

--# Variables
local player = Services.Players.LocalPlayer
local camera = workspace.CurrentCamera

local blur = Instance.new('BlurEffect')
blur.Size = 0
blur.Parent = camera

local colorCorrection = Instance.new('ColorCorrectionEffect')
colorCorrection.TintColor = Color3.fromRGB(255, 255, 255)
colorCorrection.Parent = camera

--# Module
local UIEffects = {}

function UIEffects:CameraZoomIn()
	blur.Size = 0
	spr.target(blur, 1, 4, { Size = 12 })
	spr.target(camera, 1, 4, { FieldOfView = 50 })
end

function UIEffects:CameraZoomOut()
	blur.Size = 12
	spr.target(blur, 1, 4, { Size = 0 })
	spr.target(camera, 1, 4, { FieldOfView = 70 })
end

function UIEffects:FadeScreenIn()
	spr.target(colorCorrection, 1, 4, { TintColor = Color3.fromRGB(53, 53, 53) })
end

function UIEffects:FadeScreenOut()
	spr.target(colorCorrection, 1, 4, { TintColor = Color3.fromRGB(255, 255, 255) })
end

function UIEffects:HideUIs()
	local Knit = require(Services.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
	local UIController = Knit.GetController("UIController")
	local HUD = UIController.UI:WaitForChild("HUD")
	spr.target(HUD, 1, 4, { Position = UDim2.fromScale(-0.1, 0.5) })
end

function UIEffects:ShowUIs()
	local Knit = require(Services.ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
	local UIController = Knit.GetController("UIController")
	local HUD = UIController.UI:WaitForChild("HUD")
	spr.target(HUD, 1, 4, { Position = UDim2.fromScale(0, 0.5) })
end

return UIEffects