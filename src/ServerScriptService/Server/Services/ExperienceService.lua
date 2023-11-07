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
local RunService = game:GetService("RunService")

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)
local SakuraAutomation = require(Knit.Modules.SakuraAutomation)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(2)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local ExperienceService = Knit.CreateService {
    Name = "ExperienceService",
	Client = {
        Update = Knit:CreateSignal()
	},
}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function ExperienceService:ChangeXP(Player: Player, Set: boolean, Amount: number)
    if Knit.Profiles[Player] then
        local Profile = Knit.Profiles[Player]
        if Profile.Data.XP == nil then Profile.Data.XP = 0 end
        if Set ~= nil and Set then
            Profile.Data.XP = Amount
        else
            Profile.Data.XP += Amount
        end

        if Set or (Amount ~= 0) then
            self.Client.Update:Fire(Player, Profile.Data.XP)
        end
        return true
    else
        return false, "Player's profile does not exist."
    end
end

function ExperienceService:GetXP(Player)
    if Knit.Profiles[Player] then
        local Profile = Knit.Profiles[Player]
        if Profile.Data.XP == nil then Profile.Data.XP = 0 end
        return Profile.Data.XP or 0
    else
        return 0, "Player's profile does not exist."
    end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Client Functions
function ExperienceService.Client:GetXP(Player)
    return self.Server:GetXP(Player)
end

function ExperienceService.Client:ChangeXP(Player, Set, Amount)
    return self.Server:ChangeXP(Player, Set, Amount)
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return ExperienceService