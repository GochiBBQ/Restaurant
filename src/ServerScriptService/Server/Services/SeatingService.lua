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

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

local RateLimiter = require(Knit.Modules.RateLimiter)
local RequestRateLimiter = RateLimiter.NewRateLimiter(4)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Service
local SeatingService = Knit.CreateService {
    Name = "SeatingService",
	Client = {
        TemplateRemote = Knit:CreateSignal()
	},
}

--local TableManagement = workspace.Functionality:WaitForChild("Tables")
local NotificationService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Server Functions
function SeatingService:KnitStart()
    NotificationService = Knit.GetService("NotificationService")
end

function SeatingService:ClaimSeat(Server: Player, Customer: Player, TableNumber: number)
    if TableManagement:FindFirstChild(TableNumber) then
        local ReservedTable = TableManagement:FindFirstChild(TableNumber)
        
        if not ReservedTable:GetAttribute("Claimed") then

        else
            NotificationService.Send:Fire(Server, string.format("Table #%s has already been claimed. Try another table!", TableNumber))
        end
    else
        Server:Kick("🥩 Table #" ..TableNumber.. " does not exist. Do not attempt to exploit our systems.")
    end
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Service to Knit.
return SeatingService