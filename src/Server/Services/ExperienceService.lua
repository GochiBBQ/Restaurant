--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Signal = require(ReplicatedStorage.Packages.Signal)

-- Create Knit Service
local ExperienceService = Knit.CreateService({
	Name = "ExperienceService",
	UpdateXP = Signal.new(),
	Client = {
		UpdateClient = Knit.CreateSignal(),
	},
})

local productFunctions = {}

-- Variables

local RankService

-- Server Functions
function ExperienceService:KnitStart()
	RankService = Knit.GetService("RankService")
end

function ExperienceService:Get(Player)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then
		local XP = Profile.Data.XP
		local Level = Profile.Data.Level

		if Level < 1 then
			Profile.Data.Level = 1
		end

		return XP, self:GetRequired(Player), Level
	else
		return 0
	end
end

function ExperienceService:GetRequired(Player)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then
		local XP = Profile.Data.XP
		local Level = Profile.Data.Level

		return 500 * (Level * 1.5)
	end
end

function ExperienceService:Set(Player, Amount)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then
		if Amount >= 0 then
			Profile.Data.XP = tonumber(Amount)

			if (Profile.Data.XP / self:GetRequired(Player)) >= 1 then
				while (Profile.Data.XP / self:GetRequired(Player)) >= 1 do
					Profile.Data.Level += 1
				end
			else
				local newLevel = 1

				while (Profile.Data.XP / self:GetRequired(Player)) >= 1 do
					newLevel += 1
				end

				Profile.Data.Level = newLevel
			end

			self.Client.UpdateClient:Fire(Player, self:Get(Player), self:GetRequired(Player), Profile.Data.Level)
			self.UpdateXP:Fire(Player, self:Get(Player))
		end
	end
end

function ExperienceService:Give(Player, Amount)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then

		if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, 651665962) or RankService:GetRank(Player) >= 60 then
			Profile.Data.XP += (Amount * 2)
		else
			Profile.Data.XP += Amount
		end

		local Required = self:GetRequired(Player)

		if Profile.Data.XP >= Required then
			while (Profile.Data.XP / self:GetRequired(Player)) >= 1 do
				Profile.Data.Level += 1
			end
		end

		self.Client.UpdateClient:Fire(Player, self:Get(Player), self:GetRequired(Player), Profile.Data.Level)
		self.UpdateXP:Fire(Player, self:Get(Player))
	end
end

function ExperienceService:Remove(Player, Amount)
	repeat
		task.wait()
	until Player:GetAttribute("Loaded")

	local Profile = Knit.Profiles[Player]

	if Profile then
		Profile.Data.XP = -Amount

		local newLevel = 1

		while (Profile.Data.XP / self:GetRequired(Player)) >= 1 do
			newLevel += 1
		end

		Profile.Data.Level = newLevel

		if Profile.Data.XP < 0 then
			Profile.Data.XP = 0
			Profile.Data.Level = 1
		end

		self.Client.UpdateClient:Fire(Player, self:Get(Player), self:GetRequired(Player), Profile.Data.Level)
		self.UpdateXP:Fire(Player, self:Get(Player))
	end
end

-- ————————— 🂡 —————————
-- Client Functions

function ExperienceService.Client:GetXP(Player)
	return self.Server:Get(Player)
end

function ExperienceService.Client:GiveXP(Player, XP)
	self.Server:Give(Player, XP)
end

-- ————————— 🂡 —————————
-- Return Service to Knit.
return ExperienceService