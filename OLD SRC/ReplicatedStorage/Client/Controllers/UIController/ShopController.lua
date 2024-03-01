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
local UIEffects = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("UIEffects"))
local spr = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("spr"))

local Knit = require(ReplicatedStorage.Packages.Knit)
local LocalPlayer = PlayerService.LocalPlayer

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local MenuController = Knit.CreateController {
    Name = "MenuController",
}

local UIController

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function MenuController:KnitStart()
    UIController = Knit.GetController("UIController")
end

function MenuController:NavigationButtons()
    
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return MenuController