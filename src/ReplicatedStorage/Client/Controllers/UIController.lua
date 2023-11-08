local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = PlayerService.LocalPlayer

local UIEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIEffects"))
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("spr"))

local IconController = require(ReplicatedStorage.Modules.Icon.IconController)
local Themes = require(ReplicatedStorage.Modules.Icon.Themes)
local Icon = require(ReplicatedStorage.Modules.Icon)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Controller
local UIController = Knit.CreateController { 
	Name = "UIController"
}

local function FormatNumber(amount) -- Adds commas to number digits.
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
			break
		end
	end
	return formatted
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Client Functions
function UIController:KnitInit()
	-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵
	-- init self
	local playerGui = Knit.Player:WaitForChild("PlayerGui")
	self.UI = playerGui:WaitForChild("GochiUI")
	self.HUD = playerGui:WaitForChild("GochiUI"):WaitForChild("HUD")
	
	-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵
	-- load all UI controllers into its own env
	self.Interfaces = {}
	for _, interface in ipairs(script:GetChildren()) do
		self.Interfaces[interface.Name] = require(interface)
		
		if self.Interfaces[interface.Name].Init then
			self.Interfaces[interface.Name]:Init(Knit)	
		end
	end
	
	-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵
	-- preload all content
	local descendants = self.UI:GetDescendants()
	Services.ContentProvider:PreloadAsync(descendants)
	
	-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵
	-- process ui's marked StartHidden
	for _, frame in ipairs(self.UI:GetChildren()) do
		if frame:GetAttribute("StartHidden") then
			frame.Visible = false
			frame.Position = UDim2.fromScale(0.5, 0.55)
			frame.GroupTransparency = 1
		end
	end
end

function UIController:KnitStart()
	for _, controller in pairs(self.Interfaces) do
		task.spawn(controller.Start, controller, Knit)
	end
	self:ManageHUD()
	
	repeat task.wait() until Player:GetAttribute("WorkerPoints") and Player:GetAttribute("Petals")
	
	local PIcon = Topbar.new()
	:setProperty("deselectWhenOtherIconSelected", false)
	:setImage(8615863895)
	:setLabel(commaValue(Player:GetAttribute("Petals")))
	:setLeft()
	:lock()
	
	local WPIcon = Topbar.new()
	:setProperty("deselectWhenOtherIconSelected", false)
	:setImage(9812538631)
	:setLabel(commaValue(Player:GetAttribute("WorkerPoints")))
	:setLeft()
	:lock()

	Player:GetAttributeChangedSignal("Petals"):Connect(function()
		PIcon:setLabel(commaValue(Player:GetAttribute("Petals")))
	end)
	
	Player:GetAttributeChangedSignal("WorkerPoints"):Connect(function()
		WPIcon:setLabel(commaValue(Player:GetAttribute("WorkerPoints")))
	end)
end

function UIController:ManageHUD()
	local HUD = UIController.HUD

	for _, Button in pairs(HUD:GetDescendants()) do
		if Button:IsA("ImageButton") then
			Button.MouseButton1Down:Connect(function()
				if Knit.CurrentFrame and Knit.CurrentFrame.Name == Button.Parent.Name then return end
				if Knit.CurrentFrame then
					spr.target(Knit.CurrentFrame, 1, 4, { Position = UDim2.fromScale(0.5, 0.55), GroupTransparency = 1})
					UIEffects:CameraZoomOut()
					task.wait(0.5)
					Knit.CurrentFrame.Visible = false
					Knit.CurrentFrame = nil
				end

				Knit.CurrentFrame = UIController.UI[Button.Parent.Name]
				Knit.CurrentFrame.Visible = true
				
				spr.target(Knit.CurrentFrame, 0.5, 4, { Position = UDim2.fromScale(0.5, 0.5), GroupTransparency = 0})
				UIEffects:CameraZoomIn()
			end)

			Button.MouseEnter:Connect(function()
				spr.target(Button, 0.5, 4, { Rotation = 10})
			end)

			Button.MouseLeave:Connect(function()
				spr.target(Button, 0.5, 4, { Rotation = 0})
			end)
		end
	end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Controller to Knit
return UIController