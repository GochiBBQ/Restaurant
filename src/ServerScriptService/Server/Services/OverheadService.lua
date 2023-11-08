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
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local OverheadService = Knit.CreateService {
	Name = "OverheadService",
	Client = {
		Update = Knit.CreateSignal()	
	},
}

-- ————————— ↢ ⭐️ ↣ —————————
-- Server Functions
function OverheadService:KnitStart()
	for _, Player in pairs(PlayerService:GetPlayers()) do
		Player.CharacterAdded:Connect(function()
			self:CreateFunction(Player)
		end)
		self:CreateFunction(Player)
	end

	PlayerService.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function()
			self:CreateFunction(Player)
		end)
	end)
end

function OverheadService:CreateFunction(Player: Player)
	local ClonedFrame = Knit.Static:WaitForChild("OverheadTemplate"):Clone()
	local Character = Player.Character or Player.CharacterAdded:Wait()
	repeat task.wait() until Character.Head
	
	ClonedFrame.Frame.Rank.Text = Player:GetRoleInGroup(6975354)
	ClonedFrame.Frame.Username.Text = Player.Name
	ClonedFrame.Parent = Character.Head
	
	self:TweenFunction(Player)
end

function OverheadService:TweenFunction(Player: Player)
	while task.wait() do
		local Character = Player.Character or Player.CharacterAdded:Wait()
		local Overhead = Character.Head:WaitForChild("OverheadTemplate"):WaitForChild("Frame")
		local Badges = Overhead:WaitForChild("Icons")
		
		if #Badges:GetChildren() > 1 then
			for _, Badge in next, Badges:GetChildren() do
				TweenService:Create(Badge, TweenInfo.new(1), {BackgroundTransparency = 0}):Play()
				TweenService:Create(Badge.Misc, TweenInfo.new(1), {TextTransparency = 0}):Play()
				task.wait(5)
				
				TweenService:Create(Badge, TweenInfo.new(1), {BackgroundTransparency = 1}):Play()
				TweenService:Create(Badge.Misc, TweenInfo.new(1), {TextTransparency = 1}):Play()
				task.wait(0.3)
			end
		end
	end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return OverheadService