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
local PetalsService = Knit.CreateService {
	Name = "PetalsService",
	Client = {
		Update = Knit.CreateSignal()	
	},
}

local SubscriptionService

-- ————————— ↢ ⭐️ ↣ —————————
-- Server Functions
function PetalsService:GetBalance(Player: Player)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Petals == nil then Profile.Data.Petals = 0 end
		return Profile.Data.Petals or 0
	else
		return 0
	end
end

function PetalsService:IncreasePetals(Player: Player, Amount: number, allowMultipliers: boolean)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Petals == nil then Profile.Data.Petals = 0 end
		if allowMultipliers then Amount = self:CalculateMultiplier(Player, Amount) end
		Profile.Data.Petals += Amount
	end
	self:UpdateClient(Player)
end

function PetalsService:DecreasePetals(Player: Player, Amount: number)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Petals == nil then Profile.Data.Petals = 0 end
		Profile.Data.Petals -= Amount
	end
	self:UpdateClient(Player)
end

function PetalsService:SetPetals(Player: Player, Amount: number)
	if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]

		if Profile.Data.Petals == nil then Profile.Data.Petals = 0 end
		Profile.Data.Petals = Amount
	end
	self:UpdateClient(Player)
end

function PetalsService:CalculateMultiplier(Player: Player, Amount: number)
	local Active, Expiration = SubscriptionService:GetSubscription(Player)

	if Knit.Gamepasses[Player][13588976] then -- x2 Points
		Amount += 2
	end
	if Knit.Gamepasses[Player][13588993] then -- x5 Points
		Amount += 5
	end
	if Active and Expiration then -- x2 Premium Points
		Amount += 2
	end

	return Amount
end

function PetalsService:UpdateClient(Player: Player)
	local Petals = self:GetBalance(Player)

	if Petals then
		self.Client.Update:Fire(Player, Petals)
	end
end

function PetalsService:KnitStart()
	SubscriptionService = Knit.GetService("SubscriptionService")
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return PetalsService