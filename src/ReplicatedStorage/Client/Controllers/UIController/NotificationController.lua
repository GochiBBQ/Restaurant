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
local StarterGui = game:GetService("StarterGui")

-- ————————— ↢ ⭐️ ↣ —————————
-- Variables
local Knit = require(ReplicatedStorage.Packages.Knit)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local NotificationController = Knit.CreateController {
    Name = "NotificationController",
}

local NotificationService

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function NotificationController:KnitStart()
    NotificationService = Knit.GetService("NotificationService")
    
    NotificationService.Send:Connect(function(v)
        StarterGui:SetCore("SendNotification", v)
    end)
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return NotificationController