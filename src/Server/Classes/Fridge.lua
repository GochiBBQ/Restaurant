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
local Knit = require(ReplicatedStorage.Packages.Knit) --@module Knit
local Promise = require(Knit.Util.Promise) -- @module Promise

-- Variables
local Fridges: Folder = workspace:WaitForChild("Functionality"):WaitForChild("Cooking"):WaitForChild("Fridges")

local KitchenService, NavigationService

Knit.OnStart():andThen(function()
    KitchenService = Knit.GetService("KitchenService")
    NavigationService = Knit.GetService("NavigationService")
end)

function Fridge.new()
    local self = setmetatable({}, Fridge)
    return self
end

function Fridge:_getRandom(): Model
    local Fridge = Fridges:GetChildren()
    local RandomFridge = Fridge[math.random(1, #Fridge)]
    return RandomFridge
end

function Fridge:_getIngredient(Player: Player, Item: string)
    return Promise.new(function(resolve, reject)
        local FridgeModel = self:_getRandom()

        local result = NavigationService:InitBeam(Player, FridgeModel)
        if not result then
            return reject("Failed to beam item")
        end

        local task = KitchenService:_assignTask(Player, "Fridge", "getIngredient", FridgeModel)
        if not task then
            return reject("Could not assign fridge task to player")
        end

        task.Ingredient = Item

        task.Complete:Wait()
        resolve(true)
    end)
end


return Fridge
