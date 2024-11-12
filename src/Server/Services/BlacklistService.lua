--[[

Author: alreadyfans
For: Gochi

]]

-- ————————— 🂡 —————————
-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

-- ————————— 🂡 —————————
-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)

-- ————————— 🂡 —————————
-- Create Knit Service
local BlacklistService = Knit.CreateService {
    Name = "BlacklistService",
    Client = {},
}

-- ————————— 🂡 —————————
-- Variables

local url = "http://138.197.80.59:3001"
local key = `QJvdks3RUn6vklV1G2kQPsUsclZxvDzd`

-- ————————— 🂡 —————————
-- Server Functions
--[[
    Starts the BlacklistService.
    Connects to the PlayerAdded event to check if a player is blacklisted upon joining and kicks them if they are.
    Periodically fetches the list of blacklisted users and kicks any currently connected players who are blacklisted.

    @function KnitStart
    @within BlacklistService
]]
function BlacklistService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        local success, response = pcall(HttpService.RequestAsync, HttpService, {
            Url = ("%s/checkblacklist?id=%d"):format(url, Player.UserId),
            Method = "GET",
            Headers = {
                ["Content-Type"] = "application/json",
                ["Authorization"] = key,  
            },
        })


        response = HttpService:JSONDecode(response.Body)
        if not response.success then
            warn(("Error with %d: %s"):format(Player.UserId, response.msg))
        else
            if response.blacklisted then
                Player:Kick("You are blacklisted. Reason: " .. response.reason)
            end
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
    
            response = HttpService:JSONDecode(response.Body)
            if not response.success then
                warn(("Error fetching blacklists: %s"):format(response.msg))
            else
                if (response.msg == "No currently blacklisted users.") then return end
                for _, blacklist in pairs(HttpService:JSONDecode(response.data)) do
                    local player = Players:GetPlayerByUserId(blacklist.robloxId) 
                    if player then
                        player:Kick("You are blacklisted. Reason: " .. blacklist.blacklistReason)
                    end
                end
            end
            task.wait(60 * 5) 
        end
    end)
end


-- ————————— 🂡 —————————
 -- Return Service to Knit.
return BlacklistService
