--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Modules
local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(Knit.Util.Promise) -- @module Promise

-- Create Controller
local KitchenController = Knit.CreateController { Name = "KitchenController" }

-- Variables
local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")
local GochiUI = PlayerGui:WaitForChild("GochiUI")
local FridgeUI = GochiUI:WaitForChild("Fridge")

local KitchenService

-- Controller Functions
function KitchenController:KnitStart()
    KitchenService = Knit.GetService("KitchenService")

    KitchenService.Tasks:Connect(function(type, action, model, item)
        -- Handle fridges
        if type == "Fridge" then
            if action == "getIngredient" then
                return Promise.new(function(resolve, reject)
                    -- logic here
                    local success, result = pcall(function()
                        model:FindFirstChildOfClass("ProximityPrompt").Enabled = true
                        
                        return item -- Example: returning the item
                    end)

                    if success then
                        resolve(result)
                    else
                        reject("Failed to get ingredient")
                    end
                end)
            end
        -- Handle plates
        elseif type == "Plate" then
            if action == "getPlate" then
                return Promise.new(function(resolve, reject)
                    -- logic here
                    local success, result = pcall(function()
                        -- Perform the operation to get the plate
                        return item -- Example: returning the item
                    end)

                    if success then
                        resolve(result)
                    else
                        reject("Failed to get plate")
                    end
                end)
            end
        end
        
    end)
end

-- Return Controller to Knit
return KitchenController
