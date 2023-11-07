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
local Knit = require(ReplicatedStorage.Packages.Knit)

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Create Knit Service
local StaffRatingService = Knit.CreateService {
	Name = "StaffRatingService",
	Client = {
		Update = Knit.CreateSignal()	
	},
}

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Server Functions
function StaffRatingService:GetRating(Player: Player)
    if Knit.Profiles[Player] then
		local Profile = Knit.Profiles[Player]
        local TotalRating = 0

        for _, Ratings in pairs(Profile.Data.Ratings.Received) do
            if Ratings["Stars"] then
                TotalRating += Ratings["Stars"]
            end
        end

        return TotalRating / #Profile.Data.Ratings.Received
    else
        return 0
    end
end

function StaffRatingService:AddRating(Player: Player, Server: Player, Stars: number, Message: string)
    if not Message then return end
    if not Server then return end
    if not Stars then return end

    if Knit.Profiles[Player] and Knit.Profiles[Server] then
		local ServerProfile = Knit.Profiles[Server]
        local CustomerProfile = Knit.Profiles[Player]

		table.insert(ServerProfile.Data.Ratings.Received, {Stars = Stars, From = Player.UserId, Message = Message})
        table.insert(CustomerProfile.Data.Ratings.Given, {Stars = Stars, To = Server.UserId, Message = Message})
    else
        return false, "Server or player profile could not be found."
	end
	self:UpdateAmount(Player)
end

function StaffRatingService:RemoveRating(Player: Player, Server: Player)
    if not Server then return end

    if Knit.Profiles[Server] then
        local Profile = Knit.Profiles[Server]
        for i, Ratings in pairs(Profile.Data.Ratings.Received) do
            if Ratings["From"] == Player.UserId then
                table.remove(Profile.Data.Ratings.Received, i)
            end
        end
    else
        return false, "Player profile could not be found."
    end
end

-- ︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿︵‿︵︵‿︵‿
-- Return Service to Knit.
return StaffRatingService