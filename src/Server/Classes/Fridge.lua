--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Lua Class
local Fridge = {}
Fridge.__index = Fridge

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise)

-- Variables
local KitchenService

Knit.OnStart():andThen(function()
    KitchenService = Knit.GetService("KitchenService")
end)

function Fridge.new()
    local self = setmetatable({}, Fridge)
    return self
end

function Fridge:_getItem(Player: Player, Item: string)
    return Promise.new(function(resolve, reject)
        -- logic here
    end)
end

return Fridge
