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
local trove = Trove.new() -- USE TROVE TO DISCONNECT REMOTE CONNECTIONS (ONLY DISCONNECT IF ITS ONLY USED ONCE) (DONT USE ON PLAYERADDED N STUFF)

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local TemplateController = Knit.CreateController {
    Name = "TemplateController",
}

Knit.TemplateVariable = nil

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function TemplateController:KnitInit()
    
end

function TemplateController:KnitStart()

end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return TemplateController