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

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local WhitelistService = Knit.CreateService {
    Name = "WhitelistService",
	Client = {
        NotWhitelisted = Knit.CreateSignal()
	},
}
local Whitelisted = {
    [54753551] = "nodoubtzack",
    [536046541] = "asurent",
    [117862085] = "sakunasrevenge",
    [637056208] = "asurent",
    [5874921] = "thinklwter",
    [133126945] = "mwssier",
    [1219780357] = "prevair",
    [35052055] = "avshleigh",
    [18646514] = "aesveIvet",
    [602110315] = "frompIace",
    [496829917] = "auzorn",
    [383896135] = "nodoubtjordan",
}

function WhitelistService:KnitStart()
    PlayerService.PlayerAdded:Connect(function(player)
        if Whitelisted[player.UserId] then
            return
        else
            self.Client.NotWhitelisted:Fire(player)
            task.delay(7, function()
                player:Kick("You must be whitelisted to join this experience.")
            end)
        end
    end)
end

return WhitelistService
