--[[


                    __            __    __    _                __          
   ____  ____  ____/ /___  __  __/ /_  / /_  (_)___  _________/ /___ _____ 
  / __ \/ __ \/ __  / __ \/ / / / __ \/ __/ / / __ \/ ___/ __  / __ `/ __ \
 / / / / /_/ / /_/ / /_/ / /_/ / /_/ / /_  / / /_/ / /  / /_/ / /_/ / / / /
/_/ /_/\____/\__,_/\____/\__,_/_.___/\__/_/ /\____/_/   \__,_/\__,_/_/ /_/ 
                                       /___/                               


Author: nodoubtjordan
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
local spr = require(ReplicatedStorage.Modules.spr)

local Trove = require(ReplicatedStorage.Packages.Trove)
local trove = Trove.new()

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

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return MenuController