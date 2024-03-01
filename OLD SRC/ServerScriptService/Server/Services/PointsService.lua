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
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local PointsService = Knit.CreateService {
	Name = "PointsService",
	Client = {
		Update = Knit.CreateSignal()	
	},
}

-- ————————— ↢ ⭐️ ↣ —————————
-- Server Functions
function PointsService:GetBalance(Player: Player)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Petals == nil then Profile.Data.Petals = 0 end
		return Profile.Data.Petals or 0
	else
		return 0
	end
end

function PointsService:IncreasePoints(Player: Player, Amount: number)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Points == nil then Profile.Data.Points = 0 end
		Profile.Data.Points += Amount
	end
	self:UpdateAmount(Player)
end

function PointsService:DecreasePoints(Player: Player, Amount: number)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Points == nil then Profile.Data.Points = 0 end
		Profile.Data.Points -= Amount
	end
	self:UpdateAmount(Player)
end

function PointsService:SetPoints(Player: Player, Amount: number)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Points == nil then Profile.Data.Points = 0 end
		Profile.Data.Points = Amount
	end
	self:UpdateAmount(Player)
end

function PointsService:UpdateAmount(Player, Amount: number)
	local Profile = Knit.Profiles[Player]
	local Amount = Profile.Data.Points

	Player:WaitForChild("leaderstats"):WaitForChild("Worker Points").Value = Amount
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return PointsService