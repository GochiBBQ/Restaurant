--[[

█▀▀▄ █▀▀█ █▀▀▄ █▀▀█ █░░█ █▀▀▄ ▀▀█▀▀ ▀▀█ █▀▀█ █▀▀ █░█ 
█░░█ █░░█ █░░█ █░░█ █░░█ █▀▀▄ ░░█░░ ▄▀░ █▄▄█ █░░ █▀▄ 
▀░░▀ ▀▀▀▀ ▀▀▀░ ▀▀▀▀ ░▀▀▀ ▀▀▀░ ░░▀░░ ▀▀▀ ▀░░▀ ▀▀▀ ▀░▀

Author: nodoubtzack
For: Sakura Kitchen 🥢
https://www.roblox.com/groups/6975354/Sakura-Kitchen#!/about

]]

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerService = game:GetService("Players")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local DailyRewardsList = require(ReplicatedStorage:WaitForChild("Data"):WaitForChild("DailyRewardsList"))
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local DailyRewardsService = Knit.CreateService {
	Name = "DailyRewardsService",
	Client = {
	},
}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function DailyRewardsService:CheckDate(lastLogin, currentLogin)
	return (currentLogin.year > lastLogin.year) or (currentLogin.month > lastLogin.month) or (currentLogin.day > lastLogin.day)
end

function DailyRewardsService:GetCurrentDay(Player: Player)
	repeat task.wait() until Knit.Profiles[Player]
	local data = Knit.Profiles[Player].Data

	local currentTime = os.time()
	local currentLoginFormatted = {
		year = tonumber(os.date('%Y', currentTime)),
		month = tonumber(os.date('%m', currentTime)),
		day = tonumber(os.date('%d', currentTime)),
	}

	self:UpdateDaily(Player, currentLoginFormatted)
	return (self:CheckDate(data.DailyRewards.LastLogin, currentLoginFormatted)), data.DailyRewards.Day, Player:GetAttribute("Booster")
end

function DailyRewardsService:UpdateDaily(Player: Player, currentLoginFormatted)
	local PetalsService = Knit.GetService("PetalsService")
	local data = Knit.Profiles[Player].Data

	if (not data.DailyRewards.LastLogin) or (self:CheckDate(data.DailyRewards.LastLogin, currentLoginFormatted)) then
		data.DailyRewards.Day = ((data.DailyRewards.Day or 0) % 7) + 1
		data.DailyRewards.LastLogin = currentLoginFormatted

		PetalsService:IncreasePetals(Player, Player:GetAttribute("Booster") and DailyRewardsList[data.DailyRewards.Day].Premium or DailyRewardsList[data.DailyRewards.Day].Regular)
	end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Client Functions
function DailyRewardsService.Client:GetDate(Player)
	return self.Server:GetCurrentDay(Player)
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return DailyRewardsService