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

end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return OverheadService