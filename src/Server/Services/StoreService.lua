--[[

Author: alreadyfans
For: Gochi

]]

-- Services
local ReplicatedStorage: ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players: Players = game:GetService("Players")

-- Modules
local Knit: ModuleScript = require(ReplicatedStorage.Packages.Knit) --- @module Knit
local NametagList: ModuleScript = require(Knit.Data.NametagList) -- @module NametagList
local ParticleList: ModuleScript = require(Knit.Data.ParticleList) -- @module ParticleList
local CrateList: ModuleScript = require(Knit.Data.CrateList) -- @module CrateList

-- Create Service
local StoreService = Knit.CreateService {
    Name = "StoreService",
    Client = {},
}

-- Variables
local InventoryService, CurrencyService, NotificationService

-- Server Functions
function StoreService:KnitStart()
    InventoryService = Knit.GetService("InventoryService")
    CurrencyService = Knit.GetService("CurrencyService") 
    NotificationService = Knit.GetService("NotificationService")
end

function StoreService:_getCrateReward(Player: Player, Crate: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    local roll = math.random(1, 100)
    local cumulative = 0

    for _, item in ipairs(CrateList[Crate].Rewards) do
        cumulative += item.Chance

        if roll <= cumulative then
            return item
        end
    end
end

function StoreService:PurchaseCrate(Player: Player, Crate: string)
    repeat task.wait() until Player:GetAttribute("Loaded")

    if InventoryService:Get(Player) >= CrateList[Crate].Price then
        CurrencyService:Remove(Player, CrateList[Crate].Price)

        local reward = self:_getCrateReward(Player, Crate)

        if reward then
            if InventoryService:_search(Player, reward.Type, reward.Name) then
                NotificationService:_createNotif(Player, "You already have this item! You have been refunded " .. math.floor(CrateList[Crate].DuplicateRefund * CrateList[Crate].Price) .. " coins.")
                CurrencyService:Give(Player, math.floor(CrateList[Crate].DuplicateRefund * CrateList[Crate].Price))
            end
        else
            NotificationService:_createNotif(Player, "You have received a " .. reward.Name .. "!")
            InventoryService:_update(Player, reward.Type, reward.Name, true)
            return reward
        end
    else
        NotificationService:_createNotif(Player, "You do not have enough coins to purchase this crate!")
    end
end

-- Return Service to Knit
return StoreService
