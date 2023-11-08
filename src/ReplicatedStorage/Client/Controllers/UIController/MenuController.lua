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
local trove = Trove.new() -- USE TROVE TO DISCONNECT REMOTE CONNECTIONS (ONLY DISCONNECT IF ITS ONLY USED ONCE) (DONT USE ON PLAYERADDED N STUFF)

local LocalPlayer = PlayerService.LocalPlayer

local GochiUI = LocalPlayer.PlayerGui.GochiCore
local NavigationButtons = GochiUI.NavigationButtons

-- ————————— ↢ ⭐️ ↣ —————————
-- Create Knit Controller
local MenuController = Knit.CreateController {
    Name = "MenuController",
}

local UIController

-- ————————— ↢ ⭐️ ↣ —————————-
-- Client Functions
function MenuController:RegisterButtonClick(Button, Function)
    Button.MouseButton1Click:Connect(function()
        task.spawn(Function)
    end)
end

function MenuController:KnitInit()
    for Index, MenuButtons in pairs(NavigationButtons:GetDescendants()) do
        if MenuButtons:IsA("TextButton") then
            MenuButtons.MouseEnter:Connect(function()
                spr.target(MenuButtons.Parent, 0.75, 1, {Rotation = 45})
            end)
            
            MenuButtons.MouseLeave:Connect(function()
                spr.target(MenuButtons.Parent, 0.75, 1, {Rotation = 0})
            end)
        end
    end
end

function MenuController:KnitStart()
    UIController = Knit.GetController("UIControlelr")
    self.
end

-- ————————— ↢ ⭐️ ↣ —————————
-- Return Controller to Knit.
return MenuController