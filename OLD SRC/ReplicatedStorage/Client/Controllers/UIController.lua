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
local TeamService = game:GetService("Teams")

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

local CurrentFrame = nil
local RankService

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
			CurrentFrame = nil
			
			task.wait(0.15)
			self.Pages[Button.Parent.Name].Visible = false
		else
			CurrentFrame = Button.Name

			for _, MenuPages in pairs(self.Pages:GetChildren()) do
				if MenuPages.Visible then
					spr.target(MenuPages, 1, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.55)})
					task.wait(0.15)
					MenuPages.Visible = false

					if MenuPages.Name == "ChefQueue" then
						local icon = IconController.getIcon("ChefQueue")
						icon:deselect()
					end
					FrameFound = true
				end
			end

			self.Pages[Button.Parent.Name].Visible = true
			spr.target(self.Pages[Button.Parent.Name], 1, 4, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)})
			if not FrameFound then UIEffects:CameraZoomIn() end
		end
    end)
end

function UIController:RegisterButtonClick(Button: GuiButton)
	local function CheckOpenedFrames()
		for i, UIPages in pairs(self.Pages:GetChildren()) do
			if UIPages.Visible then
				spr.target(UIPages, 1, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.55)})
				task.wait(0.15)
				UIPages.Visible = false

				return true
			end
		end
	end

	Button.MouseButton1Click:Connect(function()
		
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
	self.Backpack = playerGui:WaitForChild("Backpack")

	RankService = Knit.GetService("RankService")

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

function UIController:AdvertisementBoards()
	local AdvertBoards = workspace.Functionality.Advertisements
	local Character = Player.Character or Player.CharacterAdded:Wait()
	local Distance = 15 -- How far in studs the player must be.

	local function CheckDistance()
		for i, AdvertBoard in pairs(AdvertBoards:GetChildren()) do
			local Humanoid = Character:WaitForChild("HumanoidRootPart")
			local Surface = AdvertBoard.SurfaceDisplay
			local Frame = Surface.SurfaceGui.Frame
	
			if Humanoid then
				if (AdvertBoard.SurfaceDisplay.Position - Humanoid.Position).Magnitude < Distance then
					spr.target(Frame, 0.9, 2, { Position = UDim2.fromScale(0.02, 0.01)})
				else
					spr.target(Frame, 0.9, 2, { Position = UDim2.fromScale(0.02, 1)})
				end
			end
		end
	end

	task.spawn(function()
		while task.wait() do
			CheckDistance()
		end
	end)
end

function UIController:TopbarMenu()
	if Player:GetAttribute("GochiRank") >= 60 then 
		local icon = Icon.new()
		icon:set("dropdownSquareCorners", false)
		icon:setLabel("🔑 Staff Options")
		icon:setName("StaffOptions")
		icon:setRight()
		icon:setDropdown({
			Icon.new()
				:setLabel("📈 Dashboard")
				:setName("Dashboard")
				,
			Icon.new()
				:setLabel("🔪 Chef Queue")
				:setName("ChefQueue")
				:setEnabled(Player.Team == TeamService["Cook"] and true or false)
		})

		local icon = IconController.getIcon("ChefQueue")
		icon.selected:Connect(function()
			local FrameFound = false
			for _, MenuPages in pairs(self.Pages:GetChildren()) do
				if MenuPages.Visible then
					spr.target(MenuPages, 1, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.55)})
					task.wait(0.15)
					MenuPages.Visible = false
					FrameFound = true
				end
			end

			self.Pages.ChefQueue.Visible = true
			spr.target(self.Pages.ChefQueue, 1, 4, { GroupTransparency = 0, Position = UDim2.fromScale(0.5, 0.5)})
			if not FrameFound then UIEffects:CameraZoomIn() end
			CurrentFrame = "ChefQueue"
		end)

		icon.deselected:Connect(function()
			spr.target(self.Pages.ChefQueue, 1, 4, { GroupTransparency = 1, Position = UDim2.fromScale(0.5, 0.55)})
			if not CurrentFrame or CurrentFrame == "ChefQueue" then UIEffects:CameraZoomOut() end
			if CurrentFrame == "ChefQueue" then CurrentFrame = nil end
			
			task.wait(0.15)
			self.Pages.ChefQueue.Visible = false
		end)

		Player:GetPropertyChangedSignal("TeamColor"):Connect(function()
			if Player.Team == TeamService["Cook"] then
				local icon = IconController.getIcon("ChefQueue")
				icon:setEnabled(true)
			else
				local icon = IconController.getIcon("ChefQueue")
				icon:setEnabled(false)
			end
		end)
	end
end

function UIController:KnitStart()
	IconController.setGameTheme(Themes["Gochi"])
	for _, controller in pairs(self.Interfaces) do
		task.spawn(controller.Start, controller, Knit)
	end

	self:AdvertisementBoards()
	self:NavigationMenu()
	self:TopbarMenu()
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Controller to Knit
return UIController