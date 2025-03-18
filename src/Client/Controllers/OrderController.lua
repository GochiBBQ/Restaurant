--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService('ReplicatedStorage')
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit) -- @module Knit

-- Create Knit Controller
local OrderController = Knit.CreateController {
    Name = "OrderController",
}

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")

local OrderBoard = PlayerGui:WaitForChild("SurfaceUIs"):WaitForChild("OrderBoard") -- @type SurfaceGui

local OrderService

-- Client Functions
function OrderController:KnitStart()
    OrderService = Knit.GetService("OrderService") -- @module OrderService
end

function OrderController:KnitInit()
    
end

 -- Return Controller to Knit.
return OrderController
