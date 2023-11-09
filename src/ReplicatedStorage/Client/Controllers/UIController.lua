--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Gochí Restaurant 🥩
https://www.roblox.com/groups/5874921/Goch#!/about

]]

-- ————————— ↢ ⭐️ ↣ —————————
-- Services
local ContentProvider = game:GetService("ContentProvider")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables

local UIEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIEffects"))
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("spr"))

local IconController = require(ReplicatedStorage.Modules.Icon.IconController)
local Themes = require(ReplicatedStorage.Modules.Icon.Themes)
local Icon = require(ReplicatedStorage.Modules.Icon)

local Knit = require(ReplicatedStorage.Packages.Knit)
local Player = PlayerService.LocalPlayer
local UISelect = SoundService.UISelect
local UIHover = SoundService.UIHover

-- ————————— ↢ ⭐️ ↣ —————————
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

-- ————————— ↢ ⭐️ ↣ —————————
-- Client Functions
function UIController:RegisterButtonClick(Button)
    Button.MouseButton1Click:Connect(function()
		local FrameFound = false
		UISelect:Play()

		if self.Pages[Button.Parent.Name].Visible then
			spr.target(self.Pages[Button.Parent.Name], 1, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.55)})
			UIEffects:CameraZoomOut()
			
			task.wait(0.15)
			self.Pages[Button.Parent.Name].Visible = false
		else
			for _, MenuPages in pairs(self.Pages:GetChildren()) do
				if MenuPages.Visible then
					spr.target(MenuPages, 1, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.55)})
					task.wait(0.15)
					MenuPages.Visible = false
					FrameFound = true
				end
			end

			self.Pages[Button.Parent.Name].Visible = true
			spr.target(self.Pages[Button.Parent.Name], 1, 4, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)})
			if not FrameFound then UIEffects:CameraZoomIn() end
		end
    end)
end

function UIController:NavigationMenu()
    for Index, MenuButtons in pairs(self.NavigationButtons:GetDescendants()) do
        if MenuButtons:IsA("TextButton") then
            MenuButtons.MouseEnter:Connect(function()
                spr.target(MenuButtons, 0.3, 4, {Rotation = 8})
				UIHover:Play()
            end)
            
            MenuButtons.MouseLeave:Connect(function()
                spr.target(MenuButtons, 0.3, 4, {Rotation = 0})
            end)

			self:RegisterButtonClick(MenuButtons)
        end
    end
end

function UIController:KnitInit()
	local playerGui = Knit.Player:WaitForChild("PlayerGui")
	self.NavigationButtons = playerGui:WaitForChild("GochiUI"):WaitForChild("Navigation")
	self.Pages = playerGui:WaitForChild("GochiUI"):WaitForChild("Pages")

	-- load all UI controllers into its own env
	self.Interfaces = {}
	for _, interface in ipairs(script:GetChildren()) do
		self.Interfaces[interface.Name] = require(interface)
		
		if self.Interfaces[interface.Name].Init then
			self.Interfaces[interface.Name]:Init(Knit)	
		end
	end
	
	-- preload all content
	local descendants = self.Pages:GetDescendants()
	ContentProvider:PreloadAsync(descendants)
	
	-- process ui's marked StartHidden
	for _, frame in ipairs(self.Pages:GetChildren()) do
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

	self:NavigationMenu()
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Controller to Knit
return UIController