--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Trove = require(ReplicatedStorage.Packages.Trove) --- @module Trove

-- Create Knit Service
local BlacklistService = Knit.CreateService {
    Name = "BlacklistService",
    Client = {},
}

-- Variables
local url = "http://138.197.80.59:3001"
local key = `QJvdks3RUn6vklV1G2kQPsUsclZxvDzd`

-- Trove for managing player connections
local playerTroves = {}

-- Server Functions
function BlacklistService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        local trove = Trove.new()
        playerTroves[Player] = trove

        local success, response = pcall(HttpService.RequestAsync, HttpService, {
            Url = ("%s/checkblacklist?id=%d"):format(url, Player.UserId),
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = key,
            },
        })

        if success then
            response = HttpService:JSONDecode(response.Body)
            if not response.success then
                warn(("Error with %d: %s"):format(Player.UserId, response.msg))
            elseif response.blacklisted then
                Player:Kick("You are blacklisted. Reason: " .. response.reason)
            end
        else
            warn(("HTTP error checking blacklist for %d"):format(Player.UserId))
        end

        trove:Connect(Player.AncestryChanged, function(_, parent)
            if not parent then
                if playerTroves[Player] then
                    playerTroves[Player]:Destroy()
                    playerTroves[Player] = nil
                end
            end
        end)
    end)

    Players.PlayerRemoving:Connect(function(Player)
        if playerTroves[Player] then
            playerTroves[Player]:Destroy()
            playerTroves[Player] = nil
        end
    end)

    task.spawn(function()
        while true do
            local success, response = pcall(HttpService.RequestAsync, HttpService, {
                Url = ("%s/blacklists"):format(url),
                Method = "GET",
                Headers = {
                    ["Content-Type"] = "application/json",
                    ["Authorization"] = key,
                },
            })

            if success then
                response = HttpService:JSONDecode(response.Body)
                if not response.success then
                    warn(("Error fetching blacklists: %s"):format(response.msg))
                elseif response.msg ~= "No currently blacklisted users." then
                    for _, blacklist in pairs(HttpService:JSONDecode(response.data)) do
                        local player = Players:GetPlayerByUserId(blacklist.robloxId)
                        if player then
                            player:Kick("You are blacklisted. Reason: " .. blacklist.blacklistReason)
                        end
                    end
                end
            else
                warn("Failed to fetch blacklist data from server.")
            end

            task.wait(60 * 5) -- wait 5 minutes before next poll
        end
    end)
end

-- Return Service to Knit.
return BlacklistService
